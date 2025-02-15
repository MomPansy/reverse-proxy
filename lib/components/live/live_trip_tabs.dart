import 'package:flutter/material.dart';

import 'map_tab.dart';

class LiveTripTabs extends StatefulWidget {
  const LiveTripTabs({super.key});

  @override
  State<LiveTripTabs> createState() => _LiveTripTabsState();
}

class _LiveTripTabsState extends State<LiveTripTabs> {
  int _selectedIndex = 0;

  final List<String> _tabs = [
    'Map',
    'Travel Plan',
    'Alerts'
  ];

  Widget _getContent(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return MapTab();
      case 1:
        return Container();
      case 2:
        return Container();
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height:64,
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                _tabs.length,
                    (index) => GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          _tabs[index],
                          style: TextStyle(
                            color: _selectedIndex == index ? Colors.blue : Colors.grey,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 3,
                        width: 100,
                        color: _selectedIndex == index ? Colors.blue : Colors.transparent,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          _getContent(_selectedIndex),
        ],
      ),
    );
  }
}