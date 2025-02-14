import 'package:flutter/material.dart';
import '../Constants/constants.dart';

class BottomNavBar extends StatefulWidget{
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  void _switchTab(int newIndex) {
    setState(() {
      _selectedIndex = newIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Icon(
              Icons.house_rounded,
              size: _selectedIndex == 0
                  ? Values.BAR_ICON_LARGE
                  : Values.BAR_ICON_SMALL,
            ),
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Icon(
              Icons.airplanemode_active,
              size: _selectedIndex == 1
                  ? Values.BAR_ICON_LARGE
                  : Values.BAR_ICON_SMALL,
            ),
          ),
          label: 'New Trip',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Icon(
              Icons.map,
              size: _selectedIndex == 2
                  ? Values.BAR_ICON_LARGE
                  : Values.BAR_ICON_SMALL,
            ),
          ),
          label: 'Explore',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Icon(
              Icons.account_circle_outlined,
              size: _selectedIndex == 3
                  ? Values.BAR_ICON_LARGE
                  : Values.BAR_ICON_SMALL,
            ),
          ),
          label: 'Profile',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      onTap: (int index) => _switchTab(index),
    );
  }
}