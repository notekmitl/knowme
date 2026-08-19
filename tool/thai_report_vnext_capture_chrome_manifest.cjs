const fs = require('fs');
const { chromium } = require('playwright');

async function main() {
  const [url, outputPath, executablePath] = process.argv.slice(2);
  if (!url || !outputPath || !executablePath) {
    throw new Error('usage: node capture.cjs <url> <output> <chrome.exe>');
  }

  const browser = await chromium.launch({
    executablePath,
    headless: true,
  });
  try {
    const page = await browser.newPage();
    await page.goto(url, { waitUntil: 'networkidle' });
    await page.waitForSelector('body[data-status="complete"]', {
      timeout: 120000,
    });
    const manifest = await page.locator('#manifest').textContent();
    if (!manifest) {
      throw new Error('Chrome page completed without manifest content');
    }
    fs.writeFileSync(outputPath, manifest, { encoding: 'utf8' });
    process.stdout.write(`captured ${Buffer.byteLength(manifest, 'utf8')} bytes\n`);
  } finally {
    await browser.close();
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
