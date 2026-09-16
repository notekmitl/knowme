"""Structured BaZi reader facts for the KnowMe Reader V2 contract.

This module keeps calculation facts separate from Thai reader copy.  It uses
the same lunar_python EightChar instance as the four-pillar calculation and
adds only deterministic, reviewable derivations needed by the richer report.
"""

from __future__ import annotations

from math import ceil

from app.services.bazi.constants import WU_XING_GAN
TEN_GOD_FAMILY = {
    "正印": "resource",
    "偏印": "resource",
    "比肩": "peer",
    "劫财": "peer",
    "食神": "output",
    "伤官": "output",
    "正财": "wealth",
    "偏财": "wealth",
    "正官": "authority",
    "七杀": "authority",
}

ELEMENT_GENERATES = {
    "wood": "fire",
    "fire": "earth",
    "earth": "metal",
    "metal": "water",
    "water": "wood",
}

STEM_COMBINES = {
    frozenset(("甲", "己")): "earth",
    frozenset(("乙", "庚")): "metal",
    frozenset(("丙", "辛")): "water",
    frozenset(("丁", "壬")): "wood",
    frozenset(("戊", "癸")): "fire",
}

STEM_CLASHES = {
    frozenset(("甲", "庚")),
    frozenset(("乙", "辛")),
    frozenset(("丙", "壬")),
    frozenset(("丁", "癸")),
}

BRANCH_COMBINES = {
    frozenset(("子", "丑")): "earth",
    frozenset(("寅", "亥")): "wood",
    frozenset(("卯", "戌")): "fire",
    frozenset(("辰", "酉")): "metal",
    frozenset(("巳", "申")): "water",
    frozenset(("午", "未")): "earth",
}

BRANCH_CLASHES = {
    frozenset(("子", "午")),
    frozenset(("丑", "未")),
    frozenset(("寅", "申")),
    frozenset(("卯", "酉")),
    frozenset(("辰", "戌")),
    frozenset(("巳", "亥")),
}

BRANCH_HARMS = {
    frozenset(("子", "未")),
    frozenset(("丑", "午")),
    frozenset(("寅", "巳")),
    frozenset(("卯", "辰")),
    frozenset(("申", "亥")),
    frozenset(("酉", "戌")),
}

BRANCH_BREAKS = {
    frozenset(("子", "酉")),
    frozenset(("丑", "辰")),
    frozenset(("寅", "亥")),
    frozenset(("卯", "午")),
    frozenset(("巳", "申")),
    frozenset(("未", "戌")),
}

BRANCH_PUNISHMENTS = {
    frozenset(("子", "卯")),
    frozenset(("寅", "巳", "申")),
    frozenset(("丑", "未", "戌")),
}

BRANCH_SELF_PUNISHMENTS = {"辰", "午", "酉", "亥"}

BRANCH_HARMONIES = {
    frozenset(("申", "子", "辰")): "water",
    frozenset(("亥", "卯", "未")): "wood",
    frozenset(("寅", "午", "戌")): "fire",
    frozenset(("巳", "酉", "丑")): "metal",
}


def normalize_gender(gender: str | None) -> str | None:
    value = str(gender or "").strip().lower()
    if value in {"ชาย", "ช", "male", "man", "m", "1"}:
        return "male"
    if value in {"หญิง", "ญ", "female", "woman", "f", "0"}:
        return "female"
    return None


def enrich_pillars(pillars: dict, eight_char) -> dict:
    getters = {
        "year": (
            eight_char.getYearHideGan,
            eight_char.getYearShiShenGan,
            eight_char.getYearShiShenZhi,
            eight_char.getYearDiShi,
            eight_char.getYearNaYin,
        ),
        "month": (
            eight_char.getMonthHideGan,
            eight_char.getMonthShiShenGan,
            eight_char.getMonthShiShenZhi,
            eight_char.getMonthDiShi,
            eight_char.getMonthNaYin,
        ),
        "day": (
            eight_char.getDayHideGan,
            eight_char.getDayShiShenGan,
            eight_char.getDayShiShenZhi,
            eight_char.getDayDiShi,
            eight_char.getDayNaYin,
        ),
        "hour": (
            eight_char.getTimeHideGan,
            eight_char.getTimeShiShenGan,
            eight_char.getTimeShiShenZhi,
            eight_char.getTimeDiShi,
            eight_char.getTimeNaYin,
        ),
    }
    result = {}
    for role, pillar in pillars.items():
        if not isinstance(pillar, dict):
            result[role] = None
            continue
        hide, stem_god, hidden_gods, growth, nayin = getters[role]
        result[role] = {
            **pillar,
            "hidden_stems": list(hide()),
            "stem_ten_god": str(stem_god()),
            "hidden_ten_gods": list(hidden_gods()),
            "growth_stage": str(growth()),
            "nayin": str(nayin()),
        }
    return result


