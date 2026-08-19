const fs = require('fs');
const path = require('path');
const { chromium } = require('playwright');

async function captureViewport(page, outputPath) {
  await page.screenshot({ path: outputPath, fullPage: false });
}

async function captureAt(page, outputRoot, stem, position) {
  const outputPath = path.join(outputRoot, `${stem}-${position}.png`);
  await captureViewport(page, outputPath);
  return outputPath;
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
      await captureAt(page, outputRoot, stem, 'top');
      await scrollFlutterSurface(page, item.width, item.height, 6);
      await captureAt(page, outputRoot, stem, 'middle');
      await scrollFlutterSurface(page, item.width, item.height, 10);
      await captureAt(page, outputRoot, stem, 'bottom');
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
