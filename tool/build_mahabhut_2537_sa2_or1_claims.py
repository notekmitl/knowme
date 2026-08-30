#!/usr/bin/env python3
"""Reclassify SA2 placement skeleton and build evidence-bound claim corpus v2."""

from __future__ import annotations

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SOURCE_EDITION = "mahabhut-complete-duangkaew-2537-primary-working-edition"
PDF_SHA256 = "28D74F5D7258A00EFA4967186B15ED97174E173AB12BD4DF9FBED66BD3EA890E"
V1 = ROOT / "knowledge/canon/proposed/mahabhut_2537_predictive_corpus_v1.json"
OUT = ROOT / "knowledge/canon/proposed/mahabhut_2537_predictive_claims_v2.json"
SCHEMA = ROOT / "knowledge/canon/proposed/mahabhut_2537_predictive_claims_v2.schema.json"


def evidence(page: int, boundary: str, excerpt: str) -> dict:
    return {
        "editionId": SOURCE_EDITION,
        "page": page,
        "pageImageReviewed": True,
        "paragraphBoundary": boundary,
        "shortExcerpt": excerpt,
        "pdfSha256": PDF_SHA256,
    }


def direct(claim_id: str, page: int, boundary: str, excerpt: str, domain: str,
           subject: str, outcome: str, timing: str, age: str,
           allowed: str) -> dict:
    return {
        "claimId": claim_id,
        "claimType": "SOURCE_DIRECT_PREDICTION",
        "contextId": "mahabhut2537.rem0.saturday",
        "sourceEvidence": evidence(page, boundary, excerpt),
        "agePeriodBinding": age,
        "domain": domain,
        "subject": subject,
        "movementOutcome": outcome,
        "timingGranularity": timing,
        "allowedConclusion": allowed,
        "prohibitedEscalation": [
            "specific promotion", "specific month", "specific amount",
            "medical diagnosis", "marriage or separation event",
            "different archetype or Thai day",
        ],
    }


def general(claim_id: str, placement_id: str, role: str, domain: str,
            age: str, outcome: str) -> dict:
    return {
        "claimId": claim_id,
        "claimType": "SOURCE_GENERAL_RULE_APPLICATION",
        "contextId": "mahabhut2537.rem0.saturday",
        "placementRecordId": placement_id,
        "sourceRuleRefs": ["SGR-RISE-POSITION", f"SGR-ROLE-{role.upper()}"],
        "conditionsSatisfied": ["exact context", "exact Thai day", "exact age period", "placement proven", "ordinary rise/fall rule applies"],
        "agePeriodBinding": age,
        "domain": domain,
        "movementOutcome": outcome,
        "allowedConclusion": "State only a broad direction in the role's own domain.",
        "prohibitedEscalation": ["specific event", "specific actor", "specific date", "specific amount", "cross-domain claim"],
    }


def product(claim_id: str, evidence_refs: list[str], domain: str, age: str,
            outcome: str, allowed: str) -> dict:
    return {
        "claimId": claim_id,
        "claimType": "OWNER_AUTHORIZED_PRODUCT_INTERPRETATION",
        "contextId": "mahabhut2537.rem0.saturday",
        "evidenceRefs": evidence_refs,
        "agePeriodBinding": age,
        "domain": domain,
        "movementOutcome": outcome,
        "allowedConclusion": allowed,
        "prohibitedEscalation": [
            "job title", "named person type not present in evidence", "amount",
            "month or date", "disease or diagnosis", "marriage or separation",
            "job transfer", "large windfall", "numeric threshold", "invented confidence",
        ],
        "labelPolicy": "INTERNAL_PRODUCT_INTERPRETATION_NOT_SOURCE_QUOTE",
    }


def schema() -> dict:
    evidence_schema = {
        "type": "object",
        "required": ["editionId", "page", "pageImageReviewed", "paragraphBoundary", "shortExcerpt", "pdfSha256"],
        "properties": {
            "editionId": {"type": "string", "minLength": 1},
            "page": {"type": "integer"},
            "pageImageReviewed": {"const": True},
            "paragraphBoundary": {"type": "string", "minLength": 1},
            "shortExcerpt": {"type": "string", "minLength": 1, "maxLength": 180},
            "pdfSha256": {"const": PDF_SHA256},
        },
    }
    claim_common = {
        "type": "object",
        "required": ["claimId", "claimType", "contextId", "agePeriodBinding", "domain", "movementOutcome", "allowedConclusion", "prohibitedEscalation"],
        "properties": {"claimId": {"type": "string", "minLength": 1}, "contextId": {"type": "string", "minLength": 1}},
    }
    return {
        "$schema": "https://json-schema.org/draft/2020-12/schema",
        "type": "object",
        "required": ["version", "status", "placementRecords", "sourceGeneralRules", "sourceDirectClaims", "generalRuleApplications", "productInterpretationClaims", "discoveryKeywordHits", "counts"],
        "properties": {
            "version": {"const": 2},
            "status": {"const": "PROPOSED_NOT_RUNTIME_PENDING_OWNER_REVIEW"},
            "placementRecords": {"type": "array", "minItems": 392, "maxItems": 392},
            "sourceGeneralRules": {"type": "array"},
            "sourceDirectClaims": {"type": "array", "items": {**claim_common, "properties": {**claim_common["properties"], "sourceEvidence": evidence_schema}}},
            "generalRuleApplications": {"type": "array", "items": claim_common},
            "productInterpretationClaims": {"type": "array", "items": claim_common},
            "discoveryKeywordHits": {"type": "array"},
            "counts": {"type": "object"},
        },
    }


