import 'package:flutter_test/flutter_test.dart';
import 'package:medicines_for_children_flutter/features/medicines/domain/qr_medicine_catalog.dart';

void main() {
  test('parseQrScanResult resolves medicine entries', () {
    const url = 'https://www.medicinesforchildren.org.uk/medicines/amoxicillin-for-bacterial-infections/';
    final result = parseQrScanResult(url);

    expect(result.type, QrScanType.medicine);
    expect(result.medicine?.name, 'Amoxicillin');
  });

  test('parseQrScanResult resolves advice entries', () {
    const url =
        'https://www.medicinesforchildren.org.uk/advice-guides/giving-medicines/how-to-give-medicines-tablets/';
    final result = parseQrScanResult(url);

    expect(result.type, QrScanType.advice);
    expect(result.advice?.title, 'How to give medicines: tablets');
  });

  test('parseQrScanResult resolves external entries without trailing slash', () {
    const url = 'https://www.medicinesforchildren.org.uk';
    final result = parseQrScanResult(url);

    expect(result.type, QrScanType.external);
    expect(result.external?.title, 'Medicines for Children');
  });

  test('parseQrScanResult marks unknown values', () {
    const url = 'https://example.com/not-in-catalog';
    final result = parseQrScanResult(url);

    expect(result.type, QrScanType.unknown);
  });
}
