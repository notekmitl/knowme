# Local production-equivalent browser QA

- Source HEAD: `7a2bdea4d88ebd3e87ee7268641a37a70a7a959f`
- Build manifest SHA-256: `E0C5E976076F7165DD6CA4913A7227585E2579AAA8F123302A6895877A3767F5`
- Route: `http://127.0.0.1:4175/beta/thai`
- Firebase-equivalent SPA rewrite: `/beta/thai` served `build/web/index.html`, HTTP 200
- Desktop viewport: 1280 × 720; document width 1280; no console warnings or errors
- Mobile viewport: 390 × 844; document width 390; horizontal overflow false; no console warnings or errors
- Accessibility semantics: Thai research heading, research/privacy explanation, participant count, and analysis-start control exposed
- Analysis flow: the start control opened the four-step input flow; required name, birth date, time/unknown-time, birthplace, gender, and analyze controls were exposed
- Desktop visual check: fields, progress indicator, and primary action were legible and not clipped
- Mobile visual check: fields and primary action fit the 390-pixel viewport; no horizontal clipping or overlap was observed
- Screenshots: `local-browser-desktop.png`, `local-browser-mobile-390x844.png`
- Result: `PASS`
