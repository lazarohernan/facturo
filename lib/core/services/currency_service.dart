import 'package:intl/intl.dart';

/// Model representing a currency with all its properties
class Currency {
  final String code;       // ISO 4217 code (USD, EUR, etc.)
  final String symbol;     // Currency symbol ($, €, etc.)
  final String name;       // Full name (US Dollar, Euro, etc.)
  final String nameEs;     // Spanish name
  final int decimalDigits; // Number of decimal places
  final bool symbolBefore; // Symbol before amount (true: $100, false: 100€)
  final String region;     // Geographic region
  final String flag;       // Flag emoji (🇺🇸, 🇪🇺, etc.)

  const Currency({
    required this.code,
    required this.symbol,
    required this.name,
    required this.nameEs,
    this.decimalDigits = 2,
    this.symbolBefore = true,
    required this.region,
    required this.flag,
  });

  /// Format an amount using this currency
  String format(double amount) {
    final formatter = NumberFormat.currency(
      symbol: symbolBefore ? '$symbol ' : '',
      decimalDigits: decimalDigits,
    );
    final formatted = formatter.format(amount);
    return symbolBefore ? formatted : '$formatted $symbol';
  }

  /// Get NumberFormat for this currency
  NumberFormat get numberFormat => NumberFormat.currency(
    symbol: '$symbol ',
    decimalDigits: decimalDigits,
  );
}

/// Service providing access to all supported currencies
class CurrencyService {
  CurrencyService._();
  static final CurrencyService _instance = CurrencyService._();
  factory CurrencyService() => _instance;

  /// All supported currencies organized by region
  static const Map<String, List<Currency>> currenciesByRegion = {
    'North America': _northAmerica,
    'Central America': _centralAmerica,
    'Caribbean': _caribbean,
    'South America': _southAmerica,
    'Europe': _europe,
    'Asia': _asia,
    'Oceania': _oceania,
    'Africa': _africa,
    'Middle East': _middleEast,
  };

  // ==================== NORTH AMERICA ====================
  static const List<Currency> _northAmerica = [
    Currency(
      code: 'USD',
      symbol: '\$',
      name: 'US Dollar',
      nameEs: 'Dólar Estadounidense',
      region: 'North America',
      flag: '🇺🇸',
    ),
    Currency(
      code: 'CAD',
      symbol: 'CA\$',
      name: 'Canadian Dollar',
      nameEs: 'Dólar Canadiense',
      region: 'North America',
      flag: '🇨🇦',
    ),
    Currency(
      code: 'MXN',
      symbol: 'MX\$',
      name: 'Mexican Peso',
      nameEs: 'Peso Mexicano',
      region: 'North America',
      flag: '🇲🇽',
    ),
  ];

  // ==================== CENTRAL AMERICA ====================
  static const List<Currency> _centralAmerica = [
    Currency(
      code: 'GTQ',
      symbol: 'Q',
      name: 'Guatemalan Quetzal',
      nameEs: 'Quetzal Guatemalteco',
      region: 'Central America',
      flag: '🇬🇹',
    ),
    Currency(
      code: 'BZD',
      symbol: 'BZ\$',
      name: 'Belize Dollar',
      nameEs: 'Dólar Beliceño',
      region: 'Central America',
      flag: '🇧🇿',
    ),
    Currency(
      code: 'HNL',
      symbol: 'L',
      name: 'Honduran Lempira',
      nameEs: 'Lempira Hondureño',
      region: 'Central America',
      flag: '🇭🇳',
    ),
    Currency(
      code: 'NIO',
      symbol: 'C\$',
      name: 'Nicaraguan Córdoba',
      nameEs: 'Córdoba Nicaragüense',
      region: 'Central America',
      flag: '🇳🇮',
    ),
    Currency(
      code: 'CRC',
      symbol: '₡',
      name: 'Costa Rican Colón',
      nameEs: 'Colón Costarricense',
      region: 'Central America',
      flag: '🇨🇷',
    ),
    Currency(
      code: 'PAB',
      symbol: 'B/.',
      name: 'Panamanian Balboa',
      nameEs: 'Balboa Panameño',
      region: 'Central America',
      flag: '🇵🇦',
    ),
    // El Salvador uses USD
  ];

