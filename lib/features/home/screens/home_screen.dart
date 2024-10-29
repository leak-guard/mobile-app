import 'package:flutter/material.dart';
import 'package:leak_guard/shared/widgets/bottom_navigation_bar.dart';
import '../../../shared/widgets/drawer_menu.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool isLiked = false;
  int currentIndex = 1;

  List<IconData> icons = const [
    Icons.face_sharp,
    Icons.favorite,
    Icons.water_drop,
  ];

  void _onIndexChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  void _handleTap() {
    setState(() {
      isLiked = !isLiked;
      if (isLiked) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Epic App",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
            icon: const Icon(
              Icons.settings,
            ),
          )
        ],
      ),
      bottomNavigationBar: MyBottomNavigationBar(
          currentIndex: currentIndex, onTap: _onIndexChanged),
      drawer: const DrawerMenu(),
      body: Center(
        child: Container(
          height: 300,
          width: 300,
          decoration: BoxDecoration(
            color: Colors.deepPurple,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(25),
          child: GestureDetector(
            onTap: _handleTap,
            child: RotationTransition(
              turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  icons[currentIndex],
                  color: isLiked ? Colors.red : Colors.deepPurple[400],
                  size: 100,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
