import 'package:flutter/material.dart';

/// Fixed set of household expense categories tracked by the app.
enum ExpenseCategory {
  household,
  water,
  gas,
  internet,
  fuel,
  electricity,
  mobile,
  education,
  localTraveling,
  charity,
  gifts,
  cashToPerson,
}

class CategoryInfo {
  final ExpenseCategory category;
  final String id;
  final String label;
  final IconData icon;
  final Color color;

  /// Whether entries in this category can be attributed to a named person
  /// (e.g. "Cash to person", "Gifts").
  final bool supportsRecipient;

  const CategoryInfo({
    required this.category,
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    this.supportsRecipient = false,
  });
}

const List<CategoryInfo> kCategories = [
  CategoryInfo(
    category: ExpenseCategory.household,
    id: 'household',
    label: 'Household',
    icon: Icons.home_rounded,
    color: Color(0xFF6C63FF),
  ),
  CategoryInfo(
    category: ExpenseCategory.water,
    id: 'water',
    label: 'Water',
    icon: Icons.water_drop_rounded,
    color: Color(0xFF2FA4E7),
  ),
  CategoryInfo(
    category: ExpenseCategory.gas,
    id: 'gas',
    label: 'Gas',
    icon: Icons.local_fire_department_rounded,
    color: Color(0xFFFF7A45),
  ),
  CategoryInfo(
    category: ExpenseCategory.internet,
    id: 'internet',
    label: 'Internet',
    icon: Icons.wifi_rounded,
    color: Color(0xFF17B2A5),
  ),
  CategoryInfo(
    category: ExpenseCategory.fuel,
    id: 'fuel',
    label: 'Fuel',
    icon: Icons.local_gas_station_rounded,
    color: Color(0xFFE0562D),
  ),
  CategoryInfo(
    category: ExpenseCategory.electricity,
    id: 'electricity',
    label: 'Electricity',
    icon: Icons.bolt_rounded,
    color: Color(0xFFF5B400),
  ),
  CategoryInfo(
    category: ExpenseCategory.mobile,
    id: 'mobile',
    label: 'Mobile',
    icon: Icons.smartphone_rounded,
    color: Color(0xFF5C7CFA),
  ),
  CategoryInfo(
    category: ExpenseCategory.education,
    id: 'education',
    label: 'Education',
    icon: Icons.school_rounded,
    color: Color(0xFF7C4DFF),
  ),
  CategoryInfo(
    category: ExpenseCategory.localTraveling,
    id: 'local_traveling',
    label: 'Local Traveling',
    icon: Icons.directions_car_filled_rounded,
    color: Color(0xFF00B8A9),
  ),
  CategoryInfo(
    category: ExpenseCategory.charity,
    id: 'charity',
    label: 'Charity',
    icon: Icons.volunteer_activism_rounded,
    color: Color(0xFFE7527D),
  ),
  CategoryInfo(
    category: ExpenseCategory.gifts,
    id: 'gifts',
    label: 'Gifts',
    icon: Icons.card_giftcard_rounded,
    color: Color(0xFFEF6C9E),
    supportsRecipient: true,
  ),
  CategoryInfo(
    category: ExpenseCategory.cashToPerson,
    id: 'cash_to_person',
    label: 'Cash to Person',
    icon: Icons.payments_rounded,
    color: Color(0xFF4CAF7D),
    supportsRecipient: true,
  ),
];

final Map<String, CategoryInfo> kCategoriesById = {
  for (final c in kCategories) c.id: c,
};

CategoryInfo categoryById(String id) =>
    kCategoriesById[id] ?? kCategories.first;
