import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../core/service_locator.dart';
import '../../core/network/dio_client.dart';
import '../blocs/transaction/transaction_bloc.dart';
import '../blocs/transaction/transaction_event.dart';

class CreateTransactionDialog extends StatefulWidget {
  final bool isImport;

  const CreateTransactionDialog({super.key, required this.isImport});

  @override
  State<CreateTransactionDialog> createState() => _CreateTransactionDialogState();
}

class _CreateTransactionDialogState extends State<CreateTransactionDialog> {
  bool _isLoading = true;
  List<dynamic> _products = [];
  List<dynamic> _warehouses = [];
  List<dynamic> _partners = []; // Suppliers or Customers

  int? _selectedWarehouseId;
  int? _selectedPartnerId;

  // Selected items: productId -> { 'quantity': x, 'unitPrice': y, 'name': z }
  final Map<int, Map<String, dynamic>> _selectedItems = {};

  @override
  void initState() {
    super.initState();
    _fetchDropdownData();
  }

  Future<void> _fetchDropdownData() async {
    try {
      final dio = sl<DioClient>().dio;
      final prodRes = await dio.get('/Products/GetAllProduct');
      final wareRes = await dio.get('/Warehouses');
      final partnerRes = await dio.get(widget.isImport ? '/Suppliers' : '/Customers');

      if (mounted) {
        setState(() {
          _products = prodRes.data ?? [];
          _warehouses = wareRes.data ?? [];
          _partners = partnerRes.data ?? [];
          
          if (_warehouses.isNotEmpty) _selectedWarehouseId = _warehouses.first['id'];
          if (_partners.isNotEmpty) _selectedPartnerId = _partners.first['id'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải dữ liệu: $e')),
        );
      }
    }
  }

  void _submit() {
    if (_selectedWarehouseId == null || _selectedPartnerId == null || _selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đủ thông tin và chọn ít nhất 1 sản phẩm!')),
      );
      return;
    }

    final details = _selectedItems.entries.map((e) => {
      'productId': e.key,
      'quantity': e.value['quantity'],
      'unitPrice': e.value['unitPrice'],
    }).toList();

    final data = {
      widget.isImport ? 'supplierId' : 'customerId': _selectedPartnerId,
      'warehouseId': _selectedWarehouseId,
      'details': details,
    };

    if (widget.isImport) {
      context.read<TransactionBloc>().add(TransactionCreatePurchaseOrder(data));
    } else {
      context.read<TransactionBloc>().add(TransactionCreateSalesOrder(data));
    }
    Navigator.pop(context);
  }

  double get _totalPrice {
    double t = 0;
    for (var v in _selectedItems.values) {
      t += (v['quantity'] as int) * (v['unitPrice'] as double);
    }
    return t;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Dialog(
        child: SizedBox(
          width: 200, height: 100,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 850,
        height: 650,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.isImport ? 'Tạo Phiếu Nhập Kho' : 'Tạo Phiếu Xuất Kho',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left side (Form)
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        border: Border(right: BorderSide(color: Colors.black12)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Thông tin chung', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<int>(
                            value: _selectedPartnerId,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.blueGrey),
                            decoration: InputDecoration(
                              labelText: widget.isImport ? 'Nhà cung cấp' : 'Khách hàng',
                              labelStyle: const TextStyle(color: Colors.blueGrey, fontSize: 14),
                              filled: true,
                              fillColor: Colors.grey.withOpacity(0.05),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                              ),
                            ),
                            items: _partners.map((p) => DropdownMenuItem<int>(
                              value: p['id'],
                              child: Text(p['name'] ?? p['supplierName'] ?? p['customerName'] ?? 'Không tên', style: const TextStyle(fontSize: 14)),
                            )).toList(),
                            onChanged: (v) => setState(() => _selectedPartnerId = v),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<int>(
                            value: _selectedWarehouseId,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.blueGrey),
                            decoration: InputDecoration(
                              labelText: 'Kho hàng',
                              labelStyle: const TextStyle(color: Colors.blueGrey, fontSize: 14),
                              filled: true,
                              fillColor: Colors.grey.withOpacity(0.05),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                              ),
                            ),
                            items: _warehouses.map((w) => DropdownMenuItem<int>(
                              value: w['id'],
                              child: Text(w['name'] ?? w['warehouseName'] ?? 'Không tên', style: const TextStyle(fontSize: 14)),
                            )).toList(),
                            onChanged: (v) => setState(() => _selectedWarehouseId = v),
                          ),
                          const Spacer(),
                          const Divider(),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Tổng tiền:', style: TextStyle(fontSize: 16, color: Colors.grey)),
                              Text(
                                '${_totalPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} ₫',
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Lưu Phiếu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Right side (Products)
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Danh sách Sản phẩm', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              SizedBox(
                                width: 250,
                                height: 40,
                                child: DropdownButtonFormField<int>(
                                  isExpanded: true,
                                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.blueGrey),
                                  decoration: InputDecoration(
                                    labelText: 'Thêm sản phẩm...',
                                    labelStyle: const TextStyle(color: Colors.blueGrey, fontSize: 13),
                                    filled: true,
                                    fillColor: Colors.grey.withOpacity(0.05),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                                    ),
                                  ),
                                  items: _products.map((p) => DropdownMenuItem<int>(
                                    value: p['id'],
                                    child: Text(p['name'] ?? 'Không tên', style: const TextStyle(fontSize: 13)),
                                  )).toList(),
                                  onChanged: (prodId) {
                                    if (prodId != null && !_selectedItems.containsKey(prodId)) {
                                      final p = _products.firstWhere((x) => x['id'] == prodId);
                                      setState(() {
                                        _selectedItems[prodId] = {
                                          'name': p['name'],
                                          'quantity': 1,
                                          'unitPrice': (p['price'] ?? 0).toDouble(),
                                        };
                                      });
                                    }
                                  },
                                  value: null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Table Header
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                            child: const Row(
                              children: [
                                Expanded(flex: 3, child: Text('Tên SP', style: TextStyle(fontWeight: FontWeight.bold))),
                                Expanded(flex: 2, child: Text('SL', style: TextStyle(fontWeight: FontWeight.bold))),
                                Expanded(flex: 3, child: Text('Đơn giá', style: TextStyle(fontWeight: FontWeight.bold))),
                                Expanded(flex: 3, child: Text('Thành tiền', style: TextStyle(fontWeight: FontWeight.bold))),
                                SizedBox(width: 40),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          // Table Body
                          Expanded(
                            child: _selectedItems.isEmpty
                                ? const Center(child: Text('Chưa có sản phẩm nào được chọn', style: TextStyle(color: Colors.grey)))
                                : ListView.separated(
                                    itemCount: _selectedItems.length,
                                    separatorBuilder: (_, __) => const Divider(height: 1),
                                    itemBuilder: (context, index) {
                                      final id = _selectedItems.keys.elementAt(index);
                                      final data = _selectedItems[id]!;
                                      final total = (data['quantity'] as int) * (data['unitPrice'] as double);
                                      
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                        child: Row(
                                          children: [
                                            Expanded(flex: 3, child: Text(data['name'], style: const TextStyle(fontWeight: FontWeight.w500))),
                                            Expanded(
                                              flex: 2,
                                              child: Padding(
                                                padding: const EdgeInsets.only(right: 16),
                                                child: TextFormField(
                                                  initialValue: data['quantity'].toString(),
                                                  decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.all(8), border: OutlineInputBorder()),
                                                  keyboardType: TextInputType.number,
                                                  onChanged: (v) => setState(() => data['quantity'] = int.tryParse(v) ?? 1),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Padding(
                                                padding: const EdgeInsets.only(right: 16),
                                                child: TextFormField(
                                                  initialValue: data['unitPrice'].toString(),
                                                  decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.all(8), border: OutlineInputBorder()),
                                                  keyboardType: TextInputType.number,
                                                  onChanged: (v) => setState(() => data['unitPrice'] = double.tryParse(v) ?? 0),
                                                ),
                                              ),
                                            ),
                                              Expanded(
                                                flex: 3,
                                                child: Text('${total.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} ₫', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                                              ),
                                            SizedBox(
                                              width: 40,
                                              child: IconButton(
                                                icon: const Icon(Icons.close, color: Colors.red, size: 20),
                                                padding: EdgeInsets.zero,
                                                onPressed: () => setState(() => _selectedItems.remove(id)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

