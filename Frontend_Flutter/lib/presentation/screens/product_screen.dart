import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/product/product_bloc.dart';
import '../blocs/product/product_state.dart';
import '../blocs/product/product_event.dart';
import '../../core/theme/theme_cubit.dart';
import 'product_dialog.dart';

// Copying some color extensions for local use from main_layout
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

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final Set<int> _selectedIds = {};

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Title & Add Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quản lý Sản phẩm',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              Row(
                children: [
                  if (_selectedIds.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Show delete confirmation for multiple
                          showDialog(
                            context: context,
                            builder: (dCtx) => AlertDialog(
                              title: const Text('Xác nhận xóa'),
                              content: Text('Bạn có chắc muốn xóa ${_selectedIds.length} sản phẩm đã chọn?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(dCtx), child: const Text('Hủy')),
                                TextButton(
                                  onPressed: () {
                                    for (var id in _selectedIds) {
                                      context.read<ProductBloc>().add(ProductDeleted(id));
                                    }
                                    setState(() => _selectedIds.clear());
                                    Navigator.pop(dCtx);
                                  },
                                  child: const Text('Xóa', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: Text('Xóa (${_selectedIds.length})'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[400],
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => BlocProvider.value(
                          value: context.read<ProductBloc>(),
                          child: const ProductDialog(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Thêm Sản phẩm'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 20),
          
          // Data Table Container
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: colors.bgCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.border),
              ),
              child: BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  if (state is ProductLoading || state is ProductInitial) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ProductFailure) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, color: Colors.red[400], size: 40),
                          const SizedBox(height: 12),
                          Text(state.message, style: TextStyle(color: colors.textPrimary)),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () => context.read<ProductBloc>().add(ProductListRequested()),
                            child: const Text('Thử lại'),
                          )
                        ],
                      ),
                    );
                  } else if (state is ProductLoaded) {
                    final products = state.products;
                    if (products.isEmpty) {
                      return Center(
                        child: Text(
                          'Chưa có sản phẩm nào',
                          style: TextStyle(color: colors.textSecond),
                        ),
                      );
                    }

                    return Column(
                      children: [
                        // Table Header
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: colors.border)),
                          ),
                          child: Row(
                            children: [
                              // Checkbox All
                              Expanded(
                                flex: 1,
                                child: Checkbox(
                                  value: _selectedIds.length == products.length && products.isNotEmpty,
                                  onChanged: (val) {
                                    setState(() {
                                      if (val == true) {
                                        _selectedIds.addAll(products.map((p) => p['id'] as int));
                                      } else {
                                        _selectedIds.clear();
                                      }
                                    });
                                  },
                                ),
                              ),
                              _th('SKU', flex: 2, colors: colors),
                              _th('Tên sản phẩm', flex: 4, colors: colors),
                              _th('Danh mục', flex: 2, colors: colors),
                              _th('Giá (VNĐ)', flex: 2, colors: colors),
                              _th('Tồn kho', flex: 2, colors: colors),
                              _th('Thao tác', flex: 2, colors: colors),
                            ],
                          ),
                        ),
                        // Table Body
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: products.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 4),
                            itemBuilder: (context, index) {
                              final p = products[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Checkbox(
                                        value: _selectedIds.contains(p['id']),
                                        onChanged: (val) {
                                          setState(() {
                                            if (val == true) {
                                              _selectedIds.add(p['id']);
                                            } else {
                                              _selectedIds.remove(p['id']);
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                    _td(p['sku']?.toString() ?? '-', flex: 2, colors: colors),
                                    _td(p['name']?.toString() ?? '-', flex: 4, colors: colors, isBold: true),
                                    _td(p['categoryName']?.toString() ?? '-', flex: 2, colors: colors),
                                    _td(_formatPrice(p['basePrice']), flex: 2, colors: colors, color: const Color(0xFF10B981)),
                                    _td((p['totalQuantity'] ?? 0).toString(), flex: 2, colors: colors),
                                    Expanded(
                                      flex: 2,
                                      child: Row(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              // TODO: Navigate to transactions screen for this product
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Tính năng đang phát triển')),
                                              );
                                            },
                                            child: Icon(Icons.remove_red_eye_outlined, size: 16, color: colors.textSecond),
                                          ),
                                          const SizedBox(width: 12),
                                          InkWell(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (_) => BlocProvider.value(
                                                  value: context.read<ProductBloc>(),
                                                  child: ProductDialog(product: p),
                                                ),
                                              );
                                            },
                                            child: Icon(Icons.edit_outlined, size: 16, color: colors.textSecond),
                                          ),
                                          const SizedBox(width: 12),
                                          InkWell(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (dCtx) => AlertDialog(
                                                  title: const Text('Xác nhận'),
                                                  content: const Text('Bạn có chắc muốn xóa sản phẩm này không?'),
                                                  actions: [
                                                    TextButton(onPressed: () => Navigator.pop(dCtx), child: const Text('Hủy')),
                                                    TextButton(
                                                      onPressed: () {
                                                        context.read<ProductBloc>().add(ProductDeleted(p['id']));
                                                        Navigator.pop(dCtx);
                                                      },
                                                      child: const Text('Xóa', style: TextStyle(color: Colors.red)),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            child: Icon(Icons.delete_outline, size: 16, color: Colors.red[400]),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _th(String text, {required int flex, required _AppColorTokens colors}) {
    return Expanded(
      flex: flex,
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: colors.textSecond,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _td(String text, {required int flex, required _AppColorTokens colors, bool isBold = false, Color? color}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          color: color ?? colors.textPrimary,
          fontSize: 13,
          fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '0';
    final p = double.tryParse(price.toString()) ?? 0;
    // Simple format
    return '${p.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')} đ';
  }
}
