import argparse
import json
from pathlib import Path

from PIL import Image, ImageStat
from playwright.sync_api import sync_playwright

ORIGIN = 'https://knowme-trial-694e1.web.app'
parser = argparse.ArgumentParser()
parser.add_argument('--width', type=int, choices=(390, 1280, 1920), required=True)
parser.add_argument('--cpu', action='store_true')
parser.add_argument('--out', type=Path, required=True)
args = parser.parse_args()
height = {390: 844, 1280: 800, 1920: 911}[args.width]
box = {
    390: (20, 210, 370, 460),
    1280: (50, 150, 618, 700),
    1920: (370, 205, 938, 755),
}[args.width]
args.out.mkdir(parents=True, exist_ok=True)
label = f'{args.width}-{"cpu" if args.cpu else "chrome"}'

with sync_playwright() as playwright:
    browser = playwright.chromium.launch(
        channel='chrome', headless=True,
        args=['--disable-gpu', '--disable-webgl'] if args.cpu else [],
    )
    context = browser.new_context(viewport={'width': args.width, 'height': height},
                                  device_scale_factor=1, timezone_id='Asia/Bangkok')
    page = context.new_page()
    requests, responses, errors, failures = [], [], [], []
    page.on('request', lambda r: requests.append({'method': r.method, 'url': r.url}))
    page.on('response', lambda r: responses.append({'url': r.url, 'status': r.status})
            if '/assets/assets/trial_visual/' in r.url else None)
    page.on('pageerror', lambda error: errors.append(str(error)))
    page.on('console', lambda message: errors.append(message.text)
            if message.type == 'error' else None)
    page.on('requestfailed', lambda request: failures.append(request.url))
    checks = []
    for step in ('initial', 'reload'):
        if step == 'initial':
            page.goto(ORIGIN + '/beta/thai', wait_until='domcontentloaded', timeout=30000)
        else:
            page.reload(wait_until='domcontentloaded', timeout=30000)
        page.wait_for_timeout(3500)
        page.locator('flt-semantics-placeholder').focus()
        page.keyboard.press('Enter')
        picture = args.out / f'{step}-{label}.png'
        page.screenshot(path=str(picture))
        with Image.open(picture) as rendered:
            paint = round(max(ImageStat.Stat(rendered.convert('RGB').crop(box)).stddev), 2)
        cta = page.get_by_role('button', name='เริ่มดูดวงรวม')
        check = {
            'step': step,
            'url': page.url,
            'cta_count': cta.count(),
            'art_rgb_stddev_max': paint,
            'document_width': page.evaluate('document.documentElement.scrollWidth'),
        }
        checks.append(check)
    forbidden = [r for r in requests if any(term in r['url'].lower() for term in (
        'accounts.google.com/gsi', 'firebase-auth', 'firebase-firestore',
        'identitytoolkit.googleapis.com', 'securetoken.googleapis.com',
        'firestore.googleapis.com', 'knowme-astrology-api',
    ))]
    writes = [r for r in requests if r['method'] not in ('GET', 'OPTIONS')]
    summary = {
        'viewport': [args.width, height], 'cpu_fallback': args.cpu,
        'checks': checks, 'art_responses': responses,
        'forbidden_count': len(forbidden), 'write_count': len(writes),
        'error_count': len(errors), 'failed_count': len(failures),
        'service_worker_controlled': bool(page.evaluate('navigator.serviceWorker?.controller')),
    }
    (args.out / f'reload-{label}.json').write_text(
        json.dumps(summary, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print(json.dumps(summary, ensure_ascii=False))
    assert all(check['cta_count'] == 1 and check['art_rgb_stddev_max'] > 10
               and check['document_width'] == args.width for check in checks)
    assert responses and all(response['status'] == 200 for response in responses)
    assert not forbidden and not writes and not errors and not failures
    context.close()
    browser.close()
