import argparse
import json
from pathlib import Path
from urllib.parse import urlsplit

from PIL import Image, ImageStat
from playwright.sync_api import sync_playwright


ORIGIN = 'https://knowme-app-694e1--pr-149-overall-safe-c41ic92g.web.app'
API = 'https://knowme-overall-pr149-preview-avbyttircq-as.a.run.app'


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--build', type=Path)
    parser.add_argument('--hosted', action='store_true')
    parser.add_argument('--width', type=int, choices=[320, 390, 1280], required=True)
    parser.add_argument('--case', choices=['a', 'b', 'unknown'], required=True)
    parser.add_argument('--mode', choices=['chrome', 'cpu', 'cpu_png'], required=True)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--expect-landing-art', choices=['painted', 'blank'], default='painted')
    args = parser.parse_args()
    out = args.out.resolve()
    out.mkdir(parents=True, exist_ok=True)
    height = {320: 740, 390: 844, 1280: 800}[args.width]
    if not args.hosted and args.build is None:
        parser.error('--build is required unless --hosted is set')
    build = args.build.resolve() if args.build else None
    label = f'{"hosted-" if args.hosted else ""}{args.case}-{args.width}-{args.mode}'

    def local_asset(route):
        path = urlsplit(route.request.url).path.lstrip('/')
        if not path or path.startswith('beta/'):
            path = 'index.html'
        file = build / path
        if file.is_file() and file.resolve().is_relative_to(build):
            route.fulfill(path=str(file))
        else:
            route.abort()

    with sync_playwright() as playwright:
        browser = playwright.chromium.launch(
            channel='chrome', headless=True,
            args=['--disable-gpu', '--disable-webgl'] if args.mode != 'chrome' else [],
        )
        context = browser.new_context(
            viewport={'width': args.width, 'height': height},
            device_scale_factor=1,
            timezone_id='Asia/Bangkok',
            service_workers='block',
        )
        page = context.new_page()
        if args.mode == 'cpu_png':
            from io import BytesIO

            source_dir = Path(__file__).resolve().parents[3] / 'assets/trial_visual'

            def png_art(route):
                name = Path(urlsplit(route.request.url).path).name
                with Image.open(source_dir / name) as source:
                    buffer = BytesIO()
                    source.save(buffer, format='PNG')
                route.fulfill(status=200, content_type='image/png', body=buffer.getvalue())

            page.route('**/assets/assets/trial_visual/*.webp', png_art)
        if not args.hosted:
            page.route(ORIGIN + '/**', local_asset)
        requests, responses, errors, failures, widths = [], [], [], [], {}
        artwork_responses, warnings = [], []
        page.on('request', lambda r: requests.append({'method': r.method, 'url': r.url}))
        page.on('response', lambda r: responses.append({'method': r.request.method, 'url': r.url, 'status': r.status}) if r.request.method == 'POST' else None)
        page.on('response', lambda r: artwork_responses.append({
            'url': r.url, 'status': r.status,
            'content_type': r.headers.get('content-type'),
            'from_service_worker': r.from_service_worker,
        }) if '/trial_visual/' in r.url else None)
        page.on('pageerror', lambda e: errors.append(str(e)))
        page.on('console', lambda m: errors.append(m.text) if m.type == 'error' else None)
        page.on('console', lambda m: warnings.append(m.text) if m.type == 'warning' else None)
        page.on('requestfailed', lambda r: failures.append({'method': r.method, 'url': r.url, 'failure': r.failure}))

        def capture(name):
            page.screenshot(path=str(out / f'{name}-{label}.png'))
            widths[name] = page.evaluate('document.documentElement.scrollWidth')

        def art_score(name, box):
            with Image.open(out / f'{name}-{label}.png') as rendered:
                return round(max(ImageStat.Stat(rendered.convert('RGB').crop(box)).stddev), 2)

        art_boxes = (
            {'overall': (20, 175, 370, 275), 'thai': (40, 92, 350, 249),
             'chinese': (40, 98, 55, 230), 'western': (40, 125, 80, 210)}
            if args.width == 390 else
            {'overall': (150, 230, 630, 470), 'thai': (160, 140, 1120, 295),
             'chinese': (145, 150, 160, 350), 'western': (1100, 200, 1140, 300)}
            if args.width == 1280 else
            {'overall': (20, 175, 300, 275), 'thai': (40, 92, 280, 249),
             'chinese': (40, 98, 55, 230), 'western': (40, 125, 80, 210)}
        )
        art_paint = {}

        page.goto(ORIGIN + '/beta/thai', wait_until='domcontentloaded', timeout=30000)
        page.wait_for_timeout(3500)
        page.locator('flt-semantics-placeholder').focus()
        page.keyboard.press('Enter')
        capture('landing')
        landing = out / f'landing-{label}.png'
        box = (20, 210, 370, 460) if args.width == 390 else (
            (140, 184, 723, 594) if args.width == 1280 else (20, 210, 300, 460)
        )
        with Image.open(landing) as rendered:
            painted_stddev = max(ImageStat.Stat(rendered.convert('RGB').crop(box)).stddev)
        if args.expect_landing_art == 'painted':
            assert painted_stddev > 10, f'landing artwork did not paint: {painted_stddev}'
        else:
            assert painted_stddev < 2, f'expected blank diagnostic control: {painted_stddev}'
        artwork_diagnostics = page.evaluate('''async () => {
          const asset = '/assets/assets/trial_visual/overall.webp';
          const img = new Image();
          img.src = asset;
          let decode = 'ok';
          try { await img.decode(); } catch (e) { decode = String(e); }
          const canvas = document.createElement('canvas');
          return {
            decode, natural_width: img.naturalWidth,
            natural_height: img.naturalHeight,
            webgl_available: !!canvas.getContext('webgl'),
            asset_entries: performance.getEntriesByType('resource')
              .filter(e => e.name.includes('/trial_visual/'))
              .map(e => ({name:e.name, duration:e.duration, transferSize:e.transferSize,
                          decodedBodySize:e.decodedBodySize})),
          };
        }''')
        page.get_by_text('เริ่มดูดวงรวม').click()
        page.wait_for_timeout(350)
        capture('form')

        for field, value in [('ชื่อจริง *', 'QA'), ('นามสกุล *', 'Fixture')]:
            page.get_by_role('textbox', name=field).click()
            page.wait_for_timeout(350)
            page.keyboard.type(value)
            page.wait_for_timeout(350)

        page.get_by_role('button', name='เลือกวันเกิด').click()
        page.wait_for_timeout(200)
        capture('date-picker')
        day = 2 if args.case == 'b' else 1
        day_label = (
            '2, วันอังคารที่ 2 มกราคม ค.ศ. 2001'
            if day == 2 else '1, วันจันทร์ที่ 1 มกราคม ค.ศ. 2001'
        )
        page.get_by_role('button', name=day_label).click()
        page.get_by_role('button', name='ตกลง').click()
        page.wait_for_timeout(350)

        if args.case == 'unknown':
            page.get_by_role('checkbox').click()
            page.wait_for_timeout(300)
        else:
            hour = '06' if args.case == 'b' else '12'
            page.get_by_role('textbox', name='ชั่วโมง').click()
            page.wait_for_timeout(350)
            page.keyboard.type(hour)
            page.keyboard.press('ArrowDown')
            page.keyboard.press('Enter')
            page.wait_for_timeout(350)

        province = 'เชียงใหม่' if args.case == 'b' else 'กรุงเทพมหานคร'
        page.get_by_role('textbox', name='จังหวัดที่เกิด (ถ้าทราบ)').click()
        page.wait_for_timeout(350)
        page.keyboard.type(province)
        page.wait_for_timeout(600)
        page.get_by_role('button', name=province, exact=True).click()
        page.wait_for_timeout(350)
        capture('form-ready')
        page.get_by_role('button', name='ดูดวงรวม').click()

        if args.case == 'unknown':
            page.wait_for_timeout(1000)
            capture('unknown-result')
        else:
            try:
                page.get_by_text('อ่านรายละเอียด', exact=True).first.wait_for(timeout=30000)
            except Exception:
                capture('debug-after-submit')
                print('DEBUG', responses, errors, failures,
                      page.get_by_role('button').all_text_contents()[:20],
                      page.locator('body').inner_text()[:900], flush=True)
                raise
            page.wait_for_timeout(600)
            capture('overall')
            art_paint['overall'] = art_score('overall', art_boxes['overall'])
            assert art_paint['overall'] > 5, 'Overall art did not paint'
            for _ in range(5):
                if page.get_by_text('อ่านรายละเอียด', exact=True).count():
                    break
                page.mouse.wheel(0, 400)
                page.wait_for_timeout(250)
            detail = page.get_by_text('อ่านรายละเอียด', exact=True).first
            detail.click()
            page.wait_for_timeout(450)
            capture('overall-expanded')
            detail.click()
            page.wait_for_timeout(450)
            capture('overall-recollapsed')
            for tab, screen in [('ไทย', 'thai'), ('จีน', 'chinese'), ('ตะวันตก', 'western')]:
                page.get_by_role('button', name=tab, exact=True).click()
                page.wait_for_timeout(550)
                capture(screen)
                immediate_score = art_score(screen, art_boxes[screen])
                page.wait_for_timeout(2200)
                capture(screen + '-settled')
                settled_score = art_score(screen + '-settled', art_boxes[screen])
                art_paint[screen] = {'immediate': immediate_score, 'settled': settled_score}
                assert settled_score > 5, f'{screen} art remained blank: {art_paint[screen]}'
                page.mouse.move(args.width // 2, height // 2)
                page.mouse.wheel(0, 620)
                page.wait_for_timeout(400)
                capture(screen + '-reading')
                if screen == 'thai':
                    page.get_by_text('อ่านรายงานไทยฉบับเต็ม').click()
                    page.wait_for_timeout(450)
                    capture('thai-full-reading')
                    page.mouse.wheel(0, 560)
                    page.wait_for_timeout(350)
                    capture('thai-full-deep')
                    annual = page.get_by_text('ภาพสรุป 12 เดือนข้างหน้า')
                    for _ in range(40):
                        if annual.count():
                            break
                        page.mouse.wheel(0, 600)
                        page.wait_for_timeout(80)
                    if annual.count():
                        annual.scroll_into_view_if_needed()
                        page.wait_for_timeout(350)
                        capture('thai-annual')
                    else:
                        capture('thai-annual-search')
                if screen == 'chinese':
                    page.get_by_text('ดูสัดส่วนธาตุที่คำนวณได้').click()
                    page.wait_for_timeout(350)
                    capture('chinese-elements')
                page.get_by_role('button', name='ดวงรวม', exact=True).click()
                page.wait_for_timeout(450)
            for tab in ('ไทย', 'จีน', 'ตะวันตก', 'ดวงรวม'):
                page.get_by_role('button', name=tab, exact=True).click()
                page.wait_for_timeout(400)
            capture('overall-returned')

        posts = [r for r in requests if r['method'] == 'POST']
        forbidden = [r for r in requests if any(x in r['url'].lower() for x in (
            'accounts.google.com/gsi', 'firebase-auth', 'firebase-firestore',
            'identitytoolkit.googleapis.com', 'securetoken.googleapis.com',
            'firestore.googleapis.com', 'knowme-astrology-api',
        ))]
        other_writes = [r for r in requests if r['method'] not in ('GET', 'OPTIONS')
                        and not (r['method'] == 'POST' and r['url'].startswith(API + '/v1/calculate-'))]
        result = {
            'viewport': [args.width, height],
            'case': args.case,
            'local_build': str(build) if build else None,
            'local_assets_under_allowed_origin': not args.hosted,
            'requests': requests,
            'post_responses': responses,
            'posts': posts,
            'forbidden': forbidden,
            'other_writes': other_writes,
            'errors': errors,
            'failed_requests': failures,
            'document_widths': widths,
            'artwork_responses': artwork_responses,
            'artwork_diagnostics': artwork_diagnostics,
            'landing_art_rgb_stddev_max': round(painted_stddev, 2),
            'reader_art_rgb_stddev_max': art_paint,
            'warnings': warnings,
            'final_text': page.locator('body').inner_text()[:1200],
        }
        (out / f'network-{label}.json').write_text(
            json.dumps(result, ensure_ascii=False, indent=2), encoding='utf-8')
        print(label, 'POST', len(posts), responses, 'forbidden', len(forbidden),
              'other writes', len(other_writes), 'errors', len(errors),
              'failed', len(failures), 'widths', widths,
              'artwork', artwork_responses, artwork_diagnostics, flush=True)
        assert len(posts) == (0 if args.case == 'unknown' else 2)
        assert all(r['status'] == 200 for r in responses)
        assert not forbidden and not other_writes and not errors and not failures
        assert all(value == args.width for value in widths.values())
        context.close()
        browser.close()


if __name__ == '__main__':
    main()
