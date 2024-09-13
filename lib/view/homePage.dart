// ignore_for_file: use_full_hex_values_for_flutter_colors

import 'package:flutter/material.dart';
import 'package:todo/widgets/todoWidgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF547D58),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active', icon: Icon(Icons.assignment_outlined)),
            Tab(text: 'Completed', icon: Icon(Icons.assignment_turned_in)),
          ],
          indicatorColor: const Color(0xFF1F2F12),
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFFA8C98E),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Active todos
          buildTodoList(context, false, isTablet),
          // Completed todos
          buildTodoList(context, true, isTablet),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddTodoDialog(context, _formKey),
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: const Color(0xFF547D58),
      ),
    );
  }
}