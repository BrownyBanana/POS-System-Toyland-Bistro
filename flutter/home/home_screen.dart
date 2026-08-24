import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import '../main/global.dart' as globals;
import '../login/login_screen.dart';
import '../register/register_screen.dart';
import '../menu/menu_screen.dart';
import 'new_arrival_item.dart';
import 'user_orders_tab.dart';
import 'full_screen_image.dart';
import 'best_sellers_screen.dart';
import '../account/account_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool isLoggedIn;
  const HomeScreen({super.key, this.isLoggedIn = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late bool _isLoggedIn;
  bool _isDarkMode = false;

  final Color _primaryColor = const Color(0xFF800000);

  final ScrollController _newArrivalsScrollController = ScrollController();
  Timer? _newArrivalsTimer;
  bool _isAutoScrolling = true;

  final List<NewArrivalItem> _newArrivals = [
    NewArrivalItem(name: 'Seaweed Ramen', price: '₱ 115.00', imagePath: 'assets/images/seawed_ramen.jpg', tag: 'Chef\'s Choice'),
    NewArrivalItem(name: 'Pasta Meal', price: '₱ 105.00', imagePath: 'assets/images/pasta_meal.jpg', tag: 'Classic Italian'),
    NewArrivalItem(name: 'Chicken Fillet', price: '₱ 99.00', imagePath: 'assets/images/chicken_fillet.jpg', tag: 'Crispy & Juicy'),
  ];

  final List<NewArrivalItem> _bestSellers = [
    NewArrivalItem(name: 'Truffle Parmesan Fries', price: '₱ 190.00', imagePath: 'assets/images/tpff.jpg', tag: 'Best Seller'),
    NewArrivalItem(name: 'Beef Steak Rice Bowl', price: '₱ 129.00', imagePath: 'assets/images/bs.jpg', tag: 'Best Seller'),
    NewArrivalItem(name: 'Caramel Macchiato', price: '₱ 185.00', imagePath: 'assets/images/cmm.jpg', tag: 'Best Seller'),
    NewArrivalItem(name: 'I am Groot (MOCHA)', price: '₱ 205.00', imagePath: 'assets/images/ig.jpg', tag: 'Best Seller'),
  ];

  @override
  void initState() {
    super.initState();
    _isLoggedIn = widget.isLoggedIn;
    _startAutoScroll();
    if (!_isLoggedIn) _restoreSession();
  }

  Future<void> _restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool('remember_me') ?? false;
    if (!rememberMe) return;
    final userId = prefs.getString('user_id');
    final userName = prefs.getString('user_name');
    if (userId != null && userName != null) {
      globals.loggedInUserId = userId;
      globals.loggedInUserName = userName;
      globals.loggedInUserEmail = prefs.getString('user_email') ?? '';
      globals.loggedInUserPhone = prefs.getString('user_phone') ?? '';
      if (mounted) setState(() => _isLoggedIn = true);
    }
  }

  @override
  void dispose() {
    _newArrivalsTimer?.cancel();
    _newArrivalsScrollController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _newArrivalsTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_newArrivalsScrollController.hasClients && _isAutoScrolling) {
        double maxScroll = _newArrivalsScrollController.position.maxScrollExtent;
        double currentScroll = _newArrivalsScrollController.offset;
        double itemWidth = 280.0 + 16.0;

        if (currentScroll >= maxScroll - 10) {
          _newArrivalsScrollController.animateTo(0, duration: const Duration(seconds: 1), curve: Curves.easeInOut);
        } else {
          double nextScroll = currentScroll + itemWidth;
          if (nextScroll > maxScroll) nextScroll = maxScroll;
          _newArrivalsScrollController.animateTo(nextScroll, duration: const Duration(milliseconds: 800), curve: Curves.easeInOut);
        }
      }
    });
  }

  Future<void> _openMapRoute(String destination) async {
    final String encodedDest = Uri.encodeComponent(destination);
    final Uri googleMapsUrl = Uri.parse("https://maps.google.com/?q=$encodedDest");

    try {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open Maps. Please check your map application.')));
      }
    }
  }

  void _addToCart(String name, double price) {
    final existing = globals.cartItems.where((i) => i.name == name).toList();
    if (existing.isNotEmpty) {
      existing.first.quantity++;
    } else {
      globals.cartItems.add(globals.CartItem(name: name, price: price));
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$name added to cart!"),
        backgroundColor: _primaryColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  double _parsePrice(String priceStr) {
    final cleaned = priceStr.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  void _showLocationPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 5,
                width: 40,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
              ),
              const SizedBox(height: 16),
              const Text('Select Pick Up Branch', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.store, color: _primaryColor),
                title: const Text('Main Branch Carmen, CDO', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Max Suniel Street, near PHINMA-COC'),
                trailing: const Icon(Icons.directions, color: Colors.blue),
                onTap: () {
                  setState(() {
                    globals.selectedBranchName = 'Carmen, CDO';
                    globals.selectedBranchAddress = 'Max Suniel Street, near PHINMA-COC';
                    globals.estimatedTravelTime = 15;
                  });
                  Navigator.pop(context);
                  _openMapRoute('Max Suniel Street, Carmen, Cagayan de Oro');
                },
              ),
              const Divider(),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remember_me', false);
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_phone');

    globals.loggedInUserId = null;
    globals.loggedInUserName = null;
    globals.loggedInUserEmail = null;
    globals.loggedInUserPhone = null;
    globals.cartItems.clear();

    setState(() {
      _isLoggedIn = false;
      _selectedIndex = 0;
    });
  }

  void _showAuthBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 24),
                  Text('Register/Log in', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _isDarkMode ? Colors.white : Colors.black87)),
                  IconButton(
                    icon: Icon(Icons.close, color: _isDarkMode ? Colors.grey.shade400 : Colors.black54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Welcome to Bistro!\nLog in or register an account for the best ordering experience!',
                textAlign: TextAlign.center,
                style: TextStyle(color: _isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: _primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), elevation: 0),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                  },
                  child: const Text('Register', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: _isDarkMode ? Colors.white : Colors.black87, width: 1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                  },
                  child: Text('Log in', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _isDarkMode ? Colors.white : Colors.black87)),
                ),
              ),
              const SizedBox(height: 20),
              Text('or', style: TextStyle(color: _isDarkMode ? Colors.grey.shade400 : Colors.grey.shade500, fontSize: 14)),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: _isDarkMode ? Colors.white : Colors.black87, width: 1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Browsing as guest...')));
                  },
                  child: Text('Continue as guest', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _isDarkMode ? Colors.white : Colors.black87)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLockedScreen(String tabName) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, spreadRadius: 2)]),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Image.asset(
                'assets/images/logo.png',
                height: 120,
                width: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 120,
                  width: 120,
                  color: _isDarkMode ? Colors.grey.shade800 : Colors.white,
                  child: Icon(Icons.restaurant, color: _primaryColor, size: 60),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Craving Something Good?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _isDarkMode ? Colors.white : Colors.black87)),
          const SizedBox(height: 8),
          Text('Sign in to view your $tabName.', style: TextStyle(color: _isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 16)),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            ),
            onPressed: () => _showAuthBottomSheet(context),
            child: const Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildBlankScreen(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, spreadRadius: 2)]),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Image.asset(
                'assets/images/logo.png',
                height: 120,
                width: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 120,
                  width: 120,
                  color: _isDarkMode ? Colors.grey.shade800 : Colors.white,
                  child: Icon(Icons.restaurant, color: _primaryColor, size: 60),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _isDarkMode ? Colors.white : Colors.black87)),
          const SizedBox(height: 8),
          Text('Coming soon!', style: TextStyle(color: _isDarkMode ? Colors.grey.shade400 : Colors.grey.shade500, fontSize: 16)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _selectedIndex == 0 ? _primaryColor : (_isDarkMode ? const Color(0xFF121212) : Colors.white),
      body: SafeArea(bottom: false, child: _buildBody()),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: _primaryColor,
        unselectedItemColor: _isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        backgroundColor: _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 20,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'Menu'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return const MenuScreen();
      case 2:
        return _isLoggedIn ? const UserOrdersTab() : _buildLockedScreen('Orders');
      case 3:
        return _isLoggedIn
            ? AccountScreen(
                onLogout: _logout,
                isDarkMode: _isDarkMode,
                onThemeChanged: (value) {
                  setState(() {
                    _isDarkMode = value;
                  });
                },
              )
            : _buildLockedScreen('Account');
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildHomeTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Location', style: TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500, letterSpacing: 0.3)),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => _showLocationPicker(context),
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              globals.selectedBranchName ?? 'Select Branch',
                              style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w900),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              _isLoggedIn
                  ? Container(
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                      child: IconButton(
                        icon: const Icon(Icons.account_circle, color: Colors.white, size: 28),
                        onPressed: () {
                          setState(() { _selectedIndex = 3; });
                        },
                      ),
                    )
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: _primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                      onPressed: () => _showAuthBottomSheet(context),
                      child: const Text('Sign In', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                    ),
            ],
          ),
        ),

        Expanded(
          child: ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            child: Container(
              color: Colors.white,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Hello!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.black87, letterSpacing: -0.5)),
                        if (_isLoggedIn)
                          Text(
                            _isLoggedIn && globals.loggedInUserName != null ? globals.loggedInUserName! : '',
                            style: TextStyle(color: _primaryColor, fontWeight: FontWeight.w900, fontSize: 15),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text('What would you like to eat today?', style: TextStyle(fontSize: 14, color: Colors.grey.shade600, letterSpacing: -0.2)),
                  ),

                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: _primaryColor, borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Order Now &\nGet 20% Off!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, height: 1.2)),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: _primaryColor,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    elevation: 0,
                                  ),
                                  onPressed: () {
                                    setState(() { _selectedIndex = 1; });
                                  },
                                  child: const Text('Order Now', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, spreadRadius: 1)]),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Image.asset(
                                'assets/images/logo.png',
                                height: 70,
                                width: 70,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(height: 70, width: 70, color: Colors.white, child: Icon(Icons.restaurant, color: _primaryColor, size: 30)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text('New Arrivals', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black87, letterSpacing: -0.5)),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    height: 230,
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification is ScrollStartNotification) {
                          _isAutoScrolling = false;
                        } else if (notification is ScrollEndNotification) {
                          Future.delayed(const Duration(seconds: 5), () {
                            if (mounted) setState(() { _isAutoScrolling = true; });
                          });
                        }
                        return false;
                      },
                      child: ListView.builder(
                        controller: _newArrivalsScrollController,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _newArrivals.length,
                        itemBuilder: (context, index) {
                          final item = _newArrivals[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => FullScreenImage(imagePath: item.imagePath)));
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 16),
                              width: 280,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Stack(
                                  children: [
                                    Image.asset(
                                      item.imagePath,
                                      width: 280,
                                      height: 230,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: 280,
                                          height: 230,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [_primaryColor.withOpacity(0.7), _primaryColor.withOpacity(0.9)],
                                            ),
                                            borderRadius: BorderRadius.circular(24),
                                          ),
                                          child: Center(child: Icon(Icons.restaurant, color: Colors.white.withOpacity(0.5), size: 50)),
                                        );
                                      },
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 12,
                                      left: 12,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(color: _primaryColor, borderRadius: BorderRadius.circular(12)),
                                        child: const Text('NEW', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 16,
                                      left: 16,
                                      right: 16,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(item.tag, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w500)),
                                          const SizedBox(height: 2),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(item.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                              Text(item.price, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text('Exclusive Deals', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black87, letterSpacing: -0.5)),
                  ),
                  const SizedBox(height: 16),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              _addToCart('Rice Bowl Meals With Free Drink', 450.00);
                            },
                            child: _buildDealCard('Rice Bowl Meals With Free Drink', '₱ 450.00', 'assets/images/rice.jpg'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              _addToCart('Combo Meals', 250.00);
                            },
                            child: _buildDealCard("Combo Meals", '₱ 250.00', 'assets/images/combo.jpg'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Best Sellers', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black87, letterSpacing: -0.5)),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => BestSellersScreen(bestSellers: _bestSellers)));
                          },
                          child: Text('See all', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _primaryColor)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: _bestSellers.length,
                      itemBuilder: (context, index) {
                        final item = _bestSellers[index];
                        return GestureDetector(
                          onTap: () {
                            _addToCart(item.name, _parsePrice(item.price));
                          },
                          child: Container(
                            width: 140,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 140,
                                  width: 140,
                                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.asset(
                                      item.imagePath,
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, e, s) => Icon(Icons.restaurant, color: Colors.grey.shade300, size: 32),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.black87)),
                                const SizedBox(height: 4),
                                Text(item.price, style: TextStyle(color: _primaryColor, fontWeight: FontWeight.w900, fontSize: 13)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDealCard(String title, String price, String imagePath) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 120,
                width: double.infinity,
                decoration: const BoxDecoration(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.asset(imagePath, fit: BoxFit.cover, errorBuilder: (c, e, s) => Icon(Icons.fastfood, color: Colors.grey.shade300, size: 40)),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.shade700,
                    borderRadius: const BorderRadius.only(topRight: Radius.circular(20), bottomLeft: Radius.circular(16)),
                  ),
                  child: const Text('20% OFF', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.5)),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, height: 1.2)),
                const SizedBox(height: 8),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  children: [
                    Text(
                      '₱ ${(double.parse(price.replaceAll(RegExp(r'[^0-9.]'), '')) * 1.25).toStringAsFixed(2)}',
                      style: TextStyle(color: Colors.grey.shade500, decoration: TextDecoration.lineThrough, fontSize: 11),
                    ),
                    Text(price, style: TextStyle(color: _primaryColor, fontWeight: FontWeight.w900, fontSize: 14)),
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