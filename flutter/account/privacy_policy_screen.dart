import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  final bool isDarkMode;
  final Color primaryColor = const Color(0xFF800000);

  const PrivacyPolicyScreen({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Privacy Policy',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Toyland Bistro - Privacy Policy',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Last Updated: March 15, 2026',
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 32),
              
              _buildSection(
                'Introduction',
                'Toyland Bistro ("we," "our," or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application and services.',
              ),
              
              _buildSection(
                '1. Information We Collect',
                'We collect several types of information to provide and improve our services:\n\n• Personal Information: Name, email address, phone number, delivery address\n• Order Information: Food preferences, order history, payment details\n• Device Information: Device type, operating system, unique device identifiers\n• Location Data: GPS coordinates for delivery purposes (with your permission)\n• Usage Data: App interactions, pages visited, time spent on pages',
              ),
              
              _buildSection(
                '2. How We Use Your Information',
                'We use the collected information for various purposes:\n\n• Processing your orders\n• Communicating with you about your orders and our services\n• Improving our menu, services, and customer experience\n• Sending promotional offers and updates (with your consent)\n• Analyzing usage patterns to enhance our application\n• Preventing fraud and ensuring platform security\n• Complying with legal obligations',
              ),
              
              _buildSection(
                '3. Information Sharing',
                'We do not sell your personal information. We may share your information with:\n\n• Delivery Partners: To fulfill your orders\n• Payment Processors: To process transactions securely\n• Service Providers: Who assist in our operations (analytics, marketing)\n• Legal Authorities: When required by law or to protect our rights\n• Business Transfers: In case of merger, acquisition, or asset sale',
              ),
              
              _buildSection(
                '4. Data Security',
                'We implement appropriate technical and organizational measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. However, no method of transmission over the internet is 100% secure.',
              ),
              
              _buildSection(
                '5. Your Rights',
                'You have the right to:\n\n• Access your personal information\n• Correct inaccurate or incomplete data\n• Request deletion of your information\n• Opt-out of marketing communications\n• Withdraw consent for data processing\n• Request a copy of your data\n• Object to certain data processing activities',
              ),
              
              _buildSection(
                '6. Cookies and Tracking',
                'We use cookies and similar tracking technologies to improve your experience, analyze usage patterns, and personalize content. You can control cookies through your device settings, though this may affect functionality.',
              ),
              
              _buildSection(
                '7. Children\'s Privacy',
                'Our services are not intended for users under 18 years of age. We do not knowingly collect personal information from children. If we become aware of such collection, we will take steps to delete the information.',
              ),
              
              _buildSection(
                '8. Third-Party Links',
                'Our application may contain links to third-party websites or services. We are not responsible for the privacy practices of these external sites. We encourage you to review their privacy policies.',
              ),
              
              _buildSection(
                '9. Data Retention',
                'We retain your personal information for as long as necessary to provide our services and comply with legal obligations. Order history may be retained for up to 5 years for business and legal purposes.',
              ),
              
              _buildSection(
                '10. International Data Transfers',
                'Your information may be transferred to and maintained on servers located outside your country. By using our services, you consent to this transfer, where applicable data protection laws will apply.',
              ),
              
              _buildSection(
                '11. Changes to Privacy Policy',
                'We may update this Privacy Policy from time to time. Changes will be posted on this page with an updated "Last Updated" date. Continued use of our services constitutes acceptance of any modifications.',
              ),
              
              _buildSection(
                '12. Contact Us',
                'If you have questions or concerns about this Privacy Policy or our data practices, please contact us:\n\nToyland Bistro\nMax Suniel Street, Carmen, Cagayan de Oro\nEmail: toylandbistro@gmail.com\nPhone: +63 09358567902',
              ),
              
              const SizedBox(height: 40),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryColor.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.security, color: primaryColor, size: 32),
                    const SizedBox(height: 12),
                    Text(
                      'Your privacy and data security are our top priorities.',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}