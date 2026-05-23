class AppText {
  static String lang = "th";

  static const Map<String, Map<String, String>> text = {
    /// =========================
    /// GENERAL
    /// =========================
    "personality_tests": {"en": "Personality Tests", "th": "แบบทดสอบบุคลิกภาพ"},

    /// =========================
    /// ASTROLOGY (MVP)
    /// =========================
    "astro_home_primary": {
      "en": "View my chart",
      "th": "ดูดวงของฉัน",
    },
    "astro_app_bar_title": {
      "en": "Your chart",
      "th": "ดวงของคุณ",
    },
    "astro_no_data": {
      "en": "No chart data yet",
      "th": "ยังไม่มีข้อมูลดวง",
    },
    "astro_hero_eyebrow": {
      "en": "Your personality overview",
      "th": "ภาพรวมตัวตนของคุณ",
    },
    "astro_hero_supporting": {
      "en": "Reflected from your natal chart",
      "th": "สะท้อนจากดวงกำเนิดของคุณ",
    },
    "astro_big3_title": {
      "en": "What often drives you",
      "th": "สิ่งที่มักขับเคลื่อนคุณ",
    },
    "astro_big3_subtitle": {
      "en": "Three lenses on how you show up, feel, and move through life",
      "th": "สามมุมที่อาจสะท้อนว่าคุณแสดงออก รู้สึก และเดินผ่านชีวิตอย่างไร",
    },
    "astro_big3_sun": {
      "en": "Your core self",
      "th": "แก่นในตัวคุณ",
    },
    "astro_big3_inner": {
      "en": "How you may feel inside",
      "th": "โลกอารมณ์ภายใน",
    },
    "astro_big3_rising": {
      "en": "First impression",
      "th": "สิ่งที่คนมักเห็นก่อน",
    },
    "astro_insight_title": {
      "en": "A closer read",
      "th": "อ่านตัวคุณใกล้ขึ้น",
    },
    "astro_insight_subtitle": {
      "en": "Patterns that may echo in how you relate and decide",
      "th": "แนวโน้มที่อาจสะท้อนในความสัมพันธ์และการตัดสินใจ",
    },
    "astro_deep_title": {
      "en": "Another layer",
      "th": "อีกชั้นของตัวคุณ",
    },
    "astro_deep_subtitle": {
      "en": "A wider snapshot — take what resonates",
      "th": "ภาพรวมที่กว้างขึ้น — เลือกอ่านส่วนที่รู้สึกตรง",
    },
    "astro_planets_title": {
      "en": "Deeper layers of you",
      "th": "ชั้นลึกของตัวคุณ",
    },
    "astro_planets_subtitle": {
      "en": "Each placement may add nuance to how you experience life",
      "th": "แต่ละตำแหน่งอาจเติมรายละเอียดให้ประสบการณ์ชีวิตของคุณ",
    },
    "astro_planets_intro": {
      "en": "Read gently — not every line has to fit perfectly.",
      "th": "อ่านอย่างสบายๆ — ไม่จำเป็นต้องตรงทุกบรรทัด",
    },
    "astro_planet_placement": {
      "en": "May reflect {sign} • House {house}",
      "th": "อาจสะท้อนพลังของ{sign} • เรือนที่ {house}",
    },
    "astro_planet_interpretation_fallback": {
      "en":
          "This placement may reflect something personal that becomes clearer over time.",
      "th":
          "ตำแหน่งนี้อาจสะท้อนรายละเอียดบางอย่างที่ค่อยๆ ชัดขึ้นเมื่อคุณสังเกตตัวเองมากขึ้น",
    },
    "astro_insight_preparing": {
      "en": "A closer read of your chart is being prepared.",
      "th": "กำลังเตรียมภาพรวมที่ใกล้ตัวคุณมากขึ้น",
    },
    "astro_deep_preparing": {
      "en": "A wider snapshot of your chart is being prepared.",
      "th": "กำลังเตรียมภาพรวมที่กว้างขึ้นจากดวงของคุณ",
    },
    "astro_result_cta_mbti": {
      "en": "Want this chart to understand you more deeply?",
      "th": "อยากให้ดวงนี้เข้าใจคุณมากขึ้นไหม?",
    },
    "astro_result_cta_mbti_support": {
      "en": "A short personality test can help tailor what you see here — only if you feel like exploring.",
      "th": "แบบทดสอบบุคลิกสั้นๆ อาจช่วยให้คำอธิบายตรงกับคุณมากขึ้น — ทำเมื่อคุณพร้อม",
    },
    "astro_result_cta_mbti_action": {
      "en": "Explore with a short test",
      "th": "สำรวจด้วยแบบทดสอบสั้นๆ",
    },

    "start_test": {"en": "Start Test", "th": "เริ่มทำแบบทดสอบ"},

    "questions": {"en": "Questions", "th": "คำถาม"},

    "no_questions": {
      "en": "No questions available for this test",
      "th": "ยังไม่มีคำถามในแบบทดสอบนี้",
    },

    /// =========================
    /// RESULT PAGE
    /// =========================
    "result_title": {"en": "Your Personality", "th": "ผลลัพธ์บุคลิกภาพของคุณ"},

    "traits": {"en": "Personality Traits", "th": "ลักษณะบุคลิกภาพ"},

    "insights": {"en": "Personality Insights", "th": "การวิเคราะห์บุคลิก"},

    "your_type": {"en": "Your Type", "th": "ประเภทบุคลิกของคุณ"},

    "improve_accuracy": {
      "en": "Complete more tests to improve accuracy",
      "th": "ทำแบบทดสอบเพิ่มเติมเพื่อเพิ่มความแม่นยำ",
    },

    /// =========================
    /// PROFILE PAGE
    /// =========================
    "profile_title": {"en": "Personality Profile", "th": "โปรไฟล์บุคลิกภาพ"},

    "personality_analysis": {
      "en": "Personality Analysis",
      "th": "การวิเคราะห์บุคลิกของคุณ",
    },

    /// =========================
    /// TEST CATEGORIES
    /// =========================
    "category_bigfive": {
      "en": "Big Five Personality",
      "th": "บุคลิกภาพ Big Five",
    },

    "category_eq": {
      "en": "Emotional Intelligence",
      "th": "ความฉลาดทางอารมณ์ (EQ)",
    },

    "category_mbti": {"en": "MBTI Personality Type", "th": "บุคลิกภาพแบบ MBTI"},

    /// =========================
    /// TEST MODULE TITLES
    /// =========================
    "mbti_mini_title": {"en": "Quick MBTI Test", "th": "MBTI แบบสั้น"},

    "mbti_mini_description": {
      "en": "Quick overview of your personality type",
      "th": "ค้นหาประเภทบุคลิกภาพอย่างรวดเร็ว",
    },

    "mbti_short_title": {"en": "Standard MBTI Test", "th": "MBTI มาตรฐาน"},

    "mbti_short_description": {
      "en": "Standard MBTI personality analysis",
      "th": "วิเคราะห์ MBTI แบบมาตรฐาน",
    },

    "mbti_accurate_title": {
      "en": "Advanced MBTI Test",
      "th": "MBTI แบบละเอียด",
    },

    "mbti_accurate_description": {
      "en": "Highly accurate personality analysis",
      "th": "วิเคราะห์บุคลิกภาพเชิงลึก",
    },

    "mbti_progressive_title": {"en": "MBTI", "th": "MBTI"},

    "mbti_progressive_description": {
      "en": "Start fast, then add accuracy when you want.",
      "th": "เริ่มเร็ว แล้วค่อยเพิ่มความแม่นยำได้",
    },

    "mbti_result_progress_title": {
      "en": "MBTI progress",
      "th": "ความคืบหน้า MBTI",
    },

    "mbti_result_section_summary": {
      "en": "Who you are",
      "th": "คุณเป็นคนแบบไหน",
    },

    "mbti_result_section_strengths": {
      "en": "Strengths",
      "th": "จุดแข็ง",
    },

    "mbti_result_section_cautions": {
      "en": "Things to keep in mind",
      "th": "สิ่งที่ควรระวัง",
    },

    "mbti_result_section_careers": {
      "en": "Careers that may fit",
      "th": "อาชีพที่เหมาะ",
    },

    "mbti_result_section_relationships": {
      "en": "Relationships",
      "th": "ความสัมพันธ์",
    },

    "mbti_result_unknown_type_body": {
      "en":
          "We could not load detailed personality text for this result yet. Your type letters and scores below are still shown.",
      "th":
          "ยังไม่มีคำอธิบายละเอียดสำหรับผลนี้ แต่คุณยังดูตัวอักษรประเภทและกราฟด้านล่างได้",
    },

    "mbti_result_retake_dialog_title": {
      "en": "Retake test?",
      "th": "ทำแบบทดสอบใหม่?",
    },

    "mbti_result_retake_dialog_body": {
      "en": "Your previous progress will be cleared and you will start fresh.",
      "th": "ความคืบหน้าเดิมจะถูกล้าง และเริ่มทำแบบทดสอบใหม่",
    },

    "mbti_result_common_cancel": {
      "en": "Cancel",
      "th": "ยกเลิก",
    },

    "mbti_result_retake_dialog_confirm": {
      "en": "Retake",
      "th": "ทำใหม่",
    },

    "mbti_result_retake_button": {
      "en": "Retake test",
      "th": "ทำแบบทดสอบใหม่",
    },

    "mbti_result_continue_standard": {
      "en": "Continue to MBTI Standard (40 questions)",
      "th": "ทำต่อถึง MBTI Standard (40 ข้อ)",
    },

    "mbti_result_continue_accurate": {
      "en": "Continue to MBTI Accurate (80 questions)",
      "th": "ทำต่อถึง MBTI Accurate (80 ข้อ)",
    },

    "mbti_result_traits_title": {
      "en": "How your type is built",
      "th": "ทำไมถึงได้ผลลัพธ์นี้",
    },

    "mbti_result_trait_lean": {
      "en": "You lean toward",
      "th": "คุณโน้มไปทาง",
    },

    "mbti_result_traits_subtitle": {
      "en": "These four dimensions explain your type letters.",
      "th": "สี่มิตินี้บอกว่าทำไมคุณถึงได้ตัวอักษรประเภทนี้",
    },

    "mbti_pole_e_short": {
      "en": "Enjoys social energy",
      "th": "ชอบเข้าสังคม",
    },

    "mbti_pole_i_short": {
      "en": "Prefers quiet focus",
      "th": "ชอบอยู่คนเดียว",
    },

    "mbti_pole_s_short": {
      "en": "Focuses on facts",
      "th": "สนใจข้อเท็จจริง",
    },

    "mbti_pole_n_short": {
      "en": "Imagines possibilities",
      "th": "มองภาพอนาคต",
    },

    "mbti_pole_t_short": {
      "en": "Decides with logic",
      "th": "ตัดสินใจด้วยเหตุผล",
    },

    "mbti_pole_f_short": {
      "en": "Considers feelings",
      "th": "ใส่ใจความรู้สึก",
    },

    "mbti_pole_j_short": {
      "en": "Likes structure",
      "th": "ชอบวางแผน",
    },

    "mbti_pole_p_short": {
      "en": "Stays flexible",
      "th": "ชอบปรับตัว",
    },

    "mbti_trait_extroverted": {
      "en": "Extroverted",
      "th": "เอ็กซโทรเวิร์ต",
    },

    "mbti_trait_introverted": {
      "en": "Introverted",
      "th": "อินโทรเวิร์ต",
    },

    "mbti_trait_sensing": {
      "en": "Sensing",
      "th": "สัมผัส (Sensing)",
    },

    "mbti_trait_intuition": {
      "en": "Intuition",
      "th": "ลางสังหรณ์ (Intuition)",
    },

    "mbti_trait_thinking": {
      "en": "Thinking",
      "th": "คิดวิเคราะห์",
    },

    "mbti_trait_feeling": {
      "en": "Feeling",
      "th": "รู้สึกและใส่ใจ",
    },

    "mbti_trait_judging": {
      "en": "Judging",
      "th": "ชอบวางแผน",
    },

    "mbti_trait_perceiving": {
      "en": "Perceiving",
      "th": "ชอบปรับตัว",
    },

    "mbti_result_progress_hint": {
      "en": "Answer more questions to increase confidence and accuracy.",
      "th": "ทำข้อสอบเพิ่มเพื่อให้ผลลัพธ์แม่นยำและมั่นใจมากขึ้น",
    },

    "mbti_result_checkpoint_questions": {
      "en": "questions",
      "th": "ข้อ",
    },

    "mbti_result_timeline_tier_mini": {
      "en": "Quick read",
      "th": "ภาพรวมเร็ว",
    },

    "mbti_result_timeline_tier_standard": {
      "en": "Balanced",
      "th": "สมดุล",
    },

    "mbti_result_timeline_tier_accurate": {
      "en": "Most accurate",
      "th": "แม่นยำที่สุด",
    },

    "mbti_cognitive_title": {
      "en": "MBTI Cognitive",
      "th": "MBTI Cognitive",
    },

    "mbti_cognitive_description": {
      "en": "Progressive cognitive functions — 16, 40, or 80 questions.",
      "th": "ฟังก์ชันทางความคิดแบบก้าวหน้า — 16, 40 หรือ 80 ข้อ",
    },

    "mbti_summary_title": {
      "en": "MBTI Summary",
      "th": "MBTI Summary",
    },

    "mbti_summary_description": {
      "en": "Combined insight from your MBTI type and cognitive functions.",
      "th": "ภาพรวมจากประเภท MBTI และฟังก์ชันทางความคิด",
    },

    "mbti_sum_catalog_no_questions": {
      "en": "Derived insight — no new questions",
      "th": "สรุปจากผลเดิม — ไม่มีคำถามเพิ่ม",
    },

    "mbti_sum_catalog_ready": {
      "en": "Ready to view",
      "th": "พร้อมดูภาพรวม",
    },

    "mbti_sum_catalog_locked": {
      "en": "Complete both tests first",
      "th": "ทำ MBTI และ Cognitive ให้เสร็จก่อน",
    },

    "mbti_sum_locked_title": {
      "en": "Summary not ready yet",
      "th": "ยังดูภาพรวมไม่ได้",
    },

    "mbti_sum_locked_guest": {
      "en": "Sign in and complete MBTI and MBTI Cognitive to unlock your summary.",
      "th": "เข้าสู่ระบบและทำ MBTI กับ MBTI Cognitive ให้เสร็จเพื่อปลดล็อกภาพรวม",
    },

    "mbti_sum_locked_both": {
      "en": "Finish MBTI and MBTI Cognitive first — then your combined summary unlocks.",
      "th": "ทำ MBTI และ MBTI Cognitive ให้เสร็จก่อน แล้วจึงดูภาพรวมรวมได้",
    },

    "mbti_sum_locked_mbti": {
      "en": "Complete the MBTI test first to unlock your summary.",
      "th": "ทำแบบทดสอบ MBTI ให้เสร็จก่อนเพื่อดูภาพรวม",
    },

    "mbti_sum_locked_cognitive": {
      "en": "Complete MBTI Cognitive (at least one checkpoint) to see your full picture.",
      "th": "ทำ MBTI Cognitive ให้เสร็จอย่างน้อยหนึ่งช่วงเพื่อดูภาพรวม",
    },

    "mbti_sum_locked_back": {
      "en": "Back to tests",
      "th": "กลับไปรายการแบบทดสอบ",
    },

    "mbti_sum_load_error": {
      "en": "Could not load your summary. Try again later.",
      "th": "โหลดภาพรวมไม่สำเร็จ ลองใหม่อีกครั้ง",
    },

    "mbti_sum_disclaimer": {
      "en":
          "This summary combines tendencies from two assessments — not a fixed identity.",
      "th":
          "ภาพรวมนี้รวมแนวโน้มจากสองแบบทดสอบ — ไม่ใช่การกำหนดตัวตน",
    },

    "mbti_sum_hero_label": {
      "en": "Your combined profile",
      "th": "ภาพรวมบุคลิกของคุณ",
    },

    "mbti_sum_type_unknown": {
      "en": "Your answers suggest a distinctive mix of traits.",
      "th": "คำตอบของคุณสะท้อนบุคลิกที่ผสมหลายแบบ",
    },

    "mbti_sum_align_title_aligned": {
      "en": "Type & functions — aligned",
      "th": "ประเภทกับฟังก์ชัน — สอดคล้องกัน",
    },

    "mbti_sum_align_title_partial": {
      "en": "Type & functions — partly aligned",
      "th": "ประเภทกับฟังก์ชัน — สอดคล้องบางส่วน",
    },

    "mbti_sum_align_title_mixed": {
      "en": "Type & functions — mixed signals",
      "th": "ประเภทกับฟังก์ชัน — สัญญาณผสมกัน",
    },

    "mbti_sum_align_aligned": {
      "en":
          "Your MBTI type and cognitive preferences look fairly consistent — as tendencies, not rules.",
      "th":
          "ประเภท MBTI กับฟังก์ชันที่โดดเด่นค่อนข้างสอดคล้องกัน — เป็นแนวโน้ม ไม่ใช่กฎตายตัว",
    },

    "mbti_sum_align_partial": {
      "en":
          "Some cognitive strengths match your type; others may reflect context, growth, or how you adapt day to day.",
      "th":
          "ฟังก์ชันบางอย่างเข้ากับประเภทของคุณ บางอย่างอาจสะท้อนบทบาทหรือบริบทที่คุณปรับตัว",
    },

    "mbti_sum_align_mixed": {
      "en":
          "Parts of your results differ. You may be using roles or environments that draw on skills outside your usual comfort zone.",
      "th":
          "ผลลัพธ์บางส่วนต่างกัน คุณอาจกำลังใช้บทบาทหรือสภาพแวดล้อมที่ต้องคิดต่างจากธรรมชาติเดิม",
    },

    "mbti_sum_section_profile": {
      "en": "Type & functions",
      "th": "ประเภทกับฟังก์ชัน",
    },

    "mbti_sum_section_decide": {
      "en": "How you think and decide",
      "th": "คุณคิดและตัดสินใจแบบไหน",
    },

    "mbti_sum_think_anchor_primary": {
      "en": "How you tend to think",
      "th": "วิธีที่คุณมักใช้คิด",
    },

    "mbti_sum_think_anchor_secondary": {
      "en": "When you need to decide",
      "th": "เวลาต้องตัดสินใจ",
    },

    "mbti_sum_section_growth": {
      "en": "Worth noticing",
      "th": "สิ่งที่อาจคุ้มค่าถ้าลองสังเกต",
    },

    "mbti_sum_confidence_strengths_title": {
      "en": "Strengths this blend suggests",
      "th": "จุดแข็งที่ภาพรวมนี้สะท้อน",
    },

    "mbti_sum_confidence_careers_title": {
      "en": "Roles you might explore",
      "th": "บทบาทที่อาจลองพิจารณา",
    },

    "mbti_sum_profile_subtitle_strong": {
      "en": "Highly aligned",
      "th": "สอดคล้องกันสูง",
    },

    "mbti_sum_profile_subtitle_partial": {
      "en": "Partly aligned",
      "th": "สอดคล้องบางส่วน",
    },

    "mbti_sum_profile_subtitle_distinct": {
      "en": "Distinct signature",
      "th": "มีลักษณะเฉพาะตัว",
    },

    "mbti_sum_hero_role_estj_analytical": {
      "en": "The Analytical Executive",
      "th": "ผู้บริหารเชิงวิเคราะห์",
    },

    "mbti_sum_hero_role_estj_vision": {
      "en": "The Strategic Executive",
      "th": "ผู้บริหารเชิงกลยุทธ์",
    },

    "mbti_sum_hero_role_estj": {
      "en": "The Executive",
      "th": "ผู้บริหาร",
    },

    "mbti_sum_hero_role_entj_analytical": {
      "en": "The Analytical Commander",
      "th": "ผู้นำเชิงวิเคราะห์",
    },

    "mbti_sum_hero_role_entj_strategic": {
      "en": "The Strategic Commander",
      "th": "ผู้นำเชิงกลยุทธ์",
    },

    "mbti_sum_hero_role_entj": {
      "en": "The Commander",
      "th": "ผู้นำ",
    },

    "mbti_sum_hero_role_intj_balanced": {
      "en": "The Relational Strategist",
      "th": "นักกลยุทธ์ที่ใส่ใจคน",
    },

    "mbti_sum_hero_role_intj_explorer": {
      "en": "The Open Strategist",
      "th": "นักกลยุทธ์ที่เปิดทางเลือก",
    },

    "mbti_sum_hero_role_intj": {
      "en": "The Architect",
      "th": "นักวางกลยุทธ์",
    },

    "mbti_sum_hero_role_enfp_builder": {
      "en": "The Structured Inspirer",
      "th": "ผู้สร้างแรงบันดาลใจที่มีโครงสร้าง",
    },

    "mbti_sum_hero_role_enfp_grounded": {
      "en": "The Grounded Explorer",
      "th": "นักสำรวจที่ยึดประสบการณ์",
    },

    "mbti_sum_hero_role_enfp": {
      "en": "The Campaigner",
      "th": "ผู้สร้างแรงบันดาลใจ",
    },

    "mbti_sum_hero_role_generic": {
      "en": "Your fusion profile",
      "th": "โปรไฟล์ผสมของคุณ",
    },

    "mbti_sum_hero_syn_estj_te_ti_ni": {
      "en":
          "You often decide in a structured way, while still checking inner logic and the longer view before you conclude.",
      "th":
          "คุณมักตัดสินใจอย่างเป็นระบบ แต่ยังตรวจสอบตรรกะเบื้องลึกและมองภาพระยะยาวก่อนสรุป",
    },

    "mbti_sum_hero_syn_estj_analytical": {
      "en":
          "You tend to organize and execute clearly, with extra room for inner reasoning before you commit.",
      "th":
          "คุณมักจัดระบบและลงมือชัด แต่ยังมีพื้นที่ตรวจสอบเหตุผลภายในก่อนตัดสินใจ",
    },

    "mbti_sum_hero_syn_estj_vision": {
      "en":
          "You often lead with structure, yet may read patterns and futures earlier than a typical ESTJ sketch.",
      "th":
          "คุณมักนำด้วยโครงสร้าง แต่หลายครั้งอ่านแพทเทิร์นและแนวโน้มก่อนต้นแบบ ESTJ ทั่วไป",
    },

    "mbti_sum_hero_syn_estj_default": {
      "en": "You tend to value clarity, order, and follow-through in how you show up.",
      "th": "คุณมักให้ความสำคัญกับความชัดเจน ระเบียบ และการทำให้จบ",
    },

    "mbti_sum_hero_syn_entj_ti": {
      "en": "You drive outcomes, often pausing to stress-test the logic underneath.",
      "th": "คุณมุ่งผลลัพธ์ หลายครั้งหยุดขัดเกลาตรรกะเบื้องลึกก่อนลงมือ",
    },

    "mbti_sum_hero_syn_entj_ni": {
      "en": "You steer with direction and foresight — strategy may sit closer to the front than usual.",
      "th": "คุณขับด้วยทิศทางและการมองล่วงหน้า — กลยุทธ์อาจอยู่ใกล้จุดตัดสินใจมากกว่าปกติ",
    },

    "mbti_sum_hero_syn_entj_default": {
      "en": "You tend to mobilize people and resources toward a clear target.",
      "th": "คุณมักระดมคนและทรัพยากรไปสู่เป้าหมายที่ชัด",
    },

    "mbti_sum_hero_syn_intj_ni": {
      "en": "You often frame the future first, then build only what is needed to get there.",
      "th": "คุณมักวางภาพอนาคตก่อน แล้วค่อยสร้างเฉพาะสิ่งที่จำเป็นให้ไปถึง",
    },

    "mbti_sum_hero_syn_intj_default": {
      "en": "You tend to seek clarity, systems, and a line of sight to the outcome.",
      "th": "คุณมักแสวงหาความชัด ระบบ และเส้นทางไปสู่ผลลัพธ์",
    },

    "mbti_sum_hero_syn_enfp_ti": {
      "en": "You stay open and curious, with a quieter inner check on whether ideas hold up.",
      "th": "คุณเปิดกว้างและอยากรู้ แต่มีการตรวจสอบเบื้องในเบาๆ ว่าไอเดียสมเหตุสมผลหรือไม่",
    },

    "mbti_sum_hero_syn_enfp_default": {
      "en": "You tend to connect ideas, people, and possibility — energy follows what feels alive.",
      "th": "คุณมักเชื่อมไอเดีย คน และความเป็นไปได้ — พลังไปที่สิ่งที่รู้สึกมีชีวิต",
    },

    "mbti_sum_hero_syn_generic": {
      "en": "Your MBTI type and cognitive functions together shape how you tend to decide and act.",
      "th": "ประเภท MBTI และฟังก์ชันการคิดของคุณร่วมกันสร้างแนวทางตัดสินใจและลงมือ",
    },

    "mbti_sum_profile_para_estj_analytical": {
      "en":
          "You still show clear ESTJ traits.\n\nWhat stands out is how often you use analytical thinking (Ti) and long-range framing (Ni) compared with many ESTJ templates.\n\nThat can mean you are not only following a system — you may tend to review and refine it before you act.",
      "th":
          "คุณยังมีลักษณะ ESTJ ชัดเจน\n\nแต่สิ่งที่โดดเด่นคือ คุณใช้การคิดเชิงวิเคราะห์ (Ti) และมองภาพระยะยาว (Ni) มากกว่าต้นแบบทั่วไป\n\nทำให้คุณไม่ได้แค่ “ทำตามระบบ” แต่มีแนวโน้มจะตรวจสอบและปรับปรุงระบบก่อนลงมือ",
    },

    "mbti_sum_profile_para_estj_ni": {
      "en":
          "You carry ESTJ structure in action, while your function mix suggests more trend-reading and future framing than the classic stereotype.",
      "th":
          "คุณยังเป็น ESTJ ในการลงมือ แต่ลายเซ็นฟังก์ชันบอกว่าคุณมักอ่านแนวโน้มและภาพอนาคตมากกว่าต้นแบบทั่วไป",
    },

    "mbti_sum_profile_para_estj_strong": {
      "en": "Your ESTJ traits and cognitive stack seem to reinforce each other in most situations.",
      "th": "ลักษณะ ESTJ และฟังก์ชันการคิดของคุณมักเสริมกันในหลายสถานการณ์",
    },

    "mbti_sum_profile_para_estj_mixed": {
      "en":
          "You still show clear ESTJ patterns, with a personal cognitive accent that bends away from the textbook stack.",
      "th":
          "คุณยังมีรูปแบบ ESTJ ชัด แต่มีลายเซ็นทางความคิดเฉพาะตัวที่เบี่ยงจากต้นแบบ",
    },

    "mbti_sum_profile_para_estj_weak": {
      "en":
          "Your outer ESTJ style and measured functions may reflect context or role as much as type — notice which mode you are in.",
      "th":
          "สไตล์ ESTJ ที่แสดงออกกับฟังก์ชันที่วัดได้อาจสะท้อนบริบทหรือบทบาท — ลองสังเกตว่าคุณอยู่โหมดไหน",
    },

    "mbti_sum_profile_para_entj_ti": {
      "en":
          "You lead like ENTJ, yet inner logic may shape your plans more than many profiles emphasize on the surface.",
      "th":
          "คุณนำแบบ ENTJ แต่ตรรกะภายในอาจมีบทบาทในแผนมากกว่าที่หลายโปรไฟล์มักเน้น",
    },

    "mbti_sum_profile_para_entj_ni": {
      "en":
          "You are decisive and directional, with strategic intuition often weighing in earlier than an operations-first sketch.",
      "th":
          "คุณตัดสินใจและมีทิศทาง โดย Ni เชิงกลยุทธ์มักมีบทบาทเร็วกว่าแพทเทิร์นที่เน้นปฏิบัติการ",
    },

    "mbti_sum_profile_para_entj_default": {
      "en": "You tend to organize momentum toward outcomes — people and resources follow a clear line.",
      "th": "คุณมักจัดจังหวะไปสู่ผลลัพธ์ — คนและทรัพยากรตามเส้นทางที่ชัด",
    },

    "mbti_sum_profile_para_intj_fe": {
      "en":
          "You aim for clarity and systems, while people and tone may matter more in your choices than a classic INTJ sketch.",
      "th":
          "คุณมุ่งความชัดและระบบ แต่คนและบรรยากาศอาจมีน้ำหนักในทางเลือกมากกว่าภาพ INTJ ทั่วไป",
    },

    "mbti_sum_profile_para_intj_ne": {
      "en":
          "You keep INTJ focus, with more openness to alternatives than many INTJ profiles suggest.",
      "th":
          "คุณยังโฟกัสแบบ INTJ แต่เปิดรับทางเลือกมากกว่าที่หลายโปรไฟล์มักแสดง",
    },

    "mbti_sum_profile_para_intj_default": {
      "en": "You tend to connect long-range intent with the systems needed to reach it.",
      "th": "คุณมักเชื่อมเจตนาระยะยาวกับระบบที่พาไปถึง",
    },

    "mbti_sum_profile_para_enfp_te": {
      "en":
          "You radiate ENFP energy, yet structure and outcomes may show up more than stereotypes usually allow.",
      "th":
          "คุณมีพลัง ENFP ชัด แต่โครงสร้างและผลลัพธ์อาจโผล่มากกว่าที่มักเห็นในต้นแบบ",
    },

    "mbti_sum_profile_para_enfp_si": {
      "en":
          "You are exploratory at heart, with more respect for precedent and detail than a classic ENFP pattern.",
      "th":
          "คุณสำรวจในใจ แต่ให้ความสำคัญกับประสบการณ์และรายละเอียดมากกว่า ENFP ต้นแบบ",
    },

    "mbti_sum_profile_para_enfp_default": {
      "en": "You tend to link ideas, people, and possibility — with your own cognitive twist.",
      "th": "คุณมักเชื่อมไอเดีย คน และความเป็นไปได้ — ในแบบเฉพาะตัวของคุณ",
    },

    "mbti_sum_profile_para_fallback_strong": {
      "en": "Your type and cognitive functions seem to point in a similar direction.",
      "th": "ประเภทและฟังก์ชันการคิดของคุณมักไปทางเดียวกัน",
    },

    "mbti_sum_profile_para_fallback_mixed": {
      "en": "You show clear type traits, with some thinking habits that differ from the usual template.",
      "th": "คุณมีลักษณะประเภทชัด แต่มีนิสัยทางความคิดที่ต่างจากต้นแบบบางส่วน",
    },

    "mbti_sum_profile_para_fallback_weak": {
      "en": "Your expressed type and deeper functions may tell different stories — context may explain the gap.",
      "th": "ประเภทที่แสดงออกกับฟังก์ชันเชิงลึกอาจเล่าเรื่องต่างกัน — บริบทอาจอธิบายช่องว่างนี้",
    },

    "mbti_sum_think_pair_estj_plan_h": {
      "en": "Structured, not rigid",
      "th": "คิดเป็นระบบ แต่ไม่ยึดติด",
    },

    "mbti_sum_think_pair_estj_plan_b": {
      "en":
          "You often like a clear plan,\nyet may shift methods when new reasoning looks more sound.",
      "th":
          "คุณมักชอบแผนที่ชัดเจน\nแต่พร้อมเปลี่ยนวิธีเมื่อเหตุผลใหม่ดูสมเหตุสมผลกว่า",
    },

    "mbti_sum_think_pair_estj_vision_h": {
      "en": "Big picture before action",
      "th": "มองภาพก่อนลงมือ",
    },

    "mbti_sum_think_pair_estj_vision_b": {
      "en":
          "Many times you consider longer-term effects\nbefore building something tangible.",
      "th":
          "หลายครั้งคุณจะคิดถึงผลระยะยาว\nก่อนเริ่มสร้างสิ่งที่จับต้องได้จริง",
    },

    "mbti_sum_think_pair_estj_logic_h": {
      "en": "Organize, then scrutinize",
      "th": "จัดระบบ แล้วขัดเกลา",
    },

    "mbti_sum_think_pair_estj_logic_b": {
      "en":
          "You tend to pair outward structure with inner logic — efficiency plus a quiet review loop.",
      "th":
          "คุณมักผสมโครงสร้างภายนอกกับตรรกะภายใน — ทั้งคล่องและมีการทบทวนเบื้องหลัง",
    },

    "mbti_sum_think_pair_entj_drive_h": {
      "en": "Outcome-first drive",
      "th": "ขับด้วยผลลัพธ์",
    },

    "mbti_sum_think_pair_entj_drive_b": {
      "en": "You often aim for a clear target, then align people and resources behind it.",
      "th": "คุณมักตั้งเป้าชัด แล้วจัดคนและทรัพยากรให้ไปทางเดียวกัน",
    },

    "mbti_sum_think_pair_entj_refine_h": {
      "en": "Stress-test before commit",
      "th": "ทดสอบก่อนตัดสินใจ",
    },

    "mbti_sum_think_pair_entj_refine_b": {
      "en": "Inner logic may slow you just enough to avoid a brittle plan.",
      "th": "ตรรกะภายในอาจทำให้ช้าพอที่จะหลีกเลี่ยงแผนที่เปราะ",
    },

    "mbti_sum_think_pair_entj_strategy_h": {
      "en": "Direction plus foresight",
      "th": "ทิศทางพร้อมการมองล่วงหน้า",
    },

    "mbti_sum_think_pair_entj_strategy_b": {
      "en": "You may read the road ahead while still pushing execution forward.",
      "th": "คุณอาจอ่านเส้นทางข้างหน้า ในขณะที่ยังดันการลงมือไปข้างหน้า",
    },

    "mbti_sum_think_pair_intj_fe_h": {
      "en": "Clarity with people in mind",
      "th": "ชัดเจนแต่ใส่ใจคน",
    },

    "mbti_sum_think_pair_intj_fe_b": {
      "en": "Systems still matter, yet tone and relationships may weigh in more than the stereotype.",
      "th": "ระบบยังสำคัญ แต่บรรยากาศและความสัมพันธ์อาจมีน้ำหนักมากกว่าต้นแบบ",
    },

    "mbti_sum_think_pair_intj_vision_h": {
      "en": "Frame the future first",
      "th": "วางภาพอนาคตก่อน",
    },

    "mbti_sum_think_pair_intj_vision_b": {
      "en": "You often sketch where things are going before you invest in build-out.",
      "th": "คุณมักร่างทิศทางก่อนลงทุนสร้างรายละเอียด",
    },

    "mbti_sum_think_pair_intj_detail_h": {
      "en": "Details when they block",
      "th": "รายละเอียดเมื่อมันขวางทาง",
    },

    "mbti_sum_think_pair_intj_detail_b": {
      "en": "Fine print may wait unless it threatens the main line of sight.",
      "th": "รายละเอียดอาจรอ จนกว่าจะขวางเส้นทางหลัก",
    },

    "mbti_sum_think_pair_enfp_open_h": {
      "en": "Open, with an inner check",
      "th": "เปิดกว้าง แต่มีการตรวจภายใน",
    },

    "mbti_sum_think_pair_enfp_open_b": {
      "en":
          "Even when you explore widely, you may still test whether an idea holds up inside.",
      "th":
          "แม้คุณจะสำรวจกว้าง แต่ยังมีแนวโน้มตรวจสอบว่าไอเดียสมเหตุสมผลภายใน",
    },

    "mbti_sum_think_pair_enfp_check_h": {
      "en": "Warmth plus quiet scrutiny",
      "th": "อบอุ่นและขัดเกลาเบาๆ",
    },

    "mbti_sum_think_pair_enfp_check_b": {
      "en": "Curiosity stays up front; a smaller voice may edit before you share.",
      "th": "ความอยากรู่อยู่หน้า ส่วนเสียงขัดเกลาอาจอยู่ก่อนที่คุณจะแชร์",
    },

    "mbti_sum_think_pair_enfp_finish_h": {
      "en": "Ideas, then structure to finish",
      "th": "ไอเดียก่อน โครงสร้างเพื่อจบ",
    },

    "mbti_sum_think_pair_enfp_finish_b": {
      "en": "You may generate freely, then lock deliverables when something needs to land.",
      "th": "คุณอาจสร้างได้เยอะ แล้วล็อกสิ่งที่ต้องส่งเมื่อต้องให้จบ",
    },

    "mbti_sum_think_pair_enfp_explore_h": {
      "en": "Many paths at once",
      "th": "หลายเส้นทางพร้อมกัน",
    },

    "mbti_sum_think_pair_enfp_explore_b": {
      "en": "Energy often follows what feels alive, not only what was planned.",
      "th": "พลังมักไปที่สิ่งที่รู้สึกมีชีวิต ไม่ใช่แค่แผน",
    },

    "mbti_sum_think_theme_logic_h": {
      "en": "Reason-led choices",
      "th": "ตัดสินใจจากเหตุผล",
    },

    "mbti_sum_think_theme_logic_b": {
      "en": "You often lean on logic and structure when stakes are real.",
      "th": "หลายครั้งคุณพึ่งตรรกะและโครงสร้างเมื่อมีเดิมพันจริง",
    },

    "mbti_sum_think_theme_intuition_h": {
      "en": "Read what may come next",
      "th": "อ่านสิ่งที่อาจมาถัดไป",
    },

    "mbti_sum_think_theme_intuition_b": {
      "en": "Possibilities and trends may enter early in your thinking.",
      "th": "ความเป็นไปได้และแนวโน้มอาจเข้ามาเร็วในกระบวนการคิด",
    },

    "mbti_sum_think_theme_feeling_h": {
      "en": "People in the loop",
      "th": "ใส่คนในการตัดสินใจ",
    },

    "mbti_sum_think_theme_feeling_b": {
      "en": "Values and emotional impact may shape what you choose to do.",
      "th": "คุณค่าและผลกระทบทางอารมณ์อาจมีบทบาทในทางเลือก",
    },

    "mbti_sum_think_theme_structure_h": {
      "en": "Prefer clear steps",
      "th": "ชอบขั้นตอนที่ชัด",
    },

    "mbti_sum_think_theme_structure_b": {
      "en": "Predictable systems and outcomes often feel easier to trust.",
      "th": "ระบบและผลลัพธ์ที่คาดได้มักทำให้คุณมั่นใจขึ้น",
    },

    "mbti_sum_think_theme_exploration_h": {
      "en": "Stay open to options",
      "th": "เปิดรับทางเลือก",
    },

    "mbti_sum_think_theme_exploration_b": {
      "en": "You may adapt when a better opening appears.",
      "th": "คุณอาจปรับเมื่อเห็นโอกาสที่ดีกว่า",
    },

    "mbti_sum_growth_pair_estj_pace_h": {
      "en": "When things move fast",
      "th": "สิ่งที่อาจเกิดขึ้นเมื่อคุณรีบ",
    },

    "mbti_sum_growth_pair_estj_pace_b": {
      "en":
          "When a direction feels clear, you may move on quickly. You might notice others still need a moment to catch up or share how they see it.",
      "th":
          "บางครั้งเมื่อทิศทางดูชัด คุณอาจไปต่อเร็ว — คุณอาจสังเกตว่าคนอื่นยังต้องการเวลาสักครู่เพื่อตามทันหรือเล่ามุมมองของตัวเอง",
    },

    "mbti_sum_growth_pair_estj_listen_h": {
      "en": "A quieter need",
      "th": "ความต้องการที่เงียบกว่า",
    },

    "mbti_sum_growth_pair_estj_listen_b": {
      "en":
          "In some moments, the other person may need to feel understood more than the sharpest answer right away.",
      "th":
          "ในบางสถานการณ์ อีกฝ่ายอาจต้องการความเข้าใจมากกว่าคำตอบที่ดีที่สุดในทันที",
    },

    "mbti_sum_growth_pair_estj_pace_others_h": {
      "en": "Bringing others in",
      "th": "การพาคนอื่นเข้ามาในภาพ",
    },

    "mbti_sum_growth_pair_estj_pace_others_b": {
      "en":
          "When you read trends early, how you share the picture over time may shape how aligned others feel.",
      "th":
          "เมื่อคุณอ่านแนวโน้มเร็ว จังหวะที่คุณเล่าภาพให้คนอื่นฟังอาจสะท้อนว่าทีมรู้สึกสอดคล้องกันแค่ไหน",
    },

    "mbti_sum_growth_pair_entj_control_h": {
      "en": "Under pressure",
      "th": "เมื่อมีแรงกดดัน",
    },

    "mbti_sum_growth_pair_entj_control_b": {
      "en":
          "When stakes rise, you may hold the direction tighter. A pause might reveal whether speed is trading away shared ownership.",
      "th":
          "เมื่อเดิมพันสูง คุณอาจเกาะทิศทางแน่ขึ้น — บางครั้งการหยุดสักครู่อาจทำให้เห็นว่าความเร็วแลกกับการร่วมมือหรือไม่",
    },

    "mbti_sum_growth_pair_entj_constraint_h": {
      "en": "Future and today",
      "th": "อนาคตกับวันนี้",
    },

    "mbti_sum_growth_pair_entj_constraint_b": {
      "en":
          "A vivid future picture can be powerful. One near-term limit in view may keep the plan feeling close to what is happening now.",
      "th":
          "ภาพอนาคตที่ชัดมีพลัง — การมองข้อจำกัดระยะสั้นหนึ่งอย่างอาจทำให้แผนรู้สึกใกล้กับสิ่งที่เกิดขึ้นตอนนี้",
    },

    "mbti_sum_growth_pair_intj_big_picture_h": {
      "en": "The wide view",
      "th": "มุมมองกว้าง",
    },

    "mbti_sum_growth_pair_intj_big_picture_b": {
      "en":
          "You may see the arc very clearly. One detail that could block progress, if missed, sometimes sits quieter than the vision.",
      "th":
          "คุณอาจมองเส้นทางได้ชัดมาก — รายละเอียดหนึ่งอย่างที่ถ้าพลาดแล้วอาจขวางการไปต่อ บางครั้งอยู่เบากว่าภาพใหญ่",
    },

    "mbti_sum_growth_pair_intj_checkpoint_h": {
      "en": "A small anchor",
      "th": "จุดยึดเล็กๆ",
    },

    "mbti_sum_growth_pair_intj_checkpoint_b": {
      "en":
          "A verifiable step before moving on may reduce rework — without necessarily slowing the longer view.",
      "th":
          "ขั้นที่พิสูจน์ได้หนึ่งขั้นก่อนไปต่อ อาจลดงานย้อน — โดยไม่จำเป็นต้องชะลอวิสัยทัศน์ระยะยาว",
    },

    "mbti_sum_growth_pair_intj_feedback_h": {
      "en": "When tone weighs in",
      "th": "เมื่อบรรยากาศมีน้ำหนัก",
    },

    "mbti_sum_growth_pair_intj_feedback_b": {
      "en":
          "If harmony is on your mind, a clear and gentle line may land differently than waiting for the perfect moment.",
      "th":
          "ถ้าคุณใส่ใจบรรยากาศ ประโยคที่ตรงและนุ่มอาจสะท้อนต่างจากการรอจังหวะที่สมบูรณ์แบบ",
    },

    "mbti_sum_growth_pair_enfp_many_paths_h": {
      "en": "Many paths open",
      "th": "เมื่อมีหลายทางเปิด",
    },

    "mbti_sum_growth_pair_enfp_many_paths_b": {
      "en":
          "When several paths look good, choosing may slow down — or shifts of mind may arrive faster than you expected.",
      "th":
          "เมื่อมีหลายทางที่ดูดี การเลือกอาจช้าลง — หรือการเปลี่ยนใจอาจมาเร็วกว่าที่คุณคาด",
    },

    "mbti_sum_growth_pair_enfp_good_enough_h": {
      "en": "Enough for now",
      "th": "พอสำหรับตอนนี้",
    },

    "mbti_sum_growth_pair_enfp_good_enough_b": {
      "en":
          "One workable choice for now can leave room to revisit later — curiosity does not have to close.",
      "th":
          "ทางเลือกหนึ่งอย่างที่ใช้ได้ตอนนี้อาจเปิดพื้นที่ให้กลับมาทบทวนทีหลัง — ความอยากรู่อาจยังไม่ต้องจบ",
    },

    "mbti_sum_growth_pair_enfp_inner_critic_h": {
      "en": "Inner voice",
      "th": "เสียงภายใน",
    },

    "mbti_sum_growth_pair_enfp_inner_critic_b": {
      "en":
          "A quiet inner check can slow the flow of ideas. Space to explore before judging may be part of how you stay open.",
      "th":
          "การตรวจสอบเบื้องในอาจทำให้ไอเดียไหลช้าลง — พื้นที่สำหรับสำรวจก่อนตัดสินอาจเป็นส่วนหนึ่งของการเปิดรับของคุณ",
    },

    "mbti_sum_growth_pair_fallback_strong_h": {
      "en": "What already works",
      "th": "สิ่งที่เวิร์กอยู่แล้ว",
    },

    "mbti_sum_growth_pair_fallback_strong_b": {
      "en":
          "What aligns may keep showing up for you. A small pause for people and feelings can sometimes add balance.",
      "th":
          "สิ่งที่สอดคล้องอาจยังโผล่มาในชีวิตคุณ — การเผื่อเวลาให้คนและความรู้สึกบ้าง บางครั้งอาจเพิ่มความสมดุล",
    },

    "mbti_sum_growth_pair_fallback_mixed_h": {
      "en": "Switching modes",
      "th": "เมื่อสลับโหมด",
    },

    "mbti_sum_growth_pair_fallback_mixed_b": {
      "en":
          "You may move between familiar type patterns and your own habits. Noticing which mode you are in can make the moment clearer.",
      "th":
          "คุณอาจสลับระหว่างแพทเทิร์นที่คุ้นเคยกับนิสัยของตัวเอง — การสังเกตว่าตอนนี้อยู่โหมดไหนอาจทำให้ช่วงนั้นชัดขึ้น",
    },

    "mbti_sum_growth_pair_fallback_weak_h": {
      "en": "As tendencies",
      "th": "มองเป็นแนวโน้ม",
    },

    "mbti_sum_growth_pair_fallback_weak_b": {
      "en":
          "Different contexts may bring out different sides of you. One label may not need to cover every situation.",
      "th":
          "บริบทต่างๆ อาจดึงด้านต่างๆ ของคุณออกมา — ป้ายเดียวอาจไม่ต้องครอบคลุมทุกสถานการณ์",
    },

    "mbti_sum_strength_logic": {
      "en": "Turn reasoning into workable plans",
      "th": "เปลี่ยนภาพใหญ่ให้เป็นแผนลงมือทำได้",
    },

    "mbti_sum_strength_intuition": {
      "en": "Spot patterns and futures early",
      "th": "มองแนวโน้มและภาพล่วงหน้าได้เร็ว",
    },

    "mbti_sum_strength_structure": {
      "en": "Decide well on logic and structure",
      "th": "ตัดสินใจบนเหตุผลและโครงสร้างได้ดี",
    },

    "mbti_sum_strength_exploration": {
      "en": "Adapt when better options appear",
      "th": "ปรับตัวเมื่อมีทางเลือกที่ดีกว่า",
    },

    "mbti_sum_strength_people": {
      "en": "Weigh people and values in choices",
      "th": "ใส่คนและคุณค่าในการตัดสินใจ",
    },

    "mbti_sum_strength_balanced": {
      "en": "Blend several thinking styles as needed",
      "th": "ผสมหลายสไตล์ความคิดตามบริบท",
    },

    "mbti_sum_career_hint_operations": {
      "en": "Operations / program leadership",
      "th": "งานปฏิบัติการ / ผู้นำโครงการ",
    },

    "mbti_sum_career_hint_strategy": {
      "en": "Strategy / product direction",
      "th": "งานกลยุทธ์ / ทิศทางผลิตภัณฑ์",
    },

    "mbti_sum_career_hint_planning": {
      "en": "Planning / analysis roles",
      "th": "งานวางแผน / วิเคราะห์",
    },

    "mbti_sum_career_hint_innovation": {
      "en": "Innovation / venture building",
      "th": "งานนวัตกรรม / สร้างธุรกิจใหม่",
    },

    "mbti_sum_insight_align_strong_title": {
      "en": "Highly aligned",
      "th": "สอดคล้องกันสูง",
    },

    "mbti_sum_insight_align_strong_b1": {
      "en": "Your cognitive functions align closely with this MBTI type.",
      "th": "ฟังก์ชันการคิดของคุณสอดคล้องกับ MBTI ค่อนข้างมาก",
    },

    "mbti_sum_insight_align_strong_b2": {
      "en": "How you think and how you show up tend to point the same way.",
      "th": "วิธีคิดและบุคลิกที่แสดงออกไปทางเดียวกัน",
    },

    "mbti_sum_insight_align_mixed_title": {
      "en": "Partly aligned, partly different",
      "th": "มีทั้งส่วนที่ตรงและต่าง",
    },

    "mbti_sum_insight_align_mixed_b1": {
      "en": "You still show clear traits of this MBTI type.",
      "th": "คุณยังมีลักษณะของ MBTI นี้ชัดเจน",
    },

    "mbti_sum_insight_align_mixed_b2": {
      "en": "Some thinking patterns differ from the usual template for this type.",
      "th": "แต่มีรูปแบบการคิดบางส่วนที่แตกต่างจากต้นแบบ",
    },

    "mbti_sum_insight_align_weak_title": {
      "en": "Interesting differences",
      "th": "มีความแตกต่างที่น่าสนใจ",
    },

    "mbti_sum_insight_align_weak_b1": {
      "en": "Your expressed personality and deeper thinking may not match entirely.",
      "th": "บุคลิกที่คุณแสดงออกและวิธีคิดเชิงลึกอาจยังไม่ตรงทั้งหมด",
    },

    "mbti_sum_insight_align_weak_b2": {
      "en": "This may reflect your role, environment, or life experience.",
      "th": "อาจสะท้อนบทบาทงาน สภาพแวดล้อม หรือประสบการณ์ชีวิต",
    },

    "mbti_sum_profile_syn_estj_analytical": {
      "en":
          "You still read clearly as ESTJ, but with a stronger analytical streak than the usual template — leaning on inner logic alongside organizing and executing.",
      "th":
          "คุณยังมีลักษณะ ESTJ ชัดเจน แต่มีแนว analytical สูงกว่าต้นแบบทั่วไป และใช้ตรรกะภายในร่วมกับการจัดระบบมากขึ้น",
    },

    "mbti_sum_profile_syn_estj_analytical_strong": {
      "en":
          "Your ESTJ type and Te-led stack line up well — with extra inner logic (Ti) shaping how you refine decisions.",
      "th":
          "คุณเป็น ESTJ ที่สอดคล้องกับต้นแบบค่อนข้างมาก — และมี Ti ช่วยขัดเกลาเหตุผลก่อนลงมือ",
    },

    "mbti_sum_profile_syn_estj_ni_vision": {
      "en":
          "You show as ESTJ in action, yet your top functions suggest more big-picture and trend-reading than a classic ESTJ stereotype.",
      "th":
          "คุณยังเป็น ESTJ ในพฤติกรรม แต่ฟังก์ชันเด่นบอกว่าคุณมองภาพรวมและแนวโน้มมากกว่า ESTJ ทั่วไป",
    },

    "mbti_sum_profile_syn_estj_strong": {
      "en": "Your expressed ESTJ style and cognitive stack point the same way — structure, execution, and clarity first.",
      "th": "บุคลิก ESTJ และฟังก์ชันการคิดของคุณไปทางเดียวกัน — โครงสร้าง การลงมือ และความชัดเจนมาก่อน",
    },

    "mbti_sum_profile_syn_estj_mixed": {
      "en": "You carry clear ESTJ traits, with a few thinking habits that bend away from the textbook stack.",
      "th": "คุณยังมีลักษณะ ESTJ ชัดเจน แต่มีนิสัยทางความคิดบางส่วนที่เบี่ยงจากต้นแบบ",
    },

    "mbti_sum_profile_syn_estj_weak": {
      "en":
          "Your outer ESTJ presentation and inner cognitive pattern may reflect role or context as much as type — worth noticing which mode you are in.",
      "th":
          "บุคลิก ESTJ ที่แสดงออกกับรูปแบบความคิดเชิงลึกอาจสะท้อนบทบาทหรือบริบท — ลองสังเกตว่าคุณอยู่โหมดไหน",
    },

    "mbti_sum_profile_syn_entj_ti": {
      "en":
          "You lead like ENTJ, but inner logic (Ti) may shape plans more than many ENTJ profiles show on the surface.",
      "th":
          "คุณขับเคลื่อนแบบ ENTJ แต่ตรรกะภายใน (Ti) อาจมีบทบาทมากกว่าที่หลายโปรไฟล์ ENTJ มักแสดง",
    },

    "mbti_sum_profile_syn_entj_ni": {
      "en":
          "You are ENTJ in drive, with strategic intuition (Ni) weighing in earlier than the usual operations-first pattern.",
      "th":
          "คุณเป็น ENTJ ที่ขับเคลื่อนชัด แต่ Ni เชิงกลยุทธ์มีบทบาทเร็วกว่าแพทเทิร์นที่เน้นปฏิบัติการทั่วไป",
    },

    "mbti_sum_profile_syn_entj_strong": {
      "en": "Your ENTJ presence and Te–Ni stack align closely — decisive direction with strategic follow-through.",
      "th": "บุคลิก ENTJ และสแต็ก Te–Ni ของคุณสอดคล้องกัน — มุ่งเป้าและติดตามเชิงกลยุทธ์",
    },

    "mbti_sum_profile_syn_entj_mixed": {
      "en": "You read as ENTJ, with some cognitive accents that differ from the classic commander template.",
      "th": "คุณเป็น ENTJ ชัด แต่มีลายเซ็นทางความคิดที่ต่างจากต้นแบบคลาสสิก",
    },

    "mbti_sum_profile_syn_entj_weak": {
      "en": "Your ENTJ label and function ranking may tell different stories — context may explain the gap.",
      "th": "ประเภท ENTJ กับลำดับฟังก์ชันอาจเล่าเรื่องต่างกัน — บริบทอาจอธิบายช่องว่างนี้",
    },

    "mbti_sum_profile_syn_intj_fe": {
      "en":
          "You present as INTJ in focus and standards, yet people and harmony (Fe) may matter more in your choices than the usual template.",
      "th":
          "คุณเป็น INTJ ที่โฟกัสและมีมาตรฐาน แต่คนและบรรยากาศ (Fe) อาจมีน้ำหนักในทางเลือกมากกว่าต้นแบบทั่วไป",
    },

    "mbti_sum_profile_syn_intj_ne": {
      "en":
          "You are INTJ at core, with more openness to alternatives (Ne) than many INTJ profiles suggest.",
      "th":
          "คุณเป็น INTJ แก่น แต่เปิดรับทางเลือก (Ne) มากกว่าที่หลายโปรไฟล์ INTJ มักแสดง",
    },

    "mbti_sum_profile_syn_intj_strong": {
      "en": "Your INTJ type and Ni–Te stack reinforce each other — vision, systems, and follow-through in one line.",
      "th": "คุณเป็น INTJ ที่สแต็ก Ni–Te สอดคล้อง — ภาพใหญ่ ระบบ และการลงมือในทิศทางเดียวกัน",
    },

    "mbti_sum_profile_syn_intj_mixed": {
      "en": "You show INTJ depth, with a personal cognitive mix that is not a carbon copy of the textbook stack.",
      "th": "คุณมีความลึกแบบ INTJ แต่ผสมฟังก์ชันในแบบที่ไม่ใช่สำเนาต้นแบบ",
    },

    "mbti_sum_profile_syn_intj_weak": {
      "en": "Your INTJ identity and measured functions may diverge — life role can pull either side forward.",
      "th": "ตัวตน INTJ กับฟังก์ชันที่วัดได้อาจแยกกัน — บทบาทชีวิตอาจดึงด้านใดด้านหนึ่งขึ้นมา",
    },

    "mbti_sum_profile_syn_enfp_te": {
      "en":
          "You radiate ENFP energy, yet structure and outcomes (Te) show up more than stereotypes usually allow.",
      "th":
          "คุณมีพลัง ENFP ชัด แต่โครงสร้างและผลลัพธ์ (Te) โผล่มากกว่าที่มักเห็นในต้นแบบ",
    },

    "mbti_sum_profile_syn_enfp_si": {
      "en":
          "You are ENFP in spirit, with more respect for precedent and detail (Si) than the classic explorer pattern.",
      "th":
          "คุณเป็น ENFP ในจิตใจ แต่ให้ความสำคัญกับประสบการณ์และรายละเอียด (Si) มากกว่า ENFP ต้นแบบ",
    },

    "mbti_sum_profile_syn_enfp_strong": {
      "en": "Your ENFP warmth and Ne–Fi stack line up — ideas, people, and values in sync.",
      "th": "ความอบอุ่น ENFP และสแต็ก Ne–Fi ของคุณไปด้วยกัน — ไอเดีย คน และคุณค่า",
    },

    "mbti_sum_profile_syn_enfp_mixed": {
      "en": "You are recognizably ENFP, with a cognitive signature that adds its own twist.",
      "th": "คุณเป็น ENFP ที่จำได้ชัด แต่มีลายเซ็นทางความคิดเฉพาะตัว",
    },

    "mbti_sum_profile_syn_enfp_weak": {
      "en": "Your ENFP style and function ranking may not fully match — notice when you lead with ideas vs. structure.",
      "th": "สไตล์ ENFP กับลำดับฟังก์ชันอาจไม่ตรงกันทั้งหมด — สังเกตเมื่อคุณนำด้วยไอเดียหรือโครงสร้าง",
    },

    "mbti_sum_think_combo_estj_te_ti_ni_b1": {
      "en":
          "You often decide in a structured way — but not only by following steps.",
      "th":
          "คุณมักตัดสินใจแบบเป็นระบบ แต่ไม่ได้ยึดขั้นตอนเพียงอย่างเดียว",
    },

    "mbti_sum_think_combo_estj_te_ti_ni_b2": {
      "en":
          "You like to pressure-test reasons inside, then zoom out to the big picture before you conclude.",
      "th":
          "คุณยังชอบวิเคราะห์เหตุผลภายใน และมองภาพรวมก่อนสรุป",
    },

    "mbti_sum_think_combo_estj_logic": {
      "en":
          "You pair outward organizing (Te) with inner logic (Ti) — efficiency plus scrutiny.",
      "th":
          "คุณผสมการจัดระบบภายนอก (Te) กับตรรกะภายใน (Ti) — ทั้งคล่องและขัดเกลา",
    },

    "mbti_sum_think_combo_entj_te_ti_b1": {
      "en": "You drive toward outcomes, then refine with inner logic before you commit.",
      "th": "คุณมุ่งผลลัพธ์ก่อน แล้วใช้ตรรกะภายในขัดเกลาก่อนตัดสินใจ",
    },

    "mbti_sum_think_combo_entj_te_ti_b2": {
      "en": "Strategy and execution stay linked — you rarely accept a plan you have not stress-tested.",
      "th": "กลยุทธ์กับการลงมือไปด้วยกัน — คุณไม่ค่อยยอมแผนที่ยังไม่ได้ทดสอบ",
    },

    "mbti_sum_think_combo_entj_ni": {
      "en":
          "You steer with Te and read the road ahead with Ni — direction plus foresight.",
      "th":
          "คุณขับด้วย Te และอ่านเส้นทางข้างหน้าด้วย Ni — ทิศทางพร้อมการมองล่วงหน้า",
    },

    "mbti_sum_think_combo_intj_fe": {
      "en":
          "You still aim for clarity and systems, but people and tone may weigh in more than a classic INTJ sketch.",
      "th":
          "คุณยังมุ่งความชัดและระบบ แต่คนและบรรยากาศอาจมีน้ำหนักมากกว่าภาพ INTJ ทั่วไป",
    },

    "mbti_sum_think_combo_intj_ni_b1": {
      "en": "You tend to frame the future first, then build the minimum structure to get there.",
      "th": "คุณมักวางภาพอนาคตก่อน แล้วค่อยสร้างโครงสร้างขั้นต่ำให้ไปถึง",
    },

    "mbti_sum_think_combo_intj_ni_b2": {
      "en": "Details matter when they block the vision — otherwise you may delegate or defer them.",
      "th": "รายละเอียดสำคัญเมื่อขวางวิสัยทัศน์ — นอกนั้นคุณอาจมอบหมายหรือเลื่อนไว้",
    },

    "mbti_sum_think_combo_enfp_ti_b1": {
      "en":
          "Even when you stay open and exploratory, you may still pressure-test ideas with inner logic.",
      "th":
          "แม้คุณจะเปิดกว้างและชอบสำรวจ แต่คุณยังมีแนวโน้มตรวจสอบเหตุผลภายในมากกว่า ENFP ทั่วไป",
    },

    "mbti_sum_think_combo_enfp_ti_b2": {
      "en": "Warmth and curiosity stay — with a quieter editor in the background.",
      "th": "ความอบอุ่นและความอยากรู้อยู่ — แต่มีเสียงขัดเกลาเบาๆ อยู่เบื้องหลัง",
    },

    "mbti_sum_think_combo_enfp_te": {
      "en":
          "You generate options freely, then sometimes lock onto structure and deliverables to finish.",
      "th":
          "คุณสร้างทางเลือกได้เยอะ แล้วบางครั้งล็อกโครงสร้างและสิ่งที่ต้องส่งให้จบ",
    },

    "mbti_sum_think_combo_enfp_explore": {
      "en":
          "You scan many paths at once — energy goes to what feels alive, not only what is planned.",
      "th":
          "คุณมองหลายเส้นทางพร้อมกัน — พลังไปที่สิ่งที่รู้สึกมีชีวิต ไม่ใช่แค่แผน",
    },

    "mbti_sum_growth_estj_logic_b1": {
      "en":
          "You may trust logic or systems so much that you decide quickly — or expect others to think in systems like you.",
      "th":
          "คุณอาจมั่นใจในเหตุผลหรือระบบมาก จนตัดสินใจเร็วเกินไป หรือคาดหวังให้คนอื่นคิดเป็นระบบเหมือนคุณ",
    },

    "mbti_sum_growth_estj_logic_b2": {
      "en":
          "Before you push a plan through, it may help to ask what others need to feel heard — not only what is efficient.",
      "th":
          "ก่อนดันทางแผน อาจช่วยถามว่าคนอื่นต้องการรู้สึกถูกรับฟังอะไร — ไม่ใช่แค่สิ่งที่มีประสิทธิภาพ",
    },

    "mbti_sum_growth_estj_vision": {
      "en":
          "When you read trends early, others may still be on yesterday's facts — pace how you bring them along.",
      "th":
          "เมื่อคุณอ่านแนวโน้มเร็ว คนอื่นอาจยังยึดข้อมูลเก่า — ลองปรับจังหวะพาเขามาด้วย",
    },

    "mbti_sum_growth_entj_logic": {
      "en":
          "Under pressure you may tighten control — pause to check whether speed is costing buy-in.",
      "th":
          "เมื่อกดดัน คุณอาจเกาะการควบคุม — หยุดเช็คว่าความเร็วแลกกับการร่วมมือหรือไม่",
    },

    "mbti_sum_growth_entj_vision": {
      "en":
          "A strong future picture can skip today's constraints — name one near-term constraint before you scale.",
      "th":
          "ภาพอนาคตที่แรงอาจข้ามข้อจำกัดวันนี้ — ลองระบุข้อจำกัดระยะสั้นหนึ่งอย่างก่อนขยาย",
    },

    "mbti_sum_growth_intj_intuition_b1": {
      "en":
          "You may see the big picture very well — yet sometimes skip details that still matter.",
      "th":
          "คุณอาจมองภาพใหญ่ได้ดีมาก แต่บางครั้งอาจข้ามรายละเอียดสำคัญ",
    },

    "mbti_sum_growth_intj_intuition_b2": {
      "en":
          "Pick one concrete checkpoint before you move on — it can save rework later.",
      "th":
          "เลือกจุดตรวจสอบที่จับต้องได้หนึ่งจุดก่อนไปต่อ — อาจลดงานย้อนกลับ",
    },

    "mbti_sum_growth_intj_fe": {
      "en":
          "When you weigh harmony, you might soften feedback — practice one clear, kind sentence instead of avoiding it.",
      "th":
          "เมื่อคุณใส่ใจบรรยากาศ อาจทำให้ฟีดแบ็กนุ่มเกิน — ลองประโยคชัดและใจดีหนึ่งประโยคแทนการเลี่ยง",
    },

    "mbti_sum_growth_enfp_explore_b1": {
      "en":
          "You may see many openings — which can make decisions slow or shifts quick.",
      "th":
          "คุณอาจเห็นโอกาสหลายทาง จนตัดสินใจยากหรือเปลี่ยนใจเร็ว",
    },

    "mbti_sum_growth_enfp_explore_b2": {
      "en":
          "Try naming one 'good enough for now' choice — you can revisit without losing curiosity.",
      "th":
          "ลองตั้งทางเลือก 'พอใช้ได้ตอนนี้' หนึ่งอย่าง — คุณกลับมาทบทวนได้โดยไม่เสียความอยากรู้",
    },

    "mbti_sum_growth_enfp_ti": {
      "en":
          "Your inner critic can stall brainstorming — set a time box to explore before you judge.",
      "th":
          "เสียงวิจารณ์ภายในอาจหยุดการระดมไอเดีย — กำหนดเวลาสำรวจก่อนตัดสิน",
    },

    "mbti_sum_insight_profile_lead_estj": {
      "en":
          "You come across as {type} with a strong {functions} cognitive signature — often more analytical than a typical {type}.",
      "th":
          "คุณเป็น {type} ที่มีลายเซ็นฟังก์ชัน {functions} ชัดเจน — มักมีแนว analytical สูงกว่า {type} ทั่วไป",
    },

    "mbti_sum_insight_profile_lead_entj": {
      "en":
          "You read as {type} led by {functions} — decisive structure with room for strategic depth.",
      "th":
          "คุณเป็น {type} ที่ขับเคลื่อนด้วย {functions} — โครงสร้างชัดแต่ยังมีมิติเชิงกลยุทธ์",
    },

    "mbti_sum_insight_profile_lead_intj": {
      "en":
          "You present as {type} with {functions} in front — vision-first, with your own relational nuances.",
      "th":
          "คุณเป็น {type} ที่ {functions} โดดเด่น — มองภาพใหญ่ก่อน และมีมิติความสัมพันธ์เฉพาะตัว",
    },

    "mbti_sum_insight_profile_lead_enfp": {
      "en":
          "You show as {type} with {functions} — ideas and people first, sometimes with unexpected structure.",
      "th":
          "คุณเป็น {type} ที่ {functions} โดดเด่น — ไอเดียและคนมาก่อน บางครั้งมีโครงสร้างที่ไม่คาดคิด",
    },

    "mbti_sum_insight_profile_lead_generic": {
      "en": "You combine {type} with dominant {functions} in how you decide and act.",
      "th": "คุณผสม {type} กับฟังก์ชันเด่น {functions} ในการตัดสินใจและลงมือทำ",
    },

    "mbti_sum_outlier_estj_analytical": {
      "en": "You lean more analytical (Ti) than a typical ESTJ template (Si second).",
      "th": "คุณมีแนว analytical (Ti) มากกว่า ESTJ ทั่วไป (ที่มักเน้น Si รอง)",
    },

    "mbti_sum_outlier_estj_ni_vision": {
      "en": "You see big-picture patterns and futures more than a classic ESTJ stereotype.",
      "th": "คุณมองภาพรวมและแนวโน้มมากกว่าต้นแบบ ESTJ ทั่วไป",
    },

    "mbti_sum_outlier_entj_ti_analytical": {
      "en": "You refine ideas with inner logic (Ti) more than many ENTJ profiles emphasize.",
      "th": "คุณขัดเกลาไอเดียด้วยตรรกะภายใน (Ti) มากกว่า ENTJ ทั่วไป",
    },

    "mbti_sum_outlier_entj_ni_strategic": {
      "en": "Strategic intuition (Ni) may lead more than the usual ENTJ operations focus.",
      "th": "สัญชาตญาณเชิงกลยุทธ์ (Ni) อาจนำมากกว่าโฟกัสปฏิบัติการแบบ ENTJ ทั่วไป",
    },

    "mbti_sum_outlier_intj_fe": {
      "en": "You may weigh people and harmony (Fe) more than a typical INTJ template.",
      "th": "คุณอาจใส่ใจมุมมองหรือความรู้สึกของคนมากกว่าต้นแบบ INTJ ทั่วไป",
    },

    "mbti_sum_outlier_intj_ne": {
      "en": "You explore alternatives (Ne) more openly than many INTJ profiles suggest.",
      "th": "คุณเปิดรับทางเลือก (Ne) มากกว่าที่หลายโปรไฟล์ INTJ มักแสดง",
    },

    "mbti_sum_outlier_enfp_te": {
      "en": "You use structure and outcomes (Te) more than many ENFP stereotypes allow.",
      "th": "คุณใช้โครงสร้างและผลลัพธ์ (Te) มากกว่าที่มักเห็นใน ENFP ทั่วไป",
    },

    "mbti_sum_outlier_enfp_si": {
      "en": "You value precedent and detail (Si) more than a classic ENFP pattern.",
      "th": "คุณให้ความสำคัญกับประสบการณ์และรายละเอียด (Si) มากกว่า ENFP ต้นแบบ",
    },

    "mbti_sum_insight_thinking_title": {
      "en": "How you tend to decide",
      "th": "แนวทางการคิดที่โดดเด่น",
    },

    "mbti_sum_insight_theme_logic": {
      "en": "You tend to decide with logic and structure first.",
      "th": "คุณตัดสินใจโดยใช้ตรรกะและโครงสร้างเป็นหลัก",
    },

    "mbti_sum_insight_theme_intuition": {
      "en": "You often read the big picture, possibilities, or what may come next.",
      "th": "คุณมักมองภาพใหญ่ ความเป็นไปได้ หรือแนวโน้มล่วงหน้า",
    },

    "mbti_sum_insight_theme_feeling": {
      "en": "You weigh people, values, or emotional impact in your choices.",
      "th": "คุณให้ความสำคัญกับคน คุณค่า หรือผลกระทบทางอารมณ์",
    },

    "mbti_sum_insight_theme_structure": {
      "en": "You prefer clear systems, steps, and predictable outcomes.",
      "th": "คุณชอบระบบที่ชัดเจน ขั้นตอน และผลลัพธ์ที่คาดการณ์ได้",
    },

    "mbti_sum_insight_theme_exploration": {
      "en": "You stay open to new options, experiments, or adapting to opportunity.",
      "th": "คุณเปิดรับทางเลือกใหม่ ทดลอง หรือปรับตัวกับโอกาส",
    },

    "mbti_sum_insight_growth_outlier": {
      "en":
          "Lean into your atypical strengths — they may be assets, not noise — while checking blind spots they create.",
      "th":
          "ใช้จุดแข็งที่แตกต่างจากต้นแบบให้เป็นประโยชน์ — และสังเกตจุดบอดที่อาจตามมา",
    },

    "mbti_sum_insight_growth_strong": {
      "en": "Keep doing what aligns type and functions; add deliberate pauses for people and feelings.",
      "th": "ทำต่อในสิ่งที่สอดคล้องกับประเภทและฟังก์ชัน — และเผื่อเวลาให้คนและความรู้สึก",
    },

    "mbti_sum_insight_growth_mixed": {
      "en": "Notice when you switch between template traits and your own cognitive habits.",
      "th": "สังเกตเมื่อคุณสลับระหว่างลักษณะต้นแบบกับนิสัยทางความคิดของตัวเอง",
    },

    "mbti_sum_insight_growth_weak": {
      "en": "Treat results as tendencies; experiment with contexts where each strength helps most.",
      "th": "มองผลเป็นแนวโน้ม — ลองบริบทที่แต่ละจุดแข็งช่วยได้มากที่สุด",
    },

    "mbti_sum_think_section_title": {
      "en": "How you tend to think",
      "th": "คุณมักคิดและทำงานแบบไหน",
    },

    "mbti_sum_think_lead": {
      "en": "From your top cognitive functions, you often:",
      "th": "จากฟังก์ชันที่โดดเด่น คุณมัก:",
    },

    "mbti_sum_confidence_title": {
      "en": "Summary confidence",
      "th": "ความมั่นใจของภาพรวม",
    },

    "mbti_sum_confidence_detail": {
      "en": "Based on MBTI ({mbti} questions) and Cognitive ({cognitive} questions).",
      "th": "จาก MBTI ({mbti} ข้อ) และ Cognitive ({cognitive} ข้อ)",
    },

    "mbti_sum_growth_title": {
      "en": "Gentle reflection",
      "th": "มุมมองที่อาจช่วยได้",
    },

    "mbti_sum_caution_logic_blindspot": {
      "en":
          "You may lean on logic and structure so much that emotions or others' needs get less attention than you intend.",
      "th":
          "คุณอาจให้น้ำหนักตรรกะและระบบมาก จนอารมณ์หรือความต้องการของคนอื่นถูกมองข้ามโดยไม่ตั้งใจ",
    },

    "mbti_sum_caution_logic_over_feeling": {
      "en":
          "Your type suggests a feeling-oriented style, but your functions show strong logic — you might be balancing heart and structure in different settings.",
      "th":
          "ประเภทของคุณเน้นความรู้สึก แต่ฟังก์ชันโดดเด่นด้านตรรกะ — อาจสะท้อนการปรับหัวใจกับระบบตามบริบท",
    },

    "mbti_sum_caution_intuition_vs_type": {
      "en":
          "You may explore ideas and possibilities even when your type label suggests a more practical baseline.",
      "th":
          "คุณอาจมองไอเดียและความเป็นไปได้มาก แม้ประเภทจะเน้นความเป็นจริง",
    },

    "mbti_sum_caution_sensing_vs_type": {
      "en":
          "You may rely on detail and experience even when your type leans toward big-picture or abstract thinking.",
      "th":
          "คุณอาจยึดรายละเอียดและประสบการณ์ แม้ประเภทจะเน้นภาพใหญ่หรือนามธรรม",
    },

    "mbti_sum_caution_balanced": {
      "en":
          "Keep noticing when your strengths help — and when a slower pause for people or feelings could help too.",
      "th":
          "สังเกตว่าจุดแข็งช่วยคุณเมื่อไหร่ — และเมื่อไหร่การหยุดฟังความรู้สึกอาจช่วยได้เช่นกัน",
    },

    "mbti_cog_confidence_mini": {
      "en": "Quick insight",
      "th": "ภาพรวมเบื้องต้น",
    },

    "mbti_cog_confidence_standard": {
      "en": "Better understanding",
      "th": "เข้าใจมากขึ้น",
    },

    "mbti_cog_confidence_accurate": {
      "en": "Deep cognitive profile",
      "th": "โปรไฟล์เชิงลึก",
    },

    "mbti_cog_timeline_tier_mini": {
      "en": "Quick insight",
      "th": "ภาพรวมเบื้องต้น",
    },

    "mbti_cog_timeline_tier_standard": {
      "en": "Better understanding",
      "th": "เข้าใจมากขึ้น",
    },

    "mbti_cog_timeline_tier_accurate": {
      "en": "Deep profile",
      "th": "โปรไฟล์เชิงลึก",
    },

    "mbti_cog_progress_title": {
      "en": "Cognitive depth",
      "th": "ระดับความลึกของผล",
    },

    "mbti_cog_progress_hint": {
      "en": "More questions refine your function profile.",
      "th": "ยิ่งทำมาก ผลยิ่งละเอียดขึ้น",
    },

    "mbti_cog_continue_standard": {
      "en": "Continue to 40 questions (better understanding)",
      "th": "ทำต่อถึง 40 ข้อ (เข้าใจมากขึ้น)",
    },

    "mbti_cog_continue_accurate": {
      "en": "Continue to 80 questions (deep profile)",
      "th": "ทำต่อถึง 80 ข้อ (โปรไฟล์เชิงลึก)",
    },

    "mbti_cog_retake_dialog_title": {
      "en": "Start over?",
      "th": "เริ่มใหม่?",
    },

    "mbti_cog_retake_dialog_body": {
      "en": "Your saved answers for this test will be cleared.",
      "th": "คำตอบที่บันทึกไว้จะถูกล้าง",
    },

    "mbti_cog_retake_cancel": {
      "en": "Cancel",
      "th": "ยกเลิก",
    },

    "mbti_cog_retake_confirm": {
      "en": "Start over",
      "th": "เริ่มใหม่",
    },

    "mbti_cog_result_title": {
      "en": "Cognitive Functions Result",
      "th": "ผลลัพธ์ฟังก์ชันทางความคิด",
    },

    "mbti_cog_functions_title": {
      "en": "Function strengths",
      "th": "ความแรงของแต่ละฟังก์ชัน",
    },

    "mbti_cog_ranking_title": {
      "en": "Cognitive preference ranking",
      "th": "ลำดับความถนัดทางความคิด",
    },

    "mbti_cog_ranking_hint": {
      "en": "Order shows relative preference — small gaps are normal.",
      "th": "ลำดับสะท้อนความถนัดสัมพัทธ์ — ช่องว่างเล็กน้อยเป็นเรื่องปกติ",
    },

    "mbti_cog_ranking_rest_title": {
      "en": "Also present (lower emphasis)",
      "th": "ฟังก์ชันอื่นที่ยังมีบทบาท",
    },

    "mbti_cog_top_four_title": {
      "en": "Your top four functions",
      "th": "สี่ฟังก์ชันที่โดดเด่นที่สุด",
    },

    "mbti_cog_think_heading": {
      "en": "How you tend to think",
      "th": "คุณมักคิดและตัดสินใจแบบไหน",
    },

    "mbti_cog_profile_title": {
      "en": "Cognitive profile",
      "th": "ภาพรวมทางความคิด",
    },

    "mbti_cog_think_fallback": {
      "en": "Your answers suggest a mixed cognitive style.",
      "th": "คำตอบของคุณสะท้อนสไตล์ความคิดที่กระจายหลายแบบ",
    },

    "mbti_cog_think_theme_logic": {
      "en": "You often lean on logic and structure before deciding.",
      "th": "คุณมักใช้เหตุผลและโครงสร้างก่อนตัดสินใจ",
    },

    "mbti_cog_think_theme_intuition": {
      "en": "You tend to read patterns, possibilities, and what may come next.",
      "th": "คุณมักมองรูปแบบ ความเป็นไปได้ และทิศทางข้างหน้า",
    },

    "mbti_cog_think_theme_sensing": {
      "en": "You often ground choices in real detail and what has worked before.",
      "th": "คุณมักอิงรายละเอียดจริงและประสบการณ์ที่เคยได้ผล",
    },

    "mbti_cog_think_theme_feeling": {
      "en": "You often weigh values and how people are affected.",
      "th": "คุณมักพิจารณาคุณค่าและผลต่อคนรอบตัว",
    },

    "mbti_cog_think_te": {
      "en": "You like clear systems and outcomes you can measure.",
      "th": "คุณชอบระบบที่ชัดเจนและผลลัพธ์ที่จับต้องได้",
    },

    "mbti_cog_think_ti": {
      "en": "You refine ideas until they fit a precise inner model.",
      "th": "คุณชอบขัดเกลาไอเดียจนกลายเป็นกรอบความคิดที่แม่นยำ",
    },

    "mbti_cog_think_ni": {
      "en": "You look for the deeper thread behind what is happening.",
      "th": "คุณมักมองภาพรวมเชิงลึกเบื้องหลังเหตุการณ์",
    },

    "mbti_cog_think_ne": {
      "en": "You stay open to new angles when they help solve the problem.",
      "th": "คุณพร้อมเปิดรับแนวคิดใหม่เมื่อช่วยแก้ปัญหาได้",
    },

    "mbti_cog_think_si": {
      "en": "You trust proven steps and familiar reference points.",
      "th": "คุณเชื่อขั้นตอนที่เคยใช้ได้และจุดอ้างอิงที่คุ้นเคย",
    },

    "mbti_cog_think_se": {
      "en": "You respond to what is happening here and now.",
      "th": "คุณตอบสนองกับสิ่งที่เกิดขึ้นในปัจจุบัน",
    },

    "mbti_cog_think_fi": {
      "en": "You check choices against what feels authentic to you.",
      "th": "คุณเทียบการตัดสินใจกับความจริงใจและคุณค่าส่วนตัว",
    },

    "mbti_cog_think_fe": {
      "en": "You notice group tone and emotional balance.",
      "th": "คุณสังเกตบรรยากาศและความลงตัวทางอารมณ์ของคนรอบตัว",
    },

    "mbti_cog_disclaimer": {
      "en":
          "This is a tendency snapshot, not a fixed identity or clinical diagnosis.",
      "th":
          "ผลลัพธ์นี้สะท้อนแนวโน้ม ไม่ใช่ตัวตนถาวรหรือการวินิจฉัยทางคลินิก",
    },

    "mbti_cog_stack_none": {
      "en":
          "Your answers show a mixed cognitive pattern without one clear type stack.",
      "th":
          "คำตอบของคุณกระจายหลายฟังก์ชัน ยังไม่ชี้ไปสู่สแต็กประเภทใดประเภทหนึ่งอย่างชัด",
    },

    "mbti_cog_stack_one": {
      "en":
          "You show patterns similar to a {types} cognitive stack — as a tendency, not a label.",
      "th":
          "คำตอบของคุณคล้ายสแต็กแบบ {types} — เป็นแนวโน้ม ไม่ใช่การกำหนดตัวตน",
    },

    "mbti_cog_stack_two": {
      "en":
          "You show patterns similar to {types} cognitive stacks — as tendencies, not fixed types.",
      "th":
          "คำตอบของคุณคล้ายสแต็กแบบ {types} — เป็นแนวโน้ม ไม่ใช่การกำหนดตัวตน",
    },

    "mbti_cog_question_progress": {
      "en": "Question {current} / {total}",
      "th": "คำถาม {current} / {total}",
    },

    "mbti_cog_back": {"en": "Back", "th": "ย้อนกลับ"},

    "mbti_cog_next": {"en": "Next", "th": "ถัดไป"},

    "mbti_cog_see_result": {"en": "See result", "th": "ดูผล"},

    "mbti_cog_restart": {
      "en": "Take again",
      "th": "ทำแบบทดสอบอีกครั้ง",
    },

    "mbti_cog_fn_ni_name": {
      "en": "Introverted Intuition",
      "th": "ลัทธิภายใน (Ni)",
    },
    "mbti_cog_fn_ni_desc": {
      "en": "Seeing deeper patterns, futures, and symbolic connections.",
      "th": "มองเห็นรูปแบบลึก อนาคต และความเชื่อมโยงเชิงสัญลักษณ์",
    },
    "mbti_cog_fn_ne_name": {
      "en": "Extraverted Intuition",
      "th": "สัญชาตญาณภายนอก (Ne)",
    },
    "mbti_cog_fn_ne_desc": {
      "en": "Exploring possibilities, ideas, and what could be next.",
      "th": "สำรวจความเป็นไปได้ ไอเดีย และทางเลือกใหม่ ๆ",
    },
    "mbti_cog_fn_si_name": {
      "en": "Introverted Sensing",
      "th": "ประสาทสัมผัสภายใน (Si)",
    },
    "mbti_cog_fn_si_desc": {
      "en": "Recalling detail, precedent, and what has worked before.",
      "th": "อ้างอิงประสบการณ์ รายละเอียด และวิธีที่เคยได้ผล",
    },
    "mbti_cog_fn_se_name": {
      "en": "Extraverted Sensing",
      "th": "ประสาทสัมผัสภายนอก (Se)",
    },
    "mbti_cog_fn_se_desc": {
      "en": "Acting in the moment and responding to the environment.",
      "th": "ลงมือในปัจจุบันและตอบสนองสิ่งรอบตัวทันที",
    },
    "mbti_cog_fn_ti_name": {
      "en": "Introverted Thinking",
      "th": "คิดวิเคราะห์ภายใน (Ti)",
    },
    "mbti_cog_fn_ti_desc": {
      "en": "Building precise internal models and logical consistency.",
      "th": "สร้างโมเดลความคิดภายในที่สอดคล้องและแม่นยำ",
    },
    "mbti_cog_fn_te_name": {
      "en": "Extraverted Thinking",
      "th": "คิดวิเคราะห์ภายนอก (Te)",
    },
    "mbti_cog_fn_te_desc": {
      "en": "Organizing systems, efficiency, and measurable outcomes.",
      "th": "จัดระบบ ประสิทธิภาพ และผลลัพธ์ที่วัดได้",
    },
    "mbti_cog_fn_fi_name": {
      "en": "Introverted Feeling",
      "th": "ความรู้สึกภายใน (Fi)",
    },
    "mbti_cog_fn_fi_desc": {
      "en": "Aligning choices with personal values and authenticity.",
      "th": "ยึดคุณค่าส่วนตัวและความจริงใจในการตัดสินใจ",
    },
    "mbti_cog_fn_fe_name": {
      "en": "Extraverted Feeling",
      "th": "ความรู้สึกภายนอก (Fe)",
    },
    "mbti_cog_fn_fe_desc": {
      "en": "Reading group tone and supporting emotional harmony.",
      "th": "อ่านบรรยากาศกลุ่มและดูแลความลงตัวทางอารมณ์",
    },

    /// =========================
    /// BIG FIVE TESTS
    /// =========================
    "bigfive_mini": {
      "en": "Quick Personality Test",
      "th": "แบบทดสอบบุคลิกภาพแบบสั้น",
    },

    "bigfive_short": {
      "en": "Standard Personality Test",
      "th": "แบบทดสอบบุคลิกภาพมาตรฐาน",
    },

    "bigfive_accurate": {
      "en": "In-Depth Personality Test",
      "th": "แบบทดสอบบุคลิกภาพแบบละเอียด",
    },

    /// =========================
    /// BIG FIVE TRAITS
    /// =========================
    "openness": {"en": "Openness", "th": "การเปิดรับประสบการณ์"},

    "conscientiousness": {
      "en": "Conscientiousness",
      "th": "ความมีวินัยและความรับผิดชอบ",
    },

    "extraversion": {"en": "Extraversion", "th": "การเข้าสังคม"},

    "agreeableness": {"en": "Agreeableness", "th": "ความเห็นอกเห็นใจผู้อื่น"},

    "neuroticism": {
      "en": "Emotional Sensitivity",
      "th": "ความอ่อนไหวทางอารมณ์",
    },

    /// =========================
    /// EQ TESTS
    /// =========================
    "eq_awareness": {
      "en": "Understanding Your Emotions",
      "th": "การเข้าใจอารมณ์ของตัวเอง",
    },

    "eq_regulation": {
      "en": "Managing Your Emotions",
      "th": "การควบคุมอารมณ์ของตัวเอง",
    },

    "eq_empathy": {
      "en": "Understanding Others",
      "th": "การเข้าใจความรู้สึกของผู้อื่น",
    },

    "eq_social": {"en": "Social Skills", "th": "ทักษะการเข้าสังคม"},

    "eq_stress": {"en": "Handling Stress", "th": "การรับมือกับความเครียด"},

    "eq_decision": {
      "en": "Emotion & Decision Making",
      "th": "การตัดสินใจภายใต้อารมณ์",
    },

    /// =========================
    /// MBTI TESTS
    /// =========================
    "mbti_mini": {"en": "Quick MBTI Test", "th": "MBTI แบบสั้น"},

    "mbti_short": {"en": "Standard MBTI Test", "th": "MBTI มาตรฐาน"},

    "mbti_accurate": {"en": "Advanced MBTI Test", "th": "MBTI แบบละเอียด"},

    /// =========================
    /// ATTACHMENT
    /// =========================
    "attachment": {"en": "Attachment Style", "th": "รูปแบบความสัมพันธ์"},

    "secure": {"en": "Secure", "th": "ความสัมพันธ์แบบมั่นคง"},

    "anxious": {"en": "Anxious", "th": "ความสัมพันธ์แบบกังวล"},

    "avoidant": {"en": "Avoidant", "th": "ความสัมพันธ์แบบหลีกเลี่ยง"},

    /// =========================
    /// MOTIVATION
    /// =========================
    "motivation": {"en": "Life Motivation", "th": "แรงจูงใจในชีวิต"},

    "growth": {"en": "Growth", "th": "การพัฒนาตัวเอง"},

    "achievement": {"en": "Achievement", "th": "ความสำเร็จ"},

    "purpose": {"en": "Purpose", "th": "เป้าหมายชีวิต"},
  };

  static String t(String key) {
    return text[key]?[lang] ?? text[key]?["en"] ?? key;
  }
}
