import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  final bool isDarkMode;
  
  const TermsConditionsScreen({super.key, this.isDarkMode = false});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF800000);
    
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Terms & Conditions',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87, 
            fontWeight: FontWeight.bold
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Toyland Bistro Terms & Conditions',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: ${DateTime.now().year}',
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),

            _buildSection(
              title: '1. Service Overview',
              content: 'Toyland Bistro provides food ordering services through our mobile application and walk-in services at our physical location.',
              isDarkMode: isDarkMode,
            ),

            _buildSection(
              title: '2. Order Fulfillment',
              content: 'PICKUP ONLY: All online orders placed through our mobile application are for PICKUP ONLY. We do not offer delivery services for online orders.\n\nWalk-in customers at our physical location can dine in or request face-to-face pickup service.',
              isDarkMode: isDarkMode,
              highlight: true,
            ),

            _buildSection(
              title: '3. Payment Terms',
              content: 'Payment must be made upon pickup of your order. We accept cash and major credit/debit cards.\n\nOnline orders are reserved for 15 minutes from the scheduled pickup time. Unclaimed orders may be cancelled without refund.',
              isDarkMode: isDarkMode,
            ),

            _buildSection(
              title: '4. Order Cancellation',
              content: 'Orders can be cancelled up to 1 hour before the scheduled pickup time through the app. Orders cancelled within 10 minutes of pickup time or unclaimed orders are non-refundable.',
              isDarkMode: isDarkMode,
            ),

            _buildSection(
              title: '5. Food Safety & Quality',
              content: 'We maintain the highest standards of food safety and quality. All meals are prepared fresh upon order. Please inspect your order upon pickup and report any issues immediately.',
              isDarkMode: isDarkMode,
            ),

            _buildSection(
              title: '6. User Account',
              content: 'You are responsible for maintaining the confidentiality of your account credentials. Any activity under your account is your responsibility.',
              isDarkMode: isDarkMode,
            ),

            _buildSection(
              title: '7. Pricing',
              content: 'All prices are in Philippine Peso (₱) and are subject to change without notice. Promotional prices and discounts are available for a limited time only.',
              isDarkMode: isDarkMode,
            ),

            _buildSection(
              title: '8. Allergies & Dietary Restrictions',
              content: 'Please inform our staff of any allergies or dietary restrictions when placing your order. While we take precautions, we cannot guarantee that our products are allergen-free.',
              isDarkMode: isDarkMode,
            ),

            _buildSection(
              title: '9. Intellectual Property',
              content: 'All content, trademarks, and materials on our app and premises are the property of Toyland Bistro and are protected by intellectual property laws.',
              isDarkMode: isDarkMode,
            ),

            _buildSection(
              title: '10. Contact Information',
              content: 'For questions or concerns regarding these terms, please contact us at our Carmen, CDO branch or through the app.',
              isDarkMode: isDarkMode,
            ),

            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: primaryColor, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'By using our service, you agree to these terms and conditions.',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    required bool isDarkMode,
    bool highlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: highlight ? const EdgeInsets.all(12) : EdgeInsets.zero,
            decoration: highlight
                ? BoxDecoration(
                    color: const Color(0xFF800000).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF800000).withOpacity(0.3),
                      width: 1,
                    ),
                  )
                : null,
            child: Text(
              content,
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
                fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}