  // ==================== CARIBBEAN ====================
  static const List<Currency> _caribbean = [
    Currency(
      code: 'DOP',
      symbol: 'RD\$',
      name: 'Dominican Peso',
      nameEs: 'Peso Dominicano',
      region: 'Caribbean',
      flag: '🇩🇴',
    ),
    Currency(
      code: 'CUP',
      symbol: '\$',
      name: 'Cuban Peso',
      nameEs: 'Peso Cubano',
      region: 'Caribbean',
      flag: '🇨🇺',
    ),
    Currency(
      code: 'JMD',
      symbol: 'J\$',
      name: 'Jamaican Dollar',
      nameEs: 'Dólar Jamaiquino',
      region: 'Caribbean',
      flag: '🇯🇲',
    ),
    Currency(
      code: 'HTG',
      symbol: 'G',
      name: 'Haitian Gourde',
      nameEs: 'Gourde Haitiano',
      region: 'Caribbean',
      flag: '🇭🇹',
    ),
    Currency(
      code: 'TTD',
      symbol: 'TT\$',
      name: 'Trinidad and Tobago Dollar',
      nameEs: 'Dólar de Trinidad y Tobago',
      region: 'Caribbean',
      flag: '🇹🇹',
    ),
    Currency(
      code: 'BBD',
      symbol: 'Bds\$',
      name: 'Barbadian Dollar',
      nameEs: 'Dólar de Barbados',
      region: 'Caribbean',
      flag: '🇧🇧',
    ),
    Currency(
      code: 'XCD',
      symbol: 'EC\$',
      name: 'East Caribbean Dollar',
      nameEs: 'Dólar del Caribe Oriental',
      region: 'Caribbean',
      flag: '🇦🇬', // Antigua & Barbuda as representative
    ),
    Currency(
      code: 'AWG',
      symbol: 'Afl.',
      name: 'Aruban Florin',
      nameEs: 'Florín Arubeño',
      region: 'Caribbean',
      flag: '🇦🇼',
    ),
    Currency(
      code: 'ANG',
      symbol: 'NAƒ',
      name: 'Netherlands Antillean Guilder',
      nameEs: 'Florín Antillano Neerlandés',
      region: 'Caribbean',
      flag: '🇨🇼', // Curaçao as representative
    ),
  ];

  // ==================== SOUTH AMERICA ====================
  static const List<Currency> _southAmerica = [
    Currency(
      code: 'BRL',
      symbol: 'R\$',
      name: 'Brazilian Real',
      nameEs: 'Real Brasileño',
      region: 'South America',
      flag: '🇧🇷',
    ),
    Currency(
      code: 'ARS',
      symbol: 'AR\$',
      name: 'Argentine Peso',
      nameEs: 'Peso Argentino',
      region: 'South America',
      flag: '🇦🇷',
    ),
    Currency(
      code: 'CLP',
      symbol: 'CL\$',
      name: 'Chilean Peso',
      nameEs: 'Peso Chileno',
      decimalDigits: 0,
      region: 'South America',
      flag: '🇨🇱',
    ),
    Currency(
      code: 'COP',
      symbol: 'CO\$',
      name: 'Colombian Peso',
      nameEs: 'Peso Colombiano',
      decimalDigits: 0,
      region: 'South America',
      flag: '🇨🇴',
    ),
    Currency(
      code: 'PEN',
      symbol: 'S/',
      name: 'Peruvian Sol',
      nameEs: 'Sol Peruano',
      region: 'South America',
      flag: '🇵🇪',
    ),
    Currency(
      code: 'VES',
      symbol: 'Bs.',
      name: 'Venezuelan Bolívar',
      nameEs: 'Bolívar Venezolano',
      region: 'South America',
      flag: '🇻🇪',
    ),
    Currency(
      code: 'UYU',
      symbol: '\$U',
      name: 'Uruguayan Peso',
      nameEs: 'Peso Uruguayo',
      region: 'South America',
      flag: '🇺🇾',
    ),
    Currency(
      code: 'PYG',
      symbol: '₲',
      name: 'Paraguayan Guaraní',
      nameEs: 'Guaraní Paraguayo',
      decimalDigits: 0,
      region: 'South America',
      flag: '🇵🇾',
    ),
    Currency(
      code: 'BOB',
      symbol: 'Bs.',
      name: 'Bolivian Boliviano',
      nameEs: 'Boliviano',
      region: 'South America',
      flag: '🇧🇴',
    ),
    Currency(
      code: 'GYD',
      symbol: 'GY\$',
      name: 'Guyanese Dollar',
      nameEs: 'Dólar Guyanés',
      region: 'South America',
      flag: '🇬🇾',
    ),
    Currency(
      code: 'SRD',
      symbol: 'SR\$',
      name: 'Surinamese Dollar',
      nameEs: 'Dólar Surinamés',
      region: 'South America',
      flag: '🇸🇷',
    ),
    // Ecuador uses USD
    // French Guiana uses EUR
  ];

