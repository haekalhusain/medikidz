
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Basic smoke test untuk 

import 'package:medikidz/maindart_backup.txt';

void main() {
  testWidgets('RoleSelectionPage menampilkan judul dan 2 tombol', (WidgetTester tester) async {
    await tester.pumpWidget(const MedikidzApp());

    // Verifikasi judul app muncul
    expect(find.text('Medikidz'), findsOneWidget);

    // Verifikasi 2 tombol pilihan role muncul
    expect(find.text('Admin'), findsOneWidget);
    expect(find.text('Pengguna'), findsOneWidget);
  });
}