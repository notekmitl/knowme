# backend/app/services/overall_summary_service.py

def generate_overall_summary(astrology_data):
    """
    Generate overall personality summary
    from astrology data.
    """

    big3 = astrology_data.get("big3", {})

    sun = big3.get("sun", "")
    moon = big3.get("moon", "")
    rising = big3.get("rising", "")

    # THAI SUMMARY
    thai_summary = (
        f"คุณเป็นคนที่มีพลังของราศี {sun} "
        f"ผสมกับอารมณ์แบบราศี {moon} "
        f"และมีภาพลักษณ์ภายนอกแบบราศี {rising} "
        f"ทำให้คุณเป็นคนที่มีเอกลักษณ์เฉพาะตัว "
        f"และมีความซับซ้อนทางอารมณ์พอสมควร"
    )

    # ENGLISH SUMMARY
    english_summary = (
        f"You carry the energy of {sun}, "
        f"combined with the emotional nature of {moon}, "
        f"and present yourself outwardly like {rising}. "
        f"This creates a unique personality "
        f"with emotional depth and individuality."
    )

    return {
        "th": thai_summary,
        "en": english_summary,
    }