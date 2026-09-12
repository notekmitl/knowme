import 'package:knowme/data/models/bazi_chart_model.dart';
import 'package:knowme/features/bazi_compatibility/domain/bazi_compatibility_report.dart';

abstract final class BaziCompatibilityReportBuilder {
  static BaziCompatibilityReport build(
    BaziChartModel chart, {
    String languageCode = 'th',
  }) {
    final th = languageCode != 'en';
    return BaziCompatibilityReport(
      title: 'KnowMe BaZi Compatibility V1',
      subtitle: th
          ? 'ผลคำนวณตามกติกาความเข้ากันได้ของ KnowMe รุ่น V1 — ไม่ได้อ้างว่าเป็นมาตรฐานสากลของทุกสำนัก'
          : 'Calculated with the KnowMe V1 compatibility rules; this is not claimed as a universal standard across all schools.',
      sections: [
        _inputSection(chart, th),
        _pillarsSection(chart, th),
        _elementSection(chart, th),
        _methodSection(chart, th),
        _limitationsSection(chart, th),
      ],
    );
  }

  static BaziCompatibilityReportSection _inputSection(
    BaziChartModel chart,
    bool th,
  ) {
    final birthTime = _text(chart.input['birth_time']);
    return BaziCompatibilityReportSection(
      title: th ? 'ข้อมูลที่ใช้คำนวณ' : 'Calculation input',
      rows: [
        BaziCompatibilityReportRow(
          label: th ? 'วันเกิดตามปฏิทินเกรกอเรียน' : 'Gregorian birth date',
          value: _text(chart.input['birth_date'], fallback: '—'),
        ),
        BaziCompatibilityReportRow(
          label: th ? 'เวลาเกิด' : 'Birth time',
          value: chart.timeKnown ? birthTime : (th ? 'ไม่ทราบเวลา' : 'Unknown'),
        ),
        BaziCompatibilityReportRow(
          label: th ? 'เขตเวลา IANA' : 'IANA timezone',
          value: _text(chart.input['timezone'], fallback: '—'),
        ),
      ],
      notes: chart.timeKnown
          ? const []
          : [
              th
                  ? 'เมื่อไม่ทราบเวลา ระบบจะไม่แสดงเสาชั่วโมงหรือข้อมูลที่ขึ้นกับเวลา และจะตัดเสาปี/เดือนที่เปลี่ยนภายในวันนั้นออก'
                  : 'With Unknown time, the Hour pillar and time-dependent outputs are omitted; a Year or Month pillar that changes during that date is also omitted.',
            ],
    );
  }

  static BaziCompatibilityReportSection _pillarsSection(
    BaziChartModel chart,
    bool th,
  ) {
    final rows = <BaziCompatibilityReportRow>[];
    void add(String roleTh, String roleEn, BaziPillar pillar) {
      if (!pillar.isAvailable) return;
      rows.add(
        BaziCompatibilityReportRow(
          label: th ? roleTh : roleEn,
          value:
              '${pillar.pillarLabel} '
              '(${pillar.stemRoman}/${pillar.branchRoman}) — '
              '${_element(pillar.stemElement, th)} + '
              '${_element(pillar.branchElement, th)}',
        ),
      );
    }

    add('เสาปี', 'Year pillar', chart.pillars.year);
    add('เสาเดือน', 'Month pillar', chart.pillars.month);
    add('เสาวัน', 'Day pillar', chart.pillars.day);
    add('เสาชั่วโมง', 'Hour pillar', chart.pillars.hour);

    final notes = <String>[];
    if (!chart.pillars.year.isAvailable) {
      notes.add(
        th
            ? 'ไม่แสดงเสาปี: วันดังกล่าวคร่อมจุดเปลี่ยน Li Chun (ลี่ชุน) และไม่มีเวลาเกิดมายืนยันด้านของเส้นแบ่ง'
            : 'Year pillar omitted: the date crosses Li Chun and no birth time fixes the side of the boundary.',
      );
    }
    if (!chart.pillars.month.isAvailable) {
      notes.add(
        th
            ? 'ไม่แสดงเสาเดือน: วันดังกล่าวคร่อมจุดเปลี่ยน Jie (เจี๋ย) และไม่มีเวลาเกิดมายืนยันด้านของเส้นแบ่ง'
            : 'Month pillar omitted: the date crosses a Jie boundary and no birth time fixes the side of the boundary.',
      );
    }
    if (!chart.pillars.hour.isAvailable) {
      notes.add(
        th
            ? 'ไม่แสดงเสาชั่วโมง เพราะไม่มีเวลาเกิดที่ทราบแน่ชัด'
            : 'Hour pillar omitted because the birth time is unknown.',
      );
    }
    if (chart.yearAnimal.isAvailable) {
      rows.add(
        BaziCompatibilityReportRow(
          label: th ? 'สัตว์ประจำเสาปี' : 'Year-pillar animal',
          value: '${chart.yearAnimal.zh} (${chart.yearAnimal.en})',
        ),
      );
    }

    return BaziCompatibilityReportSection(
      title: th ? 'ผลเสาหลักที่ยืนยันได้' : 'Available pillar results',
      intro: th
          ? 'เสาหลักคือรหัสก้านฟ้าและกิ่งดินที่ engine คำนวณได้ ส่วน Day Master ในข้อมูลดิบคือก้านฟ้าของเสาวัน ไม่ใช่คำอธิบายบุคลิก'
          : 'Each pillar is an engine-calculated heavenly-stem/earthly-branch code. Day Master is the Day pillar stem, not a personality description.',
      rows: rows,
      notes: notes,
    );
  }

