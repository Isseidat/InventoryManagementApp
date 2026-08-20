import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/dio_client.dart' as dio_client;
import '../../core/service_locator.dart' as di;
import '../../core/theme/theme_cubit.dart';

extension _ContextColors on BuildContext {
  _AppColorTokens get appColors {
    final isDark = watch<ThemeCubit>().state;
    return isDark ? _AppColorTokens.dark() : _AppColorTokens.light();
  }
}

class _AppColorTokens {
  final Color bgPrimary;
  final Color bgSidebar;
  final Color bgTopbar;
  final Color textPrimary;
  final Color textSecond;
  final Color border;
  final Color bgCard;

  _AppColorTokens({
    required this.bgPrimary,
    required this.bgSidebar,
    required this.bgTopbar,
    required this.textPrimary,
    required this.textSecond,
    required this.border,
    required this.bgCard,
  });

  factory _AppColorTokens.light() {
    return _AppColorTokens(
      bgPrimary: const Color(0xFFF1F5F9),
      bgSidebar: const Color(0xFFFFFFFF),
      bgTopbar: const Color(0xFFFFFFFF),
      textPrimary: const Color(0xFF0F172A),
      textSecond: const Color(0xFF64748B),
      border: const Color(0xFFE2E8F0),
      bgCard: const Color(0xFFFFFFFF),
    );
  }

