import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/dio_client.dart';

import '../../core/theme/theme_cubit.dart';
import '../../core/service_locator.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  Map<String, dynamic>? _user;
  bool _isLoading = true;
  bool _isEditingInfo = false;
  bool _isSavingInfo = false;

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final dio = sl<DioClient>().dio;
      final res = await dio.get('/Profile');
      setState(() {
        _user = res.data;
        _nameCtrl.text = _user?['fullName'] ?? '';
        _phoneCtrl.text = _user?['phoneNumber'] ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveBasicInfo() async {
    setState(() => _isSavingInfo = true);
    try {
      final dio = sl<DioClient>().dio;
      await dio.put(
        '/Profile',
        data: {
          'fullName': _nameCtrl.text.trim(),
          'phoneNumber': _phoneCtrl.text.trim(),
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 18),
                SizedBox(width: 10),
                Text('Cập nhật thông tin thành công!'),
              ],
            ),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
        _loadProfile();
        setState(() => _isEditingInfo = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 18),
                SizedBox(width: 10),
                Text('Có lỗi xảy ra khi lưu'),
              ],
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() => _isSavingInfo = false);
    }
  }

  void _showChangePasswordDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (ctx, a1, a2) => const _ChangePasswordDialog(),
      transitionBuilder: (ctx, a1, a2, child) {
        final curved = CurvedAnimation(parent: a1, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: Tween<double>(begin: 0.85, end: 1.0).animate(curved),
          child: FadeTransition(opacity: a1, child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = context.watch<ThemeCubit>().isDark;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_user == null) {
      return const Center(child: Text('Lỗi tải dữ liệu'));
    }

    final fullName = (_user!['fullName'] as String? ?? '').trim();
    final username = _user!['username'] as String? ?? '';
    final email = _user!['email'] as String? ?? '';
    final phone = _user!['phoneNumber'] as String? ?? '';
    final role = _user!['role'] as String? ?? 'Nhân viên';
    final jobTitle = _user!['jobTitle'] as String? ?? '';
    final initial = fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 32, 32, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── HEADER CARD ─────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: isDark
                  ? const LinearGradient(
                      colors: [Color(0xFF1E1B4B), Color(0xFF1E293B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(
                    0xFF6366F1,
                  ).withValues(alpha: isDark ? 0.2 : 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.2),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                      width: 2.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: const TextStyle(
                        fontSize: 34,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                // Name & Meta
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName.isEmpty ? username : fullName,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _MetaBadge(
                            label: username.startsWith('@')
                                ? username
                                : '@$username',
                            icon: Icons.tag_rounded,
                          ),
                          const SizedBox(width: 10),
                          _MetaBadge(label: role, icon: Icons.shield_outlined),
                          if (jobTitle.isNotEmpty) ...[
                            const SizedBox(width: 10),
                            _MetaBadge(
                              label: jobTitle,
                              icon: Icons.work_outline_rounded,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Action buttons
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _WhiteOutlineBtn(
                      label: 'Đổi mật khẩu',
                      icon: Icons.lock_reset_rounded,
                      onTap: _showChangePasswordDialog,
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ── THÔNG TIN CÁ NHÂN ────────────────────────────────────────────
          _SectionCard(
            colors: colors,
            title: 'Thông tin cá nhân',
            subtitle: 'Các thông tin định danh của tài khoản',
            icon: Icons.person_outline_rounded,
            iconColor: const Color(0xFF6366F1),
            child: Column(
              children: [
                // Row 1: username & email (read-only)
                Row(
                  children: [
                    Expanded(
                      child: _InfoField(
                        label: 'Tên người dùng',
                        value: username,
                        icon: Icons.alternate_email_rounded,
                        colors: colors,
                        readOnly: true,
                        badge: 'Không thể đổi',
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _InfoField(
                        label: 'Email',
                        value: email.isEmpty ? 'Chưa cập nhật' : email,
                        icon: Icons.email_outlined,
                        colors: colors,
                        readOnly: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Row 2: role & jobTitle (read-only)
                Row(
                  children: [
                    Expanded(
                      child: _InfoField(
                        label: 'Vai trò',
                        value: role,
                        icon: Icons.shield_outlined,
                        colors: colors,
                        readOnly: true,
                        roleColor: _roleColor(role),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _InfoField(
                        label: 'Chức danh',
                        value: jobTitle.isEmpty ? 'Chưa cập nhật' : jobTitle,
                        icon: Icons.work_outline_rounded,
                        colors: colors,
                        readOnly: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── THÔNG TIN CÓ THỂ CHỈNH SỬA ─────────────────────────────────
          _SectionCard(
            colors: colors,
            title: 'Thông tin cá nhân có thể chỉnh sửa',
            subtitle: _isEditingInfo
                ? 'Đang ở chế độ chỉnh sửa'
                : 'Họ tên và số điện thoại',
            icon: Icons.edit_note_rounded,
            iconColor: const Color(0xFF10B981),
            headerTrailing: _isEditingInfo
                ? null
                : ElevatedButton.icon(
                    onPressed: () => setState(() => _isEditingInfo = true),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text(
                      'Chỉnh sửa',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                  ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _isEditingInfo
                          ? _EditableField(
                              label: 'Họ và tên',
                              controller: _nameCtrl,
                              icon: Icons.badge_outlined,
                              colors: colors,
                            )
                          : _InfoField(
                              label: 'Họ và tên',
                              value: fullName.isEmpty
                                  ? 'Chưa cập nhật'
                                  : fullName,
                              icon: Icons.badge_outlined,
                              colors: colors,
                            ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _isEditingInfo
                          ? _EditableField(
                              label: 'Số điện thoại',
                              controller: _phoneCtrl,
                              icon: Icons.phone_outlined,
                              colors: colors,
                              keyboardType: TextInputType.phone,
                            )
                          : _InfoField(
                              label: 'Số điện thoại',
                              value: phone.isEmpty ? 'Chưa cập nhật' : phone,
                              icon: Icons.phone_outlined,
                              colors: colors,
                            ),
                    ),
                  ],
                ),
                if (_isEditingInfo) ...[
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isEditingInfo = false;
                            _nameCtrl.text = _user?['fullName'] ?? '';
                            _phoneCtrl.text = _user?['phoneNumber'] ?? '';
                          });
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          foregroundColor: colors.textSecond,
                        ),
                        child: const Text(
                          'Hủy',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _isSavingInfo ? null : _saveBasicInfo,
                        icon: _isSavingInfo
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.check_rounded, size: 18),
                        label: Text(
                          _isSavingInfo ? 'Đang lưu...' : 'Lưu thay đổi',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── BẢO MẬT ─────────────────────────────────────────────────────
          _SectionCard(
            colors: colors,
            title: 'Bảo mật & Đăng nhập',
            subtitle: 'Quản lý mật khẩu và phương thức xác thực',
            icon: Icons.security_rounded,
            iconColor: const Color(0xFFF59E0B),
            child: Row(
              children: [
                Expanded(
                  child: _SecurityItem(
                    colors: colors,
                    icon: Icons.lock_outline_rounded,
                    iconColor: const Color(0xFFF59E0B),
                    title: 'Mật khẩu',
                    desc: 'Thay đổi mật khẩu đăng nhập của bạn',
                    btnLabel: 'Đổi mật khẩu',
                    btnColor: const Color(0xFFF59E0B),
                    onTap: _showChangePasswordDialog,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _SecurityItem(
                    colors: colors,
                    icon: Icons.email_outlined,
                    iconColor: const Color(0xFF6366F1),
                    title: 'Xác thực Gmail',
                    desc: 'OTP được gửi qua Gmail khi đổi mật khẩu',
                    btnLabel: 'Đổi Gmail',
                    btnColor: const Color(0xFF6366F1),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Chức năng đang phát triển'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _roleColor(String role) {
    return switch (role.toLowerCase()) {
      'admin' => const Color(0xFFEF4444),
      'manager' => const Color(0xFFF59E0B),
      _ => const Color(0xFF10B981),
    };
  }
}

// ─────────────────────────────────────────────────────────────
// Helper widgets
// ─────────────────────────────────────────────────────────────

class _MetaBadge extends StatelessWidget {
  const _MetaBadge({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white70),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _WhiteOutlineBtn extends StatelessWidget {
  const _WhiteOutlineBtn({
    required this.label,
    required this.icon,
    required this.onTap,
    this.filled = false,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return filled
        ? ElevatedButton.icon(
            onPressed: onTap,
            icon: Icon(icon, size: 16),
            label: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF6366F1),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
          )
        : OutlinedButton.icon(
            onPressed: onTap,
            icon: Icon(icon, size: 16),
            label: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white54),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.colors,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.child,
    this.headerTrailing,
  });

  final _AppColorTokens colors;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Widget child;
  final Widget? headerTrailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: colors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 13, color: colors.textSecond),
                    ),
                  ],
                ),
              ),
              if (headerTrailing != null) headerTrailing!,
            ],
          ),
          const SizedBox(height: 24),
          Divider(color: colors.border, height: 1),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}

class _InfoField extends StatelessWidget {
  const _InfoField({
    required this.label,
    required this.value,
    required this.icon,
    required this.colors,
    this.readOnly = false,
    this.badge,
    this.roleColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final _AppColorTokens colors;
  final bool readOnly;
  final String? badge;
  final Color? roleColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: colors.textSecond),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: colors.textSecond,
                letterSpacing: 0.3,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge!,
                  style: TextStyle(
                    fontSize: 10,
                    color: colors.textSecond,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: readOnly
                ? colors.bgApp.withValues(alpha: 0.6)
                : colors.bgApp,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colors.border),
          ),
          child: roleColor != null
              ? Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: roleColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      value,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              : Text(
                  value,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
      ],
    );
  }
}

class _EditableField extends StatelessWidget {
  const _EditableField({
    required this.label,
    required this.controller,
    required this.icon,
    required this.colors,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final _AppColorTokens colors;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: const Color(0xFF6366F1)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6366F1),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF6366F1).withValues(alpha: 0.06),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFF6366F1),
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFF6366F1),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class _SecurityItem extends StatelessWidget {
  const _SecurityItem({
    required this.colors,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.desc,
    required this.btnLabel,
    required this.btnColor,
    required this.onTap,
  });

  final _AppColorTokens colors;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String desc;
  final String btnLabel;
  final Color btnColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.bgApp,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.textSecond,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: btnColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              btnLabel,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Change Password Dialog
// ─────────────────────────────────────────────────────────────

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();
  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  int _step = 1;
  bool _isLoading = false;
  bool _obscureOld = true;
  bool _obscureNew = true;

  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();

  Future<void> _requestOtp() async {
    setState(() => _isLoading = true);
    try {
      final dio = sl<DioClient>().dio;
      await dio.post('/Profile/RequestOtp');
      if (mounted) {
        setState(() {
          _step = 2;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã gửi mã OTP, kiểm tra Gmail!'),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lỗi: Không thể gửi OTP'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _submitChangePassword() async {
    setState(() => _isLoading = true);
    try {
      final dio = sl<DioClient>().dio;
      await dio.post(
        '/Profile/ChangePassword',
        data: {
          'oldPassword': _oldPassCtrl.text,
          'newPassword': _newPassCtrl.text,
          'otp': _otpCtrl.text,
        },
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đổi mật khẩu thành công!'),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.lock_reset_rounded,
                      color: Color(0xFF6366F1),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Đổi Mật Khẩu',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Xác thực qua OTP Gmail',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    style: IconButton.styleFrom(
                      foregroundColor: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              if (_step == 1) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Color(0xFF6366F1),
                        size: 18,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Hệ thống sẽ gửi mã OTP 6 số tới Gmail của bạn để xác minh.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6366F1),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _requestOtp,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.send_rounded, size: 18),
                    label: Text(
                      _isLoading ? 'Đang gửi...' : 'Gửi mã OTP',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ] else ...[
                _DialogField(
                  label: 'Mã OTP (6 số)',
                  controller: _otpCtrl,
                  icon: Icons.pin_outlined,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _DialogField(
                  label: 'Mật khẩu cũ',
                  controller: _oldPassCtrl,
                  icon: Icons.lock_outline,
                  obscureText: _obscureOld,
                  onToggleObscure: () =>
                      setState(() => _obscureOld = !_obscureOld),
                ),
                const SizedBox(height: 16),
                _DialogField(
                  label: 'Mật khẩu mới',
                  controller: _newPassCtrl,
                  icon: Icons.lock_open_outlined,
                  obscureText: _obscureNew,
                  onToggleObscure: () =>
                      setState(() => _obscureNew = !_obscureNew),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Hủy',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _submitChangePassword,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.check_rounded, size: 18),
                      label: Text(
                        _isLoading ? 'Đang xử lý...' : 'Xác nhận đổi',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogField extends StatelessWidget {
  const _DialogField({
    required this.label,
    required this.controller,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.onToggleObscure,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final VoidCallback? onToggleObscure;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: onToggleObscure != null
            ? IconButton(
                onPressed: onToggleObscure,
                icon: Icon(
                  obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                ),
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Theme color tokens
// ─────────────────────────────────────────────────────────────

class _AppColorTokens {
  final Color bgApp;
  final Color bgCard;
  final Color textPrimary;
  final Color textSecond;
  final Color border;

  const _AppColorTokens({
    required this.bgApp,
    required this.bgCard,
    required this.textPrimary,
    required this.textSecond,
    required this.border,
  });
}

extension _ContextColors on BuildContext {
  _AppColorTokens get appColors {
    final isDark = watch<ThemeCubit>().isDark;
    if (isDark) {
      return const _AppColorTokens(
        bgApp: Color(0xFF0D1117),
        bgCard: Color(0xFF21262D),
        textPrimary: Color(0xFFE6EDF3),
        textSecond: Color(0xFF8B949E),
        border: Color(0xFF30363D),
      );
    }
    return const _AppColorTokens(
      bgApp: Color(0xFFF0F2F7),
      bgCard: Color(0xFFFFFFFF),
      textPrimary: Color(0xFF0F172A),
      textSecond: Color(0xFF64748B),
      border: Color(0xFFE2E8F0),
    );
  }
}