  // ==================== EUROPE ====================
  static const List<Currency> _europe = [
    Currency(
      code: 'EUR',
      symbol: '€',
      name: 'Euro',
      nameEs: 'Euro',
      symbolBefore: false,
      region: 'Europe',
      flag: '🇪🇺',
    ),
    Currency(
      code: 'GBP',
      symbol: '£',
      name: 'British Pound',
      nameEs: 'Libra Esterlina',
      region: 'Europe',
      flag: '🇬🇧',
    ),
    Currency(
      code: 'CHF',
      symbol: 'CHF',
      name: 'Swiss Franc',
      nameEs: 'Franco Suizo',
      region: 'Europe',
      flag: '🇨🇭',
    ),
    Currency(
      code: 'SEK',
      symbol: 'kr',
      name: 'Swedish Krona',
      nameEs: 'Corona Sueca',
      symbolBefore: false,
      region: 'Europe',
      flag: '🇸🇪',
    ),
    Currency(
      code: 'NOK',
      symbol: 'kr',
      name: 'Norwegian Krone',
      nameEs: 'Corona Noruega',
      symbolBefore: false,
      region: 'Europe',
      flag: '🇳🇴',
    ),
    Currency(
      code: 'DKK',
      symbol: 'kr',
      name: 'Danish Krone',
      nameEs: 'Corona Danesa',
      symbolBefore: false,
      region: 'Europe',
      flag: '🇩🇰',
    ),
    Currency(
      code: 'PLN',
      symbol: 'zł',
      name: 'Polish Złoty',
      nameEs: 'Zloty Polaco',
      symbolBefore: false,
      region: 'Europe',
      flag: '🇵🇱',
    ),
    Currency(
      code: 'CZK',
      symbol: 'Kč',
      name: 'Czech Koruna',
      nameEs: 'Corona Checa',
      symbolBefore: false,
      region: 'Europe',
      flag: '🇨🇿',
    ),
    Currency(
      code: 'HUF',
      symbol: 'Ft',
      name: 'Hungarian Forint',
      nameEs: 'Florín Húngaro',
      decimalDigits: 0,
      symbolBefore: false,
      region: 'Europe',
      flag: '🇭🇺',
    ),
    Currency(
      code: 'RON',
      symbol: 'lei',
      name: 'Romanian Leu',
      nameEs: 'Leu Rumano',
      symbolBefore: false,
      region: 'Europe',
      flag: '🇷🇴',
    ),
    Currency(
      code: 'BGN',
      symbol: 'лв',
      name: 'Bulgarian Lev',
      nameEs: 'Lev Búlgaro',
      symbolBefore: false,
      region: 'Europe',
      flag: '🇧🇬',
    ),
    Currency(
      code: 'HRK',
      symbol: 'kn',
      name: 'Croatian Kuna',
      nameEs: 'Kuna Croata',
      symbolBefore: false,
      region: 'Europe',
      flag: '🇭🇷',
    ),
    Currency(
      code: 'RSD',
      symbol: 'дин.',
      name: 'Serbian Dinar',
      nameEs: 'Dinar Serbio',
      symbolBefore: false,
      region: 'Europe',
      flag: '🇷🇸',
    ),
    Currency(
      code: 'UAH',
      symbol: '₴',
      name: 'Ukrainian Hryvnia',
      nameEs: 'Grivna Ucraniana',
      region: 'Europe',
      flag: '🇺🇦',
    ),
    Currency(
      code: 'RUB',
      symbol: '₽',
      name: 'Russian Ruble',
      nameEs: 'Rublo Ruso',
      symbolBefore: false,
      region: 'Europe',
      flag: '🇷🇺',
    ),
    Currency(
      code: 'TRY',
      symbol: '₺',
      name: 'Turkish Lira',
      nameEs: 'Lira Turca',
      region: 'Europe',
      flag: '🇹🇷',
    ),
    Currency(
      code: 'ISK',
      symbol: 'kr',
      name: 'Icelandic Króna',
      nameEs: 'Corona Islandesa',
      decimalDigits: 0,
      symbolBefore: false,
      region: 'Europe',
      flag: '🇮🇸',
    ),
  ];

