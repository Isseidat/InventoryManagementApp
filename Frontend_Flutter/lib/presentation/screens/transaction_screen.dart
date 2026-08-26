import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/theme_cubit.dart';
import '../../core/theme/app_theme.dart';
import '../blocs/transaction/transaction_bloc.dart';
import '../blocs/transaction/transaction_event.dart';
import '../blocs/transaction/transaction_state.dart';
import '../widgets/create_transaction_dialog.dart';

class _AppColorTokens {
  final Color bgCard;
  final Color textPrimary;
  final Color textSecond;
  final Color border;

  const _AppColorTokens({
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
        bgCard: Color(0xFF21262D),
        textPrimary: Color(0xFFE6EDF3),
        textSecond: Color(0xFF8B949E),
        border: Color(0xFF30363D),
      );
    }
    return const _AppColorTokens(
      bgCard: Color(0xFFFFFFFF),
      textPrimary: Color(0xFF0F172A),
      textSecond: Color(0xFF64748B),
      border: Color(0xFFE2E8F0),
    );
  }
}

class TransactionScreen extends StatefulWidget {
  final String initialTab;
  final bool triggerCreate;
  final VoidCallback? onResetTrigger;

  const TransactionScreen({
    super.key,
    this.initialTab = 'import',
    this.triggerCreate = false,
    this.onResetTrigger,
  });

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  late String _activeTab;

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTab;
    if (widget.triggerCreate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showCreateTransactionModal();
        widget.onResetTrigger?.call();
      });
    }
  }

  @override
  void didUpdateWidget(TransactionScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTab != oldWidget.initialTab) {
      _activeTab = widget.initialTab;
    }
    if (widget.triggerCreate && !oldWidget.triggerCreate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showCreateTransactionModal();
        widget.onResetTrigger?.call();
      });
    }
  }

  void _showCreateTransactionModal() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (ctx, anim1, anim2) => BlocProvider.value(
        value: context.read<TransactionBloc>(),
        child: CreateTransactionDialog(isImport: _activeTab == 'import'),
      ),
      transitionBuilder: (ctx, anim1, anim2, child) {
        return Transform.scale(
          scale: Curves.easeOutBack.transform(anim1.value),
          child: Opacity(
            opacity: anim1.value,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = context.watch<ThemeCubit>().isDark;

    return Container(
      color: isDark ? const Color(0xFF0D1117) : const Color(0xFFF0F2F7),
      child: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          // HEADER
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nhập/Xuất kho (Transactions)',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      showGeneralDialog(
                        context: context,
                        barrierDismissible: true,
                        barrierLabel: '',
                        transitionDuration: const Duration(milliseconds: 400),
                        pageBuilder: (ctx, anim1, anim2) => AlertDialog(
                          title: const Text('Báo cáo'),
                          content: const Text('Tính năng đang phát triển...'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Đóng'),
                            ),
                          ],
                        ),
                        transitionBuilder: (ctx, anim1, anim2, child) {
                          return Transform.scale(
                            scale: Curves.easeOutBack.transform(anim1.value),
                            child: Opacity(
                              opacity: anim1.value,
                              child: child,
                            ),
                          );
                        },
                      );
                    },
                    icon: Icon(
                      Icons.file_download_outlined,
                      color: AppColors.accentLight,
                      size: 20,
                    ),
                    label: Text(
                      'Báo cáo',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.bgCard,
                      elevation: 0,
                      side: BorderSide(color: colors.border),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _showCreateTransactionModal,
                    icon: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    label: Text(
                      _activeTab == 'import'
                          ? 'Tạo Phiếu Nhập'
                          : 'Tạo Phiếu Xuất',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentLight,
                      elevation: 4,
                      shadowColor: AppColors.accentLight.withOpacity(0.4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),

          // TABS
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: colors.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTab(
                  'import',
                  'Phiếu Nhập (PO)',
                  Icons.local_shipping_outlined,
                  isDark,
                ),
                _buildTab(
                  'export',
                  'Phiếu Xuất (SO)',
                  Icons.shopping_cart_checkout_rounded,
                  isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // GRID OF CARDS
          BlocConsumer<TransactionBloc, TransactionState>(
            listener: (context, state) {
              if (state is TransactionActionSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: const Color(0xFF10B981),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else if (state is TransactionActionFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is TransactionLoading || state is TransactionInitial) {
                return const Padding(
                  padding: EdgeInsets.all(48.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (state is TransactionFailure) {
                return Padding(
                  padding: const EdgeInsets.all(48.0),
                  child: Center(
                    child: Text(
                      state.error,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                );
              }

              if (state is TransactionLoaded) {
                List<dynamic> rawData = _activeTab == 'import'
                    ? state.purchaseOrders
                    : state.salesOrders;
                if (rawData.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(48.0),
                    child: Center(
                      child: Text(
                        'Không có dữ liệu',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                }

                // Map real API data to expected format
                final List<Map<String, dynamic>> mappedData = rawData.map((e) {
                  final mapData = e as Map<String, dynamic>;
                  double total = 0;
                  int itemsCount = 0;
                  if (mapData['details'] != null) {
                    for (var d in mapData['details']) {
                      itemsCount++;
                      total += (d['quantity'] ?? 0) * (d['unitPrice'] ?? 0);
                    }
                  }
                  String dateStr = mapData['orderDate'] != null
                      ? mapData['orderDate'].toString().split('T')[0]
                      : '';

                  return {
                    'rawId': mapData['id'],
                    'id':
                        '${_activeTab == 'import' ? 'PO' : 'SO'}-${mapData['id']}',
                    'supplier': mapData['supplierName'],
                    'customer': mapData['customerName'],
                    'date': dateStr,
                    'amount': '${total.toStringAsFixed(0)} ₫',
                    'status': mapData['status'] ?? 'Pending',
                    'items': itemsCount,
                  };
                }).toList();

                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: GridView.builder(
                    key: ValueKey(_activeTab),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 450,
                          mainAxisExtent: 260,
                          crossAxisSpacing: 24,
                          mainAxisSpacing: 24,
                        ),
                    itemCount: mappedData.length,
                    itemBuilder: (context, index) {
                      final item = mappedData[index];
                      return _buildTransactionCard(item, colors, isDark);
                    },
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String id, String label, IconData icon, bool isDark) {
    final isActive = _activeTab == id;
    final activeColor = id == 'import'
        ? AppColors.accentLight
        : AppColors.accentGreen;

    return InkWell(
      onTap: () => setState(() => _activeTab = id),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? (isDark
                    ? activeColor.withOpacity(0.15)
                    : activeColor.withOpacity(0.08))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive
                  ? activeColor
                  : (isDark ? Colors.white54 : Colors.black54),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive
                    ? activeColor
                    : (isDark ? Colors.white54 : Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(
    Map<String, dynamic> data,
    _AppColorTokens colors,
    bool isDark,
  ) {
    final isImport = _activeTab == 'import';
    final accentColor = isImport
        ? AppColors.accentLight
        : AppColors.accentGreen;
    final rawId = data['rawId'];
    final status = data['status'] as String? ?? 'Pending';

    // ── Status badge ─────────────────────────────────────────────────────────
    Color statusColor;
    String statusLabel;
    IconData statusIcon;
    switch (status) {
      case 'Pending':
        statusColor = const Color(0xFFF59E0B);
        statusLabel = 'Chờ xử lý';
        statusIcon = Icons.hourglass_empty_rounded;
        break;
      case 'Approved':
        statusColor = const Color(0xFF3B82F6);
        statusLabel = 'Đã duyệt';
        statusIcon = Icons.verified_rounded;
        break;
      case 'Completed':
        statusColor = const Color(0xFF10B981);
        statusLabel = 'Hoàn thành';
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'Cancelled':
        statusColor = const Color(0xFFEF4444);
        statusLabel = 'Đã huỷ';
        statusIcon = Icons.cancel_rounded;
        break;
      default:
        statusColor = const Color(0xFF8B5CF6);
        statusLabel = status;
        statusIcon = Icons.info_rounded;
    }

    // ── Action button logic ──────────────────────────────────────────────────
    Widget? actionButton;
    if (rawId != null) {
      if (isImport && status == 'Pending') {
        actionButton = _ActionButton(
          label: 'Nhận hàng',
          icon: Icons.move_to_inbox_rounded,
          color: const Color(0xFF10B981),
          onTap: () =>
              context.read<TransactionBloc>().add(TransactionReceivePO(rawId)),
        );
      } else if (!isImport && status == 'Pending') {
        actionButton = _ActionButton(
          label: 'Duyệt đơn',
          icon: Icons.fact_check_rounded,
          color: const Color(0xFF3B82F6),
          onTap: () =>
              context.read<TransactionBloc>().add(TransactionApproveSO(rawId)),
        );
      } else if (!isImport && status == 'Approved') {
        actionButton = _ActionButton(
          label: 'Xuất kho',
          icon: Icons.outbox_rounded,
          color: const Color(0xFF8B5CF6),
          onTap: () =>
              context.read<TransactionBloc>().add(TransactionShipSO(rawId)),
        );
      }
    }

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, double val, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - val)),
          child: Opacity(opacity: val, child: child),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: colors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Container(height: 4, width: double.infinity, color: accentColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ID + Status badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          data['id'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: colors.textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: statusColor.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon, size: 11, color: statusColor),
                              const SizedBox(width: 4),
                              Text(
                                statusLabel,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Partner
                    Row(
                      children: [
                        Icon(
                          isImport
                              ? Icons.business_rounded
                              : Icons.person_rounded,
                          size: 14,
                          color: colors.textSecond,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            data['supplier'] ?? data['customer'] ?? '',
                            style: TextStyle(
                              color: colors.textSecond,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Date + Items
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: colors.textSecond,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          data['date'],
                          style: TextStyle(
                            color: colors.textSecond,
                            fontSize: 13,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${data['items']} sp',
                          style: TextStyle(
                            color: colors.textSecond,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(height: 1),
                    ),
                    // Total + Action
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            data['amount'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                        if (actionButton != null) actionButton,
                      ],
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
}

// ── Action button widget ──────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
