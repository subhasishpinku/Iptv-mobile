import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iptvmobile/OtpScreen.dart/providers/auth_provider.dart';
import 'package:iptvmobile/routes/routes_names.dart';

class CustomDrawer extends ConsumerStatefulWidget {
  final String userName;
  final String userMobile;

  const CustomDrawer({
    super.key,
    required this.userName,
    required this.userMobile,
  });

  @override
  ConsumerState<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends ConsumerState<CustomDrawer> {
  bool _isLoggingOut = false;

  Future<void> _handleLogout() async {
    if (_isLoggingOut) return;
    
    setState(() {
      _isLoggingOut = true;
    });
    
    try {
      // Perform logout first
      await ref.read(authStateProvider.notifier).logout();
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Logged out successfully."),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      // Wait for snackbar to show
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Navigate to login screen - Use the root navigator
      if (mounted) {
        // Close drawer if open
        Navigator.pop(context);
        
        // Use WidgetsBinding to ensure navigation happens after current frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            // Clear all routes and go to login
            Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
              RouteNames.loginScreen,
              (route) => false,
            );
          }
        });
      }
    } catch (e) {
      print("Logout error in drawer: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Logout failed. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 100, 94, 93),
        title: const Text(
          "Logout",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "Are you sure you want to logout?",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // Close dialog
              _handleLogout();
            },
            child: const Text(
              "Logout",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, top: 10),
            child: UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.black),
              accountName: Padding(
                padding: const EdgeInsets.only(left: 10, top: 0),
                child: Text(
                  widget.userName,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              accountEmail: Padding(
                padding: const EdgeInsets.only(left: 10, top: 00),
                child: Text(
                  widget.userMobile,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 30, color: Colors.black),
              ),
            ),
          ),
          
          _drawerItem(context, Icons.person, "Account", () {
            Navigator.pop(context);
          }),
          
          _drawerItem(context, Icons.payment, "Payment", () {
            Navigator.pop(context);
          }),
          
          _drawerItem(context, Icons.devices, "Device Info", () {
            Navigator.pop(context);
          }),
          
          _drawerItem(context, Icons.info, "About", () {
            Navigator.pop(context);
          }),
          
          _drawerItem(context, Icons.language, "Language", () {
            Navigator.pop(context);
          }),
          
          _drawerItem(context, Icons.support_agent, "Help and Support", () {
            Navigator.pop(context);
          }),
          
          const Divider(color: Colors.grey),
          
          _drawerItem(
            context, 
            Icons.logout, 
            "Log Out", 
            _showLogoutDialog,
            isLogout: true,
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isLogout = false,
  }) {
    return ListTile(
      leading: Icon(
        icon, 
        color: isLogout ? Colors.red : Colors.white,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isLogout ? Colors.red : Colors.white,
        ),
      ),
      onTap: _isLoggingOut ? null : onTap,
    );
  }
}