def compute_ten_god_balance(pillars: dict) -> dict:
    visible = {name: 0 for name in TEN_GOD_FAMILY}
    hidden = {name: 0 for name in TEN_GOD_FAMILY}
    family_weight = {name: 0 for name in set(TEN_GOD_FAMILY.values())}

    for role in ("year", "month", "day", "hour"):
        pillar = pillars.get(role)
        if not isinstance(pillar, dict):
            continue
        stem_god = pillar.get("stem_ten_god")
        if stem_god in visible:
            visible[stem_god] += 1
            family_weight[TEN_GOD_FAMILY[stem_god]] += 2
        for god in pillar.get("hidden_ten_gods", []):
            if god in hidden:
                hidden[god] += 1
                family_weight[TEN_GOD_FAMILY[god]] += 1

    top_weight = max(family_weight.values(), default=0)
    top_families = sorted(
        family for family, weight in family_weight.items() if weight == top_weight
    )
    return {
        "visible": visible,
        "hidden": hidden,
        "family_weight": family_weight,
        "top_families": top_families,
        "method": "visible_stem_2_hidden_stem_1_v2",
    }


def compute_day_master_support(pillars: dict, day_element: str) -> dict:
    resource_element = next(
        (
            source
            for source, produced in ELEMENT_GENERATES.items()
            if produced == day_element
        ),
        "",
    )
    supportive = {day_element, resource_element}
    month = pillars.get("month")
    primary_month_element = _primary_branch_element(month)
    season_score = 0
    if primary_month_element == day_element:
        season_score = 3
    elif primary_month_element == resource_element:
        season_score = 2

    ground_score = 0
    possible_ground = 0
    for role in ("year", "day", "hour"):
        pillar = pillars.get(role)
        if not isinstance(pillar, dict):
            continue
        possible_ground += 1
        if _primary_branch_element(pillar) in supportive:
            ground_score += 1

    visible_score = 0
    possible_visible = 0
    for role in ("year", "month", "hour"):
        pillar = pillars.get(role)
        if not isinstance(pillar, dict):
            continue
        possible_visible += 1
        if pillar.get("stem_element") in supportive:
            visible_score += 1

    max_score = 3 + possible_ground + possible_visible
    score = season_score + ground_score + visible_score
    if score >= ceil(max_score / 2):
        band = "supported"
    elif score >= ceil(max_score / 3):
        band = "balanced"
    else:
        band = "lean"

    return {
        "score": score,
        "max_score": max_score,
        "band": band,
        "season_score": season_score,
        "ground_score": ground_score,
        "visible_support_score": visible_score,
        "resource_element": resource_element,
        "method": "three_gains_primary_qi_v2",
    }


def compute_natal_relations(pillars: dict) -> list[dict]:
    available = [
        (role, pillar)
        for role, pillar in pillars.items()
        if isinstance(pillar, dict)
    ]
    result = []
    for index, (left_role, left) in enumerate(available):
        for right_role, right in available[index + 1 :]:
            result.extend(
                _pair_relations(
                    left_role,
                    left.get("stem", ""),
                    left.get("branch", ""),
                    right_role,
                    right.get("stem", ""),
                    right.get("branch", ""),
                )
            )

    branches = [(role, pillar.get("branch", "")) for role, pillar in available]
    result.extend(_group_branch_relations(branches))
    return _dedupe_relations(result)


def build_luck_cycles(eight_char, gender: str | None, pillars: dict) -> dict | None:
    normalized = normalize_gender(gender)
    if normalized is None:
        return None

    gender_code = 1 if normalized == "male" else 0
    yun = eight_char.getYun(gender_code, 1)
    cycles = []
    for da_yun in yun.getDaYun(11):
        gan_zhi = da_yun.getGanZhi()
        if not gan_zhi:
            continue
        stem, branch = gan_zhi[0], gan_zhi[1]
        annual = []
        for liu_nian in da_yun.getLiuNian():
            annual_gan_zhi = liu_nian.getGanZhi()
            annual.append(
                {
                    "year": liu_nian.getYear(),
                    "age": liu_nian.getAge(),
                    "pillar_label": annual_gan_zhi,
                    "stem": annual_gan_zhi[0],
                    "branch": annual_gan_zhi[1],
                    "stem_ten_god": _ten_god(eight_char, annual_gan_zhi[0]),
                    "natal_relations": _transit_relations(
                        pillars,
                        "annual",
                        annual_gan_zhi[0],
                        annual_gan_zhi[1],
                    ),
                }
            )
        cycles.append(
            {
                "start_year": da_yun.getStartYear(),
                "end_year": da_yun.getEndYear(),
                "start_age": da_yun.getStartAge(),
                "end_age": da_yun.getEndAge(),
                "pillar_label": gan_zhi,
                "stem": stem,
                "branch": branch,
                "stem_ten_god": _ten_god(eight_char, stem),
                "natal_relations": _transit_relations(
                    pillars,
                    "decade",
                    stem,
                    branch,
                ),
                "annual": annual,
            }
        )

    start = yun.getStartSolar()
    return {
        "gender": normalized,
        "direction": "forward" if yun.isForward() else "backward",
        "onset": {
            "years": yun.getStartYear(),
            "months": yun.getStartMonth(),
            "days": yun.getStartDay(),
            "date": start.toYmd(),
        },
        "cycles": cycles,
        "method": "lunar_python_yun_traditional_sect_1_v2",
    }


