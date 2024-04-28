import 'package:bns_skill_assistant/controller/skill_data_controller.dart';
import 'package:bns_skill_assistant/services/key_hook_manager.dart';
import 'package:bns_skill_assistant/services/skill_combo_service.dart';
import 'package:bns_skill_assistant/tools/screen_color_picker.dart';
import 'package:flutter/material.dart';

import 'widgets/combos_page.dart';

void main() {
  KeyHookManager.init();
  SkillComboService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _controller = SkillDataController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _controller.tabs.length, vsync: this);
    _controller.init();
    _controller.addListener(() {
      setState(() {
        // _tabController = TabController(length: _controller.tabs.length, vsync: this);
      });
    });
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        bottom: TabBar(
            indicatorSize:TabBarIndicatorSize.label,
            indicator:const UnderlineTabIndicator(),
            controller: _tabController,
            isScrollable: true,
            tabs: _controller.tabs.map((e){
              return Tab(text: e.title,);
            }).toList()),
      ),
      body: Center(
        child: TabBarView(
            controller: _tabController,
            children: _controller.tabs.map((e){
              return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: CombosPage(e),
                  ),
              );
            }).toList()
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {},
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
