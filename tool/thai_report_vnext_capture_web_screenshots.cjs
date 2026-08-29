const fs = require('fs');
const path = require('path');
const { chromium } = require('playwright');
const crypto = require('crypto');

async function captureViewport(page, outputPath) {
  await page.screenshot({ path: outputPath, fullPage: false });
}

async function captureAt(page, outputRoot, stem, position) {
  const outputPath = path.join(outputRoot, `${stem}-${position}.png`);
  await captureViewport(page, outputPath);
  return outputPath;
}

function sha256(filePath) {
  return crypto.createHash('sha256').update(fs.readFileSync(filePath)).digest('hex');
}

async function capturePosition(page, outputRoot, stem, position, fraction) {
  await page.waitForFunction(() =>
    typeof window.__setThaiBetaCaptureScrollFraction === 'function' &&
    window.__thaiBetaCaptureScrollMetrics,
  );
  const before = await page.evaluate((value) => {
    window.__setThaiBetaCaptureScrollFraction(value);
    return window.__thaiBetaCaptureScrollMetrics;
  }, fraction);
  await page.waitForTimeout(300);
  const actual = await page.evaluate(() => window.__thaiBetaCaptureScrollMetrics);
  const outputPath = await captureAt(page, outputRoot, stem, position);
  const tolerancePx = Math.max(2, actual.maxScroll * 0.005);
  const requestedScrollTop = actual.maxScroll * fraction;
  return {
    mode: stem.split('-')[0],
    viewport: null,
    filename: path.basename(outputPath),
    scroll_container_identity: actual.identity,
    requested_position: position,
    requested_scroll_top: requestedScrollTop,
    actual_scroll_top: actual.scrollTop,
    scroll_height: actual.scrollHeight,
    client_height: actual.clientHeight,
    max_scroll: actual.maxScroll,
    actual_percentage_of_max_scroll: actual.maxScroll === 0 ? 0 : actual.scrollTop / actual.maxScroll,
    tolerance_px: tolerancePx,
    pass: Math.abs(actual.scrollTop - requestedScrollTop) <= tolerancePx,
    sha256: sha256(outputPath),
    bridge_before_capture: before,
  };
}

async function main() {
  const [baseUrl, outputRoot, executablePath] = process.argv.slice(2);
  if (!baseUrl || !outputRoot || !executablePath) {
    throw new Error('usage: node capture.cjs <base-url> <output-root> <chrome.exe>');
  }
  fs.mkdirSync(outputRoot, { recursive: true });

  const browser = await chromium.launch({ executablePath, headless: true });
  try {
    const cases = [
      { mode: 'known', width: 1440, height: 900 },
      { mode: 'unknown', width: 1440, height: 900 },
      { mode: 'known', width: 360, height: 844 },
      { mode: 'known', width: 390, height: 844 },
      { mode: 'unknown', width: 360, height: 844 },
      { mode: 'unknown', width: 390, height: 844 },
    ];
    for (const item of cases) {
      const page = await browser.newPage({
        viewport: { width: item.width, height: item.height },
        deviceScaleFactor: 1,
      });
      const url = `${baseUrl}${item.mode === 'unknown' ? '?mode=unknown' : ''}`;
      await page.goto(url, { waitUntil: 'networkidle' });
      await page.waitForTimeout(3500);
      const stem = `${item.mode}-${item.width}`;
      const captures = [];
      for (const [position, fraction] of [['top', 0], ['middle', 0.5], ['bottom', 1]]) {
        const capture = await capturePosition(page, outputRoot, stem, position, fraction);
        capture.viewport = { width: item.width, height: item.height };
        captures.push(capture);
      }
      const hashes = captures.map((capture) => capture.sha256);
      if (captures.some((capture) => !capture.pass)) {
        throw new Error(`capture geometry outside tolerance for ${stem}`);
      }
      if (captures[0].max_scroll > 0 && new Set(hashes).size !== captures.length) {
        throw new Error(`capture positions did not move for ${stem}`);
      }
      fs.writeFileSync(
        path.join(outputRoot, `${stem}-scroll-metadata.json`),
        `${JSON.stringify({
          mode: item.mode,
          viewport: { width: item.width, height: item.height },
          scroll_container_identity: captures[0].scroll_container_identity,
          captures,
          distinct_capture_count: new Set(hashes).size,
        }, null, 2)}\n`,
      );
      process.stdout.write(
        `captured mode=${item.mode} width=${item.width} height=${item.height} ` +
          'positions=top,50%-middle,max-bottom geometry=verified\n',
      );
      await page.close();
    }
  } finally {
    await browser.close();
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
