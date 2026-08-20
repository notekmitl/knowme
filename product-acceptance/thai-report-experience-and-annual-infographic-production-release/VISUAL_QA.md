# Preview Visual QA

Manual review was performed from unique source-bound renders and downloaded
Preview artifacts.

## Dedicated PDFs

- 5 PDFs / 40 pages reviewed.
- Blank pages: 0.
- Page clipping/overlap/missing-section findings: 0.
- Page 2 contains the complete 1080×1920 annual infographic in every fixture.
- Remaining narrative, timeline, transparency, provenance, and limitation pages
  are readable and present.

## Browser-print PDFs

- 5 PDFs / 5 emitted pages reviewed.
- All five are incomplete: the single page contains introductory text and only
  part of the annual infographic.
- All narrative sections after the infographic are absent.
- Result: 0/5; mandatory Preview gate blocked.

## Infographics

- 5 canonical Preview downloads and 1 mobile Preview download reviewed.
- Dimensions: 1080×1920 in 6/6.
- Title `ดวงชะตาปี 2569`: visible and unclipped in 6/6.
- Four category rows and their icons: present.
- Opportunity/caution cards: present.
- Unknown disclosure is present on the Unknown artifact.
- Monthly Timeline, month names, fake monthly graph, and unsupported monthly
  opportunity/caution claims: absent.
- Mobile download is byte-identical to desktop Owner Known.

The fresh deterministic pre-deploy 15-fixture geometry/title gate remains 15/15,
including stress and year-boundary cases. It does not override the live
browser-print failure.