  static BaziCompatibilityReportSection _elementSection(
    BaziChartModel chart,
    bool th,
  ) {
    final balance = chart.elementBalance;
    return BaziCompatibilityReportSection(
      title: th ? 'จำนวนธาตุที่ปรากฏ' : 'Visible element counts',
      intro: th
          ? 'นับธาตุบนก้านฟ้าและกิ่งดินของเสาที่แสดงเท่านั้น ไม่รวมก้านซ่อน ราก ฤดูกาล หรือน้ำหนักความแข็งแรง'
          : 'Counts visible stem and branch elements from displayed pillars only; hidden stems, rooting, seasonality, and strength weighting are excluded.',
      rows: [
        BaziCompatibilityReportRow(
          label: _element('wood', th),
          value: '${balance.wood}',
        ),
        BaziCompatibilityReportRow(
          label: _element('fire', th),
          value: '${balance.fire}',
        ),
        BaziCompatibilityReportRow(
          label: _element('earth', th),
          value: '${balance.earth}',
        ),
        BaziCompatibilityReportRow(
          label: _element('metal', th),
          value: '${balance.metal}',
        ),
        BaziCompatibilityReportRow(
          label: _element('water', th),
          value: '${balance.water}',
        ),
        BaziCompatibilityReportRow(
          label: th ? 'ช่องข้อมูลที่นับ' : 'Counted slots',
          value: '${balance.totalSlots}',
        ),
      ],
    );
  }

  static BaziCompatibilityReportSection _methodSection(
    BaziChartModel chart,
    bool th,
  ) {
    return BaziCompatibilityReportSection(
      title: th
          ? 'กติกาและแหล่งที่ตรวจย้อนกลับได้'
          : 'Traceable rules and source',
      rows: [
        BaziCompatibilityReportRow(
          label: th ? 'สัญญากติกา' : 'Rule contract',
          value: chart.contractId,
        ),
        BaziCompatibilityReportRow(
          label: th ? 'engine' : 'Engine',
          value: chart.engineVersion,
        ),
        BaziCompatibilityReportRow(
          label: th ? 'ฐานเวลา' : 'Time basis',
          value: th
              ? 'เวลาท้องถิ่นตาม IANA zone ที่ระบุ โดยไม่แปลงเป็น UTC'
              : 'Local civil time in the supplied IANA zone, without UTC conversion',
        ),
        BaziCompatibilityReportRow(
          label: th ? 'เส้นแบ่งปี' : 'Year boundary',
          value: 'Li Chun (立春)',
        ),
        BaziCompatibilityReportRow(
          label: th ? 'เส้นแบ่งเดือน' : 'Month boundary',
          value: 'Jie (節)',
        ),
        BaziCompatibilityReportRow(
          label: th ? 'เส้นแบ่งวัน' : 'Day boundary',
          value: th
              ? '00:00 ตามเวลาท้องถิ่น (sect=2)'
              : '00:00 local civil time (sect=2)',
        ),
        BaziCompatibilityReportRow(
          label: th ? 'การปรับเวลาสุริยะจริง' : 'True-solar correction',
          value: th ? 'ไม่ปรับ' : 'None',
        ),
        BaziCompatibilityReportRow(
          label: th ? 'สถานที่และพิกัด' : 'Location and coordinates',
          value: th
              ? 'บันทึกเป็นบริบท แต่ไม่ใช้เปลี่ยนผลคำนวณใน V1'
              : 'Recorded as context but do not alter the V1 calculation',
        ),
        BaziCompatibilityReportRow(
          label: th ? 'รหัสตรวจ input' : 'Input fingerprint',
          value: chart.inputHash,
        ),
      ],
    );
  }

  static BaziCompatibilityReportSection _limitationsSection(
    BaziChartModel chart,
    bool th,
  ) {
    return BaziCompatibilityReportSection(
      title: th ? 'ข้อจำกัดและคำเตือน' : 'Limitations and cautions',
      notes: [
        th
            ? 'รายงานนี้แสดงข้อมูลคำนวณตาม KnowMe BaZi Compatibility V1 เท่านั้น ไม่ใช่มาตรฐานสากลของทุกสำนัก และไม่มีคำทำนายหรือคำอธิบายบุคลิก'
            : 'This report presents only KnowMe BaZi Compatibility V1 calculations. It is not a universal school standard and contains no prediction or personality reading.',
        if (!chart.timeKnown)
          th
              ? 'ผล Unknown time เป็นแบบ fail-closed: ข้อมูลที่ต้องใช้เวลาและค่าปี/เดือนที่กำกวมจะไม่ถูกแสดง'
              : 'Unknown-time results fail closed: time-dependent and ambiguous Year/Month values are not shown.',
        th
            ? 'ห้ามใช้รายงานนี้แทนคำแนะนำจากผู้เชี่ยวชาญด้านสุขภาพ การแพทย์ การเงิน การลงทุน หรือกฎหมาย และไม่ควรใช้เพื่อรับประกันเหตุการณ์ในอนาคต'
            : 'Do not use this report as health, medical, financial, investment, or legal advice, or as a guarantee of future events.',
      ],
    );
  }

  static String _element(String value, bool th) {
    const thai = {
      'wood': 'ไม้',
      'fire': 'ไฟ',
      'earth': 'ดิน',
      'metal': 'ทอง',
      'water': 'น้ำ',
    };
    return th ? (thai[value] ?? value) : value;
  }

  static String _text(dynamic value, {String fallback = ''}) {
    final result = value is String ? value.trim() : '';
    return result.isEmpty ? fallback : result;
  }
}
