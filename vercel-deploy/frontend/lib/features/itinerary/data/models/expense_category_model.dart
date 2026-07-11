import 'package:freezed_annotation/freezed_annotation.dart';

part 'expense_category_model.freezed.dart';
part 'expense_category_model.g.dart';

/// Predefined expense categories
enum ExpenseCategoryType {
  accommodation,
  transportation,
  foodAndBeverage,
  attractions,
  itinerary,
  communication,
  others,
}

@freezed
class ExpenseCategory with _$ExpenseCategory {
  const ExpenseCategory._();

  const factory ExpenseCategory({
    required int id,
    required String name,
    required String slug,
    required String icon,
    String? description,
    @Default(false) bool isCustom,
  }) = _ExpenseCategory;

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) =>
      _$ExpenseCategoryFromJson(json);

  /// Default categories based on PRD
  static List<ExpenseCategory> get defaultCategories => [
    const ExpenseCategory(
      id: 1,
      name: 'Akomodasi',
      slug: 'accommodation',
      icon: 'hotel',
      description: 'Hotel, villa, homestay, hostel, camping',
    ),
    const ExpenseCategory(
      id: 2,
      name: 'Transportasi',
      slug: 'transportation',
      icon: 'directions_car',
      description: 'Pesawat, kereta, sewa motor, ojek online',
    ),
    const ExpenseCategory(
      id: 3,
      name: 'Konsumsi',
      slug: 'food_and_beverage',
      icon: 'restaurant',
      description: 'Makan, jajan, air minum',
    ),
    const ExpenseCategory(
      id: 4,
      name: 'Atraksi & Hiburan',
      slug: 'attractions',
      icon: 'attractions',
      description: 'Tiket wisata, wahana, tur lokal',
    ),
    const ExpenseCategory(
      id: 5,
      name: 'Itinerary',
      slug: 'itinerary',
      icon: 'schedule',
      description: 'Jadwal atau rencana kegiatan',
    ),
    const ExpenseCategory(
      id: 6,
      name: 'Komunikasi & Dokumen',
      slug: 'communication',
      icon: 'phone',
      description: 'Paket data, paspor, visa, asuransi',
    ),
    const ExpenseCategory(
      id: 7,
      name: 'Lainnya',
      slug: 'others',
      icon: 'more_horiz',
      description: 'Pengeluaran lainnya',
    ),
  ];

  /// Get icon name for Material Icons
  String get iconName => icon;

  /// Check if this is the default category
  bool get isDefault => id <= 7 && !isCustom;
}

/// Extension to get category from slug
extension ExpenseCategoryExtension on List<ExpenseCategory> {
  ExpenseCategory? findBySlug(String slug) {
    try {
      return firstWhere((c) => c.slug == slug);
    } catch (_) {
      return null;
    }
  }

  ExpenseCategory? findByName(String name) {
    try {
      return firstWhere((c) => c.name.toLowerCase() == name.toLowerCase());
    } catch (_) {
      return null;
    }
  }
}
