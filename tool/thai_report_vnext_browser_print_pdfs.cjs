const fs = require('fs');
const path = require('path');
const { pathToFileURL } = require('url');
const { chromium } = require('playwright');

const fixtureIds = [
  'known',
  'unknown',
  'owner-known-0035',
  'owner-unknown',
  'regression-known-0003',
  'comparison-known-bangkok',
  'comparison-known-khon-kaen',
];

async function main() {
  const [artifactRoot, executablePath] = process.argv.slice(2);
  if (!artifactRoot || !executablePath) {
    throw new Error(
      'usage: node thai_report_vnext_browser_print_pdfs.cjs <artifact-root> <chrome.exe>',
    );
  }
  const root = path.resolve(artifactRoot);
  const browser = await chromium.launch({ executablePath, headless: true });
  try {
    for (const fixtureId of fixtureIds) {
      const html = path.join(root, `browser-print-${fixtureId}.html`);
      const pdf = path.join(root, `browser-print-${fixtureId}.pdf`);
      if (!fs.existsSync(html)) throw new Error(`missing HTML: ${html}`);
      const page = await browser.newPage();
      await page.goto(pathToFileURL(html).href, { waitUntil: 'load' });
      await page.emulateMedia({ media: 'print' });
      await page.evaluate(async () => {
        if (document.fonts && document.fonts.ready) await document.fonts.ready;
      });
      await page.pdf({
        path: pdf,
        format: 'A4',
        printBackground: true,
        preferCSSPageSize: true,
        displayHeaderFooter: false,
      });
      const stat = fs.statSync(pdf);
      process.stdout.write(`fixture=${fixtureId}|bytes=${stat.size}|pdf=${pdf}\n`);
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
