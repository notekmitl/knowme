import argparse
import hashlib
import json
import re
from pathlib import Path

from pypdf import PdfReader


FIXTURES = (
    "known",
    "unknown",
    "owner-known-0035",
    "owner-unknown",
    "regression-known-0003",
    "comparison-known-bangkok",
    "comparison-known-khon-kaen",
)


def pdf_text(path: Path) -> str:
    return "\n".join(page.extract_text() or "" for page in PdfReader(str(path)).pages)


def semantic_text_identity(path: Path) -> str:
    # PDF extractors insert line breaks at different wrapping points. Whitespace is
    # layout, so the identity intentionally preserves every non-whitespace code point.
    normalized = re.sub(r"\s+", "", pdf_text(path))
    return hashlib.sha256(normalized.encode("utf-8")).hexdigest().upper()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--live-root", type=Path, required=True)
    parser.add_argument("--approved-root", type=Path, required=True)
    parser.add_argument("--environment", required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()

    qa_path = args.live_root / f"{args.environment}-browser-qa.json"
    qa = {item["fixtureId"]: item for item in json.loads(qa_path.read_text(encoding="utf-8"))}
    results = []
    total_pages = 0
    for fixture in FIXTURES:
        live_browser = args.live_root / f"{args.environment}-browser-print-{fixture}.pdf"
        live_dedicated = args.live_root / f"{args.environment}-dedicated-{fixture}.pdf"
        approved_browser = args.approved_root / f"browser-print-{fixture}.pdf"
        approved_dedicated = args.approved_root / f"dedicated-report-{fixture}.pdf"
        identity = json.loads(
            (args.approved_root / f"{fixture}-identity.json").read_text(encoding="utf-8")
        )
        fixture_qa = qa[fixture]
        browser_pages = len(PdfReader(str(live_browser)).pages)
        dedicated_pages = len(PdfReader(str(live_dedicated)).pages)
        total_pages += browser_pages + dedicated_pages
        screen_ids = [section["id"] for section in fixture_qa["screenState"]["sections"]]
        print_ids = [section["id"] for section in fixture_qa["printState"]["sections"]]
        approved_section_count = identity["sectionCount"]
        browser_live_identity = semantic_text_identity(live_browser)
        browser_approved_identity = semantic_text_identity(approved_browser)
        dedicated_live_identity = semantic_text_identity(live_dedicated)
        dedicated_approved_identity = semantic_text_identity(approved_dedicated)
        checks = {
            "browserPages7": browser_pages == 7,
            "dedicatedPages8": dedicated_pages == 8,
            "screenPrintSectionInventoryExact": screen_ids == print_ids,
            "approvedSectionCoverage100": len(print_ids) == approved_section_count,
            "browserReaderVisibleTextExact": browser_live_identity == browser_approved_identity,
            "dedicatedReaderVisibleTextExact": dedicated_live_identity == dedicated_approved_identity,
            "printRootPresent": fixture_qa["printState"]["printRootExists"],
            "dialogCountZero": fixture_qa["screenState"]["dialogCount"] == 0,
            "printBodyPositionStatic": fixture_qa["printState"]["bodyStyle"]["position"] == "static",
            "printHtmlHasContentHeight": fixture_qa["printState"]["htmlStyle"]["height"] != "0px",
            "consoleErrorsZero": len(fixture_qa["consoleErrors"]) == 0,
            "pageErrorsZero": len(fixture_qa["pageErrors"]) == 0,
            "requestFailuresZero": len(fixture_qa["requestFailures"]) == 0,
        }
        results.append(
            {
                "fixtureId": fixture,
                "browserPrint": {
                    "path": live_browser.as_posix(),
                    "bytes": live_browser.stat().st_size,
                    "pages": browser_pages,
                    "semanticTextSha256": browser_live_identity,
                    "approvedSemanticTextSha256": browser_approved_identity,
                },
                "dedicated": {
                    "path": live_dedicated.as_posix(),
                    "bytes": live_dedicated.stat().st_size,
                    "pages": dedicated_pages,
                    "semanticTextSha256": dedicated_live_identity,
                    "approvedSemanticTextSha256": dedicated_approved_identity,
                },
                "semanticSections": {
                    "actual": len(print_ids),
                    "approved": approved_section_count,
                    "coveragePercent": 100 if len(print_ids) == approved_section_count else 0,
                    "ids": print_ids,
                },
                "checks": checks,
                "passed": all(checks.values()),
            }
        )

    summary = {
        "environment": args.environment,
        "fixtureCount": len(results),
        "browserPdfCount": len(results),
        "browserPageCount": sum(item["browserPrint"]["pages"] for item in results),
        "dedicatedPdfCount": len(results),
        "dedicatedPageCount": sum(item["dedicated"]["pages"] for item in results),
        "totalPdfCount": len(results) * 2,
        "totalPageCount": total_pages,
        "semanticCoveragePercent": 100 if all(item["passed"] for item in results) else 0,
        "results": results,
    }
    summary["passed"] = (
        summary["browserPageCount"] == 49
        and summary["dedicatedPageCount"] == 56
        and summary["totalPageCount"] == 105
        and all(item["passed"] for item in results)
    )
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(summary, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(
        f"fixtures={summary['fixtureCount']}|browser={summary['browserPdfCount']}/"
        f"{summary['browserPageCount']}|dedicated={summary['dedicatedPdfCount']}/"
        f"{summary['dedicatedPageCount']}|total={summary['totalPdfCount']}/"
        f"{summary['totalPageCount']}|semantic={summary['semanticCoveragePercent']}|"
        f"passed={str(summary['passed']).lower()}"
    )
    if not summary["passed"]:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
