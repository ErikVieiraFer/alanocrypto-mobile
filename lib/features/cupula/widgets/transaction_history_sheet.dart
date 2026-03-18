import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../models/portfolio_models.dart';
import '../services/cupula_portfolio_service.dart';
import 'add_transaction_modal.dart';

const Color _kNeonGreen = Color(0xFF00FF88);

class TransactionHistorySheet extends StatefulWidget {
  final String coinSymbol;
  final String coin;
  final String oderId;
  final bool isReadOnly;
  final VoidCallback onChanged;

  const TransactionHistorySheet({
    super.key,
    required this.coinSymbol,
    required this.coin,
    required this.oderId,
    required this.isReadOnly,
    required this.onChanged,
  });

  @override
  State<TransactionHistorySheet> createState() =>
      _TransactionHistorySheetState();
}

class _TransactionHistorySheetState extends State<TransactionHistorySheet> {
  final CupulaPortfolioService _service = CupulaPortfolioService();
  List<PortfolioTransaction> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final all = await _service.getTransactionsOnce(widget.oderId);
      final filtered = all
          .where((t) =>
              t.coinSymbol.toLowerCase() == widget.coinSymbol.toLowerCase())
          .toList();
      if (mounted) {
        setState(() {
          _transactions = filtered;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _delete(PortfolioTransaction tx) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Excluir transação',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          'Deseja excluir esta ${tx.type == TransactionType.buy ? 'compra' : 'venda'} de ${tx.coinSymbol.toUpperCase()}?',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child:
                Text('Cancelar', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _service.deleteTransaction(tx.id);
      widget.onChanged();
      await _load();
      if (mounted && _transactions.isEmpty) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro ao excluir: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  void _edit(PortfolioTransaction tx) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTransactionModal(
        existingTransaction: tx,
        onTransactionAdded: () {
          widget.onChanged();
          _load();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Color(0xFF111418),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: _kNeonGreen))
                : _transactions.isEmpty
                    ? Center(
                        child: Text('Nenhuma transação encontrada',
                            style:
                                TextStyle(color: AppTheme.textSecondary)))
                    : RefreshIndicator(
                        onRefresh: _load,
                        color: _kNeonGreen,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _transactions.length,
                          itemBuilder: (_, i) =>
                              _buildItem(_transactions[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final symbol = widget.coinSymbol.length > 2
        ? widget.coinSymbol.substring(0, 2).toUpperCase()
        : widget.coinSymbol.toUpperCase();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(color: _kNeonGreen.withValues(alpha: 0.15))),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _kNeonGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _kNeonGreen.withValues(alpha: 0.3)),
            ),
            child: Center(
              child: Text(
                symbol,
                style: const TextStyle(
                  color: _kNeonGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.coin,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                Text(
                  '${_transactions.length} ${_transactions.length == 1 ? 'transação' : 'transações'}',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(PortfolioTransaction tx) {
    final isBuy = tx.type == TransactionType.buy;
    final typeColor = isBuy ? _kNeonGreen : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: typeColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isBuy ? 'COMPRA' : 'VENDA',
                  style: TextStyle(
                      color: typeColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${tx.date.day.toString().padLeft(2, '0')}/${tx.date.month.toString().padLeft(2, '0')}/${tx.date.year}',
                style:
                    TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
              const Spacer(),
              if (!widget.isReadOnly) ...[
                GestureDetector(
                  onTap: () => _edit(tx),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _kNeonGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.edit_rounded,
                        color: _kNeonGreen, size: 16),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _delete(tx),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.delete_rounded,
                        color: Colors.red, size: 16),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _info(
                    'Quantidade',
                    '${tx.quantity.toStringAsFixed(6)} ${tx.coinSymbol.toUpperCase()}'),
              ),
              Expanded(
                child:
                    _info('Preço', '\$${tx.pricePerUnit.toStringAsFixed(2)}'),
              ),
              Expanded(
                child:
                    _info('Total', '\$${tx.totalValue.toStringAsFixed(2)}'),
              ),
            ],
          ),
          if (tx.fee > 0 || (tx.note != null && tx.note!.isNotEmpty)) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (tx.fee > 0)
                  Expanded(
                    child: _info('Taxa', '\$${tx.fee.toStringAsFixed(2)}'),
                  ),
                if (tx.note != null && tx.note!.isNotEmpty)
                  Expanded(
                    flex: 2,
                    child: _info('Nota', tx.note!),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _info(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}
