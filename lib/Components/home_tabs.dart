import 'package:flutter/material.dart';

class HomeTabs extends StatefulWidget {
  const HomeTabs({super.key});

  @override
  State<HomeTabs> createState() => _HomeTabsState();
}

class _HomeTabsState extends State<HomeTabs> {
  int _selectedIndex = 0;

  final List<String> _tabs = [
    'Upcoming trips',
    'Saved trips',
    'Past trips'
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Custom Tab Bar
        Container(
          height: 50,
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

        // Content area
        Container(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              _tabs[_selectedIndex],
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }
}