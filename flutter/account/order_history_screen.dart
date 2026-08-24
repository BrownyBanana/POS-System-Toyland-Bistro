import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../main/global.dart' as globals;

class OrderHistoryScreen extends StatefulWidget {
  final bool isDarkMode;

  const OrderHistoryScreen({super.key, required this.isDarkMode});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<dynamic> _orders = [];
  bool _isLoading = true;
  final Color _primaryColor = const Color(0xFF800000);
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _fetchOrderHistory();
  }

  Future<void> _fetchOrderHistory() async {
    if (globals.loggedInUserName == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      var url = Uri.parse(
        "http://10.118.5.117/bistro/flutter/order_history_api.php?customer_name=${Uri.encodeComponent(globals.loggedInUserName!)}",
      );
      var response = await http.get(url);

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _orders = json.decode(response.body);
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<dynamic> get _filteredOrders {
    if (_selectedFilter == 'All') return _orders;
    if (_selectedFilter == 'Completed') {
      return _orders.where((o) => !_isCancelled(o)).toList();
    }
    return _orders.where((o) => _isCancelled(o)).toList();
  }

  String _formatDate(String rawDate) {
    try {
      final dt = DateTime.parse(rawDate);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      final minute = dt.minute.toString().padLeft(2, '0');
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}  $hour:$minute $period';
    } catch (_) {
      return rawDate;
    }
  }

  bool _isCancelled(dynamic order) {
    final status = order['status']?.toString().toLowerCase() ?? '';
    return status == 'cancelled' || status == 'canceled';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDarkMode ? const Color(0xFF121212) : Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Order History',
          style: TextStyle(
            color: widget.isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: widget.isDarkMode ? Colors.white : Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _primaryColor))
          : Column(
              children: [
                _buildFilterRow(),
                Expanded(
                  child: _filteredOrders.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          color: _primaryColor,
                          onRefresh: _fetchOrderHistory,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: _filteredOrders.length,
                            itemBuilder: (context, index) {
                              return _buildOrderCard(_filteredOrders[index]);
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterRow() {
    final filters = ['All', 'Completed', 'Cancelled'];
    return Container(
      color: widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          Color chipColor;
          if (!isSelected) {
            chipColor = Colors.transparent;
          } else if (filter == 'Cancelled') {
            chipColor = _primaryColor;
          } else if (filter == 'Completed') {
            chipColor = Colors.green;
          } else {
            chipColor = _primaryColor;
          }

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = filter),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? chipColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? chipColor
                        : (widget.isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    filter,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? Colors.white
                          : (widget.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
            child: Icon(Icons.receipt_long_outlined, size: 72, color: Colors.grey.shade300),
          ),
          const SizedBox(height: 24),
          Text(
            _selectedFilter == 'All' ? 'No Order History Yet' : 'No $_selectedFilter Orders',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: widget.isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFilter == 'All'
                ? 'Your completed orders will appear here.'
                : 'No ${_selectedFilter.toLowerCase()} orders found.',
            style: TextStyle(
              fontSize: 14,
              color: widget.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(dynamic order) {
    final cancelled = _isCancelled(order);
    final statusColor = cancelled ? _primaryColor : Colors.green;
    final statusLabel = cancelled ? 'Cancelled' : 'Completed';
    final statusIcon = cancelled ? Icons.cancel_outlined : Icons.check_circle;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(statusLabel, style: TextStyle(color: statusColor, fontWeight: FontWeight.w900, fontSize: 15)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '#${order['order_id']}',
                    style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
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
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(order['order_date'].toString()),
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Text(
                  order['product_sold'] ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: widget.isDarkMode ? Colors.white : Colors.black87,
                    height: 1.4,
                  ),
                ),

                const Divider(height: 28),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Payment', style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              order['payment_method']?.toString().toLowerCase() == 'gcash'
                                  ? Icons.phone_android
                                  : order['payment_method']?.toString().toLowerCase() == 'card'
                                      ? Icons.credit_card
                                      : Icons.money,
                              size: 14,
                              color: Colors.black54,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              order['payment_method'] ?? 'Cash',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Total', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                        const SizedBox(height: 2),
                        Text(
                          '₱${double.parse(order['total_amount'].toString()).toStringAsFixed(2)}',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: _primaryColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}