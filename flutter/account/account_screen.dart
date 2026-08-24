import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../main/global.dart' as globals;
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';
import 'terms_conditions_screen.dart';
import 'privacy_policy_screen.dart';
import 'order_history_screen.dart';

class AccountScreen extends StatefulWidget {
  final VoidCallback onLogout;
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const AccountScreen({
    super.key, 
    required this.onLogout,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final Color primaryColor = const Color(0xFF800000);
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    
    if (photo != null) {
      setState(() {
        _profileImage = File(photo.path);
      });
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose Photo Source',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: widget.isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Icon(Icons.camera_alt, color: primaryColor),
              title: Text(
                'Take Photo',
                style: TextStyle(
                  color: widget.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: primaryColor),
              title: Text(
                'Choose from Gallery',
                style: TextStyle(
                  color: widget.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountMenuItem(IconData icon, String title, {required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: widget.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: widget.isDarkMode ? Colors.white : Colors.black87),
        ),
        title: Text(
          title, 
          style: TextStyle(
            fontWeight: FontWeight.w600, 
            fontSize: 16, 
            color: widget.isDarkMode ? Colors.white : Colors.black87
          )
        ),
        trailing: Icon(
          Icons.arrow_forward_ios, 
          size: 16, 
          color: widget.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade400
        ),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Profile', 
                    style: TextStyle(
                      fontSize: 20, 
                      fontWeight: FontWeight.bold, 
                      color: widget.isDarkMode ? Colors.white : Colors.black87
                    )
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Profile Picture with clickable edit button
              GestureDetector(
                onTap: _showImageSourceDialog,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: primaryColor.withOpacity(0.2), width: 3),
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: widget.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                        backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                        child: _profileImage == null
                          ? Icon(
                              Icons.person, 
                              size: 50, 
                              color: widget.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade400
                            )
                          : null,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: widget.isDarkMode ? Colors.grey.shade900 : Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.edit, size: 14, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Name & Email
              Text(
                globals.loggedInUserName ?? 'Guest User',
                style: TextStyle(
                  fontSize: 22, 
                  fontWeight: FontWeight.w900, 
                  color: widget.isDarkMode ? Colors.white : Colors.black87
                ),
              ),
              const SizedBox(height: 4),
              Text(
                globals.loggedInUserEmail ?? 'user@gmail.com',
                style: TextStyle(
                  fontSize: 14, 
                  color: widget.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600
                ),
              ),
              const SizedBox(height: 40),
              
              // Menu Items
              _buildAccountMenuItem(
                Icons.person_outline, 
                'Edit Profile', 
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfileScreen(isDarkMode: widget.isDarkMode),
                    ),
                  ).then((_) => setState(() {}));
                },
              ),
              _buildAccountMenuItem(
                Icons.lock_outline, 
                'Change Password', 
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChangePasswordScreen(isDarkMode: widget.isDarkMode),
                    ),
                  );
                },
              ),

              // ── NEW: Order History ──
              _buildAccountMenuItem(
                Icons.history,
                'Order History',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderHistoryScreen(isDarkMode: widget.isDarkMode),
                    ),
                  );
                },
              ),

              _buildAccountMenuItem(
                Icons.description_outlined, 
                'Terms & Conditions', 
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TermsConditionsScreen(isDarkMode: widget.isDarkMode),
                    ),
                  );
                },
              ),
              _buildAccountMenuItem(
                Icons.privacy_tip_outlined, 
                'Privacy Policy', 
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PrivacyPolicyScreen(isDarkMode: widget.isDarkMode),
                    ),
                  );
                },
              ),
              
              // Dark Mode Toggle
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: widget.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.dark_mode_outlined, 
                      color: widget.isDarkMode ? Colors.white : Colors.black87
                    ),
                  ),
                  title: Text(
                    'Dark Mode',
                    style: TextStyle(
                      fontWeight: FontWeight.w600, 
                      fontSize: 16, 
                      color: widget.isDarkMode ? Colors.white : Colors.black87
                    ),
                  ),
                  trailing: Switch(
                    value: widget.isDarkMode,
                    activeColor: primaryColor,
                    onChanged: (value) {
                      widget.onThemeChanged(value);
                    },
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Log Out Button
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.logout, color: Colors.red),
                ),
                title: const Text(
                  'Log Out', 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red)
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
                onTap: widget.onLogout, 
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}