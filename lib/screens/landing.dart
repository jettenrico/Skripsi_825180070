import 'package:flutter/material.dart';
import 'package:harusnyabisa/constants.dart';
import 'package:harusnyabisa/screens/explore.dart';
import 'package:harusnyabisa/screens/principle.dart';
import 'package:harusnyabisa/screens/restock.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile.dart';
import 'cart.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  var tipeuser = "";
  PageController pageController = PageController();

  List<Widget> pagescust = [ExplorePage(), OrderScreen(), ProfileCust()];
  List<Widget> pagesba = [OrderBA(), RestockPage(), ProfilePage()];
  List<Widget> pagesprinciple = [ReportPrinciple(), ProfileCust()];

  Future getTipe() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      tipeuser = preferences.getString('tipeuser')!;
    });
  }

  void _onItemTapped(int index) {
    this.pageController.animateToPage(index,
        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  void onPageChanged(int page) {
    if (!mounted) return;
    setState(() {
      this._selectedIndex = page;
    });
  }

  @override
  void initState() {
    getTipe();
    super.initState();
    pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
          appBar: tipeuser == "BA"
              ? AppBar(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  actions: <Widget>[
                    InkWell(
                      child: Icon(
                        Icons.shopping_cart_outlined,
                        color: kTextColor,
                        size: 32,
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PemesananProduk()));
                      },
                    ),
                    SizedBox(width: kDefaultPaddin / 1.5),
                  ],
                )
              : tipeuser == "Customer"
                  ? AppBar(
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      actions: <Widget>[
                        InkWell(
                          child: Icon(
                            Icons.shopping_cart_outlined,
                            color: kTextColor,
                            size: 32,
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CartPage()));
                          },
                        ),
                        SizedBox(width: kDefaultPaddin / 1.5),
                      ],
                    )
                  : AppBar(
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                    ),
          body: SafeArea(
              child: tipeuser == "BA"
                  ? PageView(
                      onPageChanged: onPageChanged,
                      controller: pageController,
                      children: [...pagesba],
                    )
                  : tipeuser == "Customer"
                      ? PageView(
                          onPageChanged: onPageChanged,
                          controller: pageController,
                          children: [...pagescust],
                        )
                      : PageView(
                          onPageChanged: onPageChanged,
                          controller: pageController,
                          children: [...pagesprinciple],
                        )),
          bottomNavigationBar: tipeuser == "BA"
              ? BottomNavigationBar(
                  items: const <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                        icon: Icon(Icons.list), label: 'Pesanan'),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.attach_money_outlined),
                        label: 'Restock'),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.account_circle_outlined),
                        label: 'Profile')
                  ],
                  currentIndex: _selectedIndex,
                  selectedItemColor: Colors.blue,
                  unselectedItemColor: Colors.black,
                  onTap: _onItemTapped,
                )
              : tipeuser == "Customer"
                  ? BottomNavigationBar(
                      items: const <BottomNavigationBarItem>[
                        BottomNavigationBarItem(
                            icon: Icon(Icons.shopping_bag_outlined),
                            label: 'Explore'),
                        BottomNavigationBarItem(
                            icon: Icon(Icons.list), label: 'Pesanan'),
                        BottomNavigationBarItem(
                            icon: Icon(Icons.account_circle_outlined),
                            label: 'Profile')
                      ],
                      currentIndex: _selectedIndex,
                      selectedItemColor: Colors.blue,
                      unselectedItemColor: Colors.black,
                      onTap: _onItemTapped,
                    )
                  : BottomNavigationBar(
                      items: const <BottomNavigationBarItem>[
                        BottomNavigationBarItem(
                            icon: Icon(Icons.list), label: 'Report'),
                        BottomNavigationBarItem(
                            icon: Icon(Icons.account_circle_outlined),
                            label: 'Profile')
                      ],
                      currentIndex: _selectedIndex,
                      selectedItemColor: Colors.blue,
                      unselectedItemColor: Colors.black,
                      onTap: _onItemTapped,
                    )),
    );
  }
}
