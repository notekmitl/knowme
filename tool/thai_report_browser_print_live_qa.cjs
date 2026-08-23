const fs = require('fs');
const path = require('path');
const { chromium } = require('playwright');

const fixtures = {
  known: {
    firstName: 'Fixture', lastName: 'A', date: '4/4/1982', hour: 10,
    minute: 30, province: 'กรุงเทพมหานคร', unknown: false,
  },
  unknown: {
    firstName: 'Fixture', lastName: 'B', date: '15/6/1981', hour: 0,
    minute: 0, province: 'กรุงเทพมหานคร', unknown: true,
  },
  'owner-known-0035': {
    firstName: 'Acceptance', lastName: 'Fixture', date: '6/6/1982', hour: 0,
    minute: 35, province: 'เชียงใหม่', unknown: false,
  },
  'owner-unknown': {
    firstName: 'Acceptance', lastName: 'Fixture', date: '6/6/1982', hour: 0,
    minute: 0, province: 'เชียงใหม่', unknown: true,
  },
  'regression-known-0003': {
    firstName: 'Acceptance', lastName: 'Fixture', date: '6/6/1982', hour: 0,
    minute: 3, province: 'เชียงใหม่', unknown: false,
  },
  'comparison-known-bangkok': {
    firstName: 'Comparison', lastName: 'Fixture', date: '18/11/1991', hour: 14,
    minute: 20, province: 'กรุงเทพมหานคร', unknown: false,
  },
  'comparison-known-khon-kaen': {
    firstName: 'Comparison', lastName: 'Fixture', date: '27/2/1974', hour: 6,
    minute: 45, province: 'ขอนแก่น', unknown: false,
  },
};

async function screenshot(page, outputRoot, environment, fixtureId, state) {
  const output = path.join(
    outputRoot,
    `${environment}-browser-flow-${fixtureId}-${state}.png`,
  );
  await page.screenshot({ path: output, fullPage: false });
  return output;
}

async function setDate(page, date) {
  await page.mouse.click(640, 358);
  await page.waitForTimeout(250);
  await page.mouse.click(420, 508);
  await page.waitForTimeout(200);
  await page.mouse.click(700, 333);
  await page.keyboard.press('Control+A');
  await page.keyboard.type(date, { delay: 35 });
  await page.mouse.click(851, 414);
  await page.waitForTimeout(300);
}

async function selectNumericDropdown(page, x, y, value) {
  await page.mouse.click(x, y);
  await page.waitForTimeout(150);
  await page.keyboard.press('Control+A');
  await page.keyboard.type(String(value).padStart(2, '0'), { delay: 45 });
  await page.waitForTimeout(150);
  await page.keyboard.press('ArrowDown');
  await page.keyboard.press('Enter');
  await page.waitForTimeout(150);
}

async function fillFixture(page, fixture, outputRoot, environment, fixtureId) {
  await page.mouse.click(640, 688);
  await page.waitForTimeout(500);
  await page.mouse.click(640, 228);
  await page.keyboard.type(fixture.firstName, { delay: 20 });
  await page.mouse.click(640, 292);
  await page.keyboard.type(fixture.lastName, { delay: 20 });
  await setDate(page, fixture.date);
  if (fixture.unknown) {
    await page.mouse.click(400, 501);
  } else {
    await selectNumericDropdown(page, 505, 448, fixture.hour);
    await selectNumericDropdown(page, 775, 448, fixture.minute);
  }
  await page.mouse.click(640, 561);
  await page.keyboard.type(fixture.province, { delay: 35 });
  await page.waitForTimeout(250);
  await page.mouse.click(510, 611);
  await screenshot(page, outputRoot, environment, fixtureId, 'form-filled');
  await page.mouse.click(640, fixture.unknown ? 674 : 695, { delay: 120 });
  await page.waitForTimeout(1200);
  await screenshot(page, outputRoot, environment, fixtureId, 'review');
  const semanticsPlaceholder = page.locator('flt-semantics-placeholder');
  if (await semanticsPlaceholder.count()) {
    await semanticsPlaceholder.focus();
    await page.keyboard.press('Enter');
    await page.waitForTimeout(300);
  }
  const analyzeButton = page.getByText('เริ่มวิเคราะห์', { exact: true });
  if (await analyzeButton.count()) {
    await analyzeButton.last().click({ force: true });
    await page.waitForTimeout(1200);
  }
  const confirmButton = page.getByText('ยืนยันข้อมูลและดูผล', { exact: true });
  if (await confirmButton.count()) {
    await confirmButton.last().click({ force: true });
  } else {
    await page.mouse.click(640, 690, { delay: 180 });
  }
  await page.waitForTimeout(5000);
}

