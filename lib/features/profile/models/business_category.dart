import 'package:facturo/generated/l10n/app_localizations.dart';

class BusinessCategory {
  final String id;
  final String name;
  final String description;
  final String icon;

  const BusinessCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });

  // Factory method to create translated categories
  factory BusinessCategory.translated({
    required String id,
    required String nameKey,
    required String descriptionKey,
    required String icon,
    required AppLocalizations localizations,
  }) {
    return BusinessCategory(
      id: id,
      name: _getTranslation(localizations, nameKey),
      description: _getTranslation(localizations, descriptionKey),
      icon: icon,
    );
  }

  static String _getTranslation(AppLocalizations localizations, String key) {
    // This will dynamically get the translation based on the key
    // We need to handle this carefully to avoid runtime errors
    switch (key) {
      case 'businessCategoryRetail':
        return localizations.businessCategoryRetail;
      case 'businessCategoryRetailDesc':
        return localizations.businessCategoryRetailDesc;
      case 'businessCategoryFoodBeverage':
        return localizations.businessCategoryFoodBeverage;
      case 'businessCategoryFoodBeverageDesc':
        return localizations.businessCategoryFoodBeverageDesc;
      case 'businessCategoryProfessionalServices':
        return localizations.businessCategoryProfessionalServices;
      case 'businessCategoryProfessionalServicesDesc':
        return localizations.businessCategoryProfessionalServicesDesc;
      case 'businessCategoryHealthBeauty':
        return localizations.businessCategoryHealthBeauty;
      case 'businessCategoryHealthBeautyDesc':
        return localizations.businessCategoryHealthBeautyDesc;
      case 'businessCategoryConstruction':
        return localizations.businessCategoryConstruction;
      case 'businessCategoryConstructionDesc':
        return localizations.businessCategoryConstructionDesc;
      case 'businessCategoryAutomotive':
        return localizations.businessCategoryAutomotive;
      case 'businessCategoryAutomotiveDesc':
        return localizations.businessCategoryAutomotiveDesc;
      case 'businessCategoryTechnology':
        return localizations.businessCategoryTechnology;
      case 'businessCategoryTechnologyDesc':
        return localizations.businessCategoryTechnologyDesc;
      case 'businessCategoryEducation':
        return localizations.businessCategoryEducation;
      case 'businessCategoryEducationDesc':
        return localizations.businessCategoryEducationDesc;
      case 'businessCategoryRealEstate':
        return localizations.businessCategoryRealEstate;
      case 'businessCategoryRealEstateDesc':
        return localizations.businessCategoryRealEstateDesc;
      case 'businessCategoryManufacturing':
        return localizations.businessCategoryManufacturing;
      case 'businessCategoryManufacturingDesc':
        return localizations.businessCategoryManufacturingDesc;
      case 'businessCategoryAgriculture':
        return localizations.businessCategoryAgriculture;
      case 'businessCategoryAgricultureDesc':
        return localizations.businessCategoryAgricultureDesc;
      case 'businessCategoryTransportation':
        return localizations.businessCategoryTransportation;
      case 'businessCategoryTransportationDesc':
        return localizations.businessCategoryTransportationDesc;
      case 'businessCategoryEntertainment':
        return localizations.businessCategoryEntertainment;
      case 'businessCategoryEntertainmentDesc':
        return localizations.businessCategoryEntertainmentDesc;
      case 'businessCategoryWholesale':
        return localizations.businessCategoryWholesale;
      case 'businessCategoryWholesaleDesc':
        return localizations.businessCategoryWholesaleDesc;
      case 'businessCategoryCreative':
        return localizations.businessCategoryCreative;
      case 'businessCategoryCreativeDesc':
        return localizations.businessCategoryCreativeDesc;
      case 'businessCategoryOther':
        return localizations.businessCategoryOther;
      case 'businessCategoryOtherDesc':
        return localizations.businessCategoryOtherDesc;
      default:
        return key; // Fallback to key if translation not found
    }
  }
}