  // ==================== ASIA ====================
  static const List<Currency> _asia = [
    Currency(
      code: 'JPY',
      symbol: '¥',
      name: 'Japanese Yen',
      nameEs: 'Yen Japonés',
      decimalDigits: 0,
      region: 'Asia',
      flag: '🇯🇵',
    ),
    Currency(
      code: 'CNY',
      symbol: '¥',
      name: 'Chinese Yuan',
      nameEs: 'Yuan Chino',
      region: 'Asia',
      flag: '🇨🇳',
    ),
    Currency(
      code: 'KRW',
      symbol: '₩',
      name: 'South Korean Won',
      nameEs: 'Won Surcoreano',
      decimalDigits: 0,
      region: 'Asia',
      flag: '🇰🇷',
    ),
    Currency(
      code: 'INR',
      symbol: '₹',
      name: 'Indian Rupee',
      nameEs: 'Rupia India',
      region: 'Asia',
      flag: '🇮🇳',
    ),
    Currency(
      code: 'IDR',
      symbol: 'Rp',
      name: 'Indonesian Rupiah',
      nameEs: 'Rupia Indonesia',
      decimalDigits: 0,
      region: 'Asia',
      flag: '🇮🇩',
    ),
    Currency(
      code: 'MYR',
      symbol: 'RM',
      name: 'Malaysian Ringgit',
      nameEs: 'Ringgit Malasio',
      region: 'Asia',
      flag: '🇲🇾',
    ),
    Currency(
      code: 'SGD',
      symbol: 'S\$',
      name: 'Singapore Dollar',
      nameEs: 'Dólar de Singapur',
      region: 'Asia',
      flag: '🇸🇬',
    ),
    Currency(
      code: 'THB',
      symbol: '฿',
      name: 'Thai Baht',
      nameEs: 'Baht Tailandés',
      region: 'Asia',
      flag: '🇹🇭',
    ),
    Currency(
      code: 'PHP',
      symbol: '₱',
      name: 'Philippine Peso',
      nameEs: 'Peso Filipino',
      region: 'Asia',
      flag: '🇵🇭',
    ),
    Currency(
      code: 'VND',
      symbol: '₫',
      name: 'Vietnamese Dong',
      nameEs: 'Dong Vietnamita',
      decimalDigits: 0,
      region: 'Asia',
      flag: '🇻🇳',
    ),
    Currency(
      code: 'HKD',
      symbol: 'HK\$',
      name: 'Hong Kong Dollar',
      nameEs: 'Dólar de Hong Kong',
      region: 'Asia',
      flag: '🇭🇰',
    ),
    Currency(
      code: 'TWD',
      symbol: 'NT\$',
      name: 'Taiwan Dollar',
      nameEs: 'Dólar Taiwanés',
      region: 'Asia',
      flag: '🇹🇼',
    ),
    Currency(
      code: 'PKR',
      symbol: '₨',
      name: 'Pakistani Rupee',
      nameEs: 'Rupia Pakistaní',
      region: 'Asia',
      flag: '🇵🇰',
    ),
    Currency(
      code: 'BDT',
      symbol: '৳',
      name: 'Bangladeshi Taka',
      nameEs: 'Taka de Bangladés',
      region: 'Asia',
      flag: '🇧🇩',
    ),
    Currency(
      code: 'LKR',
      symbol: 'Rs',
      name: 'Sri Lankan Rupee',
      nameEs: 'Rupia de Sri Lanka',
      region: 'Asia',
      flag: '🇱🇰',
    ),
    Currency(
      code: 'NPR',
      symbol: 'Rs',
      name: 'Nepalese Rupee',
      nameEs: 'Rupia Nepalí',
      region: 'Asia',
      flag: '🇳🇵',
    ),
    Currency(
      code: 'MMK',
      symbol: 'K',
      name: 'Myanmar Kyat',
      nameEs: 'Kyat de Myanmar',
      region: 'Asia',
      flag: '🇲🇲',
    ),
    Currency(
      code: 'KHR',
      symbol: '៛',
      name: 'Cambodian Riel',
      nameEs: 'Riel Camboyano',
      region: 'Asia',
      flag: '🇰🇭',
    ),
  ];