async function scrollToBottom(page) {
  await page.mouse.move(1170, 650);
  for (let index = 0; index < 24; index += 1) {
    await page.mouse.wheel(0, 620);
    await page.waitForTimeout(80);
  }
}

async function collectPrintState(page) {
  return page.evaluate(() => {
    const root = document.getElementById('knowme-print-root');
    const rootStyle = root == null ? null : getComputedStyle(root);
    const bodyStyle = getComputedStyle(document.body);
    const htmlStyle = getComputedStyle(document.documentElement);
    return {
      url: location.href,
      viewport: { width: innerWidth, height: innerHeight, dpr: devicePixelRatio },
      activeElement: {
        tag: document.activeElement?.tagName ?? null,
        id: document.activeElement?.id ?? null,
        ariaLabel: document.activeElement?.getAttribute?.('aria-label') ?? null,
      },
      dialogCount: document.querySelectorAll('[role="dialog"]').length,
      printRootExists: root != null,
      printRootTextLength: root?.innerText.length ?? 0,
      printRootHtmlLength: root?.innerHTML.length ?? 0,
      printRootRect: root?.getBoundingClientRect().toJSON() ?? null,
      printRootStyle: rootStyle == null ? null : {
        display: rootStyle.display,
        position: rootStyle.position,
        height: rootStyle.height,
        overflow: rootStyle.overflow,
      },
      bodyStyle: {
        position: bodyStyle.position,
        height: bodyStyle.height,
        overflow: bodyStyle.overflow,
        scrollHeight: document.body.scrollHeight,
      },
      htmlStyle: {
        position: htmlStyle.position,
        height: htmlStyle.height,
        overflow: htmlStyle.overflow,
        scrollHeight: document.documentElement.scrollHeight,
      },
      sections: [...document.querySelectorAll('#knowme-print-root [data-section-id]')]
        .map((section) => ({
          id: section.getAttribute('data-section-id'),
          textLength: (section.textContent ?? '').length,
          rect: section.getBoundingClientRect().toJSON(),
        })),
      infographicCount: document.querySelectorAll(
        '#knowme-print-root .infographic-page img',
      ).length,
    };
  });
}

