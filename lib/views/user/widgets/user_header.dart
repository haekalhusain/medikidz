import 'package:flutter/material.dart';
import '../../notification/notifikasi_page.dart';
import '../profile/profil_anda_page.dart';

/// Header khusus untuk halaman-halaman Role User.
PreferredSizeWidget buildUserTopBar(
  BuildContext context, {
  bool showDivider = true,
  bool hideNotification = false,
  bool hideProfileIcon = false,
  bool showBackButton = false,
}) {
  const primaryTeal = Color(0xFF00A884);
  const lightTealBg = Color(0xFFE8F7F2);

  return PreferredSize(
    preferredSize: Size.fromHeight(showDivider ? 84 : 67),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          toolbarHeight: 67,
          titleSpacing: 16,
          leading: showBackButton
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: primaryTeal),
                  onPressed: () => Navigator.of(context).pop(),
                )
              : null,
          title: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logo.png',
                    height: 30,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.local_hospital,
                      color: primaryTeal,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Image.asset(
                    'assets/logo2.png',
                    height: 12,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Text(
                      'MediKidz',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: primaryTeal,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            if (!hideNotification)
              Center(
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: const BoxDecoration(
                    color: lightTealBg,
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.notifications_none_rounded,
                          color: primaryTeal,
                          size: 22,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  const NotifikasiPage(adminMode: false),
                            ),
                          );
                        },
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 14,
                            minHeight: 14,
                          ),
                          child: const Text(
                            '3',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (!hideProfileIcon)
              Center(
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  decoration: const BoxDecoration(
                    color: lightTealBg,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.person, color: primaryTeal, size: 22),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ProfilAndaPage()),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
        if (showDivider)
          Container(
            height: 2.0,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFFA3D9CD), Color(0xFFC5BC9B)],
              ),
            ),
          ),
      ],
    ),
  );
}
