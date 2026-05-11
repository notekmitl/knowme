def generate_personality_summary(
    chart
):

    big3 = chart["big3"]

    interpretations = chart[
        "interpretations"
    ]

    summary_parts_en = []

    summary_parts_th = []

    sun = big3["sun"]
    moon = big3["moon"]
    rising = big3["rising"]

    # ---------- ZODIAC TH ----------

    zodiac_th = {

        "Aries": "เมษ",
        "Taurus": "พฤษภ",
        "Gemini": "เมถุน",
        "Cancer": "กรกฎ",
        "Leo": "สิงห์",
        "Virgo": "กันย์",
        "Libra": "ตุลย์",
        "Scorpio": "พิจิก",
        "Sagittarius": "ธนู",
        "Capricorn": "มังกร",
        "Aquarius": "กุมภ์",
        "Pisces": "มีน",
    }

    sun_th = zodiac_th.get(
        sun,
        sun,
    )

    moon_th = zodiac_th.get(
        moon,
        moon,
    )

    rising_th = zodiac_th.get(
        rising,
        rising,
    )

    # ---------- EN INTRO ----------

    intro_en = (

        f"You are a {sun} Sun, "

        f"{moon} Moon, "

        f"and {rising} Rising."
    )

    summary_parts_en.append(
        intro_en
    )

    # ---------- TH INTRO ----------

    intro_th = (

        f"คุณเป็นชาวราศี{sun_th} "

        f"มีดวงจันทร์อยู่ราศี{moon_th} "

        f"และลัคนาราศี{rising_th}"
    )

    summary_parts_th.append(
        intro_th
    )

    # ---------- INTERPRETATIONS ----------

    for item in interpretations:

        if item["en"]:

            summary_parts_en.append(
                item["en"]
            )

        if item["th"]:

            summary_parts_th.append(
                item["th"]
            )

    # ---------- FINAL ----------

    personality_summary_en = (
        " ".join(
            summary_parts_en
        )
    )

    personality_summary_th = (
        " ".join(
            summary_parts_th
        )
    )

    return {

        "en":
            personality_summary_en,

        "th":
            personality_summary_th,
    }