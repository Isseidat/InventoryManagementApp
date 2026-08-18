class ApiConstants {
  // Chạy trên Desktop (Windows/Web) dùng localhost.
  // Chú ý: Nếu chạy trên Emulator Android, đổi thành 10.0.2.2 thay vì localhost.
  static const String baseUrl = 'http://localhost:5064/api'; 
  
  // Endpoints Auth
  static const String login = '/Auth/Login';
  static const String register = '/Auth/Register';

  // Endpoints Products
  static const String products = '/Products';

  // Endpoints Orders
  static const String salesOrders = '/SalesOrders';
  static const String purchaseOrders = '/PurchaseOrders';
}
