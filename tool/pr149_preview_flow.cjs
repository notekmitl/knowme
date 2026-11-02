const fs = require('fs');
const path = require('path');
const { chromium } = require('playwright');

const out = path.resolve('.preview-qa');
fs.mkdirSync(out, { recursive: true });
const url = 'https://knowme-app-694e1--pr-149-overall-safe-vbx6de6a.web.app/beta/thai';

(async () => {
  const browser = await chromium.launch({ executablePath: 'C:/Program Files/Google/Chrome/Application/chrome.exe', headless: true });
  try {
    const context = await browser.newContext({ viewport: { width: 1280, height: 800 }, timezoneId: 'Asia/Bangkok', serviceWorkers: 'block' });
    const page = await context.newPage();
    const requests = [];
    const errors = [];
    page.on('request', r => requests.push({ method: r.method(), url: r.url(), at: Date.now() }));
    page.on('pageerror', e => errors.push(String(e)));
    await page.goto(url, { waitUntil: 'domcontentloaded' });
    await page.waitForTimeout(5500);
    await page.mouse.click(640, 768);
    await page.waitForTimeout(500);
    const semantics = page.locator('flt-semantics-placeholder');
    if (await semantics.count()) {
      await semantics.focus();
      await page.keyboard.press('Enter');
      await page.waitForTimeout(300);
    }
    await page.locator('input[aria-label="ชื่อจริง *"]').click();
    await page.keyboard.type('Preview', { delay: 60 });
    await page.waitForTimeout(150);
    await page.locator('input[aria-label="นามสกุล *"]').click();
    await page.keyboard.type('Fixture', { delay: 60 });
    await page.waitForTimeout(150);
    await page.getByText('เลือกวันเกิด', { exact: true }).click({ force: true });
    await page.waitForTimeout(200);
    await page.mouse.click(622, 399);
    await page.mouse.click(849, 546);
    await page.waitForTimeout(200);
    const hour = page.locator('input[aria-label="ชั่วโมง"]');
    await hour.click();
    await page.keyboard.type('12', { delay: 80 });
    await page.waitForTimeout(200);
    await page.keyboard.press('ArrowDown');
    await page.keyboard.press('Enter');
    const minute = page.locator('input[aria-label="นาที"]');
    await minute.click();
    await page.keyboard.press('Control+A');
    await page.keyboard.type('34', { delay: 80 });
    await page.waitForTimeout(200);
    await page.keyboard.press('ArrowDown');
    await page.keyboard.press('Enter');
    const province = page.locator('input[aria-label="จังหวัดที่เกิด (ถ้าทราบ)"]');
    await province.click();
    await page.keyboard.type('กรุงเทพมหานคร', { delay: 70 });
    await page.waitForTimeout(650);
    await page.screenshot({ path: path.join(out, 'province-suggestion.png') });
    await page.getByText('กรุงเทพมหานคร', { exact: true }).last().click({ force: true });
    await page.waitForTimeout(200);
    await page.screenshot({ path: path.join(out, 'form-complete.png') });
    await page.getByText('เริ่มวิเคราะห์', { exact: true }).last().click({ force: true });
    await page.waitForTimeout(750);
    await page.screenshot({ path: path.join(out, 'form-review.png') });
    const selectorText = await page.locator('body').innerText();
    if (!selectorText.includes('อยากดูดวงแบบไหน?') || !selectorText.includes('ดูดวงรวม')) {
      throw Error('Overall selector did not appear');
    }
    const started = Date.now();
    await page.getByText('ดูดวงรวม', { exact: true }).last().click({ force: true });
    await page.getByText('อ่านภาพรวมจากสามศาสตร์', { exact: true }).waitFor({ timeout: 90000 });
    const elapsedMs = Date.now() - started;
    await page.waitForTimeout(350);
    await page.screenshot({ path: path.join(out, 'overall-report.png') });
    const reportText = await page.locator('body').innerText();
    const apiRequests = requests.filter(r => r.url.includes('run.app'));
    const unwanted = requests.filter(r => /identitytoolkit|securetoken|firestore\.googleapis\.com|knowme-astrology-api-avbyttircq-as/.test(r.url));
    const actualPaths = apiRequests.filter(r => r.method === 'POST').map(r => new URL(r.url).pathname);
    const unexpectedMutations = requests.filter(r =>
      !['GET', 'HEAD', 'OPTIONS'].includes(r.method) &&
      !(r.method === 'POST' && r.url.startsWith('https://knowme-overall-pr149-preview-avbyttircq-as.a.run.app/') &&
        ['/v1/calculate-bazi', '/v1/calculate-chart'].includes(new URL(r.url).pathname)));
    const result = {
      previewUrl: url,
      elapsedMs,
      reportVisible: reportText.includes('อ่านภาพรวมจากสามศาสตร์'),
      hasAgreement: reportText.includes('ตรงกันทั้ง 3 ศาสตร์') || reportText.includes('สอดคล้องกัน 2 ศาสตร์'),
      actualPaths,
      apiRequests,
      unwanted,
      unexpectedMutations,
      errors,
      reportExcerpt: reportText.slice(0, 1000),
    };
    fs.writeFileSync(path.join(out, 'validation.json'), JSON.stringify(result, null, 2) + '\n');
    console.log(JSON.stringify(result, null, 2));
    if (unwanted.length || unexpectedMutations.length || errors.length ||
        actualPaths.join(',') !== '/v1/calculate-bazi,/v1/calculate-chart') {
      throw Error('Preview network gate failed');
    }
  } finally {
    await browser.close();
  }
})().catch(e => { console.error(e); process.exitCode = 1; });
