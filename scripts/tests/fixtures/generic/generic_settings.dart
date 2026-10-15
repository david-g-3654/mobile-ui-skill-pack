// Fixture: what an agent typically produces without the pack. The linter must flag it.
import 'package:flutter/material.dart';

class GenericSettings extends StatelessWidget {
  const GenericSettings({super.key, required this.loading});
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      drawer: Drawer(child: Container()),
      body: Column(
        children: [
          Row(children: [
            IconButton(icon: const Icon(Icons.arrow_back), onPressed: () {}),
            const Text('Settings', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ]),
          Card(
            elevation: 4,
            child: ListTile(
              leading: const Icon(Icons.notifications, color: Colors.deepPurple),
              title: const Text('Title', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: const Text('Subtitle', style: TextStyle(fontSize: 14, color: Colors.grey)),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
            ),
            child: const Text('Lorem ipsum dolor sit amet', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {}, child: const Icon(Icons.add)),
    );
  }
}
