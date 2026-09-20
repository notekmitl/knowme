"""Conversational deterministic copy for Western Reader V2."""

from __future__ import annotations


SIGN_TH = {
    "Aries": "เมษ",
    "Taurus": "พฤษภ",
    "Gemini": "เมถุน",
    "Cancer": "กรกฎ",
    "Leo": "สิงห์",
    "Virgo": "กันย์",
    "Libra": "ตุลย์",
    "Scorpio": "พิจิก",
    "Sagittarius": "ธนู",
    "Capricorn": "มกร",
    "Aquarius": "กุมภ์",
    "Pisces": "มีน",
}

ELEMENT_TH = {
    "fire": "ธาตุไฟ",
    "earth": "ธาตุดิน",
    "air": "ธาตุลม",
    "water": "ธาตุน้ำ",
    "balanced": "สมดุลหลายธาตุ",
}

MODALITY_TH = {
    "cardinal": "พลังเริ่มต้น",
    "fixed": "พลังยืนระยะ",
    "mutable": "พลังปรับตัว",
    "balanced": "สมดุลหลายจังหวะ",
}

PLANET_TH = {
    "sun": "ดวงอาทิตย์",
    "moon": "ดวงจันทร์",
    "mercury": "ดาวพุธ",
    "venus": "ดาวศุกร์",
    "mars": "ดาวอังคาร",
    "jupiter": "ดาวพฤหัสบดี",
    "saturn": "ดาวเสาร์",
}

_ELEMENT_VOICE = {
    "fire": {
        "strength": "คุณมีแรงขับและตัดสินใจได้ดีเมื่อเห็นเป้าหมายชัด",
        "caution": "จังหวะที่รีบเกินไปอาจทำให้ข้ามรายละเอียดหรือความรู้สึกของคนรอบตัว",
        "action": "ก่อนรับเรื่องใหม่ ให้เลือกหนึ่งเป้าหมายที่สำคัญที่สุดแล้วลงมือให้เห็นผล",
    },
    "earth": {
        "strength": "คุณเด่นเรื่องความจริงจัง การวางระบบ และทำสิ่งยากให้เกิดผลจริง",
        "caution": "ความต้องการความแน่นอนอาจทำให้ยื้อเรื่องที่ควรทดลองหรือปรับทาง",
        "action": "วางหลักที่ต้องรักษาไว้หนึ่งข้อ แล้วเปิดพื้นที่ให้ทดลองวิธีใหม่ทีละน้อย",
    },
    "air": {
        "strength": "คุณมองเห็นหลายมุม เรียนรู้ไว และเชื่อมคนหรือข้อมูลเข้าหากันได้ดี",
        "caution": "เมื่อคิดหลายทางพร้อมกัน คุณอาจตัดสินใจช้าหรืออยู่กับความรู้สึกไม่เต็มที่",
        "action": "แยกช่วงคิดออกจากช่วงตัดสินใจ และกำหนดเส้นตายให้เรื่องที่ค้างในหัว",
    },
    "water": {
        "strength": "คุณรับรู้อารมณ์และบรรยากาศละเอียด จึงเข้าใจสิ่งที่คนอื่นไม่ได้พูดออกมา",
        "caution": "การรับความรู้สึกมากเกินไปอาจทำให้เหนื่อยหรือแบกเรื่องของคนอื่นแทนเขา",
        "action": "ตั้งขอบเขตกับเรื่องที่ไม่ใช่หน้าที่ของคุณ และให้เวลาตัวเองสงบก่อนตอบ",
    },
    "balanced": {
        "strength": "คุณสลับใช้เหตุผล ความรู้สึก การลงมือ และความเป็นจริงได้ตามสถานการณ์",
        "caution": "ความยืดหยุ่นสูงอาจทำให้คนอื่นอ่านทิศทางของคุณไม่ชัด",
        "action": "บอกเป้าหมายและเหตุผลของคุณให้ชัดก่อนปรับวิธีระหว่างทาง",
    },
}

