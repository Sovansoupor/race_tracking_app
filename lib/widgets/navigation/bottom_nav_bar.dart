import 'package:flutter/material.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/result/race_list_screen.dart';
import 'package:race_tracking_app/theme/theme.dart';

class BottomNavBar extends StatefulWidget {
  final int initialIndex;

  const BottomNavBar({super.key, this.initialIndex = 0});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final widgetOptions = [
      HomeScreen(username: '', competitions: []), // Home Screen
      const RaceListScreen(), // Result Screen
    ];

    return Scaffold(
      body: Container(
        color: RaceColors.backgroundAccent,
        child: IndexedStack(index: _selectedIndex, children: widgetOptions),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: RaceColors.backgroundAccent,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: [
            _buildNavItem('assets/icon/home_icon.png', 'Home', 0),
            _buildNavItem('assets/icon/result_icon.png', 'Result', 1),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: RaceColors.backgroundAccent,
          selectedItemColor: RaceColors.primary,
          unselectedItemColor: RaceColors.white,
          showUnselectedLabels: true,
          elevation: 0,
          selectedLabelStyle: RaceTextStyles.label.copyWith(
            color: RaceColors.primary,
          ),
          unselectedLabelStyle: RaceTextStyles.label.copyWith(
            color: RaceColors.white,
          ),
          enableFeedback: false,
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
    String assetPath,
    String label,
    int index,
  ) {
    final isSelected = _selectedIndex == index;

    return BottomNavigationBarItem(
      icon: Image.asset(
        assetPath,
        width: 28,
        height: 28,
        color: RaceColors.primary,
      ),
      label: isSelected ? label : '',
    );
  }
}