// Función para obtener categorías traducidas
List<BusinessCategory> getBusinessCategories(AppLocalizations localizations) {
  return [
    BusinessCategory.translated(
      id: 'retail',
      nameKey: 'businessCategoryRetail',
      descriptionKey: 'businessCategoryRetailDesc',
      icon: '🏪',
      localizations: localizations,
    ),
    BusinessCategory.translated(
      id: 'food_beverage',
      nameKey: 'businessCategoryFoodBeverage',
      descriptionKey: 'businessCategoryFoodBeverageDesc',
      icon: '🍽️',
      localizations: localizations,
    ),
    BusinessCategory.translated(
      id: 'professional_services',
      nameKey: 'businessCategoryProfessionalServices',
      descriptionKey: 'businessCategoryProfessionalServicesDesc',
      icon: '💼',
      localizations: localizations,
    ),
    BusinessCategory.translated(
      id: 'health_beauty',
      nameKey: 'businessCategoryHealthBeauty',
      descriptionKey: 'businessCategoryHealthBeautyDesc',
      icon: '💆‍♀️',
      localizations: localizations,
    ),
    BusinessCategory.translated(
      id: 'construction',
      nameKey: 'businessCategoryConstruction',
      descriptionKey: 'businessCategoryConstructionDesc',
      icon: '🏗️',
      localizations: localizations,
    ),
    BusinessCategory.translated(
      id: 'automotive',
      nameKey: 'businessCategoryAutomotive',
      descriptionKey: 'businessCategoryAutomotiveDesc',
      icon: '🚗',
      localizations: localizations,
    ),
    BusinessCategory.translated(
      id: 'technology',
      nameKey: 'businessCategoryTechnology',
      descriptionKey: 'businessCategoryTechnologyDesc',
      icon: '💻',
      localizations: localizations,
    ),
    BusinessCategory.translated(
      id: 'education',
      nameKey: 'businessCategoryEducation',
      descriptionKey: 'businessCategoryEducationDesc',
      icon: '📚',
      localizations: localizations,
    ),
    BusinessCategory.translated(
      id: 'real_estate',
      nameKey: 'businessCategoryRealEstate',
      descriptionKey: 'businessCategoryRealEstateDesc',
      icon: '🏠',
      localizations: localizations,
    ),
    BusinessCategory.translated(
      id: 'manufacturing',
      nameKey: 'businessCategoryManufacturing',
      descriptionKey: 'businessCategoryManufacturingDesc',
      icon: '🏭',
      localizations: localizations,
    ),
    BusinessCategory.translated(
      id: 'agriculture',
      nameKey: 'businessCategoryAgriculture',
      descriptionKey: 'businessCategoryAgricultureDesc',
      icon: '🌾',
      localizations: localizations,
    ),
    BusinessCategory.translated(
      id: 'transportation',
      nameKey: 'businessCategoryTransportation',
      descriptionKey: 'businessCategoryTransportationDesc',
      icon: '🚚',
      localizations: localizations,
    ),
    BusinessCategory.translated(
      id: 'entertainment',
      nameKey: 'businessCategoryEntertainment',
      descriptionKey: 'businessCategoryEntertainmentDesc',
      icon: '🎭',
      localizations: localizations,
    ),
    BusinessCategory.translated(
      id: 'wholesale',
      nameKey: 'businessCategoryWholesale',
      descriptionKey: 'businessCategoryWholesaleDesc',
      icon: '📦',
      localizations: localizations,
    ),
    BusinessCategory.translated(
      id: 'creative',
      nameKey: 'businessCategoryCreative',
      descriptionKey: 'businessCategoryCreativeDesc',
      icon: '🎨',
      localizations: localizations,
    ),
    BusinessCategory.translated(
      id: 'other',
      nameKey: 'businessCategoryOther',
      descriptionKey: 'businessCategoryOtherDesc',
      icon: '✨',
      localizations: localizations,
    ),
  ];
}

// Lista de categorías de negocio comunes en Estados Unidos y Latinoamérica (DEPRECATED)
// Mantener por compatibilidad, pero usar getBusinessCategories() en su lugar
@Deprecated('Use getBusinessCategories() instead')
const List<BusinessCategory> businessCategories = [
  BusinessCategory(
    id: 'retail',
    name: 'Comercio Minorista',
    description: 'Tiendas, boutiques y comercios al por menor',
    icon: '🏪',
  ),
  BusinessCategory(
    id: 'food_beverage',
    name: 'Alimentos y Bebidas',
    description: 'Restaurantes, cafeterías, bares y servicios de catering',
    icon: '🍽️',
  ),
  BusinessCategory(
    id: 'professional_services',
    name: 'Servicios Profesionales',
    description: 'Consultoría, legal, contabilidad y servicios empresariales',
    icon: '💼',
  ),
  BusinessCategory(
    id: 'health_beauty',
    name: 'Salud y Belleza',
    description: 'Salones, spas, gimnasios y servicios de bienestar',
    icon: '💆‍♀️',
  ),
  BusinessCategory(
    id: 'construction',
    name: 'Construcción y Contratistas',
    description: 'Servicios de construcción, remodelación y mantenimiento',
    icon: '🏗️',
  ),
  BusinessCategory(
    id: 'automotive',
    name: 'Automotriz',
    description: 'Talleres, venta de repuestos y servicios automotrices',
    icon: '🚗',
  ),
  BusinessCategory(
    id: 'technology',
    name: 'Tecnología',
    description:
        'Servicios informáticos, desarrollo de software y reparaciones',
    icon: '💻',
  ),
  BusinessCategory(
    id: 'education',
    name: 'Educación y Capacitación',
    description: 'Escuelas, academias y centros de formación',
    icon: '📚',
  ),
  BusinessCategory(
    id: 'real_estate',
    name: 'Bienes Raíces',
    description: 'Venta, alquiler y administración de propiedades',
    icon: '🏠',
  ),
  BusinessCategory(
    id: 'manufacturing',
    name: 'Manufactura',
    description: 'Producción y fabricación de productos',
    icon: '🏭',
  ),
  BusinessCategory(
    id: 'agriculture',
    name: 'Agricultura y Ganadería',
    description: 'Producción agrícola, ganadera y servicios relacionados',
    icon: '🌾',
  ),
  BusinessCategory(
    id: 'transportation',
    name: 'Transporte y Logística',
    description: 'Servicios de transporte, envíos y almacenamiento',
    icon: '🚚',
  ),
  BusinessCategory(
    id: 'entertainment',
    name: 'Entretenimiento y Eventos',
    description: 'Organización de eventos, entretenimiento y recreación',
    icon: '🎭',
  ),
  BusinessCategory(
    id: 'wholesale',
    name: 'Comercio Mayorista',
    description: 'Distribución y venta al por mayor',
    icon: '📦',
  ),
  BusinessCategory(
    id: 'creative',
    name: 'Servicios Creativos',
    description: 'Diseño, publicidad, marketing y medios',
    icon: '🎨',
  ),
  BusinessCategory(
    id: 'other',
    name: 'Otro',
    description: 'Otro tipo de negocio no listado',
    icon: '✨',
  ),
];
