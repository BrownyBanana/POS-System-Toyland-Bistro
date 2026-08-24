import 'package:flutter/material.dart';
import 'new_arrival_item.dart';
import '../main/global.dart' as globals;

class BestSellersScreen extends StatelessWidget {
  final List<NewArrivalItem> bestSellers;

  const BestSellersScreen({super.key, required this.bestSellers});

  double _parsePrice(String priceStr) {
    final cleaned = priceStr.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  void _addToCart(BuildContext context, String name, double price) {
    final existing = globals.cartItems.where((i) => i.name == name).toList();
    if (existing.isNotEmpty) {
      existing.first.quantity++;
    } else {
      globals.cartItems.add(globals.CartItem(name: name, price: price));
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$name added to cart!"),
        backgroundColor: const Color(0xFF800000),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF800000);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Best Sellers',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: -0.5),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: bestSellers.length,
        itemBuilder: (context, index) {
          final item = bestSellers[index];
          return GestureDetector(
            onTap: () {
              _addToCart(context, item.name, _parsePrice(item.price));
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                    child: Image.asset(
                      item.imagePath,
                      width: 110,
                      height: 110,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        width: 110,
                        height: 110,
                        color: Colors.grey.shade100,
                        child: Icon(Icons.restaurant, color: Colors.grey.shade300, size: 36),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(item.tag, style: TextStyle(color: primaryColor, fontSize: 11, fontWeight: FontWeight.w700)),
                          ),
                          const SizedBox(height: 8),
                          Text(item.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black87)),
                          const SizedBox(height: 6),
                          Text(item.price, style: TextStyle(color: primaryColor, fontWeight: FontWeight.w900, fontSize: 15)),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Icon(Icons.add_shopping_cart, size: 20, color: primaryColor),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}