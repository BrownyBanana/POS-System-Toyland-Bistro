import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../main/global.dart' as globals;

class EditProfileScreen extends StatefulWidget {
  final bool isDarkMode;

  const EditProfileScreen({super.key, required this.isDarkMode});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final Color primaryColor = const Color(0xFF800000);
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: globals.loggedInUserName ?? '');
    _emailController = TextEditingController(text: globals.loggedInUserEmail ?? '');
    _phoneController = TextEditingController(text: globals.loggedInUserPhone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (!_isEditing) return;
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _takePhoto() async {
    if (!_isEditing) return;
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (photo != null) {
      setState(() {
        _selectedImage = File(photo.path);
      });
    }
  }

  void _showImageSourceDialog() {
    if (!_isEditing) return;
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
                style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black87),
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
                style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black87),
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

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _nameController.text = globals.loggedInUserName ?? '';
      _emailController.text = globals.loggedInUserEmail ?? '';
      _phoneController.text = globals.loggedInUserPhone ?? '';
      _selectedImage = null;
    });
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      globals.loggedInUserName = _nameController.text;
      globals.loggedInUserEmail = _emailController.text;
      globals.loggedInUserPhone = _phoneController.text;

      setState(() {
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated successfully!'),
          backgroundColor: primaryColor,
        ),
      );
    }
  }

  InputDecoration _fieldDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: widget.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
      ),
      prefixIcon: Icon(icon, color: _isEditing ? primaryColor : Colors.grey.shade400),
      filled: true,
      fillColor: _isEditing
          ? (widget.isDarkMode ? Colors.grey.shade800.withOpacity(0.3) : Colors.grey.shade100)
          : (widget.isDarkMode ? Colors.grey.shade900.withOpacity(0.3) : Colors.grey.shade50),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: _isEditing ? Colors.grey.shade300 : Colors.transparent,
          width: 1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDarkMode ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        backgroundColor: widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: widget.isDarkMode ? Colors.white : Colors.black87,
          ),
          onPressed: () {
            if (_isEditing) {
              _cancelEdit();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: widget.isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          if (!_isEditing)
            TextButton.icon(
              onPressed: () => setState(() => _isEditing = true),
              icon: Icon(Icons.edit_outlined, color: primaryColor, size: 18),
              label: Text(
                'Edit',
                style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: _cancelEdit,
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
                const SizedBox(width: 4),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _isEditing ? _showImageSourceDialog : null,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _isEditing ? primaryColor.withOpacity(0.5) : primaryColor.withOpacity(0.15),
                            width: 3,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: widget.isDarkMode
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                          backgroundImage: _selectedImage != null
                              ? FileImage(_selectedImage!)
                              : null,
                          child: _selectedImage == null
                              ? Icon(
                                  Icons.person,
                                  size: 60,
                                  color: widget.isDarkMode
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade400,
                                )
                              : null,
                        ),
                      ),
                      if (_isEditing)
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: widget.isDarkMode
                                  ? const Color(0xFF121212)
                                  : Colors.white,
                              width: 3,
                            ),
                          ),
                          child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: widget.isDarkMode
                                  ? const Color(0xFF121212)
                                  : Colors.white,
                              width: 2,
                            ),
                          ),
                          child: Icon(Icons.lock_outline, size: 14, color: Colors.grey.shade600),
                        ),
                    ],
                  ),
                ),
                if (!_isEditing) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Tap Edit to update your profile',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                  ),
                ],
                const SizedBox(height: 32),
                TextFormField(
                  controller: _nameController,
                  readOnly: !_isEditing,
                  style: TextStyle(
                    color: widget.isDarkMode ? Colors.white : Colors.black87,
                  ),
                  decoration: _fieldDecoration('Full Name', Icons.person_outline),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  readOnly: !_isEditing,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(
                    color: widget.isDarkMode ? Colors.white : Colors.black87,
                  ),
                  decoration: _fieldDecoration('Email Address', Icons.email_outlined),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _phoneController,
                  readOnly: !_isEditing,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(
                    color: widget.isDarkMode ? Colors.white : Colors.black87,
                  ),
                  decoration: _fieldDecoration('Phone Number', Icons.phone_outlined),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                if (_isEditing)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _saveProfile,
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}