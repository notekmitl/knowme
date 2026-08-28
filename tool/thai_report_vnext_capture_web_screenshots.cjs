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

async function scrollFlutterSurface(page, width, height, steps) {
  await page.mouse.move(width / 2, height / 2);
  for (let step = 0; step < steps; step += 1) {
    await page.mouse.wheel(0, 700);
    await page.waitForTimeout(220);
  }
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
      captures.push(await captureAt(page, outputRoot, stem, 'top'));
      await scrollFlutterSurface(page, item.width, item.height, 6);
      captures.push(await captureAt(page, outputRoot, stem, 'middle'));
      await scrollFlutterSurface(page, item.width, item.height, 10);
      captures.push(await captureAt(page, outputRoot, stem, 'bottom'));
      const hashes = captures.map(sha256);
      if (new Set(hashes).size !== captures.length) {
        throw new Error(`capture positions did not move for ${stem}`);
      }
      fs.writeFileSync(
        path.join(outputRoot, `${stem}-scroll-metadata.json`),
        `${JSON.stringify({
          mode: item.mode,
          viewport: { width: item.width, height: item.height },
          positions: ['top', '6-wheel-middle', '16-wheel-bottom'],
          sha256: hashes,
          distinct_capture_count: new Set(hashes).size,
        }, null, 2)}\n`,
      );
      process.stdout.write(
        `captured mode=${item.mode} width=${item.width} height=${item.height} ` +
          'positions=top,6-wheel-middle,16-wheel-bottom\n',
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