  // ==================== OCEANIA ====================
  static const List<Currency> _oceania = [
    Currency(
      code: 'AUD',
      symbol: 'A\$',
      name: 'Australian Dollar',
      nameEs: 'Dólar Australiano',
      region: 'Oceania',
      flag: '🇦🇺',
    ),
    Currency(
      code: 'NZD',
      symbol: 'NZ\$',
      name: 'New Zealand Dollar',
      nameEs: 'Dólar Neozelandés',
      region: 'Oceania',
      flag: '🇳🇿',
    ),
    Currency(
      code: 'FJD',
      symbol: 'FJ\$',
      name: 'Fijian Dollar',
      nameEs: 'Dólar Fiyiano',
      region: 'Oceania',
      flag: '🇫🇯',
    ),
    Currency(
      code: 'PGK',
      symbol: 'K',
      name: 'Papua New Guinean Kina',
      nameEs: 'Kina de Papúa Nueva Guinea',
      region: 'Oceania',
      flag: '🇵🇬',
    ),
  ];

  // ==================== AFRICA ====================
  static const List<Currency> _africa = [
    Currency(
      code: 'ZAR',
      symbol: 'R',
      name: 'South African Rand',
      nameEs: 'Rand Sudafricano',
      region: 'Africa',
      flag: '🇿🇦',
    ),
    Currency(
      code: 'EGP',
      symbol: 'E£',
      name: 'Egyptian Pound',
      nameEs: 'Libra Egipcia',
      region: 'Africa',
      flag: '🇪🇬',
    ),
    Currency(
      code: 'NGN',
      symbol: '₦',
      name: 'Nigerian Naira',
      nameEs: 'Naira Nigeriano',
      region: 'Africa',
      flag: '🇳🇬',
    ),
    Currency(
      code: 'KES',
      symbol: 'KSh',
      name: 'Kenyan Shilling',
      nameEs: 'Chelín Keniano',
      region: 'Africa',
      flag: '🇰🇪',
    ),
    Currency(
      code: 'GHS',
      symbol: 'GH₵',
      name: 'Ghanaian Cedi',
      nameEs: 'Cedi Ghanés',
      region: 'Africa',
      flag: '🇬🇭',
    ),
    Currency(
      code: 'MAD',
      symbol: 'د.م.',
      name: 'Moroccan Dirham',
      nameEs: 'Dírham Marroquí',
      region: 'Africa',
      flag: '🇲🇦',
    ),
    Currency(
      code: 'TND',
      symbol: 'د.ت',
      name: 'Tunisian Dinar',
      nameEs: 'Dinar Tunecino',
      decimalDigits: 3,
      region: 'Africa',
      flag: '🇹🇳',
    ),
    Currency(
      code: 'XOF',
      symbol: 'CFA',
      name: 'West African CFA Franc',
      nameEs: 'Franco CFA de África Occidental',
      decimalDigits: 0,
      region: 'Africa',
      flag: '🇸🇳', // Senegal as representative
    ),
    Currency(
      code: 'XAF',
      symbol: 'FCFA',
      name: 'Central African CFA Franc',
      nameEs: 'Franco CFA de África Central',
      decimalDigits: 0,
      region: 'Africa',
      flag: '🇨🇲', // Cameroon as representative
    ),
  ];

