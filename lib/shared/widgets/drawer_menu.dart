import 'package:flutter/material.dart';

import '../utils/routes.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.deepPurple,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 35, color: Colors.deepPurple),
                ),
                SizedBox(height: 10),
                Text(
                  'Epic App',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.popUntil(context, ModalRoute.withName(Routes.home));
            },
          ),
          ListTile(
            leading: const Icon(Icons.collections_bookmark_outlined),
            title: const Text('Collumns'),
            onTap: () {
              Navigator.popUntil(context, ModalRoute.withName(Routes.home));
              Navigator.pushNamed(context, Routes.columns);
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('ListView'),
            onTap: () {
              Navigator.popUntil(context, ModalRoute.withName(Routes.home));
              Navigator.pushNamed(context, Routes.listView);
            },
          ),
          ListTile(
            leading: const Icon(Icons.list_alt_rounded),
            title: const Text('ListView.builder'),
            onTap: () {
              Navigator.popUntil(context, ModalRoute.withName(Routes.home));
              Navigator.pushNamed(context, Routes.listViewBuilder);
            },
          ),
          ListTile(
            leading: const Icon(Icons.grid_4x4),
            title: const Text('GridView'),
            onTap: () {
              Navigator.popUntil(context, ModalRoute.withName(Routes.home));
              Navigator.pushNamed(context, Routes.gridView);
            },
          ),
          ListTile(
            leading: const Icon(Icons.stacked_bar_chart),
            title: const Text('Stack'),
            onTap: () {
              Navigator.popUntil(context, ModalRoute.withName(Routes.home));
              Navigator.pushNamed(context, Routes.stack);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.popUntil(context, ModalRoute.withName(Routes.home));
              Navigator.pushNamed(context, Routes.settings);
            },
          ),
        ],
      ),
    );
  }
}
