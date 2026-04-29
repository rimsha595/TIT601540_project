import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/app_drawer.dart';
import 'home_screen.dart';
import 'friends_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ✅ AppBar title state
  String _title = "Home";

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 4, vsync: this);

    // 🔥 Listen tab changes
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      _updateTitle(_tabController.index);
    });
  }

  void _updateTitle(int index) {
    setState(() {
      switch (index) {
        case 0:
          _title = "Home";
          break;
        case 1:
          _title = "Friends";
          break;
        case 2:
          _title = "Profile";
          break;
        case 3:
          _title = "Settings";
          break;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A14),

      // 🔥 APP BAR (FIXED)
      appBar: CustomAppBar(
        title: _title, // ✅ NOW DYNAMIC
        showNotification: true,
        onNotificationTap: () {},
      ),

      // 🔥 DRAWER
      drawer: AppDrawer(tabController: _tabController),

      // 🔥 BODY
      body: TabBarView(
        controller: _tabController,
        children: const [
          HomeScreen(),
          FriendsScreen(),
          ProfileScreen(),
          SettingsScreen(),
        ],
      ),

      // 🔥 BOTTOM TAB BAR
      bottomNavigationBar: Container(
        color: const Color(0xFF121222),
        child: TabBar(
          controller: _tabController,
          labelColor: Colors.blueAccent,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blueAccent,
          onTap: (index) {
            _updateTitle(index); // ✅ important fix
          },
          tabs: const [
            Tab(icon: Icon(Icons.home), text: "Home"),
            Tab(icon: Icon(Icons.people), text: "Friends"),
            Tab(icon: Icon(Icons.person), text: "Profile"),
            Tab(icon: Icon(Icons.settings), text: "Settings"),
          ],
        ),
      ),
    );
  }
}
