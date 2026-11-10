from pathlib import Path
import json,time
from playwright.sync_api import sync_playwright
out=Path('.preview-qa/dashboard-cache-canary');out.mkdir(exist_ok=True)
signal=Path('.preview-qa/dashboard-deployed-r3.signal')
assert not signal.exists(), 'Use a fresh deployment signal'
with sync_playwright() as p:
 browser=p.chromium.launch(channel='chrome',headless=True)
 context=browser.new_context(viewport={'width':390,'height':844},timezone_id='Asia/Bangkok')
 page=context.new_page();requests=[];errors=[]
 page.on('request',lambda r:requests.append({'method':r.method,'url':r.url}))
 page.on('pageerror',lambda e:errors.append(str(e)))
 page.goto('https://knowme-trial-694e1.web.app/beta/thai',wait_until='domcontentloaded');page.wait_for_timeout(3500)
 page.locator('flt-semantics-placeholder').focus();page.keyboard.press('Enter');page.wait_for_timeout(500)
 page.screenshot(path=str(out/'before-r2.png'))
 before=list(requests)
 assert any('main.dart.js?v=trial-plain-th-20261110-r2' in r['url'] for r in before)
 (out/'ready.json').write_text(json.dumps({'before_requests':before},indent=2),encoding='utf-8')
 print('READY: existing r2 browser context retained; waiting for verified trial deploy',flush=True)
 deadline=time.monotonic()+1200
 while not signal.exists():
  if time.monotonic()>deadline:raise TimeoutError('No verified r3 deployment signal')
  page.wait_for_timeout(5000)
 cut=len(requests);page.reload(wait_until='domcontentloaded');page.wait_for_timeout(4000)
 placeholder=page.locator('flt-semantics-placeholder')
 if placeholder.count():placeholder.focus();page.keyboard.press('Enter');page.wait_for_timeout(500)
 page.screenshot(path=str(out/'after-r3.png'))
 after=requests[cut:];assert any('main.dart.js?v=trial_plain_th_20261110_r3' in r['url'] for r in after)
 assert 'เริ่มดูดวงรวม' in page.locator('body').inner_text()
 forbidden=[r for r in requests if any(v in r['url'] for v in ['identitytoolkit','securetoken','firestore','firebase-auth','firebase-firestore','knowme-astrology-api','accounts.google.com/gsi'])]
 writes=[r for r in requests if r['method'] not in ['GET','OPTIONS']]
 assert not forbidden and not writes and not errors
 controlled=page.evaluate('!!navigator.serviceWorker.controller');assert not controlled
 result={'before_requests':before,'reload_requests':after,'errors':errors,'forbidden':forbidden,'writes':writes,'service_worker_controlled':controlled,'storage_clear_calls':0,'existing_r2_context_reloaded_to_r3':True}
 (out/'result.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8');print('PASS: cached r2 context upgraded to r3 without clearing storage or calculator calls',flush=True)
 browser.close()
