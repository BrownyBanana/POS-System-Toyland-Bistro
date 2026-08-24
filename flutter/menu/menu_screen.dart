import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../main/global.dart' as globals;
import 'cart_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final Color _primaryColor = const Color(0xFF800000);
  int _selectedTabIndex = 0;

  List<String> _categories = [];
  Map<String, GlobalKey> _categoryKeys = {};

  bool _isStoreOpen() {
    return true;
  }

  Map<String, List<Map<String, dynamic>>> _menuData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMenuData();
  }

  Future<void> _fetchMenuData() async {
    const String baseUrl = 'http://10.118.5.117/bistro/';
    const String apiUrl = '${baseUrl}flutter/get_menu_api.php';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);

        if (decodedData['status'] == 'success') {
          final fetchedData = decodedData['data'] as Map<String, dynamic>;

          Map<String, List<Map<String, dynamic>>> newMenuData = {};

          fetchedData.forEach((key, value) {
            newMenuData[key] = (value as List).map((item) {
              return {
                'name': item['name'],
                'price': item['price'],
                'image': item['image'] != null && item['image'].toString().isNotEmpty
                    ? baseUrl + item['image']
                    : '',
                'description': null,
              };
            }).toList();
          });

          setState(() {
            _menuData = newMenuData;
            _categories = _menuData.keys.toList();
            for (var category in _categories) {
              _categoryKeys[category] = GlobalKey();
            }
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() { _isLoading = false; });
    }
  }

  void _scrollToCategory(int index, String category) {
    setState(() {
      _selectedTabIndex = index;
    });

    final key = _categoryKeys[category];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutQuart,
      );
    }
  }

  void _showProductModal(BuildContext context, String title, String price, String imagePath, String? description) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.85,
          child: ProductDetailsSheet(
            productName: title,
            productPrice: price,
            imagePath: imagePath,
            description: description,
            primaryColor: _primaryColor,
          ),
        );
      },
    ).then((_) {
      setState(() {});
    });
  }

  void _showHotColdSelection(BuildContext context, String name, String price, String imagePath, String? description) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('How would you like your $name?',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _showProductModal(context, "Hot $name", price, imagePath, description);
                    },
                    child: Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(color: _primaryColor, shape: BoxShape.circle),
                      child: const Center(child: Text('HOT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _showProductModal(context, "Cold $name", price, imagePath, description);
                    },
                    child: Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(color: _primaryColor, shape: BoxShape.circle),
                      child: const Center(child: Text('COLD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _quickAddToCart(String name, String price, String? description) {
    double basePrice = double.tryParse(price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;

    setState(() {
      int existingIndex = globals.cartItems.indexWhere((item) => item.name == name);
      if (existingIndex >= 0) {
        globals.cartItems[existingIndex].quantity++;
      } else {
        globals.cartItems.add(
          globals.CartItem(
            name: name,
            price: basePrice,
            quantity: 1,
            description: description,
          ),
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$name added to cart!"),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showGuestLoginPrompt() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Please Login First Before Ordering"),
        backgroundColor: const Color(0xFF800000),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildMenuCategoryTab(int index, String title) {
    bool isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => _scrollToCategory(index, title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected ? _primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? _primaryColor : Colors.grey.shade300),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String category, String name, String price, String imagePath, String? description) {
    bool isOpen = _isStoreOpen();

    return InkWell(
      onTap: isOpen ? () {
        if (globals.loggedInUserName == null) {
          _showGuestLoginPrompt();
          return;
        }
        if (category == 'Espresso' || category == 'Non Coffee') {
          _showHotColdSelection(context, name, price, imagePath, description);
        } else {
          _showProductModal(context, name, price, imagePath, description);
        }
      } : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imagePath,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 90,
                    height: 90,
                    color: Colors.grey.shade100,
                    child: Icon(Icons.fastfood, color: Colors.grey.shade400, size: 35),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                  if (description != null && description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(description, style: TextStyle(fontSize: 12, color: Colors.grey.shade600), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                  const SizedBox(height: 6),
                  Text(price, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black54)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isOpen ? _primaryColor.withOpacity(0.1) : Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add, color: isOpen ? _primaryColor : Colors.grey, size: 20),
              ),
              onPressed: isOpen ? () {
                if (globals.loggedInUserName == null) {
                  _showGuestLoginPrompt();
                  return;
                }
                if (category == 'Espresso' || category == 'Non Coffee') {
                  _showHotColdSelection(context, name, price, imagePath, description);
                } else {
                  _quickAddToCart(name, price, description);
                }
              } : null,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isOpen = _isStoreOpen();

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: globals.cartItems.isNotEmpty
        ? FloatingActionButton.extended(
            backgroundColor: _primaryColor,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen()))
                .then((_) => setState(() {}));
            },
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            label: Text("${globals.cartItems.length} items", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        : null,

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Pick Up • ${globals.selectedBranchName}',
                      style: TextStyle(color: _primaryColor, fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Bistro Menu', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.black87, letterSpacing: -1)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isOpen ? Colors.green.shade50 : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isOpen ? 'Open Now' : 'Closed',
                          style: TextStyle(color: isOpen ? Colors.green : Colors.red, fontSize: 12, fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('${globals.estimatedTravelTime} mins away', style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  return _buildMenuCategoryTab(index, _categories[index]);
                },
              ),
            ),
            Divider(thickness: 1, height: 24, color: Colors.grey.shade200),
            Expanded(
              child: _isLoading
                ? Center(child: CircularProgressIndicator(color: _primaryColor))
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _categories.map<Widget>((category) {
                          final items = _menuData[category] ?? [];
                          return Column(
                            key: _categoryKeys[category],
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
                                child: Text(
                                  category,
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black87, letterSpacing: -0.5),
                                ),
                              ),
                              ...items.map<Widget>((item) => Column(
                                    children: [
                                      _buildMenuItem(
                                        context,
                                        category,
                                        item['name'].toString(),
                                        item['price'].toString(),
                                        item['image'].toString(),
                                        item['description']?.toString(),
                                      ),
                                      Divider(color: Colors.grey.shade200),
                                    ],
                                  )),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductDetailsSheet extends StatefulWidget {
  final String productName;
  final String productPrice;
  final String imagePath;
  final String? description;
  final Color primaryColor;

  const ProductDetailsSheet({
    super.key,
    required this.productName,
    required this.productPrice,
    required this.imagePath,
    this.description,
    required this.primaryColor,
  });

  @override
  State<ProductDetailsSheet> createState() => _ProductDetailsSheetState();
}

class _ProductDetailsSheetState extends State<ProductDetailsSheet> {
  int _quantity = 1;

  double get _basePrice {
    String cleanString = widget.productPrice.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleanString) ?? 0.0;
  }

  double get _totalPrice => _basePrice * _quantity;

  void _addToCart() {
    globals.cartItems.add(
      globals.CartItem(
        name: widget.productName,
        price: _basePrice,
        quantity: _quantity,
        description: widget.description,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 28),
              Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                  child: const Icon(Icons.close, size: 20, color: Colors.black54),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  widget.imagePath,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 250,
                      color: Colors.grey.shade200,
                      child: Icon(Icons.fastfood, color: Colors.grey.shade400, size: 80),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(widget.productName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black87, height: 1.2)),
                          ),
                          const SizedBox(width: 16),
                          Text(widget.productPrice, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                        ],
                      ),
                      if (widget.description != null && widget.description!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(widget.description!, style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.4)),
                      ],
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => setState(() { if (_quantity > 1) _quantity--; }),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                              child: Icon(Icons.remove, color: _quantity > 1 ? Colors.black87 : Colors.grey.shade400),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Text('$_quantity', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                          ),
                          GestureDetector(
                            onTap: () => setState(() { _quantity++; }),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                              child: const Icon(Icons.add, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SafeArea(
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: _addToCart,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Add to Cart', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('₱${_totalPrice.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}