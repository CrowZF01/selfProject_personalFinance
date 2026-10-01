import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isBiometricEnabled = true;
  bool _isBudgetAlertEnabled = true;
  bool _isHapticsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            // App Logo Icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F7F0),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFCBEBD8),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                color: Color(0xFF006C49),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'FinLix',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: Color(0xFF757575),
                  ),
                ),
                Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Notification Bell Button
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFFFECE5),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFF3D5C8),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.onSurface,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),

          // Profile Avatar
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 19,
              backgroundColor: const Color(0xFFD4EFE1),
              child: const CircleAvatar(
                radius: 17,
                backgroundColor: Color(0xFFFFDED4),
                child: Icon(
                  Icons.person_rounded,
                  size: 22,
                  color: Color(0xFF8E4C3B),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Profile Card
              _buildUserProfileCard(),
              const SizedBox(height: 12),

              // Membership Banner Card
              _buildMembershipBanner(),
              const SizedBox(height: 20),

              // Section 1: AKUN & KEAMANAN
              _buildSectionTitle('AKUN & KEAMANAN'),
              const SizedBox(height: 8),
              _buildGroupCard([
                _buildSettingsTile(
                  icon: Icons.mail_outline_rounded,
                  title: 'Email Terdaftar',
                  subtitle: 'alex.rivera@example.com',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4EFE1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Terverifikasi',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF006C49),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFF8E9A92)),
                    ],
                  ),
                ),
                _buildSwitchTile(
                  icon: Icons.fingerprint_rounded,
                  title: 'Kunci Biometrik / Face ID',
                  subtitle: 'Amankan dompet saat dibuka',
                  value: _isBiometricEnabled,
                  onChanged: (val) => setState(() => _isBiometricEnabled = val),
                ),
                _buildSettingsTile(
                  icon: Icons.password_rounded,
                  title: 'Ganti PIN FinLix',
                  subtitle: '6 digit keamanan transaksi',
                  trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFF8E9A92)),
                ),
              ]),
              const SizedBox(height: 20),

              // Section 2: PENGATURAN FINANSIAL
              _buildSectionTitle('PENGATURAN FINANSIAL'),
              const SizedBox(height: 8),
              _buildGroupCard([
                _buildSettingsTile(
                  icon: Icons.payments_outlined,
                  title: 'Mata Uang Utama',
                  subtitle: 'Format penulisan saldo',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'IDR (Rp)',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFF8E9A92)),
                    ],
                  ),
                ),
                _buildSettingsTile(
                  icon: Icons.calendar_month_outlined,
                  title: 'Awal Periode / Gajian',
                  subtitle: 'Reset anggaran bulanan',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'Tgl 25 Tiap\nBulan',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFF8E9A92)),
                    ],
                  ),
                ),
                _buildSwitchTile(
                  icon: Icons.notifications_active_outlined,
                  title: 'Peringatan Budget 80%',
                  subtitle: 'Notif santai saat mendekati batas',
                  value: _isBudgetAlertEnabled,
                  onChanged: (val) => setState(() => _isBudgetAlertEnabled = val),
                ),
              ]),
              const SizedBox(height: 20),

              // Section 3: KUSTOMISASI & TAMPILAN
              _buildSectionTitle('KUSTOMISASI & TAMPILAN'),
              const SizedBox(height: 8),
              _buildGroupCard([
                _buildSettingsTile(
                  icon: Icons.palette_outlined,
                  title: 'Tema Aplikasi',
                  subtitle: 'Nuansa visual antarmuka',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0E6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFF3D5C8), width: 1),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFB5A2),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Warm\nPeach',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFF8E9A92)),
                    ],
                  ),
                ),
                _buildSwitchTile(
                  icon: Icons.vibration_rounded,
                  title: 'Sentuhan Haptik & Suara',
                  subtitle: 'Sensasi klik koin kerikil',
                  value: _isHapticsEnabled,
                  onChanged: (val) => setState(() => _isHapticsEnabled = val),
                ),
              ]),
              const SizedBox(height: 20),

              // Section 4: DATA & BANTUAN
              _buildSectionTitle('DATA & BANTUAN'),
              const SizedBox(height: 8),
              _buildGroupCard([
                _buildSettingsTile(
                  icon: Icons.file_download_outlined,
                  title: 'Backup & Ekspor Data',
                  subtitle: 'Unduh riwayat format CSV / Excel',
                  trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFF8E9A92)),
                ),
                _buildSettingsTile(
                  icon: Icons.help_outline_rounded,
                  title: 'Pusat Bantuan & FAQ',
                  subtitle: 'Panduan penggunaan & tips hemat',
                  trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFF8E9A92)),
                ),
                _buildSettingsTile(
                  icon: Icons.shield_outlined,
                  title: 'Kebijakan Privasi',
                  subtitle: 'Enkripsi data pribadi offline-first',
                  trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFF8E9A92)),
                ),
              ]),
              const SizedBox(height: 22),

              // Keluar Akun Button
              _buildLogoutButton(),
              const SizedBox(height: 16),

              // Version & Footer Text
              _buildFooterInfo(),

              // Bottom padding for floating navigation bar
              const SizedBox(height: 90),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF2EB),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.borderSubtle,
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          // Avatar + User Info + Edit Button
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFFD4EFE1),
                    child: const CircleAvatar(
                      radius: 26,
                      backgroundColor: Color(0xFFFFDED4),
                      child: Icon(
                        Icons.person_rounded,
                        size: 34,
                        color: Color(0xFF8E4C3B),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFF006C49),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),

              // Name and Handle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Alex Rivera',
                          style: TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4EFE1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.stars_rounded, size: 12, color: Color(0xFF006C49)),
                              SizedBox(width: 2),
                              Text(
                                'Plus',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF006C49),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '@alexfinances • Anggota sejak Jan 2024',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
              ),

              // Edit Pencil Button
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFECE5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit_outlined,
                  color: AppColors.onSurface,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3 Stats Boxes
          Row(
            children: [
              Expanded(
                child: _buildStatBox(
                  value: '4 Kantong',
                  label: 'Pots Aktif',
                  valueColor: AppColors.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatBox(
                  value: '142 Hari',
                  label: 'Streak Hemat',
                  valueColor: AppColors.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatBox(
                  value: '98%',
                  label: 'Skor Budget',
                  valueColor: const Color(0xFF006C49),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox({
    required String value,
    required String label,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF1E8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF0DDD0),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF757575),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembershipBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF2EB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderSubtle,
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.star_rounded,
              color: Color(0xFFE2A03F),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'FinLix Plus Aktif',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Auto-kategorisasi AI & sinkron multi-device',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF757575),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: Color(0xFF8E9A92),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
        color: Color(0xFF757575),
      ),
    );
  }

  Widget _buildGroupCard(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAF1E8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderSubtle,
          width: 1.2,
        ),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final bool isLast = index == items.length - 1;
          return Column(
            children: [
              items[index],
              if (!isLast)
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.divider,
                  indent: 14,
                  endIndent: 14,
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF3E6DA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF6E7A72),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF757575),
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF3E6DA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF6E7A72),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF757575),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => onChanged(!value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 46,
              height: 26,
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                color: value ? const Color(0xFF006C49) : const Color(0xFFE2CFC2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Align(
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 21,
                  height: 21,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFECE5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFCCD0),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.logout_rounded,
            color: Color(0xFFBD382B),
            size: 20,
          ),
          SizedBox(width: 8),
          Text(
            'Keluar Akun',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFFBD382B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterInfo() {
    return Center(
      child: Column(
        children: const [
          Text(
            'FinLix v2.4.0 (Flutter Release)',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF8E9A92),
            ),
          ),
          SizedBox(height: 3),
          Text(
            'Dibuat dengan rasa tenang untuk finansialmu',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF8E9A92),
            ),
          ),
        ],
      ),
    );
  }
}
