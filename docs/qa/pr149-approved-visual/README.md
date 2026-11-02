# PR #149 — approved visual reference and Hosted Preview QA

Owner approved the **visual direction** in the two reference boards, not the
finished UI. Text, charts, signs and four-pillar characters inside those AI
boards are illustrative only. The application uses its existing calculated
results and reading strings. Application code: `252e5fa2cae174aa4494487ed35a179e633e3b33`;
test follow-up: `4d9974980604f63aaaadc0851e0ef55a9e1db077`.

The screenshots below came from Hosting Preview version `0f8eeafff3e0857b`,
not the original board or a local asset interception. The two known-time
journeys used different synthetic birth inputs. Captures are 390×844 and
1280×800 CSS pixels; the 320-pixel overflow check was local.

| View | Approved direction | Hosted mobile | Hosted desktop |
| --- | --- | --- | --- |
| Four readers | [Mobile board](reference-mobile.png) / [PC board](reference-desktop.png) | — | — |
| Start | — | [390](mobile-landing.png) | [1280](desktop-landing.png) |
| Form | — | [390](mobile-form.png) | [1280](desktop-form.png) |
| Date picker | — | [390](mobile-date-picker.png) | [1280](desktop-date-picker.png) |
| Overall | — | [390](mobile-overall.png) | [1280](desktop-overall.png) |
| Overall detail open | — | [390](mobile-overall-expanded.png) | [1280](desktop-overall-expanded.png) |
| Thai | — | [390](mobile-thai.png) | [1280](desktop-thai.png) |
| Thai full reading | — | [390](mobile-thai-full.png) | [1280](desktop-thai-full.png) |
| Chinese | — | [390](mobile-chinese.png) | [1280](desktop-chinese.png) |
| Western | — | [390](mobile-western.png) | [1280](desktop-western.png) |
| Unknown birth time | — | [390](mobile-unknown.png) | [1280](desktop-unknown.png) |

Four WebP artwork assets were generated with the built-in image generation tool
using the approved themes: interlocking gold rings over a purple night sky,
an empty Thai jade-and-gold medallion, a red moon over Chinese ink mountains,
and a gold astrolabe in a navy night sky. They contain no words, zodiac labels,
chart positions or calculated values. The Thai ascendant label comes from the
Thai profile; the Chinese day master, four pillars and element counts come from
the BaZi chart; the Western Big 3 and element percentages come from the natal
chart. Overall cards still use the unchanged life-reading text and evidence
gate.

The expanded detailed Thai report retains its existing light inner cards
inside the new dark reader shell. Its text and section structure remain intact.
The reference board uses dark cards throughout; this difference remains for
Owner review. The decorative Thai medallion is not presented as a plotted
numeric chart, since no position labels were copied from the AI reference.

Network and layout checks from fresh Hosted Preview contexts are in the
[summary](hosted-qa-summary.json) and sanitized traces for
[mobile known time](network-hosted-a-390.json),
[desktop known time](network-hosted-b-1280.json),
[mobile unknown time](network-hosted-unknown-390.json), and
[desktop unknown time](network-hosted-unknown-1280.json). The
[hosted hashes](hosted-hashes.json) and
[Hosting before](hosting-before.json) / [after](hosting-after.json) summaries
are included. Trace files contain URL, method and status, but no request
payload or reading text. No actual personal data was used. Owner UI acceptance
remains pending; PR #149 remains Draft.
