import 'package:flutter/material.dart';

class HubungiKlinikPage extends StatelessWidget {
  const HubungiKlinikPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Hubungi Klinik'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Informasi Klinik & Lokasi
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.local_hospital, color: Colors.blueGrey.shade700, size: 28),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Klinik Medikidz Banjarbaru',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on, color: Colors.redAccent, size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Jl. Rantau, Guntung Payung, Landasan Ulin, Banjarbaru',
                          style: TextStyle(fontSize: 15, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            Divider(color: Colors.grey.shade200, thickness: 1, height: 1),

            // 2. Jam Operasional
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Jam Operasional Klinik',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildListTileBullet('Senin-Jumat', '16.00 - 21.00'),
                  const SizedBox(height: 6),
                  _buildListTileBullet('Khusus Sabtu', '15.00 - 18.00'),
                ],
              ),
            ),

            Divider(color: Colors.grey.shade200, thickness: 1, height: 1),

            // 3. Kontak Resmi (WhatsApp Card)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kontak Resmi (Klik Untuk Menghubungi)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  // Kartu WhatsApp
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF25D366), // Warna hijau khas WhatsApp
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        // Header WA
                        Row(
                          children: [
                            const Icon(Icons.wechat, color: Colors.white, size: 40), // Placeholder icon WA
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Segera Hubungi!',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Ada kendala? Langsung chat aja!',
                                    style: TextStyle(
                                      // ignore: deprecated_member_use
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Badge Info CS
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
                            color: Colors.white.withOpacity(0.2), // Transparan putih
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'CS Aktif Setiap Hari, 07.00-20.00 WITA',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Tombol Buka WhatsApp
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('tombol direct ke wa, belum bisa berfungsi untuk saat ini'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF25D366), // Text warna hijau
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: const Text(
                              'Buka WhatsApp',
                              style: TextStyle(
                                fontSize: 15, 
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper untuk membuat list jadwal rapi
  Widget _buildListTileBullet(String hari, String jam) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('\u2022', style: TextStyle(fontSize: 16, height: 1.2)),
        const SizedBox(width: 8),
        SizedBox(
          width: 100, // Menjaga lebar text hari agar titik duanya sejajar
          child: Text(
            hari,
            style: const TextStyle(fontSize: 15, height: 1.2),
          ),
        ),
        Text(
          ': $jam',
          style: const TextStyle(fontSize: 15, height: 1.2),
        ),
      ],
    );
  }
}