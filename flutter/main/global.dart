String? loggedInUserId;  
String? loggedInUserName;
String? loggedInUserEmail;
String? loggedInUserPhone;
List<Map<String, dynamic>> orderHistory = [];

class CartItem {
  final String name;
  final double price;
  int quantity;
  final String? description;

  CartItem({required this.name, required this.price, this.quantity = 1, this.description});
}

List<CartItem> cartItems = [];

String selectedBranchName = 'Main Branch Carmen, CDO';
String selectedBranchAddress = 'Max Suniel Street, near PHINMA-COC';
int estimatedTravelTime = 17;