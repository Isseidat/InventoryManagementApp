import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/service_locator.dart';
import '../../core/network/dio_client.dart';
import '../blocs/product/product_bloc.dart';
import '../blocs/product/product_event.dart';
import '../blocs/product/product_state.dart';

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
  final _unitCtrl = TextEditingController();
  final _packingUnitCtrl = TextEditingController();
  final _conversionRateCtrl = TextEditingController();

  int? _selectedCategoryId;
  List<dynamic> _categories = [];
  bool _isLoading = true;

  List<String> _existingPackingUnits = [];
  List<String> _existingConversionRates = [];

  String? _selectedPackingUnitVal;
  String? _selectedConversionRateVal;

  bool _isCustomPackingUnit = false;
  bool _isCustomConversionRate = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();

    final state = context.read<ProductBloc>().state;
    if (state is ProductLoaded) {
      final pu = <String>{};
      final cv = <String>{};
      for (var p in state.products) {
        if (p['packingUnit'] != null &&
            p['packingUnit'].toString().isNotEmpty) {
          pu.add(p['packingUnit'].toString());
        }
        if (p['conversionRate'] != null &&
            p['conversionRate'].toString().isNotEmpty) {
          cv.add(p['conversionRate'].toString());
        }
      }
      _existingPackingUnits = pu.toList();
      _existingConversionRates = cv.toList();
    }

    if (widget.product != null) {
      _skuCtrl.text = widget.product!['sku']?.toString() ?? '';
      _nameCtrl.text = widget.product!['name']?.toString() ?? '';
      final price =
          double.tryParse(widget.product!['basePrice']?.toString() ?? '0') ?? 0;
      _priceCtrl.text = price == price.toInt()
          ? price.toInt().toString()
          : price.toString();
      _selectedCategoryId = widget.product!['categoryId'];
      _unitCtrl.text = widget.product!['unit']?.toString() ?? '';

      final puVal = widget.product!['packingUnit']?.toString() ?? '';
      if (puVal.isNotEmpty) {
        if (_existingPackingUnits.contains(puVal)) {
          _selectedPackingUnitVal = puVal;
        } else {
          _selectedPackingUnitVal = 'Khác';
          _isCustomPackingUnit = true;
          _packingUnitCtrl.text = puVal;
        }
      }

      final cvVal = widget.product!['conversionRate']?.toString() ?? '';
      if (cvVal.isNotEmpty) {
        if (_existingConversionRates.contains(cvVal)) {
          _selectedConversionRateVal = cvVal;
        } else {
          _selectedConversionRateVal = 'Khác';
          _isCustomConversionRate = true;
          _conversionRateCtrl.text = cvVal;
        }
      }
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final dio = sl<DioClient>().dio;
      final res = await dio.get('/Categories');
      if (res.data is List) {
        setState(() {
          _categories = res.data;
          _isLoading = false;
          // Validate existing categoryId
          if (_selectedCategoryId != null) {
            final exists = _categories.any(
              (c) => c['id'] == _selectedCategoryId,
            );
            if (!exists) _selectedCategoryId = null;
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Vui lòng chọn danh mục')));
        return;
      }

      final data = {
        'sku': _skuCtrl.text.trim(),
        'name': _nameCtrl.text.trim(),
        'basePrice': double.tryParse(_priceCtrl.text.trim()) ?? 0,
        'categoryId': _selectedCategoryId,
        'unit': _unitCtrl.text.trim(),
        'packingUnit': _isCustomPackingUnit
            ? (_packingUnitCtrl.text.trim().isEmpty
                  ? null
                  : _packingUnitCtrl.text.trim())
            : _selectedPackingUnitVal,
        'conversionRate': _isCustomConversionRate
            ? int.tryParse(_conversionRateCtrl.text.trim())
            : int.tryParse(_selectedConversionRateVal ?? ''),
      };

      if (widget.product == null) {
        context.read<ProductBloc>().add(ProductAdded(data));
      } else {
        bool isChanged = false;
        if (data['sku'] != widget.product!['sku']) isChanged = true;
        if (data['name'] != widget.product!['name']) isChanged = true;
        if (data['basePrice'] != (widget.product!['basePrice'] ?? 0))
          isChanged = true;
        if (data['categoryId'] != widget.product!['categoryId'])
          isChanged = true;
        if (data['unit'] != widget.product!['unit']) isChanged = true;
        if (data['packingUnit'] != widget.product!['packingUnit'])
          isChanged = true;
        if (data['conversionRate'] != widget.product!['conversionRate'])
          isChanged = true;

        if (!isChanged) {
          Navigator.of(context).pop();
          return;
        }

        context.read<ProductBloc>().add(
          ProductUpdated(widget.product!['id'], data),
        );
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
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEdit ? 'Điều chỉnh Sản phẩm' : 'Thêm Sản phẩm Mới',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Vui lòng điền đầy đủ thông tin bên dưới',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const SizedBox(
                height: 150,
                child: Center(child: CircularProgressIndicator()),
              )
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
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
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
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
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
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                            ),
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Bắt buộc';
                              final price = double.tryParse(v);
                              if (price == null) return 'Phải là số';
                              if (price < 0) return 'Giá phải >= 0';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            decoration: InputDecoration(
                              labelText: 'Danh mục',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
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
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _unitCtrl,
                            decoration: InputDecoration(
                              labelText: 'Đơn vị tính (VD: Gói)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                            ),
                            validator: (v) => v!.isEmpty ? 'Bắt buộc' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: 'Đơn vị lớn (Tùy chọn)',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                ),
                                value: _selectedPackingUnitVal,
                                items: [
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Text('Không có'),
                                  ),
                                  ..._existingPackingUnits.map(
                                    (u) => DropdownMenuItem(
                                      value: u,
                                      child: Text(u),
                                    ),
                                  ),
                                  const DropdownMenuItem(
                                    value: 'Khác',
                                    child: Text('Khác...'),
                                  ),
                                ],
                                onChanged: (val) {
                                  setState(() {
                                    _selectedPackingUnitVal = val;
                                    _isCustomPackingUnit = val == 'Khác';
                                    if (!_isCustomPackingUnit)
                                      _packingUnitCtrl.clear();
                                  });
                                },
                              ),
                              if (_isCustomPackingUnit) ...[
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _packingUnitCtrl,
                                  decoration: InputDecoration(
                                    labelText: 'Nhập đơn vị lớn mới',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: 'Quy đổi (Tùy chọn)',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                ),
                                value: _selectedConversionRateVal,
                                items: [
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Text('Không có'),
                                  ),
                                  ..._existingConversionRates.map(
                                    (c) => DropdownMenuItem(
                                      value: c,
                                      child: Text(c),
                                    ),
                                  ),
                                  const DropdownMenuItem(
                                    value: 'Khác',
                                    child: Text('Khác...'),
                                  ),
                                ],
                                onChanged: (val) {
                                  setState(() {
                                    _selectedConversionRateVal = val;
                                    _isCustomConversionRate = val == 'Khác';
                                    if (!_isCustomConversionRate)
                                      _conversionRateCtrl.clear();
                                  });
                                },
                              ),
                              if (_isCustomConversionRate) ...[
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _conversionRateCtrl,
                                  decoration: InputDecoration(
                                    labelText: 'Nhập quy đổi mới',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (v) {
                                    if (v != null && v.isNotEmpty) {
                                      final val = int.tryParse(v);
                                      if (val == null || val <= 0)
                                        return 'Phải > 0';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ],
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Hủy'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isEdit ? 'Lưu thay đổi' : 'Tạo mới',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
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
