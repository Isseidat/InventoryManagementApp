import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/service_locator.dart';
import '../../core/network/dio_client.dart';
import '../blocs/product/product_bloc.dart';
import '../blocs/product/product_event.dart';

class ProductDialog extends StatefulWidget {
  final Map<String, dynamic>? product; // null = Add, non-null = Edit

  const ProductDialog({super.key, this.product});

  @override
  State<ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<ProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _skuCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  int? _selectedCategoryId;
  List<dynamic> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _skuCtrl.text = widget.product!['sku']?.toString() ?? '';
      _nameCtrl.text = widget.product!['name']?.toString() ?? '';
      _priceCtrl.text = widget.product!['basePrice']?.toString() ?? '';
      // Category selection will be matched after fetching categories
    }
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final dio = sl<DioClient>().dio;
      final response = await dio.get('/Categories');
      if (response.statusCode == 200 && response.data != null) {
        setState(() {
          _categories = response.data;
          _isLoading = false;
          
          if (widget.product != null) {
            final catName = widget.product!['categoryName'];
            final match = _categories.where((c) => c['name'] == catName).toList();
            if (match.isNotEmpty) {
              _selectedCategoryId = match.first['id'];
            }
          }
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn danh mục')),
        );
        return;
      }

      final data = {
        'sku': _skuCtrl.text.trim(),
        'name': _nameCtrl.text.trim(),
        'basePrice': double.tryParse(_priceCtrl.text.trim()) ?? 0,
        'categoryId': _selectedCategoryId,
      };

      if (widget.product == null) {
        context.read<ProductBloc>().add(ProductAdded(data));
      } else {
        context.read<ProductBloc>().add(ProductUpdated(widget.product!['id'], data));
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 24,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEdit ? 'Sửa Sản phẩm' : 'Thêm Sản phẩm Mới',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vui lòng điền đầy đủ thông tin bên dưới',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const SizedBox(height: 150, child: Center(child: CircularProgressIndicator()))
            else
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _skuCtrl,
                            decoration: InputDecoration(
                              labelText: 'SKU (Mã SP)',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              filled: true,
                            ),
                            validator: (v) => v!.isEmpty ? 'Bắt buộc' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _nameCtrl,
                            decoration: InputDecoration(
                              labelText: 'Tên Sản phẩm',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              filled: true,
                            ),
                            validator: (v) => v!.isEmpty ? 'Bắt buộc' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _priceCtrl,
                            decoration: InputDecoration(
                              labelText: 'Giá cơ bản (VNĐ)',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              filled: true,
                            ),
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.isEmpty ? 'Bắt buộc' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            decoration: InputDecoration(
                              labelText: 'Danh mục',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              filled: true,
                            ),
                            value: _selectedCategoryId,
                            // ignore: deprecated_member_use
                            items: _categories.map((c) {
                              return DropdownMenuItem<int>(
                                value: c['id'],
                                child: Text(c['name']?.toString() ?? ''),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() => _selectedCategoryId = val);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Hủy'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: Text(
                    isEdit ? 'Lưu thay đổi' : 'Tạo mới',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
