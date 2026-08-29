const String kBaseUrl = 'https://awlad-rizk.vercel.app';
const String kGeminiApiKey = 'ضع_مفتاح_جوجل_هنا'; // TODO: Paste your Gemini API Key here

const String kWhatsAppNumber = '966500000000';
const String kWhatsAppUrl = 'https://wa.me/$kWhatsAppNumber?text=أهلاً، أريد الاستفسار عن خدمات التكييف';

// Colors
const int kColorPrimary = 0xFFC1502E;
const int kColorPrimaryDark = 0xFFA3401F;
const int kColorSecondary = 0xFF3B2A1F;
const int kColorAccent = 0xFFD4A643;
const int kColorSuccess = 0xFF2E7D32;
const int kColorWarning = 0xFFE8A33D;
const int kColorError = 0xFFB3261E;
const int kColorBg = 0xFFFAF3EA;
const int kColorCardWarm = 0xFFFFFBF5;
const int kColorBorder = 0xFFE8D9C4;
const int kColorTextLight = 0xFF7A6355;

final List<Map<String, String>> kTimeSlots = [
  {'id': 'SLOT-1', 'name': '8:30ص - 10:30ص'},
  {'id': 'SLOT-2', 'name': '10:30ص - 12:30م'},
  {'id': 'SLOT-3', 'name': '12:30م - 02:30م'},
  {'id': 'SLOT-4', 'name': '02:30م - 04:30م'},
  {'id': 'SLOT-5', 'name': '04:30م - 06:30م'},
  {'id': 'SLOT-6', 'name': '06:30م - 08:30م'},
  {'id': 'SLOT-7', 'name': '08:30م - 10:30م'},
  {'id': 'SLOT-8', 'name': '10:30م - 11:30م'},
];

final List<Map<String, dynamic>> kServiceAreas = [
  // 1. أحياء وسط وشرق جدة
  {'id': 'HEADER-1', 'name': '── 📍 أحياء وسط وشرق جدة ──', 'isHeader': true},
  {'id': 'AREA-MARWAH', 'name': 'حي المروة (المركز الرئيسي)', 'category': 'وسط وشرق جدة'},
  {'id': 'AREA-SAMER', 'name': 'حي السامر', 'category': 'وسط وشرق جدة'},
  {'id': 'AREA-SAFA', 'name': 'حي الصفا', 'category': 'وسط وشرق جدة'},
  {'id': 'AREA-RABWAH', 'name': 'حي الربوة', 'category': 'وسط وشرق جدة'},
  {'id': 'AREA-BAWADI', 'name': 'حي البوادي', 'category': 'وسط وشرق جدة'},
  {'id': 'AREA-FAISALIYAH', 'name': 'حي الفيصلية', 'category': 'وسط وشرق جدة'},
  {'id': 'AREA-AZIZIYAH', 'name': 'حي العزيزية', 'category': 'وسط وشرق جدة'},
  {'id': 'AREA-MUSHREFAH', 'name': 'حي مشرفة', 'category': 'وسط وشرق جدة'},
  {'id': 'AREA-REHAB', 'name': 'حي الرحاب', 'category': 'وسط وشرق جدة'},

  // 2. أحياء شمال جدة
  {'id': 'HEADER-2', 'name': '── 📍 أحياء شمال جدة ──', 'isHeader': true},
  {'id': 'AREA-NAEEM', 'name': 'حي النعيم', 'category': 'شمال جدة'},
  {'id': 'AREA-NAHDAH', 'name': 'حي النهضة', 'category': 'شمال جدة'},
  {'id': 'AREA-NUZHAH', 'name': 'حي النزهة', 'category': 'شمال جدة'},
  {'id': 'AREA-SALAMAH', 'name': 'حي السلامة', 'category': 'شمال جدة'},
  {'id': 'AREA-ZAHRA', 'name': 'حي الزهراء', 'category': 'شمال جدة'},
  {'id': 'AREA-RAWDAH', 'name': 'حي الروضة', 'category': 'شمال جدة'},
  {'id': 'AREA-MUHAMMADIYAH', 'name': 'حي المحمدية', 'category': 'شمال جدة'},
  {'id': 'AREA-SHATI', 'name': 'حي الشاطئ', 'category': 'شمال جدة'},
  {'id': 'AREA-OBHUR-SOUTH', 'name': 'حي أبحر الجنوبية', 'category': 'شمال جدة'},

  // 3. أحياء جنوب جدة
  {'id': 'HEADER-3', 'name': '── 📍 أحياء جنوب جدة ──', 'isHeader': true},
  {'id': 'AREA-NASEEM', 'name': 'حي النسيم', 'category': 'جنوب جدة'},
  {'id': 'AREA-BANI-MALIK', 'name': 'حي بني مالك', 'category': 'جنوب جدة'},
  {'id': 'AREA-WUROOD', 'name': 'حي الورود', 'category': 'جنوب جدة'},
  {'id': 'AREA-FAYHA', 'name': 'حي الفيحاء', 'category': 'جنوب جدة'},
  {'id': 'AREA-SULAIMANIYAH', 'name': 'حي السليمانية', 'category': 'جنوب جدة'},
  {'id': 'AREA-THAGHR', 'name': 'حي الثغر', 'category': 'جنوب جدة'},
  {'id': 'AREA-JAMEAH', 'name': 'حي الجامعة', 'category': 'جنوب جدة'},
  {'id': 'AREA-RUWAIS', 'name': 'حي الرويس', 'category': 'جنوب جدة'},
  {'id': 'AREA-HAMRA', 'name': 'حي الحمراء', 'category': 'جنوب جدة'},
  {'id': 'AREA-SHARAFYAH', 'name': 'حي الشرفية', 'category': 'جنوب جدة'},

  // 4. خيارات أخرى
  {'id': 'HEADER-4', 'name': '── 📍 مناطق أخرى ──', 'isHeader': true},
  {'id': 'AREA-OTHER', 'name': 'حي آخر في جدة', 'category': 'أخرى'},
];
