import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import '../../core/theme/theme_cubit.dart';
import '../../domain/entities/auth_user.dart';
import '../blocs/dashboard/dashboard_bloc.dart';
import '../blocs/dashboard/dashboard_state.dart';

class DashboardOverview extends StatefulWidget {
  const DashboardOverview({super.key});

  @override
  State<DashboardOverview> createState() => _DashboardOverviewState();
}

class _DashboardOverviewState extends State<DashboardOverview>
    with TickerProviderStateMixin {
  late AnimationController _gradientCtrl;
  late AnimationController _countCtrl;
  late Animation<double> _countAnim;

  @override
  void initState() {
    super.initState();
    _gradientCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _countCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _countAnim = CurvedAnimation(parent: _countCtrl, curve: Curves.easeOut);
    _countCtrl.forward();
  }

  @override
  void dispose() {
    _gradientCtrl.dispose();
    _countCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().isDark;
    final colors = _tokenColors(isDark);

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return const Center(child: CircularProgressIndicator());
        }
        final user = authState.user;

        return BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, dashState) {
            List<_StatData> dynamicStats = [];
            List<dynamic> dynamicActivities = [];

            if (dashState is DashboardLoaded) {
              dynamicStats = [
                _StatData(
                  'Tổng sản phẩm',
                  dashState.totalProducts,
                  'Theo giá trị thật',
                  Icons.inventory_2_outlined,
                  const Color(0xFF6366F1),
                  true,
                ),
                _StatData(
                  'Đơn chờ duyệt',
                  dashState.pendingSales,
                  'Cần xử lý',
                  Icons.fact_check_outlined,
                  const Color(0xFFF59E0B),
                  null,
                ),
                _StatData(
                  'Nhập kho hôm nay',
                  dashState.todayStockIn,
                  'Hàng có sẵn',
                  Icons.arrow_downward_rounded,
                  const Color(0xFF10B981),
                  true,
                ),
                _StatData(
                  'Xuất kho hôm nay',
                  dashState.todayStockOut,
                  'Hàng đã bán',
                  Icons.arrow_upward_rounded,
                  const Color(0xFF3B82F6),
                  true,
                ),
              ];
              dynamicActivities = dashState.recentActivities;
            } else {
              // Fallback / Loading stats
              dynamicStats = [
                _StatData(
                  'Tổng sản phẩm',
                  0,
                  'Đang tải...',
                  Icons.inventory_2_outlined,
                  const Color(0xFF6366F1),
                  null,
                ),
                _StatData(
                  'Đơn chờ duyệt',
                  0,
                  'Đang tải...',
                  Icons.fact_check_outlined,
                  const Color(0xFFF59E0B),
                  null,
                ),
                _StatData(
                  'Nhập kho hôm nay',
                  0,
                  'Đang tải...',
                  Icons.arrow_downward_rounded,
                  const Color(0xFF10B981),
                  null,
                ),
                _StatData(
                  'Xuất kho hôm nay',
                  0,
                  'Đang tải...',
                  Icons.arrow_upward_rounded,
                  const Color(0xFF3B82F6),
                  null,
                ),
              ];
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── ANIMATED WELCOME BANNER ─────────────────────────────
                  _AnimatedBanner(ctrl: _gradientCtrl, user: user),
                  const SizedBox(height: 24),

                  // ── STAT CARDS (CountUp) ────────────────────────────────
                  LayoutBuilder(
                    builder: (ctx, box) {
                      int cols = box.maxWidth > 1100
                          ? 4
                          : (box.maxWidth > 700 ? 2 : 1);
                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: cols,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 2.2,
                        children: dynamicStats
                            .map(
                              (s) => _StatCard(
                                stat: s,
                                countAnim: _countAnim,
                                isDark: isDark,
                                colors: colors,
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // ── BOTTOM SECTION ──────────────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _ActivityTable(
                          colors: colors,
                          isDark: isDark,
                          activities: dynamicActivities,
                          isLoading: dashState is DashboardLoading,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 2,
                        child: _QuickActions(
                          roleName: user.roleName,
                          colors: colors,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ── ANIMATED GRADIENT BANNER ─────────────────────────────────────────────────
class _AnimatedBanner extends StatelessWidget {
  final AnimationController ctrl;
  final AuthUser user;

  const _AnimatedBanner({required this.ctrl, required this.user});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (context, child) {
        final t = ctrl.value;
        return Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: const [
                Color(0xFF4338CA),
                Color(0xFF6366F1),
                Color(0xFF7C3AED),
              ],
              stops: [0.0, t.clamp(0.3, 0.7), 1.0],
              begin: Alignment(-1 + t * 0.6, -0.5),
              end: const Alignment(1.0, 1.0),
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFF6366F1,
                ).withValues(alpha: 0.25 + t * 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chào ${_greeting()}, ${user.fullName}! 👋',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _Chip(
                          label: user.jobTitle ?? user.roleName,
                          icon: Icons.shield_outlined,
                        ),
                        const SizedBox(width: 10),
                        _Chip(
                          label: _today(),
                          icon: Icons.calendar_today_outlined,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Floating icon animation
              Transform.rotate(
                angle: math.pi * t * 0.04,
                child: Opacity(
                  opacity: 0.15 + t * 0.05,
                  child: const Icon(
                    Icons.bar_chart_rounded,
                    size: 90,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'buổi sáng';
    if (h < 18) return 'buổi chiều';
    return 'buổi tối';
  }

  String _today() {
    final n = DateTime.now();
    const days = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    return '${days[n.weekday % 7]}, ${n.day}/${n.month}/${n.year}';
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _Chip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 12),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    ),
  );
}

// ── STAT CARD WITH COUNT-UP ANIMATION ────────────────────────────────────────
class _StatData {
  final String label;
  final int value;
  final String sub;
  final IconData icon;
  final Color color;
  final bool? positive; // null = neutral

  const _StatData(
    this.label,
    this.value,
    this.sub,
    this.icon,
    this.color,
    this.positive,
  );
}

class _StatCard extends StatelessWidget {
  final _StatData stat;
  final Animation<double> countAnim;
  final bool isDark;
  final Tok colors;

  const _StatCard({
    required this.stat,
    required this.countAnim,
    required this.isDark,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: stat.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(stat.icon, color: stat.color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  stat.label,
                  style: TextStyle(
                    color: colors.textSecond,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedBuilder(
                  animation: countAnim,
                  builder: (context, child) {
                    final displayed = (stat.value * countAnim.value).round();
                    final formatted = displayed >= 1000
                        ? '${(displayed / 1000).toStringAsFixed(1)}K'
                        : '$displayed';
                    return Text(
                      formatted,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (stat.positive != null)
                      Icon(
                        stat.positive!
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        size: 11,
                        color: stat.positive!
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                      ),
                    if (stat.positive != null) const SizedBox(width: 3),
                    Text(
                      stat.sub,
                      style: TextStyle(
                        fontSize: 10,
                        color: stat.positive == null
                            ? colors.textSecond
                            : stat.positive!
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── ACTIVITY TABLE ────────────────────────────────────────────────────────────
class _ActivityTable extends StatelessWidget {
  final Tok colors;
  final bool isDark;
  final List<dynamic> activities;
  final bool isLoading;

  const _ActivityTable({
    required this.colors,
    required this.isDark,
    required this.activities,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 12, 0),
            child: Row(
              children: [
                Text(
                  'Giao dịch gần nhất',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: colors.textPrimary,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Xem tất cả →',
                    style: TextStyle(
                      color: const Color(0xFF6366F1),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border(
                top: BorderSide(color: colors.border),
                bottom: BorderSide(color: colors.border),
              ),
            ),
            child: Row(
              children: [
                _th('Mã phiếu', flex: 2, colors: colors),
                _th('Sản phẩm', flex: 3, colors: colors),
                _th('Số lượng', flex: 1, colors: colors),
                _th('Trạng thái', flex: 2, colors: colors),
              ],
            ),
          ),
          // Rows
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (activities.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: Text("Không có giao dịch nào")),
            )
          else
            ...activities.map((a) {
              final rowTuple = (
                a['type'].toString(),
                a['code'].toString(),
                a['productName'].toString(),
                a['quantity'].toString(),
                a['status'].toString(),
              );
              return _TableRow(
                row: rowTuple,
                colors: colors,
                border: colors.border,
              );
            }),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _th(String t, {required int flex, required Tok colors}) => Expanded(
    flex: flex,
    child: Text(
      t,
      style: TextStyle(
        color: colors.textSecond,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class _TableRow extends StatefulWidget {
  final (String, String, String, String, String) row;
  final Tok colors;
  final Color border;
  const _TableRow({
    required this.row,
    required this.colors,
    required this.border,
  });

  @override
  State<_TableRow> createState() => _TableRowState();
}

class _TableRowState extends State<_TableRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.row;
    final isIn = r.$1 == 'in';
    final isPending = r.$1 == 'pending';

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        decoration: BoxDecoration(
          color: _hovered
              ? widget.colors.textSecond.withValues(alpha: 0.04)
              : Colors.transparent,
          border: Border(
            top: BorderSide(color: widget.border.withValues(alpha: 0.5)),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                r.$2,
                style: TextStyle(
                  color: widget.colors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                r.$3,
                style: TextStyle(color: widget.colors.textSecond, fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                r.$4,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isIn
                      ? const Color(0xFF10B981)
                      : const Color(0xFFEF4444),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isPending
                      ? const Color(0xFFFEF3C7).withValues(alpha: 0.15)
                      : const Color(0xFFDCFCE7).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: isPending
                        ? const Color(0xFFF59E0B).withValues(alpha: 0.4)
                        : const Color(0xFF10B981).withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  r.$5,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isPending
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFF10B981),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── QUICK ACTIONS ─────────────────────────────────────────────────────────────
class _QuickActions extends StatelessWidget {
  final String roleName;
  final Tok colors;

  const _QuickActions({required this.roleName, required this.colors});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.add_box_outlined, 'Tạo Phiếu Nhập', const Color(0xFF10B981)),
      (Icons.outbox_outlined, 'Tạo Phiếu Xuất', const Color(0xFF3B82F6)),
      if (roleName == 'Admin' || roleName == 'Manager')
        (Icons.fact_check_outlined, 'Duyệt Đơn hàng', const Color(0xFFF59E0B)),
      if (roleName == 'Admin')
        (Icons.person_add_outlined, 'Thêm Nhân sự', const Color(0xFF8B5CF6)),
      (Icons.analytics_outlined, 'Xem Báo cáo', const Color(0xFF6366F1)),
    ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
            child: Text(
              'Thao tác nhanh',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: colors.textPrimary,
              ),
            ),
          ),
          ...items.map(
            (item) => _ActionRow(
              icon: item.$1,
              label: item.$2,
              color: item.$3,
              colors: colors,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _ActionRow extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Tok colors;

  const _ActionRow({
    required this.icon,
    required this.label,
    required this.color,
    required this.colors,
  });

  @override
  State<_ActionRow> createState() => _ActionRowState();
}

class _ActionRowState extends State<_ActionRow> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: BoxDecoration(
              color: _hovered
                  ? widget.color.withValues(alpha: 0.06)
                  : Colors.transparent,
              border: Border(
                top: BorderSide(
                  color: widget.colors.border.withValues(alpha: 0.5),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Icon(widget.icon, color: widget.color, size: 15),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      color: widget.colors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 11,
                  color: widget.colors.textSecond,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── TOKEN COLORS HELPER ───────────────────────────────────────────────────────
class Tok {
  final Color card, border, textPrimary, textSecond;
  const Tok({
    required this.card,
    required this.border,
    required this.textPrimary,
    required this.textSecond,
  });
}

Tok _tokenColors(bool isDark) => isDark
    ? const Tok(
        card: Color(0xFF21262D),
        border: Color(0xFF30363D),
        textPrimary: Color(0xFFE6EDF3),
        textSecond: Color(0xFF8B949E),
      )
    : const Tok(
        card: Color(0xFFFFFFFF),
        border: Color(0xFFE2E8F0),
        textPrimary: Color(0xFF0F172A),
        textSecond: Color(0xFF64748B),
      );