def _ten_god(eight_char, stem: str) -> str:
    from lunar_python.util import LunarUtil

    return LunarUtil.SHI_SHEN.get(eight_char.getDayGan() + stem, "")


def _primary_branch_element(pillar: dict | None) -> str:
    if not isinstance(pillar, dict):
        return ""
    hidden = pillar.get("hidden_stems", [])
    if hidden:
        return WU_XING_GAN.get(hidden[0], "")
    return str(pillar.get("branch_element", ""))


def _pair_relations(
    left_role: str,
    left_stem: str,
    left_branch: str,
    right_role: str,
    right_stem: str,
    right_branch: str,
) -> list[dict]:
    result = []
    stem_pair = frozenset((left_stem, right_stem))
    if len(stem_pair) == 2 and stem_pair in STEM_COMBINES:
        result.append(
            _relation(
                "stem_combine",
                [left_role, right_role],
                [left_stem, right_stem],
                target_element=STEM_COMBINES[stem_pair],
            )
        )
    if len(stem_pair) == 2 and stem_pair in STEM_CLASHES:
        result.append(
            _relation(
                "stem_clash",
                [left_role, right_role],
                [left_stem, right_stem],
            )
        )

    branch_pair = frozenset((left_branch, right_branch))
    is_branch_combine = (
        len(branch_pair) == 2 and branch_pair in BRANCH_COMBINES
    )
    if is_branch_combine:
        result.append(
            _relation(
                "branch_combine",
                [left_role, right_role],
                [left_branch, right_branch],
                target_element=BRANCH_COMBINES[branch_pair],
            )
        )
    for kind, table in (
        ("branch_clash", BRANCH_CLASHES),
        ("branch_harm", BRANCH_HARMS),
        ("branch_break", BRANCH_BREAKS),
    ):
        # Some traditional tables label the same pair as both a combine and a
        # break. Reader V2 gives the direct combine precedence so the user does
        # not receive two contradictory labels for one pair.
        if kind == "branch_break" and is_branch_combine:
            continue
        if len(branch_pair) == 2 and branch_pair in table:
            result.append(
                _relation(
                    kind,
                    [left_role, right_role],
                    [left_branch, right_branch],
                )
            )
    if branch_pair == frozenset(("子", "卯")):
        result.append(
            _relation(
                "branch_punishment",
                [left_role, right_role],
                [left_branch, right_branch],
            )
        )
    if left_branch == right_branch and left_branch in BRANCH_SELF_PUNISHMENTS:
        result.append(
            _relation(
                "branch_self_punishment",
                [left_role, right_role],
                [left_branch, right_branch],
            )
        )
    return result


def _group_branch_relations(branches: list[tuple[str, str]]) -> list[dict]:
    available = {branch for _, branch in branches}
    result = []
    for group, target in BRANCH_HARMONIES.items():
        if group.issubset(available):
            roles = [role for role, branch in branches if branch in group]
            result.append(
                _relation(
                    "branch_three_harmony",
                    roles,
                    sorted(group),
                    target_element=target,
                )
            )
    for group in BRANCH_PUNISHMENTS:
        if len(group) == 3 and group.issubset(available):
            roles = [role for role, branch in branches if branch in group]
            result.append(
                _relation(
                    "branch_punishment",
                    roles,
                    sorted(group),
                )
            )
    return result


def _transit_relations(
    pillars: dict,
    transit_role: str,
    stem: str,
    branch: str,
) -> list[dict]:
    result = []
    branch_roles = []
    for role, pillar in pillars.items():
        if not isinstance(pillar, dict):
            continue
        result.extend(
            _pair_relations(
                transit_role,
                stem,
                branch,
                role,
                pillar.get("stem", ""),
                pillar.get("branch", ""),
            )
        )
        branch_roles.append((role, pillar.get("branch", "")))
    branch_roles.append((transit_role, branch))
    result.extend(_group_branch_relations(branch_roles))
    return _dedupe_relations(result)


def _relation(
    kind: str,
    roles: list[str],
    symbols: list[str],
    *,
    target_element: str | None = None,
) -> dict:
    value = {"kind": kind, "roles": roles, "symbols": symbols}
    if target_element:
        value["target_element"] = target_element
    return value


def _dedupe_relations(relations: list[dict]) -> list[dict]:
    seen = set()
    result = []
    for relation in relations:
        key = (
            relation.get("kind"),
            tuple(sorted(relation.get("roles", []))),
            tuple(sorted(relation.get("symbols", []))),
            relation.get("target_element"),
        )
        if key in seen:
            continue
        seen.add(key)
        result.append(relation)
    return result
