import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import '../main/global.dart' as globals;
import '../home/home_screen.dart';
import 'payment_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with RouteAware {
  final Color _primaryColor = const Color(0xFF800000);
  Map<String, String> _productImages = {};

  @override
  void initState() {
    super.initState();
    _fetchProductImages();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _fetchProductImages() async {
    try {
      const String baseUrl = 'http://10.118.5.117/bistro/';
      final response = await http.get(Uri.parse('${baseUrl}flutter/get_menu_api.php'));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['status'] == 'success') {
          final data = decoded['data'] as Map<String, dynamic>;
          Map<String, String> images = {};
          data.forEach((category, items) {
            for (var item in (items as List)) {
              String name = item['name'].toString();
              String image = item['image'] != null && item['image'].toString().isNotEmpty
                  ? baseUrl + item['image'].toString()
                  : '';
              images[name] = image;
            }
          });
          if (mounted) setState(() => _productImages = images);
        }
      }
    } catch (_) {}
  }

  double get _totalPrice {
    return globals.cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  Future<void> _openLocation() async {
    final Uri mapUri = Uri.parse(
        'https://www.google.com/maps/search/Toyland+Bistro+CDO+Carmen');
    if (await canLaunchUrl(mapUri)) {
      await launchUrl(mapUri, mode: LaunchMode.externalApplication);
    }
  }

  void _proceedToPayment() {
    if (globals.loggedInUserName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please sign in to place an order!")),
      );
      return;
    }

    final List<Map<String, dynamic>> itemsList = globals.cartItems
        .map((item) => {'name': item.name, 'quantity': item.quantity})
        .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          totalPrice: _totalPrice,
          items: itemsList,
        ),
      ),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = globals.cartItems;
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'My Cart',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: -0.5),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen(isLoggedIn: true)),
            );
          },
        ),
      ),
      body: cartItems.isEmpty ? _buildEmptyCart() : _buildCartContent(),
      bottomNavigationBar: cartItems.isEmpty ? null : _buildCheckoutBottomBar(),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
            child: Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey.shade300),
          ),
          const SizedBox(height: 24),
          const Text(
            'Your cart is empty',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            'Looks like you haven\'t added\nanything to your cart yet.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.grey.shade500, height: 1.5),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen(isLoggedIn: true)),
              );
            },
            child: const Text(
              'Browse Menu',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          _buildPickupHeader(),
          const SizedBox(height: 10),
          _buildPersonalInfoSection(),
          const SizedBox(height: 10),
          _buildItemsSection(),
          const SizedBox(height: 10),
          _buildOrderSummarySection(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPickupHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(color: _primaryColor, borderRadius: BorderRadius.circular(10)),
            child: const Row(
              children: [
                Icon(Icons.storefront_outlined, color: Colors.white, size: 15),
                SizedBox(width: 6),
                Text('Pick Up Order',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
              ],
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _openLocation,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on, color: _primaryColor, size: 16),
                const SizedBox(width: 4),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 140),
                  child: Text(
                    globals.selectedBranchName ?? 'Main Branch',
                    style: TextStyle(
                      color: _primaryColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_outline, color: _primaryColor, size: 20),
              const SizedBox(width: 8),
              const Text('Personal Information',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 14),
          _buildInfoRow(Icons.person_outline, 'Name', globals.loggedInUserName ?? 'N/A'),
          const SizedBox(height: 10),
          _buildInfoRow(Icons.mail_outline, 'Email', globals.loggedInUserEmail ?? 'N/A'),
          const SizedBox(height: 10),
          _buildPhoneRow(),
          const SizedBox(height: 10),
          _buildLocationRow(),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: _primaryColor, size: 17),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 13, color: Colors.black87),
              children: [
                TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black54)),
                TextSpan(
                    text: value,
                    style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black87)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneRow() {
    final phone = globals.loggedInUserPhone;
    final hasPhone = phone != null && phone.isNotEmpty;
    return Row(
      children: [
        Icon(Icons.phone_outlined, color: _primaryColor, size: 17),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 13),
              children: [
                const TextSpan(
                    text: 'Phone: ',
                    style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black54)),
                TextSpan(
                  text: hasPhone ? phone! : 'Not provided',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: hasPhone ? Colors.black87 : Colors.black54),
                ),
              ],
            ),
          ),
        ),
        if (!hasPhone)
          GestureDetector(
            onTap: () {},
            child: Text('+ Add number',
                style: TextStyle(fontSize: 12, color: _primaryColor, fontWeight: FontWeight.w700)),
          ),
      ],
    );
  }

  Widget _buildLocationRow() {
    return GestureDetector(
      onTap: _openLocation,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(Icons.location_on_outlined, color: _primaryColor, size: 17),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pick-up Location:',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black54)),
                const SizedBox(height: 2),
                Text(
                  globals.selectedBranchName ?? 'Main Branch',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _primaryColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
                Text(
                  globals.selectedBranchAddress ?? 'Near PHINMA-COC',
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsSection() {
    final cartItems = globals.cartItems;
    int totalQty = cartItems.fold(0, (sum, item) => sum + item.quantity);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.restaurant_menu, color: _primaryColor, size: 20),
              const SizedBox(width: 8),
              const Text('Your Items',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.black87)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$totalQty item${totalQty > 1 ? 's' : ''}',
                  style: TextStyle(fontSize: 11, color: _primaryColor, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: cartItems.length,
            separatorBuilder: (context, index) =>
                Divider(color: Colors.grey.shade100, height: 20, thickness: 1),
            itemBuilder: (context, index) {
              final item = cartItems[index];
              return _buildCartItem(item, index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(globals.CartItem item, int index) {
    String? imageUrl = _productImages[item.name];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 56,
          width: 56,
          decoration: BoxDecoration(
            color: _primaryColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          clipBehavior: Clip.antiAlias,
          child: (imageUrl != null && imageUrl.isNotEmpty)
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Icon(Icons.fastfood, color: _primaryColor.withOpacity(0.5), size: 26),
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: _primaryColor.withOpacity(0.4)),
                      ),
                    );
                  },
                )
              : Center(child: Icon(Icons.fastfood, color: _primaryColor.withOpacity(0.5), size: 26)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 14, color: Colors.black87)),
              if (item.description != null && item.description!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(item.description!,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500, height: 1.3),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
              const SizedBox(height: 4),
              Text('₱${item.price.toStringAsFixed(2)}',
                  style: TextStyle(color: _primaryColor, fontSize: 14, fontWeight: FontWeight.w900)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  if (item.quantity > 1) {
                    item.quantity--;
                  } else {
                    globals.cartItems.removeAt(index);
                  }
                });
              },
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Icon(Icons.remove, size: 14, color: Colors.black87),
              ),
            ),
            SizedBox(
              width: 32,
              child: Center(
                child: Text('${item.quantity}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 14, color: Colors.black87)),
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => item.quantity++),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(shape: BoxShape.circle, color: _primaryColor),
                child: const Icon(Icons.add, size: 14, color: Colors.white),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => setState(() => globals.cartItems.removeAt(index)),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Icon(Icons.delete_outline, size: 15, color: Colors.red.shade400),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrderSummarySection() {
    final cartItems = globals.cartItems;
    int totalQty = cartItems.fold(0, (sum, item) => sum + item.quantity);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.receipt_long_outlined, color: _primaryColor, size: 20),
                  const SizedBox(width: 8),
                  const Text('Order Summary',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w900, color: Colors.black87)),
                ],
              ),
              Text(
                '₱${_totalPrice.toStringAsFixed(2)}',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w900, color: _primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal ($totalQty item${totalQty > 1 ? 's' : ''})',
                  style: TextStyle(
                      fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
              Text('₱${_totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Colors.grey.shade200, thickness: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Payment',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w900, color: Colors.black87)),
              Text('₱${_totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w900, color: _primaryColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 20, offset: const Offset(0, -5))],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Total Payment",
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
                    Text("₱${_totalPrice.toStringAsFixed(2)}",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w900, color: _primaryColor)),
                  ],
                ),
                SizedBox(
                  width: 180,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    onPressed: _proceedToPayment,
                    child: const Text(
                      "Place Order",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}