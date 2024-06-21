import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kasir_app/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(KasirApp());

    // Verify that our counter starts at 0.
    // Di sini kita tidak memiliki counter, jadi saya akan menyesuaikan untuk memverifikasi elemen lain.

    // Verifikasi bahwa tombol "Tambahkan Barang" ditemukan.
    expect(find.text('Tambahkan Barang'), findsOneWidget);

    // Tambahkan item untuk memeriksa apakah elemen lain diperbarui dengan benar.
    await tester.enterText(find.byType(TextField).first, 'Barang Test');
    await tester.enterText(find.byType(TextField).last, '10000');
    await tester.tap(find.text('Tambahkan Barang'));
    await tester.pump();

    // Verifikasi bahwa item telah ditambahkan.
    expect(find.text('Barang Test'), findsOneWidget);
    expect(find.text('Rp 10.000'), findsOneWidget);
  });
}
