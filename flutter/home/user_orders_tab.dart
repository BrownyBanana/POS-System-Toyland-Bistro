import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../main/global.dart' as globals;

class UserOrdersTab extends StatefulWidget {
  const UserOrdersTab({super.key});

  @override
  State<UserOrdersTab> createState() => _UserOrdersTabState();
}

class _UserOrdersTabState extends State<UserOrdersTab> {
  List<dynamic> _orders = [];
  bool _isLoading = true;
  Timer? _timer;
  final Color _primaryColor = const Color(0xFF800000);
  Map<String, double> _productPrices = {};

  @override
  void initState() {
    super.initState();
    _fetchProductPrices();
    _fetchOrders();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) => _fetchOrders());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchProductPrices() async {
    try {
      const String baseUrl = 'http://10.118.5.117/bistro/';
      final response = await http.get(Uri.parse('${baseUrl}flutter/get_menu_api.php'));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['status'] == 'success') {
          final data = decoded['data'] as Map<String, dynamic>;
          Map<String, double> prices = {};
          data.forEach((category, items) {
            for (var item in (items as List)) {
              String name = item['name'].toString();
              double price = double.tryParse(item['price'].toString()) ?? 0.0;
              prices[name] = price;
            }
          });
          if (mounted) setState(() => _productPrices = prices);
        }
      }
    } catch (_) {}
  }

  Future<void> _fetchOrders() async {
    if (globals.loggedInUserName == null) return;
    try {
      var url = Uri.parse("http://10.118.5.117/bistro/flutter/my_orders_api.php?customer_name=${Uri.encodeComponent(globals.loggedInUserName!)}");
      var response = await http.get(url);
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _orders = json.decode(response.body);
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _completeOrder(String orderId) async {
    try {
      var url = Uri.parse("http://10.118.5.117/bistro/flutter/complete_order_api.php");
      var response = await http.post(url, body: {'order_id': orderId});
      if (response.statusCode == 200) {
        _fetchOrders();
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Future<void> _cancelOrder(String orderId) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel Order?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          'Are you sure you want to cancel this order? This action cannot be undone.',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('No, Keep It', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF800000),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      var url = Uri.parse("http://10.118.5.117/bistro/flutter/cancel_order_api.php");
      var response = await http.post(url, body: {'order_id': orderId});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text("Order cancelled successfully."),
                backgroundColor: const Color(0xFF800000),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.all(16),
              ),
            );
          }
          _fetchOrders();
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(data['message'] ?? "Could not cancel order.")),
            );
          }
        }
      }
    } catch (e) {
      debugPrint("Cancel error: $e");
    }
  }

  List<Map<String, dynamic>> _parseProducts(String productSold) {
    List<Map<String, dynamic>> items = [];
    List<String> parts = productSold.split(', ');
    for (String part in parts) {
      RegExp re = RegExp(r'^(\d+)x\s+(.+)$');
      Match? match = re.firstMatch(part.trim());
      if (match != null) {
        items.add({'qty': int.parse(match.group(1)!), 'name': match.group(2)!});
      } else if (part.trim().isNotEmpty) {
        items.add({'qty': 1, 'name': part.trim()});
      }
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _orders.isEmpty) {
      return Center(child: CircularProgressIndicator(color: _primaryColor));
    }

    if (_orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, color: Colors.grey.shade300, size: 80),
            const SizedBox(height: 16),
            const Text(
              'No Active Orders',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              'Go to the Menu to order your favorites!',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: _orders.length,
      itemBuilder: (context, index) {
        return _buildOrderCard(_orders[index]);
      },
    );
  }

  Widget _buildOrderCard(dynamic order) {
    String dbStatus = order['status'];
    double totalAmount = double.parse(order['total_amount'].toString());
    String productSold = order['product_sold'] ?? '';
    List<Map<String, dynamic>> items = _parseProducts(productSold);

    String statusText = "Pending...";
    Color statusColor = Colors.grey.shade700;
    IconData statusIcon = Icons.hourglass_empty;
    Color statusBgColor = Colors.grey.shade100;

    if (dbStatus == 'Pending') {
      statusText = "Waiting for staff to accept...";
      statusColor = Colors.grey.shade700;
      statusIcon = Icons.hourglass_empty;
      statusBgColor = Colors.grey.shade100;
    } else if (dbStatus == 'Cooking') {
      statusText = "Cooking the food...";
      statusColor = const Color(0xFFE65100);
      statusIcon = Icons.local_fire_department;
      statusBgColor = const Color(0xFFFFF8E1);
    } else if (dbStatus == 'Preparing') {
      statusText = "Preparing the food...";
      statusColor = const Color(0xFF1565C0);
      statusIcon = Icons.room_service;
      statusBgColor = const Color(0xFFE3F2FD);
    } else if (dbStatus == 'Ready') {
      statusText = "Ready to serve the food! You can go now.";
      statusColor = const Color(0xFF2E7D32);
      statusIcon = Icons.check_circle;
      statusBgColor = const Color(0xFFE8F5E9);
    }

    return _OrderCardWidget(
      order: order,
      items: items,
      totalAmount: totalAmount,
      dbStatus: dbStatus,
      statusText: statusText,
      statusColor: statusColor,
      statusIcon: statusIcon,
      statusBgColor: statusBgColor,
      primaryColor: _primaryColor,
      productPrices: _productPrices,
      onComplete: () => _completeOrder(order['order_id'].toString()),
      onCancel: () => _cancelOrder(order['order_id'].toString()),
    );
  }
}

