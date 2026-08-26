import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/theme_cubit.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import '../blocs/staff/staff_bloc.dart';
import '../blocs/staff/staff_event.dart';
import '../blocs/staff/staff_state.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().isDark;
    final bg = isDark ? const Color(0xFF0D1117) : const Color(0xFFF0F2F7);
    final card = isDark ? const Color(0xFF161B22) : Colors.white;
    final textPrimary = isDark ? const Color(0xFFE6EDF3) : const Color(0xFF0F172A);
    final textSecond = isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B);
    final border = isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0);

    return BlocConsumer<StaffBloc, StaffState>(
      listener: (context, state) {
        if (state is StaffActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ));
        } else if (state is StaffActionFailure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.error),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      builder: (context, state) {
        return Container(
          color: bg,
          child: Column(
            children: [
              // ── HEADER ─────────────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(32, 28, 32, 20),
                decoration: BoxDecoration(
                  color: card,
                  border: Border(bottom: BorderSide(color: border)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quản lý Nhân sự',
                            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textPrimary),
                          ),
                          const SizedBox(height: 4),
                          Text('Danh sách tài khoản người dùng trong hệ thống', style: TextStyle(color: textSecond, fontSize: 14)),
                        ],
                      ),
                    ),
                    // Search
                    SizedBox(
                      width: 260,
                      child: TextField(
                        onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                        style: TextStyle(color: textPrimary, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm nhân viên...',
                          hintStyle: TextStyle(color: textSecond, fontSize: 13),
                          prefixIcon: Icon(Icons.search_rounded, color: textSecond, size: 16),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF21262D) : const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: border),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Add button — only Admin sees it
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, authState) {
                        if (authState is AuthAuthenticated && authState.user.roleName == 'Admin') {
                          return ElevatedButton.icon(
                            onPressed: () => _showStaffDialog(context, isDark, null),
                            icon: const Icon(Icons.person_add_rounded, size: 16),
                            label: const Text('Thêm nhân viên'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ],
                ),
              ),

              // ── CONTENT ────────────────────────────────────────────────────
              Expanded(
                child: _buildContent(state, isDark, textPrimary, textSecond, border, card),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(StaffState state, bool isDark, Color textPrimary, Color textSecond, Color border, Color card) {
    if (state is StaffLoading || state is StaffInitial) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is StaffFailure) {
      return Center(child: Text(state.error, style: const TextStyle(color: Colors.red)));
    }

    List<dynamic> users = [];
    if (state is StaffLoaded) users = state.users;
    if (state is StaffActionSuccess || state is StaffActionFailure) {
      // Keep previous data visible during action feedback
    }

    // Filter
    final filtered = users.where((u) {
      if (_searchQuery.isEmpty) return true;
      return (u['fullName'] ?? '').toString().toLowerCase().contains(_searchQuery) ||
          (u['username'] ?? '').toString().toLowerCase().contains(_searchQuery) ||
          (u['email'] ?? '').toString().toLowerCase().contains(_searchQuery) ||
          (u['roleName'] ?? '').toString().toLowerCase().contains(_searchQuery);
    }).toList();

    if (filtered.isEmpty && _searchQuery.isNotEmpty) {
      return Center(child: Text('Không tìm thấy nhân viên phù hợp', style: TextStyle(color: textSecond)));
    }
    if (filtered.isEmpty) {
      return Center(child: Text('Chưa có nhân viên nào', style: TextStyle(color: textSecond)));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Container(
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Column(
          children: [
            // Table header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF21262D) : const Color(0xFFF8FAFC),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                border: Border(bottom: BorderSide(color: border)),
              ),
              child: Row(
                children: [
                  _headerCell('Họ và tên', flex: 3, textSecond: textSecond),
                  _headerCell('Tài khoản', flex: 2, textSecond: textSecond),
                  _headerCell('Email', flex: 3, textSecond: textSecond),
                  _headerCell('Chức danh', flex: 2, textSecond: textSecond),
                  _headerCell('Vai trò', flex: 2, textSecond: textSecond),
                  _headerCell('Thao tác', flex: 2, textSecond: textSecond),
                ],
              ),
            ),
            // Rows
            ...filtered.asMap().entries.map((entry) {
              final i = entry.key;
              final u = entry.value;
              return _buildRow(context, u, i, filtered.length, isDark, textPrimary, textSecond, border);
            }),
          ],
        ),
      ),
    );
  }

  Widget _headerCell(String label, {required int flex, required Color textSecond}) {
    return Expanded(
      flex: flex,
      child: Text(label.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textSecond, letterSpacing: 0.5)),
    );
  }

  Widget _buildRow(BuildContext context, dynamic u, int index, int total, bool isDark, Color textPrimary, Color textSecond, Color border) {
    final roleName = u['roleName'] ?? 'Staff';
    Color roleColor;
    switch (roleName) {
      case 'Admin': roleColor = const Color(0xFF8B5CF6); break;
      case 'Manager': roleColor = const Color(0xFF3B82F6); break;
      default: roleColor = const Color(0xFF10B981);
    }

    return Container(
      decoration: BoxDecoration(
        border: index < total - 1 ? Border(bottom: BorderSide(color: border)) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: roleColor.withOpacity(0.15),
                        child: Text(
                          (u['fullName'] ?? 'U')[0].toUpperCase(),
                          style: TextStyle(color: roleColor, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(u['fullName'] ?? '', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
                Expanded(flex: 2, child: Text(u['username'] ?? '', style: TextStyle(color: textSecond, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                Expanded(flex: 3, child: Text(u['email'] ?? '—', style: TextStyle(color: textSecond, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                Expanded(flex: 2, child: Text(u['jobTitle'] ?? '—', style: TextStyle(color: textSecond, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: roleColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(roleName, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: roleColor), textAlign: TextAlign.center),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, authState) {
                      if (authState is! AuthAuthenticated || authState.user.roleName != 'Admin') {
                        return const SizedBox();
                      }
                      return Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_rounded, size: 16),
                            color: const Color(0xFF6366F1),
                            tooltip: 'Chỉnh sửa',
                            onPressed: () => _showStaffDialog(context, isDark, u),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_rounded, size: 16),
                            color: Colors.red,
                            tooltip: 'Xoá',
                            onPressed: () => _confirmDelete(context, u),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, dynamic user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xoá'),
        content: Text('Bạn có chắc chắn muốn xoá nhân viên "${user['fullName']}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Huỷ')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<StaffBloc>().add(StaffDeleted(user['id']));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
  }

  void _showStaffDialog(BuildContext context, bool isDark, dynamic existing) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _StaffFormDialog(existing: existing),
    );
  }
}

// ── Staff Form Dialog ─────────────────────────────────────────────────────────
class _StaffFormDialog extends StatefulWidget {
  final dynamic existing;
  const _StaffFormDialog({this.existing});

  @override
  State<_StaffFormDialog> createState() => _StaffFormDialogState();
}

class _StaffFormDialogState extends State<_StaffFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _jobTitleCtrl = TextEditingController();
  int _roleId = 3; // Default: Staff

  final List<Map<String, dynamic>> _roles = [
    {'id': 1, 'name': 'Admin'},
    {'id': 2, 'name': 'Manager'},
    {'id': 3, 'name': 'Staff'},
  ];

  bool get isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _fullNameCtrl.text = widget.existing['fullName'] ?? '';
      _emailCtrl.text = widget.existing['email'] ?? '';
      _jobTitleCtrl.text = widget.existing['jobTitle'] ?? '';
      _roleId = widget.existing['roleId'] ?? 3;
    }
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _jobTitleCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (isEdit) {
      final data = {
        'fullName': _fullNameCtrl.text.trim(),
        'email': _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        'jobTitle': _jobTitleCtrl.text.trim().isEmpty ? null : _jobTitleCtrl.text.trim(),
        'roleId': _roleId,
        'newPassword': _passwordCtrl.text.trim().isEmpty ? null : _passwordCtrl.text.trim(),
      };
      context.read<StaffBloc>().add(StaffUpdated(widget.existing['id'], data));
    } else {
      final data = {
        'username': _usernameCtrl.text.trim(),
        'password': _passwordCtrl.text.trim(),
        'fullName': _fullNameCtrl.text.trim(),
        'email': _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        'jobTitle': _jobTitleCtrl.text.trim().isEmpty ? null : _jobTitleCtrl.text.trim(),
        'roleId': _roleId,
      };
      context.read<StaffBloc>().add(StaffCreated(data));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isEdit ? 'Cập nhật nhân viên' : 'Thêm nhân viên mới'),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isEdit) ...[
                  TextFormField(
                    controller: _usernameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Tên đăng nhập *',
                      labelStyle: const TextStyle(color: Colors.blueGrey, fontSize: 13),
                      filled: true,
                      fillColor: Colors.grey.withOpacity(0.05),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.withOpacity(0.3))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.withOpacity(0.3))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.blue, width: 1.5)),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập tên đăng nhập' : null,
                  ),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  controller: _fullNameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Họ và tên *',
                    labelStyle: const TextStyle(color: Colors.blueGrey, fontSize: 13),
                    filled: true,
                    fillColor: Colors.grey.withOpacity(0.05),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.withOpacity(0.3))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.withOpacity(0.3))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.blue, width: 1.5)),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập họ và tên' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailCtrl,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: const TextStyle(color: Colors.blueGrey, fontSize: 13),
                    filled: true,
                    fillColor: Colors.grey.withOpacity(0.05),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.withOpacity(0.3))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.withOpacity(0.3))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.blue, width: 1.5)),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _jobTitleCtrl,
                  decoration: InputDecoration(
                    labelText: 'Chức danh',
                    labelStyle: const TextStyle(color: Colors.blueGrey, fontSize: 13),
                    filled: true,
                    fillColor: Colors.grey.withOpacity(0.05),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.withOpacity(0.3))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.withOpacity(0.3))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.blue, width: 1.5)),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: _roleId,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.blueGrey),
                  decoration: InputDecoration(
                    labelText: 'Vai trò *',
                    labelStyle: const TextStyle(color: Colors.blueGrey, fontSize: 13),
                    filled: true,
                    fillColor: Colors.grey.withOpacity(0.05),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.withOpacity(0.3))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.withOpacity(0.3))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.blue, width: 1.5)),
                  ),
                  items: _roles.map((r) => DropdownMenuItem<int>(
                    value: r['id'],
                    child: Text(r['name'], style: const TextStyle(fontSize: 14)),
                  )).toList(),
                  onChanged: (v) => setState(() => _roleId = v ?? 3),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordCtrl,
                  decoration: InputDecoration(
                    labelText: isEdit ? 'Mật khẩu mới (để trống nếu không đổi)' : 'Mật khẩu *',
                    border: const OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (v) {
                    if (!isEdit && (v == null || v.isEmpty)) return 'Vui lòng nhập mật khẩu';
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Huỷ')),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), foregroundColor: Colors.white),
          child: Text(isEdit ? 'Lưu thay đổi' : 'Thêm nhân viên'),
        ),
      ],
    );
  }
}