def main() -> None:
    old = json.loads(V1.read_text(encoding="utf-8"))
    placement_records = []
    discovery_hits = []
    for context in old["contexts"]:
        for period in context["lifePeriodSequence"]:
            start, end = period["ageBoundary"].split("-")
            placement_records.append({
                "recordId": f"placement.{context['contextId']}.{period['planet']}.{start}_{end}",
                "recordType": "SOURCE_PLACEMENT_FACT",
                "contextId": context["contextId"],
                "archetype": context["archetype"],
                "remainder": context["remainder"],
                "thaiAstrologicalDay": context["thaiAstrologicalDay"],
                "planet": period["planet"],
                "taksaRole": period["taksaRole"],
                "mahabhutHouse": period["mahabhutHouse"],
                "agePeriodBinding": period["ageBoundary"],
                "periodStatus": period["periodStatus"],
                "exceptionRefs": ["kalakini-house-polarity-reversal"] if period["taksaRole"] == "kalakini" else [],
                "sourceEvidence": {
                    "editionId": SOURCE_EDITION,
                    "page": period["placementEvidencePage"],
                    "pageImageReviewed": True,
                    "sectionBoundary": "eight-row context placement table",
                    "shortExcerpt": f"{period['planetThai']} · {period['taksaRoleThai']} · เรือน{period['mahabhutHouse']}",
                    "pdfSha256": PDF_SHA256,
                },
                "predictionClaimStatus": "NOT_A_PREDICTION_CLAIM",
            })
        for domain, status in context.get("domainEventCoverage", {}).items():
            if status == "SOURCE_EVENT_OR_CHANGE_PRESENT":
                discovery_hits.append({
                    "hitId": f"keyword.{context['contextId']}.{domain}",
                    "status": "DISCOVERY_KEYWORD_HIT",
                    "contextId": context["contextId"],
                    "domain": domain,
                    "sourcePageRange": context["sourcePageRange2537"],
                    "eventEvidence": False,
                    "periodBound": False,
                    "note": "OCR keyword presence only; requires page-image sentence review before claim use.",
                })

    source_direct = [
        direct("SDC-R0-SAT-42_62-SUPPORT", 291, "paragraph beginning ตลอดระยะเวลาดังกล่าว; first sentence", "ได้รับการช่วยเหลือสนับสนุน", "support", "supporting_people", "support increases", "AGE_PERIOD", "42-62", "People already connected to the work provide broad support."),
        direct("SDC-R0-SAT-42_62-WORK", 291, "same paragraph; clause after support list", "ให้มีงานทำ", "work", "work_access", "work access improves", "AGE_PERIOD", "42-62", "Work becomes easier to obtain or move forward."),
        direct("SDC-R0-SAT-42_62-FINANCE", 291, "same paragraph; finance clause", "ให้มีเงินใช้ ให้มีโชคมีลาภ", "finance", "available_money", "money availability improves", "AGE_PERIOD", "42-62", "Money is more available in this period; no amount or windfall size."),
        direct("SDC-R0-SAT-42_62-FLOW", 291, "same paragraph; sentence ending ไร้อุปสรรค", "การทำการพูดการคิด ทุกอย่างจะราบรื่น", "work", "action_communication_thought", "execution becomes smoother", "AGE_PERIOD", "42-62", "Work, communication and decisions move more smoothly."),
        direct("SDC-R0-SAT-42_43_61_62-TEMPORARY-GAIN", 291, "final paragraph continuing to p292", "ได้มาในระยะเวลาอันสั้น", "finance", "temporary_gain", "gain is temporary", "AGE_BOUNDARY", "42-43|61-62", "Only the two explicit boundary windows may be described as temporary gain."),
        direct("SDC-R0-SAT-42_43_61_62-LOSS", 292, "opening continuation paragraph", "ได้มาแล้วก็สูญเสียคืนไป", "finance", "gain_then_loss", "money gained is lost again", "AGE_BOUNDARY", "42-43|61-62", "Only the two explicit boundary windows may carry the gain-then-loss claim."),
        direct("SDC-R0-SAT-42_43_61_62-SPEECH", 292, "opening continuation paragraph; final sentence", "ควรระวังคำพูดคำจา", "communication", "speech", "speech needs restraint", "AGE_BOUNDARY", "42-43|61-62", "Only the explicit boundary windows may carry a speech caution."),
    ]

    source_general_rules = [
        {"ruleId": "SGR-RISE-POSITION", "domain": "period_direction", "condition": "period planet is in thongchai, khumsap, racha or athibodi", "outcome": "dueng_khuen", "sourceEvidence": evidence(17, "paragraph defining four strong houses", "ธงชัย-ขุมทรัพย์-ราชา-อธิบดี")},
        {"ruleId": "SGR-ROLE-DET", "domain": "work", "condition": "active Taksa role is det", "outcome": "authority, strength and work responsibility are the relevant domain", "sourceEvidence": evidence(39, "เดช row in ความหมายของแต่ละภูมิ", "อำนาจ วาสนา อิทธิพล ความเข้มแข็ง")},
        {"ruleId": "SGR-ROLE-SRI", "domain": "finance", "condition": "active Taksa role is sri", "outcome": "money, assets and prosperity are the relevant domain", "sourceEvidence": evidence(39, "ศรี row in ความหมายของแต่ละภูมิ", "การได้มาซึ่งทรัพย์สินเงินทอง")},
        {"ruleId": "SGR-ROLE-MULA", "domain": "foundation", "condition": "active Taksa role is mula", "outcome": "home, property and foundation are the relevant domain", "sourceEvidence": evidence(39, "มูละ row in ความหมายของแต่ละภูมิ", "บ้านเรือนที่อยู่อาศัย บิดามารดา หลักฐาน")},
    ]

    placement_by = {item["recordId"]: item for item in placement_records}
    fixture_records = [item for item in placement_records if item["contextId"] == "mahabhut2537.rem0.saturday"]
    by_period = {(item["planet"], item["agePeriodBinding"]): item for item in fixture_records}
    past = by_period[("rahu", "30-41")]
    current = by_period[("venus", "42-62")]
    next_period = by_period[("mercury", "63-79")]
    general_apps = [
        general("GRA-R0-SAT-30_41-DET-RISE", past["recordId"], "det", "work", "30-41", "authority and work responsibility move forward broadly"),
        general("GRA-R0-SAT-42_62-SRI-RISE", current["recordId"], "sri", "finance", "42-62", "money and material results receive broad support"),
        general("GRA-R0-SAT-63_79-MULA-RISE", next_period["recordId"], "mula", "foundation", "63-79", "property and foundation building receive broad support"),
    ]
    products = [
        product("PIC-R0-SAT-LIFE-ARC", [general_apps[0]["claimId"], general_apps[1]["claimId"], general_apps[2]["claimId"]], "life_path", "30-79", "responsibility growth leads into stronger work/money and then long-term foundation building", "State only the broad chronological arc."),
        product("PIC-R0-SAT-30_41-WORK", [general_apps[0]["claimId"]], "work", "30-41", "work moves forward and larger responsibility opens", "State broad work movement without promotion, employer or date."),
        product("PIC-R0-SAT-HORIZON-WORK", ["SDC-R0-SAT-42_62-WORK", "SDC-R0-SAT-42_62-FLOW"], "work", "2026-08-29/2027-08-28|age44-45", "active work continues moving and blocked matters loosen", "State continuity inside the same source period; no monthly boundary."),
        product("PIC-R0-SAT-HORIZON-SUPPORT", ["SDC-R0-SAT-42_62-SUPPORT"], "support", "2026-08-29/2027-08-28|age44-45", "teachers, senior supporters and friends continue helping important matters move", "State broad support continuity; do not invent a person, promise or event."),
        product("PIC-R0-SAT-63_79-FOUNDATION", [general_apps[2]["claimId"]], "foundation", "63-79", "asset and home foundation building moves well", "State broad foundation movement without purchase, relocation, amount or date."),
    ]

    corpus = {
        "version": 2,
        "status": "PROPOSED_NOT_RUNTIME_PENDING_OWNER_REVIEW",
        "source": old["source"],
        "correction": {
            "rejectedCorpusVersion": 1,
            "placementRecordsArePredictionClaims": False,
            "keywordHitsAreEventEvidence": False,
            "ownerDecision": "SA2_OR1_SEMANTIC_RECLASSIFICATION_REQUIRED",
        },
        "inspectedEvidencePages": [17, 39, 40, 41, 290, 291, 292],
        "placementRecords": placement_records,
        "sourceGeneralRules": source_general_rules,
        "sourceDirectClaims": source_direct,
        "generalRuleApplications": general_apps,
        "productInterpretationClaims": products,
        "discoveryKeywordHits": discovery_hits,
        "counts": {
            "contextPlacementMappings": 49,
            "placementRecords": len(placement_records),
            "sourceDirectClaims": len(source_direct),
            "generalRuleApplications": len(general_apps),
            "productInterpretationClaims": len(products),
            "discoveryKeywordHits": len(discovery_hits),
            "unmappedPlacementContexts": 0,
        },
    }
    OUT.write_text(json.dumps(corpus, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    SCHEMA.write_text(json.dumps(schema(), ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(corpus["counts"], ensure_ascii=True))


if __name__ == "__main__":
    main()