  factory _AppColorTokens.dark() {
    return _AppColorTokens(
      bgPrimary: const Color(0xFF0D1117),
      bgSidebar: const Color(0xFF161B22),
      bgTopbar: const Color(0xFF161B22),
      textPrimary: const Color(0xFFE5E7EB),
      textSecond: const Color(0xFF8B949E),
      border: const Color(0xFF30363D),
      bgCard: const Color(0xFF161B22),
    );
  }
}

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isLoading = true;
  List<dynamic> _transactions = [];
  int _importCount = 0;
  int _exportCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    try {
      final dio = di.sl<dio_client.DioClient>().dio;
      final response = await dio.get('/Inventory/Transactions');
      if (response.data is List) {
        final allTx = response.data as List;
        final productTx = allTx
            .where((tx) => tx['productId'] == widget.product['id'])
            .toList();

        // Sắp xếp mới nhất lên đầu
        productTx.sort((a, b) {
          final d1 =
              DateTime.tryParse(a['transactionDate'] ?? '') ?? DateTime.now();
          final d2 =
              DateTime.tryParse(b['transactionDate'] ?? '') ?? DateTime.now();
          return d2.compareTo(d1);
        });

        int imp = 0;
        int exp = 0;
        for (var tx in productTx) {
          final int q = tx['quantity'] as int? ?? 0;
          if (tx['transactionType'] == 'StockIn') imp += q;
          if (tx['transactionType'] == 'StockOut') exp += q;
        }

        setState(() {
          _transactions = productTx;
          _importCount = imp;
          _exportCount = exp;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '0';
    final p = double.tryParse(price.toString()) ?? 0;
    return '${p.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')} đ';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final int qty = widget.product['totalQuantity'] ?? 0;
    // final bool inStock = qty > 0;
    // final product = widget.product;

    return Scaffold(
      backgroundColor: colors.bgPrimary,
      appBar: AppBar(
        backgroundColor: colors.bgTopbar,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Chi tiết Sản phẩm',
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: colors.border, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colors.bgCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.inventory_2_rounded,
                      size: 40,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    (qty == 0
                                            ? Colors.red
                                            : qty < 30
                                            ? Colors.deepOrange
                                            : qty < 50
                                            ? Colors.orange
                                            : Colors.green)
                                        .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                qty == 0
                                    ? 'Hết hàng'
                                    : qty < 30
                                    ? 'Sắp hết hàng'
                                    : qty < 50
                                    ? 'Cần nhập hàng'
                                    : 'Bình thường',
                                style: TextStyle(
                                  color: qty == 0
                                      ? Colors.red[700]
                                      : qty < 30
                                      ? Colors.deepOrange[700]
                                      : qty < 50
                                      ? Colors.orange[700]
                                      : Colors.green[700],
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'SKU: ${widget.product['sku'] ?? 'N/A'}',
                              style: TextStyle(
                                color: colors.textSecond,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.product['name']?.toString() ?? 'Tên sản phẩm',
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Danh mục: ${widget.product['categoryName'] ?? 'Không có'}',
                          style: TextStyle(
                            color: colors.textSecond,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Giá cơ bản',
                        style: TextStyle(
                          color: colors.textSecond,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatPrice(widget.product['basePrice']),
                        style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Middle Section (2 Columns)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: Inventory Details
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colors.bgCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Thông tin Kho',
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            _buildInfoCard(
                              'Tồn kho hiện tại',
                              '$qty ${widget.product['unit'] ?? ''}',
                              Icons.warehouse_rounded,
                              colors,
                            ),
                            if (widget.product['packingUnit'] != null &&
                                widget.product['conversionRate'] != null)
                              const SizedBox(width: 16),
                            if (widget.product['packingUnit'] != null &&
                                widget.product['conversionRate'] != null)
                              _buildInfoCard(
                                'Quy đổi',
                                '1 ${widget.product['packingUnit']} = ${widget.product['conversionRate']} ${widget.product['unit'] ?? ''}',
                                Icons.calculate_rounded,
                                colors,
                              ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'Lịch sử giao dịch gần đây',
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_isLoading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (_transactions.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 32),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.history_rounded,
                                    size: 48,
                                    color: colors.border,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Chưa có giao dịch nào',
                                    style: TextStyle(color: colors.textSecond),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _transactions.length > 5
                                ? 5
                                : _transactions.length, // Show up to 5
                            separatorBuilder: (_, __) =>
                                Divider(height: 16, color: colors.border),
                            itemBuilder: (ctx, i) {
                              final tx = _transactions[i];
                              final isStockIn =
                                  tx['transactionType'] == 'StockIn';
                              return Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isStockIn
                                          ? Colors.green.withValues(alpha: 0.1)
                                          : Colors.red.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isStockIn
                                          ? Icons.arrow_downward_rounded
                                          : Icons.arrow_upward_rounded,
                                      size: 16,
                                      color: isStockIn
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isStockIn ? 'Nhập kho' : 'Xuất kho',
                                          style: TextStyle(
                                            color: colors.textPrimary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          tx['note'] ?? 'Không có ghi chú',
                                          style: TextStyle(
                                            color: colors.textSecond,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${isStockIn ? '+' : '-'}${tx['quantity']}',
                                        style: TextStyle(
                                          color: isStockIn
                                              ? Colors.green
                                              : Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        tx['transactionDate']
                                                ?.toString()
                                                .split('T')
                                                .first ??
                                            '',
                                        style: TextStyle(
                                          color: colors.textSecond,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 24),

                // Right Column: Quick Actions & Stats
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      // Stats Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: colors.bgCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: colors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Thống kê nhanh',
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildStatRow(
                              'Tổng lượng nhập',
                              _importCount.toString(),
                              colors,
                            ),
                            const Divider(height: 24),
                            _buildStatRow(
                              'Tổng lượng xuất',
                              _exportCount.toString(),
                              colors,
                            ),
                            const Divider(height: 24),
                            _buildStatRow(
                              'Trạng thái',
                              qty == 0
                                  ? 'Hết hàng'
                                  : qty < 30
                                  ? 'Sắp hết hàng'
                                  : qty < 50
                                  ? 'Cần nhập hàng'
                                  : 'Bình thường',
                              colors,
                              valueColor: qty == 0
                                  ? Colors.red
                                  : qty < 30
                                  ? Colors.deepOrange
                                  : qty < 50
                                  ? Colors.orange
                                  : Colors.green,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    String title,
    String value,
    IconData icon,
    _AppColorTokens colors,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.bgPrimary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colors.bgCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colors.border),
              ),
              child: Icon(icon, size: 20, color: const Color(0xFF6366F1)),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: colors.textSecond, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
    String label,
    String value,
    _AppColorTokens colors, {
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: colors.textSecond, fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? colors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
