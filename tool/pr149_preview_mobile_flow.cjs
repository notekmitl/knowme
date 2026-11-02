const fs = require('fs');
const path = require('path');
const { chromium } = require('playwright');

const output = path.resolve('.preview-qa/mobile-390x844');
fs.mkdirSync(output, { recursive: true });
const previewUrl = 'https://knowme-app-694e1--pr-149-overall-safe-vbx6de6a.web.app/beta/thai';
const backendOrigin = 'https://knowme-overall-pr149-preview-avbyttircq-as.a.run.app';

async function typeInto(page, label, value, { selectAll = false } = {}) {
  const field = page.locator(`input[aria-label="${label}"]`);
  await field.click();
  if (selectAll) await page.keyboard.press('Control+A');
  await page.keyboard.type(value, { delay: 65 });
  await page.waitForTimeout(150);
}

(async () => {
  const browser = await chromium.launch({
    executablePath: 'C:/Program Files/Google/Chrome/Application/chrome.exe',
    headless: true,
  });
  try {
    const context = await browser.newContext({
      viewport: { width: 390, height: 844 },
      deviceScaleFactor: 1,
      isMobile: true,
      hasTouch: true,
      timezoneId: 'Asia/Bangkok',
      serviceWorkers: 'block',
    });
    const page = await context.newPage();
    const requests = [];
    const responses = [];
    const pageErrors = [];
    const consoleErrors = [];
    page.on('request', request => requests.push({ method: request.method(), url: request.url() }));
    page.on('response', response => {
      if (response.url().startsWith(backendOrigin)) {
        responses.push({ status: response.status(), url: response.url() });
      }
    });
    page.on('pageerror', error => pageErrors.push(String(error)));
    page.on('console', message => {
      if (message.type() === 'error') consoleErrors.push(message.text());
    });

    const navigation = await page.goto(previewUrl, { waitUntil: 'domcontentloaded' });
    await page.waitForTimeout(5000);
    const semantics = page.locator('flt-semantics-placeholder');
    if (await semantics.count()) {
      await semantics.focus();
      await page.keyboard.press('Enter');
      await page.waitForTimeout(200);
    }
    await page.screenshot({ path: path.join(output, 'landing.png') });
    await page.getByText('เริ่มการวิเคราะห์', { exact: true }).last().click({ force: true });
    await page.waitForTimeout(350);
    await page.screenshot({ path: path.join(output, 'form.png') });

    await typeInto(page, 'ชื่อจริง *', 'Preview');
    await typeInto(page, 'นามสกุล *', 'Fixture');
    await page.getByText('เลือกวันเกิด', { exact: true }).click({ force: true });
    await page.waitForTimeout(220);
    await page.mouse.click(99, 477); // 15 January 2001 in the default picker.
    await page.getByText('ตกลง', { exact: true }).last().click({ force: true });
    await page.waitForTimeout(180);
    await typeInto(page, 'ชั่วโมง', '12');
    await page.keyboard.press('ArrowDown');
    await page.keyboard.press('Enter');
    // Keep the form's valid default minute 00; mobile autocomplete differs
    // from a desktop keyboard when replacing an existing dropdown value.
    await typeInto(page, 'จังหวัดที่เกิด (ถ้าทราบ)', 'กรุงเทพมหานคร');
    await page.waitForTimeout(400);
    await page.getByText('กรุงเทพมหานคร', { exact: true }).last().click({ force: true });
    await page.screenshot({ path: path.join(output, 'form-complete.png') });
    await page.getByText('เริ่มวิเคราะห์', { exact: true }).last().click({ force: true });
    await page.waitForTimeout(700);
    await page.screenshot({ path: path.join(output, 'after-submit.png') });
    const selectorText = await page.locator('body').innerText();
    if (!selectorText.includes('อยากดูดวงแบบไหน?') ||
        !selectorText.includes('15/1/2001 · 12:00 · กรุงเทพมหานคร')) {
      throw Error('Mobile birth form did not reach the expected selector');
    }
    await page.getByText('ดูดวงรวม', { exact: true }).last().scrollIntoViewIfNeeded();
    await page.screenshot({ path: path.join(output, 'selector.png') });

    const started = Date.now();
    await page.getByText('ดูดวงรวม', { exact: true }).last().click({ force: true });
    await page.getByText('อ่านภาพรวมจากสามศาสตร์', { exact: true }).waitFor({ timeout: 90000 });
    const elapsedMs = Date.now() - started;
    await page.waitForTimeout(350);
    await page.screenshot({ path: path.join(output, 'report-top.png') });
    const reportText = await page.locator('body').innerText();
    await page.getByText('ผลนี้ไม่ระบุช่วงอายุ', { exact: false }).last().scrollIntoViewIfNeeded();
    await page.screenshot({ path: path.join(output, 'report-bottom.png') });

    const expectedPaths = ['/v1/calculate-bazi', '/v1/calculate-chart'];
    const apiPosts = requests.filter(r => r.method === 'POST' && r.url.startsWith(backendOrigin));
    const actualPaths = apiPosts.map(r => new URL(r.url).pathname);
    const forbidden = requests.filter(r => /identitytoolkit|securetoken|firestore\.googleapis\.com|knowme-astrology-api-avbyttircq-as/.test(r.url));
    const unexpectedMutation = requests.filter(r =>
      !['GET', 'HEAD', 'OPTIONS'].includes(r.method) &&
      !(r.method === 'POST' && r.url.startsWith(backendOrigin) &&
        expectedPaths.includes(new URL(r.url).pathname)));
    const metrics = await page.evaluate(() => ({
      viewportWidth: window.innerWidth,
      documentScrollWidth: document.documentElement.scrollWidth,
      bodyScrollWidth: document.body.scrollWidth,
    }));
    const result = {
      previewUrl,
      viewport: '390x844',
      navigationStatus: navigation.status(),
      elapsedMs,
      selectorText: selectorText.slice(0, 600),
      reportText: reportText.slice(0, 1500),
      hasThreeTraditions: reportText.includes('ตรงกันทั้ง 3 ศาสตร์'),
      hasTwoTraditions: reportText.includes('สอดคล้องกัน 2 ศาสตร์'),
      actualPaths,
      responses,
      forbidden,
      unexpectedMutation,
      pageErrors,
      consoleErrors,
      metrics,
    };
    fs.writeFileSync(path.join(output, 'network.json'),
      `${JSON.stringify({ requests, responses }, null, 2)}\n`);
    fs.writeFileSync(path.join(output, 'validation.json'), `${JSON.stringify(result, null, 2)}\n`);
    console.log(JSON.stringify(result, null, 2));
    if (navigation.status() !== 200 ||
        actualPaths.join(',') !== expectedPaths.join(',') ||
        responses.length !== 2 || responses.some(r => r.status !== 200) ||
        forbidden.length || unexpectedMutation.length || pageErrors.length ||
        consoleErrors.length || !result.hasThreeTraditions || !result.hasTwoTraditions ||
        metrics.documentScrollWidth > metrics.viewportWidth ||
        metrics.bodyScrollWidth > metrics.viewportWidth) {
      throw Error('Mobile Preview QA gate failed');
    }
  } finally {
    await browser.close();
  }
})().catch(error => { console.error(error); process.exitCode = 1; });
