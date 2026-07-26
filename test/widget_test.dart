// import 'package:flutter/material.dart'; // Bisa dihapus karena tidak terpakai di file ini
import 'package:flutter_test/flutter_test.dart';
import 'package:medikidz/main.dart'; 

void main() {
  testWidgets('RoleSelectionPage menampilkan judul dan 2 tombol', (WidgetTester tester) async {
    // Membangun widget utama aplikasi
    await tester.pumpWidget(const MedikidzApp());

    // Verifikasi judul app muncul
    // Menggunakan findsWidgets lebih aman jika kata 'Medikidz' muncul lebih dari 1 kali di layar
    expect(find.text('Medikidz'), findsWidgets); 

    // Verifikasi 2 tombol pilihan role muncul
    expect(find.text('Admin'), findsOneWidget);
    expect(find.text('Pengguna'), findsOneWidget);
  });
}