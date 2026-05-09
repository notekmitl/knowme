def generate_personality_summary(
    chart
):

    big3 = chart["big3"]

    interpretations = chart[
        "interpretations"
    ]

    summary_parts = []

    sun = big3["sun"]
    moon = big3["moon"]
    rising = big3["rising"]

    intro = (
        f"You are a {sun} Sun, "
        f"{moon} Moon, "
        f"and {rising} Rising."
    )

    summary_parts.append(
        intro
    )

    for item in interpretations:

        if item["en"]:

            summary_parts.append(
                item["en"]
            )

    personality_summary = " ".join(
        summary_parts
    )

    return {
        "en": personality_summary
    }