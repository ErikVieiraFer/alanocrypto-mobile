import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../theme/app_theme.dart';
import '../services/cupula_portfolio_service.dart';
import '../services/coingecko_portfolio_service.dart';
import '../models/portfolio_models.dart';
import '../widgets/add_transaction_modal.dart';
import '../widgets/portfolio_allocation_chart.dart';
import '../widgets/transaction_history_sheet.dart';

const Color _kNeonGreen = Color(0xFF00FF88);

class CupulaPortfolioScreen extends StatefulWidget {
  final bool isReadOnly;
  final String? oderId;

  const CupulaPortfolioScreen({
    super.key,
    this.isReadOnly = false,
    this.oderId,
  });

  @override
  State<CupulaPortfolioScreen> createState() => _CupulaPortfolioScreenState();
}

class _CupulaPortfolioScreenState extends State<CupulaPortfolioScreen> {
  final CupulaPortfolioService _portfolioService = CupulaPortfolioService();
  final CoingeckoPortfolioService _coingeckoService = CoingeckoPortfolioService();

  List<PortfolioHolding> _holdings = [];
  bool _isLoading = true;
  double _totalValue = 0;
  double _totalInvested = 0;
  double _totalProfitLoss = 0;
  double _totalProfitLossPercentage = 0;

  String get _effectiveoderId =>
      widget.oderId ?? FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _loadPortfolio();
  }

  Future<void> _loadPortfolio() async {
    setState(() => _isLoading = true);

    try {
      final transactions =
          await _portfolioService.getTransactionsOnce(_effectiveoderId);
      final holdings = _portfolioService.calculateHoldings(transactions);

      await _updatePrices(holdings);

      double totalInvested = 0;
      double totalValue = 0;

      for (final holding in holdings) {
        totalInvested += holding.totalInvested;
        totalValue += holding.currentValue ?? holding.totalInvested;
      }

      setState(() {
        _holdings = holdings;
        _totalInvested = totalInvested;
        _totalValue = totalValue;
        _totalProfitLoss = totalValue - totalInvested;
        _totalProfitLossPercentage =
            totalInvested > 0 ? (_totalProfitLoss / totalInvested) * 100 : 0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updatePrices(List<PortfolioHolding> holdings) async {
    if (holdings.isEmpty) return;

    try {
      final coinIds = holdings
          .where((h) => h.assetType == AssetType.crypto)
          .map((h) => h.coin.toLowerCase().replaceAll(' ', '-'))
          .toList();

      if (coinIds.isEmpty) return;

      final prices = await _coingeckoService.getMultiplePrices(coinIds);

      for (final holding in holdings) {
        final coinId = holding.coin.toLowerCase().replaceAll(' ', '-');
        final price = prices[coinId];
        if (price != null) {
          holding.updateCurrentPrice(price);
        } else {
          holding.updateCurrentPrice(holding.averagePrice);
        }
      }
    } catch (e) {
      for (final holding in holdings) {
        holding.updateCurrentPrice(holding.averagePrice);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: _kNeonGreen),
            )
          : RefreshIndicator(
              onRefresh: _loadPortfolio,
              color: _kNeonGreen,
              child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _buildHeader()),
                    SliverToBoxAdapter(child: _buildSummaryCard()),
                    if (_holdings.isNotEmpty)
                      SliverToBoxAdapter(
                        child: PortfolioAllocationChart(
                          holdings: _holdings,
                          totalValue: _totalValue,
                        ),
                      ),
                    SliverToBoxAdapter(child: _buildHoldingsHeader()),
                    _holdings.isEmpty
                        ? SliverToBoxAdapter(child: _buildEmptyState())
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration:
                                    Duration(milliseconds: 300 + (index * 60)),
                                curve: Curves.easeOut,
                                builder: (context, value, child) {
                                  return Transform.translate(
                                    offset: Offset(0, 20 * (1 - value)),
                                    child: Opacity(opacity: value, child: child),
                                  );
                                },
                                child: GestureDetector(
                  onTap: () => _showTransactionHistory(_holdings[index]),
                  child: _buildHoldingCard(_holdings[index], index),
                ),
                              ),
                              childCount: _holdings.length,
                            ),
                          ),
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
              ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _kNeonGreen.withValues(alpha: 0.15),
            _kNeonGreen.withValues(alpha: 0.05),
            Colors.transparent,
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: _kNeonGreen.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _kNeonGreen.withValues(alpha: 0.3),
                      _kNeonGreen.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _kNeonGreen.withValues(alpha: 0.4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _kNeonGreen.withValues(alpha: 0.3),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: _kNeonGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isReadOnly
                          ? 'Carteira do Alano'
                          : 'Minha Carteira',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.isReadOnly
                          ? 'Acompanhe as posições do Alano'
                          : 'Suas posições e performance',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (!widget.isReadOnly)
                GestureDetector(
                  onTap: _showAddTransactionModal,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _kNeonGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _kNeonGreen.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.add_rounded, color: _kNeonGreen, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Adicionar',
                          style: TextStyle(
                            color: _kNeonGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                _buildAssetsChip(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssetsChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _kNeonGreen.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kNeonGreen.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.pie_chart_rounded, color: _kNeonGreen, size: 14),
          const SizedBox(width: 6),
          Text(
            '${_holdings.length} ${_holdings.length == 1 ? 'ativo' : 'ativos'}',
            style: const TextStyle(
              color: _kNeonGreen,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final isProfit = _totalProfitLoss >= 0;
    final profitColor =
        isProfit ? AppTheme.successGreen : AppTheme.errorRed;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.cardDark,
            const Color(0xFF1a2535),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _kNeonGreen.withValues(alpha: 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: _kNeonGreen.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Saldo Total',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: profitColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: profitColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isProfit
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        color: profitColor,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${isProfit ? '+' : ''}${_totalProfitLossPercentage.toStringAsFixed(2)}%',
                        style: TextStyle(
                          color: profitColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '\$${_totalValue.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    isProfit
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    color: profitColor,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${isProfit ? '+' : ''}\$${_totalProfitLoss.toStringAsFixed(2)} total',
                    style: TextStyle(
                      color: profitColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.wallet_rounded,
                    size: 12,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Investido: \$${_totalInvested.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHoldingsHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          const Text(
            'Seus Ativos',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          const Spacer(),
          if (_holdings.isNotEmpty)
            Text(
              '${_holdings.length} ${_holdings.length == 1 ? 'ativo' : 'ativos'}',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHoldingCard(PortfolioHolding holding, int index) {
    final isProfit = (holding.profitLoss ?? 0) >= 0;
    final profitColor =
        isProfit ? AppTheme.successGreen : AppTheme.errorRed;

    final List<Color> accentColors = [
      _kNeonGreen,
      const Color(0xFF3B82F6),
      const Color(0xFFF59E0B),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFF14B8A6),
    ];
    final accentColor = accentColors[index % accentColors.length];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _kNeonGreen.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      accentColor,
                      accentColor.withValues(alpha: 0.4),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              accentColor.withValues(alpha: 0.25),
                              accentColor.withValues(alpha: 0.08),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: accentColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            holding.coinSymbol.length > 2
                                ? holding.coinSymbol
                                    .substring(0, 2)
                                    .toUpperCase()
                                : holding.coinSymbol.toUpperCase(),
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              holding.coinSymbol.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              holding.coin,
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Preço médio: \$${holding.averagePrice.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: AppTheme.textTertiary,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '\$${(holding.currentValue ?? 0).toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${holding.quantity.toStringAsFixed(4)} ${holding.coinSymbol.toUpperCase()}',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: profitColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: profitColor.withValues(alpha: 0.25)),
                            ),
                            child: Text(
                              '${isProfit ? '+' : ''}\$${(holding.profitLoss ?? 0).toStringAsFixed(2)} (${isProfit ? '+' : ''}${(holding.profitLossPercentage ?? 0).toStringAsFixed(1)}%)',
                              style: TextStyle(
                                color: profitColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _kNeonGreen.withValues(alpha: 0.2),
                    _kNeonGreen.withValues(alpha: 0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                size: 48,
                color: _kNeonGreen,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.isReadOnly
                  ? 'Nenhum ativo na carteira'
                  : 'Sua carteira está vazia',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.isReadOnly
                  ? 'O Alano ainda não adicionou ativos'
                  : 'Adicione sua primeira transação para começar a acompanhar sua performance',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (!widget.isReadOnly) ...[
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: _showAddTransactionModal,
                icon: const Icon(Icons.add_rounded, color: Colors.black),
                label: const Text(
                  'Adicionar Transação',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kNeonGreen,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAddTransactionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTransactionModal(
        onTransactionAdded: _loadPortfolio,
      ),
    );
  }

  void _showTransactionHistory(PortfolioHolding holding) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionHistorySheet(
        coinSymbol: holding.coinSymbol,
        coin: holding.coin,
        oderId: _effectiveoderId,
        isReadOnly: widget.isReadOnly,
        onChanged: _loadPortfolio,
      ),
    );
  }
}
