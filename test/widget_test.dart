import 'package:flutter_test/flutter_test.dart';
import 'package:household_ledger/core/constants/categories.dart';
import 'package:household_ledger/core/utils/formatters.dart';

void main() {
  test('all 12 expense categories are defined with unique ids', () {
    expect(kCategories.length, 12);
    final ids = kCategories.map((c) => c.id).toSet();
    expect(ids.length, 12);
  });

  test('cash to person and gifts support a recipient', () {
    expect(categoryById('cash_to_person').supportsRecipient, isTrue);
    expect(categoryById('gifts').supportsRecipient, isTrue);
    expect(categoryById('water').supportsRecipient, isFalse);
  });

  test('money formatting renders two decimal places', () {
    expect(Formatters.money(42), '\$42.00');
  });
}
