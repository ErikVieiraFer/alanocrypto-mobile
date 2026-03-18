import 'package:flutter/material.dart';
import 'cupula_portfolio_screen.dart';
import 'cupula_alano_portfolio_screen.dart';

class CupulaPortfolioTabsScreen extends StatefulWidget {
  const CupulaPortfolioTabsScreen({super.key});

  @override
  State<CupulaPortfolioTabsScreen> createState() =>
      _CupulaPortfolioTabsScreenState();
}

class _CupulaPortfolioTabsScreenState extends State<CupulaPortfolioTabsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    return Scaffold(
      backgroundColor: const Color(0xFF111418),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111418),
        elevation: 0,
        title: const Text(
          'Carteira',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1a1f25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: const Color(0xFF00FF88),
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.all(4),
              labelColor: const Color(0xFF111418),
              unselectedLabelColor: const Color(0xFF9ca3af),
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14),
              unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500, fontSize: 14),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Minha Carteira'),
                Tab(text: 'Carteira do Alano'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          CupulaPortfolioScreen(),
          CupulaAlanoPortfolioScreen(),
        ],
      ),
    );
  }
}
