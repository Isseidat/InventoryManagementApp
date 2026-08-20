import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import '../blocs/dashboard/dashboard_bloc.dart';
import '../blocs/dashboard/dashboard_event.dart';
import '../screens/dashboard_screen.dart';
import '../../core/theme/theme_cubit.dart';

import '../screens/product_screen.dart';
import '../blocs/product/product_bloc.dart';
import '../blocs/product/product_event.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardOverview(),
    const ProductScreen(),
    const Center(
      child: Text('Nhập / Xuất Kho', style: TextStyle(fontSize: 24)),
    ),
    const Center(
      child: Text('Quản lý Nhân sự', style: TextStyle(fontSize: 24)),
    ),
    const Center(
      child: Text('Cài đặt hệ thống', style: TextStyle(fontSize: 24)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().isDark;
    final colors = context.appColors;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = state.user;

        return Scaffold(
          backgroundColor: colors.bgPrimary,
          body: Row(
            children: [
              // ── SIDEBAR ─────────────────────────────────────────────
              Container(
                width: 255,
                decoration: BoxDecoration(
                  color: colors.bgSidebar,
                  border: Border(
                    right: BorderSide(color: colors.border, width: 1),
                  ),
                ),
                child: Column(
                  children: [
                    // Logo
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                              ),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: const Icon(
                              Icons.inventory_2_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'InventoryPro',
                                style: TextStyle(
                                  color: colors.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Warehouse System',
                                style: TextStyle(
                                  color: colors.textSecond,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // MENU label
                    _sectionLabel('MENU CHÍNH', colors),
                    _navItem(0, Icons.grid_view_rounded, 'Tổng quan', colors),
                    _navItem(1, Icons.inventory_2_outlined, 'Sản phẩm', colors),
                    if (user.roleName != 'User')
                      _navItem(
                        2,
                        Icons.local_shipping_outlined,
                        'Nhập / Xuất kho',
                        colors,
                      ),

                    if (user.roleName == 'Admin' ||
                        user.roleName == 'Manager') ...[
                      const SizedBox(height: 14),
                      _sectionLabel('QUẢN TRỊ', colors),
                    ],
                    if (user.roleName == 'Admin')
                      _navItem(
                        3,
                        Icons.people_outline_rounded,
                        'Nhân sự',
                        colors,
                      ),
                    if (user.roleName == 'Admin')
                      _navItem(4, Icons.settings_outlined, 'Cài đặt', colors),

                    const Spacer(),
                    Divider(height: 1, color: colors.border),

                    // User block (only logout button)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          _IconBtn(
                            icon: Icons.logout_rounded,
                            color: colors.textSecond,
                            tooltip: 'Đăng xuất',
                            onTap: () =>
                                context.read<AuthBloc>().add(LogoutRequested()),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── MAIN CONTENT ─────────────────────────────────────────
              Expanded(
                child: Column(
                  children: [
                    // Topbar
                    Container(
                      height: 74,
                      decoration: BoxDecoration(
                        color: colors.bgTopbar,
                        border: Border(
                          bottom: BorderSide(color: colors.border),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          // Breadcrumb
                          Text(
                            _getCategoryTitle(_selectedIndex),
                            style: TextStyle(
                              color: colors.textSecond,
                              fontSize: 13,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: colors.textSecond,
                            size: 16,
                          ),
                          Text(
                            _getPageTitle(_selectedIndex),
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const Spacer(),

                          // Search
                          Container(
                            width: 220,
                            height: 38,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF161B22)
                                  : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextField(
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontSize: 13,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Tìm kiếm...',
                                hintStyle: TextStyle(
                                  color: colors.textSecond,
                                  fontSize: 13,
                                ),
                                prefixIcon: Icon(
                                  Icons.search_rounded,
                                  color: colors.textSecond,
                                  size: 16,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // 🔄 Reload button
                          _TopbarBtn(
                            colors: colors,
                            onTap: () {
                              if (_selectedIndex == 0) {
                                context.read<DashboardBloc>().add(
                                  DashboardSummaryRequested(),
                                );
                              } else if (_selectedIndex == 1) {
                                context.read<ProductBloc>().add(
                                  ProductListRequested(),
                                );
                              }
                            },
                            child: Icon(
                              Icons.refresh_rounded,
                              color: colors.textSecond,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 6),

                          // 🌙 Dark/Light toggle
                          _TopbarBtn(
                            colors: colors,
                            onTap: () =>
                                context.read<ThemeCubit>().toggleTheme(),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              transitionBuilder: (child, anim) =>
                                  RotationTransition(turns: anim, child: child),
                              child: Icon(
                                isDark
                                    ? Icons.light_mode_rounded
                                    : Icons.dark_mode_rounded,
                                key: ValueKey(isDark),
                                color: isDark
                                    ? const Color(0xFFFBBF24)
                                    : colors.textSecond,
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),

                          // Notification bell
                          _TopbarBtn(
                            colors: colors,
                            onTap: () {},
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  Icons.notifications_active_rounded,
                                  color: isDark
                                      ? const Color(0xFF60A5FA)
                                      : const Color(0xFF3B82F6),
                                  size: 18,
                                ),
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFEF4444),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Avatar Block
                          Row(
                            children: [
                              PopupMenuButton<String>(
                                offset: const Offset(0, 40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                onSelected: (value) {
                                  if (value == 'profile') {
                                    context.push('/profile');
                                  } else if (value == 'logout') {
                                    context.read<AuthBloc>().add(
                                      LogoutRequested(),
                                    );
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'profile',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.person_outline_rounded,
                                          color: colors.textPrimary,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Hồ sơ của tôi',
                                          style: TextStyle(
                                            color: colors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuDivider(height: 1),
                                  PopupMenuItem(
                                    value: 'logout',
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.logout_rounded,
                                          color: Colors.redAccent,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        const Text(
                                          'Đăng xuất',
                                          style: TextStyle(
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: const Color(0xFF6366F1),
                                      child: Text(
                                        user.fullName.isNotEmpty
                                            ? user.fullName[0].toUpperCase()
                                            : 'U',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: colors.textSecond,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    user.fullName,
                                    style: TextStyle(
                                      color: colors.textPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    user.roleName == 'Admin'
                                        ? 'Administrator'
                                        : (user.jobTitle ?? user.roleName),
                                    style: TextStyle(
                                      color: colors.textSecond,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Page
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: _pages[_selectedIndex],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.substring(0, math.min(2, name.length)).toUpperCase();
  }

  Widget _sectionLabel(String text, _AppColorTokens colors) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          color: colors.textSecond.withValues(alpha: 0.6),
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    ),
  );

  Widget _navItem(
    int index,
    IconData icon,
    String label,
    _AppColorTokens colors,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
      child: _PressableItem(
        onTap: () => setState(() => _selectedIndex = index),
        isSelected: isSelected,
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? const Color(0xFF6366F1) // Indigo
                  : colors.textSecond,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? (isDark ? Colors.white : colors.textPrimary)
                      : colors.textSecond,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            if (isSelected)
              Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: Color(0xFF6366F1),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getPageTitle(int index) {
    switch (index) {
      case 0:
        return 'Tổng quan';
      case 1:
        return 'Sản phẩm';
      case 2:
        return 'Nhập / Xuất';
      case 3:
        return 'Nhân sự';
      case 4:
        return 'Cài đặt';
      default:
        return '';
    }
  }

  String _getCategoryTitle(int index) {
    if (index >= 0 && index <= 2) return 'Menu Chính';
    if (index >= 3 && index <= 4) return 'Quản Trị';
    return '';
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// REUSABLE WIDGETS
// ──────────────────────────────────────────────────────────────────────────────

/// Nút sidebar có press-scale + highlight effect
class _PressableItem extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final bool isSelected;

  const _PressableItem({
    required this.child,
    required this.onTap,
    required this.isSelected,
  });

  @override
  State<_PressableItem> createState() => _PressableItemState();
}

class _PressableItemState extends State<_PressableItem> {
  bool _pressed = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? const Color(0xFF6366F1).withValues(alpha: 0.15)
                  : _hovered
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: widget.isSelected
                  ? Border.all(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.25),
                    )
                  : null,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Nút topbar nhỏ (icon) với hover + press effect
class _TopbarBtn extends StatefulWidget {
  final Widget child;
  final _AppColorTokens colors;
  final VoidCallback onTap;

  const _TopbarBtn({
    required this.child,
    required this.colors,
    required this.onTap,
  });

  @override
  State<_TopbarBtn> createState() => _TopbarBtnState();
}

class _TopbarBtnState extends State<_TopbarBtn> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.88 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _hovered ? widget.colors.border : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: widget.child),
          ),
        ),
      ),
    );
  }
}

/// Icon button nhỏ chung
class _IconBtn extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _IconBtn({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  State<_IconBtn> createState() => _IconBtnState();
}

class _IconBtnState extends State<_IconBtn> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.85 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: _pressed ? 0.25 : 0.12),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(widget.icon, color: widget.color, size: 15),
          ),
        ),
      ),
    );
  }
}

/// Tập hợp màu token rút ra từ Theme
class _AppColorTokens {
  final Color bgPrimary;
  final Color bgCard;
  final Color bgSidebar;
  final Color bgTopbar;
  final Color textPrimary;
  final Color textSecond;
  final Color border;

  const _AppColorTokens({
    required this.bgPrimary,
    required this.bgCard,
    required this.bgSidebar,
    required this.bgTopbar,
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
        bgPrimary: Color(0xFF0D1117),
        bgCard: Color(0xFF21262D),
        bgSidebar: Color(0xFF161B22),
        bgTopbar: Color(0xFF161B22),
        textPrimary: Color(0xFFE6EDF3),
        textSecond: Color(0xFF8B949E),
        border: Color(0xFF30363D),
      );
    }
    return const _AppColorTokens(
      bgPrimary: Color(0xFFF0F2F7),
      bgCard: Color(0xFFFFFFFF),
      bgSidebar: Color(0xFFF8FAFC),
      bgTopbar: Color(0xFFFFFFFF),
      textPrimary: Color(0xFF0F172A),
      textSecond: Color(0xFF64748B),
      border: Color(0xFFE2E8F0),
    );
  }
}