_MODALITY_WORK = {
    "cardinal": "เหมาะกับงานที่ได้เริ่มเรื่องใหม่ ตัดสินใจ และพาคนขยับจากจุดเดิม",
    "fixed": "เหมาะกับงานที่ต้องสร้างมาตรฐาน รักษาคุณภาพ และทำต่อจนเห็นผลระยะยาว",
    "mutable": "เหมาะกับงานที่ต้องแก้โจทย์ เปลี่ยนบทบาท เรียนรู้เร็ว หรือเชื่อมหลายฝ่าย",
    "balanced": "ทำได้ทั้งบทบาทเริ่มงาน ยืนระยะ และปรับแผน จุดสำคัญคือเลือกบทบาทหลักให้ชัด",
}

_HOUSE_TH = {
    1: "ตัวตนและการเริ่มต้น",
    2: "รายได้ คุณค่า และทรัพยากร",
    3: "การสื่อสารและการเรียนรู้",
    4: "บ้าน ครอบครัว และฐานใจ",
    5: "ความสร้างสรรค์ ความรัก และการแสดงออก",
    6: "งานประจำ ระบบชีวิต และการดูแลตัวเอง",
    7: "คู่สัมพันธ์และการร่วมมือ",
    8: "ทรัพย์สินร่วม การเปลี่ยนผ่าน และเรื่องลึก",
    9: "การศึกษา ความเชื่อ และโลกที่กว้างขึ้น",
    10: "อาชีพ ชื่อเสียง และความรับผิดชอบ",
    11: "เครือข่าย เป้าหมายร่วม และอนาคต",
    12: "โลกภายใน การพัก และสิ่งที่ทำเบื้องหลัง",
}


def build_reader(big3: dict, planets: dict, analysis: dict) -> dict:
    sun = big3.get("sun", "")
    moon = big3.get("moon", "")
    rising = big3.get("rising", "")
    dominant_element = analysis["elements"].get("dominant") or "balanced"
    dominant_modality = analysis["modalities"].get("dominant") or "balanced"
    dominant_planets = analysis.get("dominant_planets") or []
    top_planet = dominant_planets[0]["planet"] if dominant_planets else "sun"
    top_houses = analysis.get("house_emphasis") or []
    top_house = top_houses[0]["house"] if top_houses else 1
    element_voice = _ELEMENT_VOICE[dominant_element]

    venus = planets.get("venus", {})
    moon_house = planets.get("moon", {}).get("house")
    saturn_house = planets.get("saturn", {}).get("house")
    money_house = _first_emphasized(top_houses, {2, 8, 10})

    return {
        "version": "western_reader_th_v2",
        "overview": {
            "th": (
                f"แกนหลักของคุณคืออาทิตย์ราศี{_sign(sun)} "
                f"จันทร์ราศี{_sign(moon)} และลัคนาราศี{_sign(rising)} "
                f"ภายนอกกับความต้องการข้างในจึงไม่ได้เดินด้วยจังหวะเดียวกันเสมอ "
                f"พลังที่เด่นคือ {ELEMENT_TH[dominant_element]} และ "
                f"{MODALITY_TH[dominant_modality]}"
            ),
            "en": (
                f"Your chart centers on a {sun} Sun, {moon} Moon, and "
                f"{rising} Rising, with {dominant_element} and "
                f"{dominant_modality} energy carrying the most weight."
            ),
        },
        "sections": [
            {
                "id": "identity",
                "title": "ตัวตนและวิธีเดินชีวิต",
                "body": (
                    f"คุณต้องการเติบโตในแบบราศี{_sign(sun)} แต่จะรับมือเรื่องส่วนตัว "
                    f"ผ่านความรู้สึกแบบราศี{_sign(moon)} คนที่เพิ่งรู้จักมักเห็นด้าน "
                    f"ราศี{_sign(rising)} ก่อน จึงมีบางช่วงที่คนอื่นเข้าใจคุณไม่ครบตั้งแต่แรก"
                ),
            },
            {
                "id": "work",
                "title": "การงาน",
                "body": (
                    f"{_MODALITY_WORK[dominant_modality]} "
                    f"เรือนที่เด่นคือเรือน {top_house} เรื่อง{_HOUSE_TH[top_house]} "
                    f"จึงควรให้น้ำหนักกับงานที่ใช้จุดนี้จริง ไม่ใช่เลือกจากตำแหน่งงานอย่างเดียว"
                ),
            },
            {
                "id": "money",
                "title": "การเงิน",
                "body": _money_copy(dominant_element, money_house),
            },
            {
                "id": "love",
                "title": "ความรัก",
                "body": (
                    f"ดาวศุกร์ราศี{_sign(venus.get('sign'))}บอกว่าคุณให้คุณค่ากับความสัมพันธ์ "
                    f"ในแบบที่ต้องมีทั้งความรู้สึกดีและวิธีอยู่ร่วมกันที่เข้ากันได้ "
                    f"ขณะเดียวกันจันทร์ในเรือน {moon_house or '—'} ทำให้ความปลอดภัยทางใจ "
                    f"เป็นเงื่อนไขสำคัญก่อนเปิดใจเต็มที่"
                ),
            },
            {
                "id": "wellbeing",
                "title": "พลังชีวิตและการดูแลตัวเอง",
                "body": (
                    f"ดาวเสาร์ในเรือน {saturn_house or '—'} ชี้พื้นที่ที่คุณมักจริงจังกับตัวเองมาก "
                    f"เมื่อรับภาระต่อเนื่อง ควรจัดเวลาพักไว้ในแผนตั้งแต่ต้น ไม่รอจนพลังหมด "
                    "คำอ่านนี้พูดถึงรูปแบบการใช้พลัง ไม่ใช่การวินิจฉัยสุขภาพ"
                ),
            },
            {
                "id": "strengths",
                "title": "จุดแข็งที่ใช้ได้จริง",
                "body": (
                    f"{element_voice['strength']} ดาวที่มีน้ำหนักมากคือ "
                    f"{PLANET_TH.get(top_planet, top_planet)} จึงยิ่งเห็นความสามารถนี้ชัด "
                    "เมื่อคุณเป็นคนกำหนดจังหวะและขอบเขตของตัวเอง"
                ),
            },
            {
                "id": "cautions",
                "title": "สิ่งที่ควรระวัง",
                "body": element_voice["caution"],
            },
            {
                "id": "guidance",
                "title": "คำแนะนำจากดวงนี้",
                "body": element_voice["action"],
            },
        ],
        "method": (
            "คำนวณแบบ Tropical Zodiac ด้วย Swiss Ephemeris ใช้เวลาเกิดท้องถิ่น "
            "เขตเวลา IANA พิกัดเกิด ระบบเรือน Placidus และมุมสัมพันธ์หลัก"
        ),
        "disclaimer": (
            "ผลนี้เป็นการอ่านแนวโน้มจากดวงกำเนิดเพื่อช่วยทบทวนและวางแผน "
            "ไม่ใช่ข้อยืนยันว่าเหตุการณ์ใดต้องเกิดขึ้น"
        ),
    }


