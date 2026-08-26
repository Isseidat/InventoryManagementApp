abstract class TransactionEvent {}

class TransactionListRequested extends TransactionEvent {}

class TransactionCreatePurchaseOrder extends TransactionEvent {
  final Map<String, dynamic> data;
  TransactionCreatePurchaseOrder(this.data);
}

class TransactionCreateSalesOrder extends TransactionEvent {
  final Map<String, dynamic> data;
  TransactionCreateSalesOrder(this.data);
}

class TransactionReceivePO extends TransactionEvent {
  final int orderId;
  TransactionReceivePO(this.orderId);
}

class TransactionApproveSO extends TransactionEvent {
  final int orderId;
  TransactionApproveSO(this.orderId);
}

class TransactionShipSO extends TransactionEvent {
  final int orderId;
  TransactionShipSO(this.orderId);
}
