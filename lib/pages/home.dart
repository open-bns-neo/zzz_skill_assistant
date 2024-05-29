import 'package:bns_skill_assistant/controller/skill_data_controller.dart';
import 'package:bns_skill_assistant/pages/settings.dart';
import 'package:bns_skill_assistant/widgets/delete_widget.dart';
import 'package:get/get.dart';
import 'package:prompt_dialog/prompt_dialog.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../controller/cache_manager.dart';
import '../tools/logger.dart';
import '../widgets/combos_page.dart';
import '../widgets/util/notification.dart';
import 'color_library.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late TabController _tabController;
  late SkillDataController _controller;

  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    try {
      final json = await CacheManager.loadSkillCache();
      if (json != null) {
        _controller = SkillDataController.fromJson(json);
      } else {
        _controller = SkillDataController();
      }
    } catch (e) {
      _controller = SkillDataController();
      logger.error('Load cache error: $e');
    }

    _initTabController();
    _controller.init();
    if (_controller.tabs.isNotEmpty) {
      ComboActiveManager().currentController = _controller.tabs[0];
    }
    _controller.addListener(() {
      setState(() {
        _tabController.dispose();
        _initTabController();
      });
    });

    setState(() {
      _isInit = true;
    });
  }

  void _initTabController() {
    _tabController = TabController(length: _controller.tabs.length, vsync: this);
    _tabController.addListener(() {
      ComboActiveManager().currentController = _controller.tabs[_tabController.index];
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
        bottom: _isInit ? _buildTabBar() : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              _controller.save();
              notify.success('保存成功', context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.color_lens_outlined),
            onPressed: () {
              ColorLibraryPage.show(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Get.to(
                () => const SettingsPage(),
                transition: Transition.rightToLeft,
              );
            },
          ),
        ],
      ),
      body: Center(
        child: _isInit ? _buildTabView() : _buildLoading(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {
          notify.error('暂未实现，敬请期待...', context)
        },
        tooltip: '从本地导入',
        child: const Icon(Icons.add),
      ),
    );
  }

  PreferredSizeWidget _buildTabBar() {
    return CustomTabBar(
      controller: _tabController,
      tabs: _controller.tabs.map((e){
        return CustomTab(
          e,
          text: e.title,
          onButtonPressed: () {
            // 删除Tab页
            _controller.removeTab(e);
            setState(() {});
          },
          onTitleChanged: (text) {
            e.title = text;
            setState(() {});
            _controller.save();
          },
          canDelete: _controller.tabs.indexOf(e) != 0,
        );
      }).toList(),
      onButtonPressed: () {
        // 增加Tab页
        _controller.addTab(TabPageController('New Tab', skills: []));
        setState(() {});
      },
    );
  }

  Widget _buildTabView() {
    return TabBarView(
        controller: _tabController,
        children: _controller.tabs.map((e){
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: CombosPage(
                e,
                key: ValueKey(e),
              ),
            ),
          );
        }).toList()
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        children: [
          Text('Loading...'),
          CircularProgressIndicator(),
        ],
      ),
    );
  }
}

class CustomTabBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController controller;
  final List<Widget> tabs;
  final VoidCallback onButtonPressed;

  const CustomTabBar({super.key, required this.controller, required this.tabs, required this.onButtonPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        TabBar(
          controller: controller,
          isScrollable: true,
          tabs: tabs,
        ),
        const SizedBox(width: 10),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: onButtonPressed,
          tooltip: '增加卡刀页',
        ),
      ],
    );
  }

  @override
  Size get preferredSize {
    return const Size.fromHeight(80);
  }
}

class CustomTab extends StatefulWidget implements PreferredSizeWidget {
  final String text;
  final VoidCallback onButtonPressed;
  final Function(String text) onTitleChanged;
  final bool canDelete;
  final TabPageController _controller;
  final _activeManager = ComboActiveManager();

  CustomTab(this._controller, {super.key, required this.text, required this.onButtonPressed, this.canDelete = true, required this.onTitleChanged});

  @override
  State<StatefulWidget> createState() => _CustomTabState();

  @override
  Size get preferredSize {
    // 这里计算整个自定义TabBar的首选高度
    return const Size.fromHeight(80);
  }
}

class _CustomTabState extends State<CustomTab> {
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    widget._activeManager.addListener(_onChange);
  }

  @override
  void dispose() {
    super.dispose();
    widget._activeManager.removeListener(_onChange);
  }

  void _onChange() {
    setState(() {});
  }

  void _handleHover(bool isHovering) {
    setState(() {
      _isHovering = isHovering;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      height: 80,
      child: Center(
        child: MouseRegion(
          onEnter: (event) => _handleHover(true),
          onExit: (event) => _handleHover(false),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (widget._activeManager.isActive && widget._activeManager.activeController == widget._controller)
                ...[
                  const Icon(
                    Icons.star_sharp,
                    color: Color(0xFFFFD700),
                  ),
                  const SizedBox(width: 5),
                ],
              Tab(
                text: widget.text,
              ),
              const Spacer(),
              if (_isHovering)
                _buildToolBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolBar() {
    return Column(
      children: <Widget>[
        if (widget.canDelete)
          DeleteWidget(
            size: 14,
            content: '是否删除Tab页？',
            onDelete: widget.onButtonPressed,
          ),
        IconButton(
          icon: const Icon(
            size: 14,
            Icons.edit,
          ),
          onPressed: () async {
            // 编辑标题
            final text = await prompt(
              context,
              initialValue: widget.text,
            );
            if (text != null && text.isNotEmpty) {
              widget.onTitleChanged(text);
            }
          },
        ),
      ],
    );
  }
}
