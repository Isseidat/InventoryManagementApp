import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/network/dio_client.dart';
import '../../core/theme/theme_cubit.dart';
import '../../core/service_locator.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _user;
  bool _isLoading = true;

  // Tab 1: Basic Info
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _isSavingBasic = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
    setState(() => _isSavingBasic = true);
    try {
      final dio = sl<DioClient>().dio;
      await dio.put('/Profile', data: {
        'fullName': _nameCtrl.text.trim(),
        'phoneNumber': _phoneCtrl.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lưu thành công!')));
        _loadProfile(); // refresh data
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Có lỗi xảy ra')));
    } finally {
      setState(() => _isSavingBasic = false);
    }
  }

  void _showChangePasswordDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, a1, a2) => const _ChangePasswordDialog(),
      transitionBuilder: (ctx, a1, a2, child) {
        return Transform.scale(
          scale: Curves.easeOutBack.transform(a1.value),
          child: FadeTransition(opacity: a1, child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.bgApp,
      appBar: AppBar(
        backgroundColor: colors.bgCard,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text('Hồ sơ của tôi', style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: colors.border, height: 1),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
              ? const Center(child: Text('Lỗi tải dữ liệu'))
              : Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column: Avatar & Summary
                      Container(
                        width: 300,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: colors.bgCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: colors.border),
                        ),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: const Color(0xFF6366F1),
                              child: Text(
                                _user!['fullName'].isNotEmpty ? _user!['fullName'][0].toUpperCase() : 'U',
                                style: const TextStyle(fontSize: 48, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              _user!['fullName'] ?? 'N/A',
                              style: TextStyle(fontSize: 20, color: colors.textPrimary, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _user!['role'] ?? 'Nhân viên',
                                style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Divider(),
                            const SizedBox(height: 16),
                            _buildInfoRow(Icons.email_outlined, _user!['email'] ?? 'Chưa cập nhật', colors),
                            const SizedBox(height: 12),
                            _buildInfoRow(Icons.phone_outlined, _user!['phoneNumber'] ?? 'Chưa cập nhật', colors),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),

                      // Right Column: Editor Tabs
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: colors.bgCard,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: colors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TabBar(
                                controller: _tabController,
                                labelColor: const Color(0xFF6366F1),
                                unselectedLabelColor: colors.textSecond,
                                indicatorColor: const Color(0xFF6366F1),
                                indicatorWeight: 3,
                                tabs: const [
                                  Tab(text: 'Thông tin cá nhân'),
                                  Tab(text: 'Bảo mật & Đăng nhập'),
                                ],
                              ),
                              Divider(height: 1, color: colors.border),
                              Expanded(
                                child: TabBarView(
                                  controller: _tabController,
                                  children: [
                                    // Basic Info Tab
                                    Padding(
                                      padding: const EdgeInsets.all(32),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Họ và Tên', style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 8),
                                          TextField(
                                            controller: _nameCtrl,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                              filled: true,
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          Text('Số điện thoại', style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 8),
                                          TextField(
                                            controller: _phoneCtrl,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                              filled: true,
                                            ),
                                          ),
                                          const SizedBox(height: 32),
                                          ElevatedButton(
                                            onPressed: _isSavingBasic ? null : _saveBasicInfo,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF6366F1),
                                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                            ),
                                            child: _isSavingBasic
                                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                                : const Text('Lưu thay đổi', style: TextStyle(color: Colors.white)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Security Tab
                                    Padding(
                                      padding: const EdgeInsets.all(32),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _buildSecurityRow('Tài khoản', _user!['username'] ?? '', 'Không thể đổi', colors, null),
                                          const Divider(height: 48),
                                          _buildSecurityRow('Email (Nhận OTP)', _user!['email'] ?? 'Chưa có', 'Đổi Email', colors, () {
                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chức năng đang phát triển')));
                                          }),
                                          const Divider(height: 48),
                                          _buildSecurityRow('Mật khẩu', '********', 'Đổi Mật khẩu', colors, _showChangePasswordDialog),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, dynamic colors) {
    return Row(
      children: [
        Icon(icon, size: 20, color: colors.textSecond),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: TextStyle(color: colors.textSecond))),
      ],
    );
  }

  Widget _buildSecurityRow(String label, String value, String btnText, dynamic colors, VoidCallback? onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: colors.textSecond, fontSize: 13)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        OutlinedButton(
          onPressed: onTap,
          child: Text(btnText),
        ),
      ],
    );
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();
  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  int _step = 1; 
  bool _isLoading = false;
  
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã gửi mã OTP, kiểm tra Email (hoặc Terminal)!')));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi: Không thể gửi OTP')));
      }
    }
  }

  Future<void> _submitChangePassword() async {
    setState(() => _isLoading = true);
    try {
      final dio = sl<DioClient>().dio;
      await dio.post('/Profile/ChangePassword', data: {
        'oldPassword': _oldPassCtrl.text,
        'newPassword': _newPassCtrl.text,
        'otp': _otpCtrl.text,
      });
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đổi mật khẩu thành công!')));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Đổi Mật Khẩu', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (_step == 1) ...[
              const Text('Hệ thống sẽ gửi một mã OTP gồm 6 số về Email của bạn để xác minh.'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _requestOtp,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Gửi mã OTP', style: TextStyle(color: Colors.white)),
                ),
              ),
            ] else ...[
              TextField(
                controller: _otpCtrl,
                decoration: const InputDecoration(labelText: 'Mã OTP (6 số)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _oldPassCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Mật khẩu cũ', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _newPassCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Mật khẩu mới', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitChangePassword,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
                    child: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Xác nhận đổi', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

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