  // ==================== MIDDLE EAST ====================
  static const List<Currency> _middleEast = [
    Currency(
      code: 'AED',
      symbol: 'د.إ',
      name: 'UAE Dirham',
      nameEs: 'Dírham de los EAU',
      region: 'Middle East',
      flag: '🇦🇪',
    ),
    Currency(
      code: 'SAR',
      symbol: '﷼',
      name: 'Saudi Riyal',
      nameEs: 'Riyal Saudí',
      region: 'Middle East',
      flag: '🇸🇦',
    ),
    Currency(
      code: 'ILS',
      symbol: '₪',
      name: 'Israeli Shekel',
      nameEs: 'Shekel Israelí',
      region: 'Middle East',
      flag: '🇮🇱',
    ),
    Currency(
      code: 'QAR',
      symbol: 'ر.ق',
      name: 'Qatari Riyal',
      nameEs: 'Riyal Catarí',
      region: 'Middle East',
      flag: '🇶🇦',
    ),
    Currency(
      code: 'KWD',
      symbol: 'د.ك',
      name: 'Kuwaiti Dinar',
      nameEs: 'Dinar Kuwaití',
      decimalDigits: 3,
      region: 'Middle East',
      flag: '🇰🇼',
    ),
    Currency(
      code: 'BHD',
      symbol: '.د.ب',
      name: 'Bahraini Dinar',
      nameEs: 'Dinar Bareiní',
      decimalDigits: 3,
      region: 'Middle East',
      flag: '🇧🇭',
    ),
    Currency(
      code: 'OMR',
      symbol: 'ر.ع.',
      name: 'Omani Rial',
      nameEs: 'Rial Omaní',
      decimalDigits: 3,
      region: 'Middle East',
      flag: '🇴🇲',
    ),
    Currency(
      code: 'JOD',
      symbol: 'د.ا',
      name: 'Jordanian Dinar',
      nameEs: 'Dinar Jordano',
      decimalDigits: 3,
      region: 'Middle East',
      flag: '🇯🇴',
    ),
    Currency(
      code: 'LBP',
      symbol: 'ل.ل',
      name: 'Lebanese Pound',
      nameEs: 'Libra Libanesa',
      region: 'Middle East',
      flag: '🇱🇧',
    ),
    Currency(
      code: 'IRR',
      symbol: '﷼',
      name: 'Iranian Rial',
      nameEs: 'Rial Iraní',
      decimalDigits: 0,
      region: 'Middle East',
      flag: '🇮🇷',
    ),
  ];

  /// Get all currencies as a flat list
  static List<Currency> get allCurrencies {
    final list = <Currency>[];
    for (final region in currenciesByRegion.values) {
      list.addAll(region);
    }
    return list;
  }

  /// Get currency by code
  static Currency? getCurrency(String code) {
    for (final region in currenciesByRegion.values) {
      for (final currency in region) {
        if (currency.code == code) {
          return currency;
        }
      }
    }
    return null;
  }

  /// Get default currency (USD)
  static Currency get defaultCurrency => _northAmerica.first;

  /// Get most common currencies (for quick selection)
  static List<Currency> get popularCurrencies => const [
    Currency(code: 'USD', symbol: '\$', name: 'US Dollar', nameEs: 'Dólar Estadounidense', region: 'North America', flag: '🇺🇸'),
    Currency(code: 'EUR', symbol: '€', name: 'Euro', nameEs: 'Euro', symbolBefore: false, region: 'Europe', flag: '🇪🇺'),
    Currency(code: 'GBP', symbol: '£', name: 'British Pound', nameEs: 'Libra Esterlina', region: 'Europe', flag: '🇬🇧'),
    Currency(code: 'MXN', symbol: 'MX\$', name: 'Mexican Peso', nameEs: 'Peso Mexicano', region: 'North America', flag: '🇲🇽'),
    Currency(code: 'CAD', symbol: 'CA\$', name: 'Canadian Dollar', nameEs: 'Dólar Canadiense', region: 'North America', flag: '🇨🇦'),
    Currency(code: 'AUD', symbol: 'A\$', name: 'Australian Dollar', nameEs: 'Dólar Australiano', region: 'Oceania', flag: '🇦🇺'),
    Currency(code: 'BRL', symbol: 'R\$', name: 'Brazilian Real', nameEs: 'Real Brasileño', region: 'South America', flag: '🇧🇷'),
    Currency(code: 'COP', symbol: 'CO\$', name: 'Colombian Peso', nameEs: 'Peso Colombiano', decimalDigits: 0, region: 'South America', flag: '🇨🇴'),
    Currency(code: 'ARS', symbol: 'AR\$', name: 'Argentine Peso', nameEs: 'Peso Argentino', region: 'South America', flag: '🇦🇷'),
    Currency(code: 'CLP', symbol: 'CL\$', name: 'Chilean Peso', nameEs: 'Peso Chileno', decimalDigits: 0, region: 'South America', flag: '🇨🇱'),
  ];

  /// Get list of all region names
  static List<String> get regionNames => currenciesByRegion.keys.toList();

  /// Get currencies for a specific region
  static List<Currency> getCurrenciesForRegion(String region) {
    return currenciesByRegion[region] ?? [];
  }

  /// Search currencies by name or code
  static List<Currency> search(String query) {
    final lowerQuery = query.toLowerCase();
    return allCurrencies.where((currency) {
      return currency.code.toLowerCase().contains(lowerQuery) ||
             currency.name.toLowerCase().contains(lowerQuery) ||
             currency.nameEs.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
