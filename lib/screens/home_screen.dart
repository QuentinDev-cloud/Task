import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/task_database.dart';
import 'tabs/actual_tab.dart';
import 'tabs/done_tab.dart';
import 'tabs/incoming_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(initialPage: 1);

  int _selectedIndex = 1;
  int validValue = 0;
  int remainValue = 0;

  final List<String> _tabs = ['Done', 'Actual', 'Incoming'];

  @override
  void initState() {
    super.initState();
    _prepareApp();
  }

  Future<void> _prepareApp() async {
    await TaskDatabase.instance.cleanupOldDoneTasks();
    await TaskDatabase.instance.resetDailyCounterIfNeeded();
    await _refreshHeader();
  }

  Future<void> _refreshHeader() async {
    final valid = await TaskDatabase.instance.getValidTodayCount();
    final remain = await TaskDatabase.instance.getRemainCount();

    if (!mounted) return;

    setState(() {
      validValue = valid;
      remainValue = remain;
    });
  }

  void _changePage(int index) {
    SystemSound.play(SystemSoundType.click);
    setState(() => _selectedIndex = index);

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  void _onPageChanged(int index) {
    SystemSound.play(SystemSoundType.click);
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: _onPageChanged,
                children: [
                  DoneTab(onDataChanged: _refreshHeader),
                  ActualTab(onDataChanged: _refreshHeader),
                  IncomingTab(onDataChanged: _refreshHeader),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
      decoration: const BoxDecoration(
        color: Color(0xFF262626),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 136,
            height: 27,
            child: CustomPaint(
              painter: _SegmentBorderPainter(),
              child: Row(
                children: List.generate(_tabs.length, (index) {
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _changePage(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        alignment: Alignment.center,
                        color: _selectedIndex == index
                            ? const Color(0xFFBDBDBD)
                            : const Color(0xFFFFFFFF),
                        child: Text(
                          _tabs[index],
                          style: const TextStyle(
                            color: Color(0xFF111111),
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 27,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF000000),
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: FittedBox(
                child: Text(
                  'VALID : $validValue | REMAIN : $remainValue',
                  style: const TextStyle(
                    color: Color(0xFF111111),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint borderPaint = Paint()
      ..color = const Color(0xFF000000)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final Paint linePaint = Paint()
      ..color = const Color(0xFF000000)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), borderPaint);

    final double segmentWidth = size.width / 3;

    canvas.drawLine(
      Offset(segmentWidth + 5, 0),
      Offset(segmentWidth - 5, size.height),
      linePaint,
    );

    canvas.drawLine(
      Offset(segmentWidth * 2 + 5, 0),
      Offset(segmentWidth * 2 - 5, size.height),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}