def _money_copy(element: str, emphasized_house: int | None) -> str:
    base = {
        "fire": "การเงินดีขึ้นเมื่อคุณแยกความกล้าเสี่ยงออกจากการตัดสินใจเร็วเกินไป",
        "earth": "การเงินเด่นเมื่อมีระบบ เกณฑ์ตัดสินใจ และเป้าหมายที่วัดผลได้",
        "air": "รายได้มักเชื่อมกับความคิด การสื่อสาร หรือเครือข่าย แต่ควรลดการตัดสินใจหลายทางพร้อมกัน",
        "water": "คุณอาจใช้เงินตามความรู้สึกหรือความผูกพันได้ง่าย จึงควรแยกงบดูแลคนอื่นออกจากงบของตัวเอง",
        "balanced": "คุณปรับวิธีหาและใช้เงินได้หลายแบบ แต่ต้องมีหลักเดียวที่ใช้ตัดสินใจทุกครั้ง",
    }[element]
    if emphasized_house is None:
        return f"{base} ดวงนี้ไม่ได้มีเรือนการเงินเด่นกว่าส่วนอื่นอย่างชัดเจน จึงควรยึดวินัยมากกว่าจังหวะ"
    return f"{base} เรือน {emphasized_house} เรื่อง{_HOUSE_TH[emphasized_house]}มีน้ำหนัก จึงควรนำเรื่องนี้มารวมในแผนการเงิน"


def _first_emphasized(houses: list[dict], candidates: set[int]) -> int | None:
    for item in houses:
        house = item.get("house")
        if house in candidates:
            return house
    return None


def _sign(value) -> str:
    return SIGN_TH.get(value, str(value or "—"))
