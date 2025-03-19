import 'package:flutter/material.dart';
import '../../data/models/home_action.dart';

class HomeProvider with ChangeNotifier {
  List<HomeActionModel> _actions = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  List<HomeActionModel> get actions => _actions;

  String getWelcomeMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  Future<void> loadHomeActions() async {
    _isLoading = true;
    notifyListeners();

    try {
      _actions = [
        HomeActionModel(
          id: 'profile',
          title: 'Profile',
          icon: Icons.person,
          color: Colors.purple,
        ),
        HomeActionModel(
          id: 'settings',
          title: 'Settings',
          icon: Icons.settings,
          color: Colors.orange,
        ),
      ];
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<HomeActionModel> getHomeActions() => _actions;
}