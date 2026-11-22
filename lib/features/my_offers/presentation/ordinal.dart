/// Port of `MyOfferBookingsAdapter.numberToOrdinalWord`: the "first / second ..."
/// word used for completed sessions ("Session first"). The tables are the Kotlin ones.
String numberToOrdinalWord(int number, [String language = 'ar']) {
  switch (language) {
    case 'ar':
      // `1` is "الأولى" only for the number 1; inside 21, 31... it is "الحادية".
      final ordinals = <int, String>{
        1: number == 1 ? 'الأولى' : 'الحادية',
        ..._ordinalsAr,
      };
      final direct = ordinals[number];
      if (direct != null) return direct;
      final unit = number % 10;
      final ten = number ~/ 10;
      final suffix = ordinals[unit];
      if (suffix == null) return 'الرقم $number';
      final base = _tensAr[ten];
      if (base == null) return 'الرقم $number';
      return '$suffix و $base';
    case 'en':
      final direct = _ordinalsEn[number];
      if (direct != null) return direct;
      final unit = number % 10;
      final ten = number ~/ 10;
      final base = _tensEn[ten];
      if (base == null) return '${number}th';
      final suffix = _ordinalsEn[unit];
      if (suffix == null) return '${number}th';
      return base + suffix.toLowerCase();
    default:
      return '$number';
  }
}

const _ordinalsEn = <int, String>{
  1: 'First',
  2: 'Second',
  3: 'Third',
  4: 'Fourth',
  5: 'Fifth',
  6: 'Sixth',
  7: 'Seventh',
  8: 'Eighth',
  9: 'Ninth',
  10: 'Tenth',
  11: 'Eleventh',
  12: 'Twelfth',
  13: 'Thirteenth',
  14: 'Fourteenth',
  15: 'Fifteenth',
  16: 'Sixteenth',
  17: 'Seventeenth',
  18: 'Eighteenth',
  19: 'Nineteenth',
  20: 'Twentieth',
  30: 'Thirtieth',
  40: 'Fortieth',
  50: 'Fiftieth',
  60: 'Sixtieth',
  70: 'Seventieth',
  80: 'Eightieth',
  90: 'Ninetieth',
};

const _tensEn = <int, String>{
  2: 'Twenty',
  3: 'Thirty',
  4: 'Forty',
  5: 'Fifty',
  6: 'Sixty',
  7: 'Seventy',
  8: 'Eighty',
  9: 'Ninety',
};

/// The feminine ordinals of the Kotlin map, except `1` (it depends on the number).
const _ordinalsAr = <int, String>{
  2: 'الثانية',
  3: 'الثالثة',
  4: 'الرابعة',
  5: 'الخامسة',
  6: 'السادسة',
  7: 'السابعة',
  8: 'الثامنة',
  9: 'التاسعة',
  10: 'العاشرة',
  11: 'الحادية عشرة',
  12: 'الثانية عشرة',
  13: 'الثالثة عشرة',
  14: 'الرابعة عشرة',
  15: 'الخامسة عشرة',
  16: 'السادسة عشرة',
  17: 'السابعة عشرة',
  18: 'الثامنة عشرة',
  19: 'التاسعة عشرة',
  20: 'العشرون',
  30: 'الثلاثون',
  40: 'الأربعون',
  50: 'الخمسون',
  60: 'الستون',
  70: 'السبعون',
  80: 'الثمانون',
  90: 'التسعون',
};

const _tensAr = <int, String>{
  2: 'عشرون',
  3: 'ثلاثون',
  4: 'أربعون',
  5: 'خمسون',
  6: 'ستون',
  7: 'سبعون',
  8: 'ثمانون',
  9: 'تسعون',
};
