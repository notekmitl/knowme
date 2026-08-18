const fs = require('fs');
const path = require('path');
const { chromium } = require('playwright');

async function captureViewport(page, outputPath) {
  await page.screenshot({ path: outputPath, fullPage: false });
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
      { mode: 'known', width: 1024, height: 900, steps: 0 },
      { mode: 'known', width: 768, height: 900, steps: 0 },
      { mode: 'known', width: 390, height: 844, steps: 12 },
      { mode: 'unknown', width: 360, height: 844, steps: 12 },
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
      await captureViewport(page, path.join(outputRoot, `${stem}-top.png`));
      for (let step = 1; step <= item.steps; step += 1) {
        await page.mouse.move(item.width / 2, item.height / 2);
        await page.mouse.wheel(0, 700);
        await page.waitForTimeout(250);
        await captureViewport(
          page,
          path.join(outputRoot, `${stem}-scroll-${String(step).padStart(2, '0')}.png`),
        );
      }
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