async function runFixture(browser, baseUrl, outputRoot, executableLabel, fixtureId) {
  const fixture = fixtures[fixtureId];
  if (fixture == null) throw new Error(`unknown fixture: ${fixtureId}`);
  const page = await browser.newPage({ viewport: { width: 1280, height: 720 } });
  const consoleErrors = [];
  const pageErrors = [];
  const requestFailures = [];
  page.on('console', (message) => {
    if (message.type() === 'error') consoleErrors.push(message.text());
  });
  page.on('pageerror', (error) => pageErrors.push(String(error)));
  page.on('requestfailed', (request) => {
    requestFailures.push({ url: request.url(), error: request.failure()?.errorText });
  });
  const result = { fixtureId, executableLabel, baseUrl };
  try {
    await page.goto(`${baseUrl}/beta/thai`, {
      waitUntil: 'load',
      timeout: 60000,
    });
    await page.waitForTimeout(5000);
    await screenshot(page, outputRoot, executableLabel, fixtureId, 'landing');
    await fillFixture(page, fixture, outputRoot, executableLabel, fixtureId);
    await screenshot(page, outputRoot, executableLabel, fixtureId, 'report-top');
    await scrollToBottom(page);
    await screenshot(page, outputRoot, executableLabel, fixtureId, 'report-bottom');
    await page.mouse.click(640, 553);
    await page.waitForTimeout(1800);
    await screenshot(page, outputRoot, executableLabel, fixtureId, 'capture-export');

    const dedicatedDownloadPromise = page.waitForEvent('download');
    await page.mouse.click(640, 81);
    const dedicatedDownload = await dedicatedDownloadPromise;
    const dedicatedPath = path.join(
      outputRoot,
      `${executableLabel}-dedicated-${fixtureId}.pdf`,
    );
    await dedicatedDownload.saveAs(dedicatedPath);

    await page.mouse.click(640, 128);
    await page.waitForTimeout(1200);
    await screenshot(page, outputRoot, executableLabel, fixtureId, 'print-page-before-print');
    result.screenState = await collectPrintState(page);

    await page.evaluate(() => {
      window.__knowmePrintEvents = [];
      window.__knowmeBeforePrint = () => window.__knowmePrintEvents.push({
        type: 'beforeprint', at: new Date().toISOString(),
      });
      window.__knowmeAfterPrint = () => window.__knowmePrintEvents.push({
        type: 'afterprint', at: new Date().toISOString(),
      });
      addEventListener('beforeprint', window.__knowmeBeforePrint);
      addEventListener('afterprint', window.__knowmeAfterPrint);
    });
    await page.mouse.click(1230, 28);
    await page.waitForTimeout(300);
    result.userPrintEvents = await page.evaluate(() => window.__knowmePrintEvents);

    await page.emulateMedia({ media: 'print' });
    result.printState = await collectPrintState(page);
    const browserPrintPath = path.join(
      outputRoot,
      `${executableLabel}-browser-print-${fixtureId}.pdf`,
    );
    await page.pdf({
      path: browserPrintPath,
      format: 'A4',
      printBackground: true,
      preferCSSPageSize: true,
      displayHeaderFooter: false,
    });
    result.cdpPrintEvents = await page.evaluate(() => window.__knowmePrintEvents);
    await page.emulateMedia({ media: 'screen' });
    await page.evaluate(() => {
      removeEventListener('beforeprint', window.__knowmeBeforePrint);
      removeEventListener('afterprint', window.__knowmeAfterPrint);
      delete window.__knowmeBeforePrint;
      delete window.__knowmeAfterPrint;
    });
    result.dedicatedPdf = {
      path: dedicatedPath,
      bytes: fs.statSync(dedicatedPath).size,
    };
    result.browserPrintPdf = {
      path: browserPrintPath,
      bytes: fs.statSync(browserPrintPath).size,
    };
    result.consoleErrors = consoleErrors;
    result.pageErrors = pageErrors;
    result.requestFailures = requestFailures;
    return result;
  } catch (error) {
    result.failure = String(error?.stack ?? error);
    result.failureUrl = page.url();
    result.consoleErrors = consoleErrors;
    result.pageErrors = pageErrors;
    result.requestFailures = requestFailures;
    try {
      await screenshot(page, outputRoot, executableLabel, fixtureId, 'failure');
    } catch (_) {}
    fs.writeFileSync(
      path.join(outputRoot, `${executableLabel}-browser-qa-failure.json`),
      `${JSON.stringify(result, null, 2)}\n`,
      'utf8',
    );
    throw error;
  } finally {
    await page.close();
  }
}

async function main() {
  const [baseUrl, outputRootArg, executablePath, environment, fixtureList] =
    process.argv.slice(2);
  if (!baseUrl || !outputRootArg || !executablePath || !environment) {
    throw new Error(
      'usage: node thai_report_browser_print_live_qa.cjs ' +
      '<base-url> <output-root> <chrome.exe> <environment> [fixture,...]',
    );
  }
  const outputRoot = path.resolve(outputRootArg);
  fs.mkdirSync(outputRoot, { recursive: true });
  const requested = fixtureList == null || fixtureList.length === 0
    ? Object.keys(fixtures)
    : fixtureList.split(',');
  const browser = await chromium.launch({ executablePath, headless: true });
  const results = [];
  try {
    for (const fixtureId of requested) {
      const result = await runFixture(
        browser,
        baseUrl.replace(/\/$/, ''),
        outputRoot,
        environment,
        fixtureId,
      );
      results.push(result);
      process.stdout.write(
        `fixture=${fixtureId}|root=${result.printState.printRootExists}|` +
        `sections=${result.printState.sections.length}|` +
        `bodyPosition=${result.printState.bodyStyle.position}|` +
        `htmlHeight=${result.printState.htmlStyle.height}|` +
        `consoleErrors=${result.consoleErrors.length}\n`,
      );
    }
  } finally {
    await browser.close();
  }
  const resultPath = path.join(outputRoot, `${environment}-browser-qa.json`);
  fs.writeFileSync(resultPath, `${JSON.stringify(results, null, 2)}\n`, 'utf8');
  process.stdout.write(`result=${resultPath}\n`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
