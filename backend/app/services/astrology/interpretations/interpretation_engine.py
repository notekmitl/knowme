from app.services.astrology.interpretations.en.planet_signs import (
    PLANET_SIGN_INTERPRETATIONS as EN_INTERPRETATIONS
)

from app.services.astrology.interpretations.th.planet_signs import (
    PLANET_SIGN_INTERPRETATIONS as TH_INTERPRETATIONS
)


def generate_interpretations(
    planets
):

    results = []

    for planet_name, planet_data in planets.items():

        sign = planet_data["sign"].lower()

        key = f"{planet_name}_{sign}"

        results.append({
            "planet": planet_name,

            "en":
                EN_INTERPRETATIONS.get(
                    key,
                    _fallback_interpretation(planet_name, sign, "en")
                ),

            "th":
                TH_INTERPRETATIONS.get(
                    key,
                    _fallback_interpretation(planet_name, sign, "th")
                )
        })

    return results


_PLANET_ROLE = {
    "sun": ("identity and direction", "ตัวตนและทิศทางชีวิต"),
    "moon": ("emotional needs", "ความต้องการทางใจ"),
    "mercury": ("thinking and communication", "ความคิดและการสื่อสาร"),
    "venus": ("values and relationships", "คุณค่าและความสัมพันธ์"),
    "mars": ("drive and action", "แรงขับและการลงมือ"),
    "jupiter": ("growth and perspective", "การเติบโตและมุมมอง"),
    "saturn": ("responsibility and long-term lessons", "ความรับผิดชอบและบทเรียนระยะยาว"),
}

_SIGN_STYLE = {
    "aries": ("direct and initiating", "ตรงไปตรงมาและชอบเริ่มก่อน"),
    "taurus": ("steady and practical", "มั่นคงและยึดสิ่งที่ใช้ได้จริง"),
    "gemini": ("curious and adaptable", "ช่างสงสัยและปรับตัวผ่านข้อมูล"),
    "cancer": ("protective and emotionally aware", "ใส่ใจความรู้สึกและความปลอดภัย"),
    "leo": ("expressive and wholehearted", "ชัดเจน อบอุ่น และอยากสร้างผลงานที่ภาคภูมิใจ"),
    "virgo": ("analytical and improvement-minded", "ช่างวิเคราะห์และมองหาวิธีทำให้ดีขึ้น"),
    "libra": ("relational and balance-seeking", "คำนึงถึงคนรอบตัวและพยายามรักษาสมดุล"),
    "scorpio": ("intense and truth-seeking", "ลึก ซื่อตรงต่อความจริง และไม่ชอบสิ่งผิวเผิน"),
    "sagittarius": ("future-facing and exploratory", "มองไกลและต้องการพื้นที่เรียนรู้"),
    "capricorn": ("structured and goal-oriented", "มีโครงสร้างและจริงจังกับเป้าหมาย"),
    "aquarius": ("independent and systems-minded", "เป็นตัวของตัวเองและมองภาพระบบ"),
    "pisces": ("intuitive and imaginative", "ใช้สัญชาตญาณและจินตนาการสูง"),
}


def _fallback_interpretation(planet: str, sign: str, language: str) -> str:
    role = _PLANET_ROLE.get(planet, ("life expression", "การแสดงออกในชีวิต"))
    style = _SIGN_STYLE.get(sign, ("distinctive", "เป็นแบบเฉพาะตัว"))
    if language == "th":
        return f"ด้าน{role[1]}ของคุณมัก{style[1]}"
    return f"Your {role[0]} tends to be {style[0]}."