class _OrderCardWidget extends StatefulWidget {
  final dynamic order;
  final List<Map<String, dynamic>> items;
  final double totalAmount;
  final String dbStatus;
  final String statusText;
  final Color statusColor;
  final IconData statusIcon;
  final Color statusBgColor;
  final Color primaryColor;
  final Map<String, double> productPrices;
  final VoidCallback onComplete;
  final VoidCallback onCancel;

  const _OrderCardWidget({
    required this.order,
    required this.items,
    required this.totalAmount,
    required this.dbStatus,
    required this.statusText,
    required this.statusColor,
    required this.statusIcon,
    required this.statusBgColor,
    required this.primaryColor,
    required this.productPrices,
    required this.onComplete,
    required this.onCancel,
  });

  @override
  State<_OrderCardWidget> createState() => _OrderCardWidgetState();
}

class _OrderCardWidgetState extends State<_OrderCardWidget> {
  bool _showItems = false;
  String _filterMode = 'All';

  List<String> get _filterOptions => ['All', 'Product', 'Qty', 'Price'];

  Widget _buildFilterChip(String label) {
    bool isSelected = _filterMode == label;
    return GestureDetector(
      onTap: () => setState(() => _filterMode = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? widget.primaryColor : Colors.white,
          border: Border.all(
            color: isSelected ? widget.primaryColor : Colors.grey.shade400,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  double _getItemPrice(String name, int qty) {
    if (widget.productPrices.containsKey(name)) {
      return widget.productPrices[name]! * qty;
    }
    if (widget.items.length == 1) {
      return widget.totalAmount;
    }
    int totalQty = widget.items.fold(0, (sum, i) => sum + (i['qty'] as int));
    if (totalQty > 0) {
      return (widget.totalAmount / totalQty) * qty;
    }
    return 0.0;
  }

  Widget _buildItemsTable() {
    bool showProduct = _filterMode == 'All' || _filterMode == 'Product';
    bool showQty = _filterMode == 'All' || _filterMode == 'Qty';
    bool showPrice = _filterMode == 'All' || _filterMode == 'Price';

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                if (showProduct)
                  Expanded(
                    flex: 10,
                    child: Text(
                      'Product',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                if (showQty)
                  SizedBox(
                    width: 48,
                    child: Text(
                      'Qty',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                if (showPrice)
                  SizedBox(
                    width: 72,
                    child: Text(
                      'Price',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          ...widget.items.asMap().entries.map((entry) {
            bool isLast = entry.key == widget.items.length - 1;
            Map<String, dynamic> item = entry.value;
            final int qty = item['qty'] as int;
            final String name = item['name'] as String;
            final double lineTotal = _getItemPrice(name, qty);
            return Container(
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  if (showProduct)
                    Expanded(
                      flex: 10,
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  if (showQty)
                    SizedBox(
                      width: 48,
                      child: Text(
                        '${qty}x',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  if (showPrice)
                    SizedBox(
                      width: 72,
                      child: Text(
                        '₱${lineTotal.toStringAsFixed(2)}',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
          GestureDetector(
            onTap: () => setState(() => _showItems = !_showItems),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: _showItems ? widget.primaryColor.withOpacity(0.04) : Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _showItems ? Icons.visibility_off : Icons.visibility,
                    size: 15,
                    color: widget.primaryColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _showItems ? 'Hide' : 'View',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: widget.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsedContainer() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: GestureDetector(
        onTap: () => setState(() => _showItems = true),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.visibility, size: 15, color: widget.primaryColor),
              const SizedBox(width: 6),
              Text(
                'View',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: widget.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: widget.statusBgColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Icon(widget.statusIcon, color: widget.statusColor, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.statusText,
                    style: TextStyle(
                      color: widget.statusColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Order Confirmation',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: widget.primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Order #${widget.order['order_id']}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: widget.primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'Filter:  ',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.black54,
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _filterOptions
                              .map((opt) => Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: _buildFilterChip(opt),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _showItems ? _buildItemsTable() : _buildCollapsedContainer(),
                const SizedBox(height: 14),
                const Divider(thickness: 1, height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '₱${widget.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: widget.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Divider(color: Colors.grey.shade200, thickness: 1),
                const SizedBox(height: 10),
                _buildInfoRow('Ordered By', widget.order['customer_name'] ?? globals.loggedInUserName ?? 'N/A'),
                const SizedBox(height: 6),
                _buildInfoRow('Pickup Location', globals.selectedBranchName ?? 'Toyland Bistro'),
                const SizedBox(height: 6),
                _buildInfoRow('Payment Method', widget.order['payment_method'] ?? 'N/A'),
                if (widget.dbStatus == 'Ready') ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: widget.onComplete,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Complete",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
                if (widget.dbStatus == 'Pending') ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: widget.onCancel,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF800000), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        "Cancel Order",
                        style: TextStyle(color: Color(0xFF800000), fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}