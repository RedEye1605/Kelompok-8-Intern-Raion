import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';
import '../widgets/welcome_section.dart';
import '../widgets/recent_activities.dart';
import '../widgets/quick_actions.dart';
import '../../../core/utils/string_extensions.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'Settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    final provider = Provider.of<HomeProvider>(context, listen: false);
    await provider.loadHomeActions();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final homeProvider = Provider.of<HomeProvider>(context);
    final email = firebase_auth.FirebaseAuth.instance.currentUser?.email ?? '';
    final username = email.split('@')[0].capitalize();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Welcome, $username',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black87),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.black87),
            onPressed: () async {
              await firebase_auth.FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/');
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.05,
                vertical: size.height * 0.02,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WelcomeSectionWidget(
                    greeting: homeProvider.getWelcomeMessage(),
                    size: size,
                  ),
                  SizedBox(height: size.height * 0.03),
                  QuickActionsWidget(actions: homeProvider.actions, size: size),
                  SizedBox(height: size.height * 0.03),
                  const RecentActivitiesWidget(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
