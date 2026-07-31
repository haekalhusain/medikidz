import 'package:flutter/material.dart';
import '../../widgets/logout_button.dart';

/// Header identik dengan yang dipakai di AdminDashboardHome (logo klinik,
/// tombol notifikasi, tombol profil). Ditarik jadi widget terpisah supaya
/// tampilannya konsisten di semua tab (Home, Vaksin, Artikel, Profile)
/// tanpa copy-paste kode AppBar berulang kali.
PreferredSizeWidget buildMedikidzHeaderAppBar() {
  const primaryTeal = Color(0xFF38B2AC);

  return AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    toolbarHeight: 70,
    title: Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/logo.png',
            height: 32,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.child_care, color: primaryTeal, size: 30),
          ),
          const SizedBox(height: 2),
          Image.asset(
            'assets/logo2.png',
            height: 12,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Text(
              'KLINIK & APOTEK MediKidz',
              style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.black54),
            ),
          ),
        ],
      ),
    ),
    actions: [
      Center(
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: const BoxDecoration(color: Color(0xFFE6FFFA), shape: BoxShape.circle),
          child: Stack(
            children: [
              const IconButton(
                icon: Icon(Icons.notifications_none_rounded, color: primaryTeal, size: 22),
                onPressed: null,
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                  child: const Text('1',
                      style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center),
                ),
              ),
            ],
          ),
        ),
      ),
      Center(
        child: Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: const BoxDecoration(color: Color(0xFFE6FFFA), shape: BoxShape.circle),
          child: const LogoutButton(),
        ),
      ),
    ],
  );
}
