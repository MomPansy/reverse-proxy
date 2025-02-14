import 'package:askngo/Components/home_tabs.dart';
import 'package:askngo/Components/top_bar.dart';
import 'package:flutter/material.dart';
import '../Components/bottom_nav_bar.dart';

class HomePage extends StatelessWidget{
  const HomePage({super.key});
  static const routeName = '/home';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: TopBar(hasBackButton: true, title: 'Home page',),
        bottomNavigationBar: BottomNavBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              HomeTabs(),
            ],
          ),
        ),
      ),
    );
  }
}