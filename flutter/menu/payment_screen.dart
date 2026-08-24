import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../main/global.dart' as globals;
import '../home/home_screen.dart';

class PaymentScreen extends StatefulWidget {
  final double totalPrice;
  final List<Map<String, dynamic>> items;

  const PaymentScreen({
    super.key,
    required this.totalPrice,
    required this.items,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final Color _primaryColor = const Color(0xFF800000);
  bool _isLoading = false;
  String _paymentMethod = 'Cash';

  final TextEditingController _cashAmountController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardExpiryController = TextEditingController();
  final TextEditingController _cardCvvController = TextEditingController();
  final TextEditingController _cardHolderController = TextEditingController();

  @override
  void dispose() {
    _cashAmountController.dispose();
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    _cardHolderController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    double cashAmount = double.tryParse(_cashAmountController.text) ?? 0.0;

    if (_paymentMethod == 'Cash' && cashAmount < widget.totalPrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cash Amount must be greater than or equal to the total!")),
      );
      return;
    }

    if (_paymentMethod == 'Card') {
      if (_cardNumberController.text.replaceAll(' ', '').length < 16) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter a valid 16-digit card number.")),
        );
        return;
      }
      if (_cardExpiryController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter card expiry date.")),
        );
        return;
      }
      if (_cardCvvController.text.length < 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter a valid CVV.")),
        );
        return;
      }
      if (_cardHolderController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter the cardholder name.")),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('http://10.118.5.117/bistro/flutter/place_order_api.php');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'customer_name': globals.loggedInUserName,
          'total_amount': widget.totalPrice,
          'payment_method': _paymentMethod,
          'cash_amount': _paymentMethod == 'Cash' ? cashAmount : widget.totalPrice,
          'items': widget.items,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          globals.cartItems.clear();
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Order placed successfully!"),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen(isLoggedIn: true)),
            (route) => false,
          );
        } else {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${data['message']}")),
          );
        }
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Server error. Status: ${response.statusCode}")),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Payment',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w900, fontSize: 20),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Order Total',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black54),
                  ),
                  Text(
                    '₱${widget.totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: _primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.payment_outlined, color: _primaryColor, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Payment Method',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.black87),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ...[
                    {'label': 'Cash', 'icon': Icons.money},
                    {'label': 'GCash', 'icon': Icons.phone_android},
                    {'label': 'Card', 'icon': Icons.credit_card},
                  ].map((method) {
                    bool selected = _paymentMethod == method['label'];
                    return GestureDetector(
                      onTap: () => setState(() => _paymentMethod = method['label'] as String),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: selected ? _primaryColor.withOpacity(0.07) : Colors.grey.shade50,
                          border: Border.all(
                            color: selected ? _primaryColor : Colors.grey.shade200,
                            width: selected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(method['icon'] as IconData,
                                color: selected ? _primaryColor : Colors.black54, size: 22),
                            const SizedBox(width: 12),
                            Text(
                              method['label'] as String,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: selected ? _primaryColor : Colors.black87,
                              ),
                            ),
                            const Spacer(),
                            if (selected)
                              Icon(Icons.check_circle, color: _primaryColor, size: 20),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  if (_paymentMethod == 'Cash') ...[
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _cashAmountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Cash Amount',
                        labelStyle: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                        prefixText: '₱ ',
                        prefixStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade200)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade200)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: _primaryColor, width: 2)),
                      ),
                    ),
                  ],
                  if (_paymentMethod == 'GCash') ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Please prepare your GCash for payment at the counter.',
                              style: TextStyle(fontSize: 13, color: Colors.blue.shade700, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (_paymentMethod == 'Card') ...[
                    const SizedBox(height: 16),
                    _buildCardPaymentSection(),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 20, offset: const Offset(0, -5)),
          ],
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
                      Text("Total", style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
                      Text("₱${widget.totalPrice.toStringAsFixed(2)}",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _primaryColor)),
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
                      onPressed: _isLoading ? null : _placeOrder,
                      child: _isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                            )
                          : const Text(
                              "Confirm Order",
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
      ),
    );
  }

  Widget _buildCardPaymentSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_primaryColor, _primaryColor.withOpacity(0.75)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: _primaryColor.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Card Details',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
              Icon(Icons.credit_card, color: Colors.white.withOpacity(0.85), size: 28),
            ],
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _cardNumberController,
            keyboardType: TextInputType.number,
            maxLength: 19,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, letterSpacing: 2),
            onChanged: (value) {
              String raw = value.replaceAll(' ', '');
              if (raw.length > 16) raw = raw.substring(0, 16);
              String formatted = '';
              for (int i = 0; i < raw.length; i++) {
                if (i != 0 && i % 4 == 0) formatted += ' ';
                formatted += raw[i];
              }
              if (formatted != value) {
                _cardNumberController.value = TextEditingValue(
                  text: formatted,
                  selection: TextSelection.collapsed(offset: formatted.length),
                );
              }
            },
            decoration: InputDecoration(
              labelText: 'Card Number',
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
              hintText: '0000 0000 0000 0000',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.35), letterSpacing: 2),
              counterText: '',
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.4))),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _cardHolderController,
            textCapitalization: TextCapitalization.characters,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              labelText: 'Cardholder Name',
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
              hintText: 'FULL NAME',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.35)),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.4))),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _cardExpiryController,
                  keyboardType: TextInputType.number,
                  maxLength: 5,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  onChanged: (value) {
                    String raw = value.replaceAll('/', '');
                    if (raw.length > 4) raw = raw.substring(0, 4);
                    String formatted =
                        raw.length >= 3 ? '${raw.substring(0, 2)}/${raw.substring(2)}' : raw;
                    if (formatted != value) {
                      _cardExpiryController.value = TextEditingValue(
                        text: formatted,
                        selection: TextSelection.collapsed(offset: formatted.length),
                      );
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Expiry Date',
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                    hintText: 'MM/YY',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.35)),
                    counterText: '',
                    enabledBorder:
                        UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.4))),
                    focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: TextFormField(
                  controller: _cardCvvController,
                  keyboardType: TextInputType.number,
                  maxLength: 3,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    labelText: 'CVV',
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                    hintText: '•••',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.35)),
                    counterText: '',
                    enabledBorder:
                        UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.4))),
                    focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}