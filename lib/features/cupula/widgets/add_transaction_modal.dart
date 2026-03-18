import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/portfolio_models.dart';
import '../services/cupula_portfolio_service.dart';
import '../services/coingecko_portfolio_service.dart';

class AddTransactionModal extends StatefulWidget {
  final VoidCallback onTransactionAdded;
  final PortfolioTransaction? existingTransaction;

  const AddTransactionModal({
    super.key,
    required this.onTransactionAdded,
    this.existingTransaction,
  });

  @override
  State<AddTransactionModal> createState() => _AddTransactionModalState();
}

class _AddTransactionModalState extends State<AddTransactionModal> {
  final CupulaPortfolioService _portfolioService = CupulaPortfolioService();
  final CoingeckoPortfolioService _coingeckoService = CoingeckoPortfolioService();

  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _feeController = TextEditingController();
  final _noteController = TextEditingController();
  final _searchController = TextEditingController();

  TransactionType _transactionType = TransactionType.buy;
  DateTime _selectedDate = DateTime.now();
  Map<String, dynamic>? _selectedCoin;
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  bool _isSaving = false;
  Timer? _debounceTimer;

  bool get _isEditing => widget.existingTransaction != null;

  double get _totalValue {
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0;
    return quantity * price;
  }

  @override
  void initState() {
    super.initState();
    if (_isEditing) _initFromExisting();
  }

  void _initFromExisting() {
    final tx = widget.existingTransaction!;
    _transactionType = tx.type;
    _selectedDate = tx.date;
    _quantityController.text = tx.quantity.toString();
    _priceController.text = tx.pricePerUnit.toString();
    _feeController.text = tx.fee > 0 ? tx.fee.toString() : '';
    _noteController.text = tx.note ?? '';
    _selectedCoin = {
      'id': tx.coinSymbol.toLowerCase(),
      'name': tx.coin,
      'symbol': tx.coinSymbol,
    };
    _searchController.text = tx.coin;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _quantityController.dispose();
    _priceController.dispose();
    _feeController.dispose();
    _noteController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchCoins(String query) async {
    _debounceTimer?.cancel();
    if (query.length < 2) {
      setState(() => _searchResults = []);
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 600), () async {
      if (!mounted) return;
      setState(() => _isSearching = true);
      try {
        final results = await _coingeckoService.searchCoins(query);
        if (mounted) {
          setState(() {
            _searchResults = results;
            _isSearching = false;
          });
        }
      } catch (e) {
        if (mounted) setState(() => _isSearching = false);
      }
    });
  }

  void _selectCoin(Map<String, dynamic> coin) {
    setState(() {
      _selectedCoin = coin;
      _searchController.text = coin['name'] ?? '';
      _searchResults = [];
    });
    _loadCurrentPrice(coin['id']);
  }

  Future<void> _loadCurrentPrice(String coinId) async {
    try {
      final price = await _coingeckoService.getCoinPrice(coinId);
      if (price != null && mounted) {
        setState(() {
          _priceController.text = price.toStringAsFixed(2);
        });
      }
    } catch (e) {
      return;
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2010),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00FF88),
              onPrimary: Color(0xFF111418),
              surface: Color(0xFF1a1f25),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveTransaction() async {
    if (_selectedCoin == null) {
      _showError('Selecione uma moeda');
      return;
    }

    final quantity = double.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) {
      _showError('Informe uma quantidade válida');
      return;
    }

    final price = double.tryParse(_priceController.text);
    if (price == null || price <= 0) {
      _showError('Informe um preço válido');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final fee = double.tryParse(_feeController.text) ?? 0;

      final transaction = PortfolioTransaction(
        id: _isEditing ? widget.existingTransaction!.id : '',
        oderId: _isEditing
            ? widget.existingTransaction!.oderId
            : (FirebaseAuth.instance.currentUser?.uid ?? ''),
        coin: _selectedCoin!['name'] ?? '',
        coinSymbol: _selectedCoin!['symbol'] ?? '',
        assetType: AssetType.crypto,
        type: _transactionType,
        quantity: quantity,
        pricePerUnit: price,
        totalValue: quantity * price,
        fee: fee,
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
        date: _selectedDate,
        createdAt: _isEditing
            ? widget.existingTransaction!.createdAt
            : DateTime.now(),
      );

      if (_isEditing) {
        await _portfolioService.updateTransaction(
            widget.existingTransaction!.id, transaction);
      } else {
        await _portfolioService.addTransaction(transaction);
      }

      widget.onTransactionAdded();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showError('Erro ao salvar: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Color(0xFF111418),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTypeToggle(),
                  const SizedBox(height: 20),
                  _buildCoinSearch(),
                  const SizedBox(height: 20),
                  _buildTextField('Quantidade', _quantityController, 'Ex: 0.5'),
                  const SizedBox(height: 16),
                  _buildTextField(
                      'Preço por Unidade (USD)', _priceController, 'Ex: 45000.00'),
                  const SizedBox(height: 16),
                  _buildDatePicker(),
                  const SizedBox(height: 16),
                  _buildTextField('Taxa (opcional)', _feeController, 'Ex: 2.50'),
                  const SizedBox(height: 16),
                  _buildNoteField(),
                  const SizedBox(height: 20),
                  _buildTotalDisplay(),
                  const SizedBox(height: 24),
                  _buildSaveButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF22282F))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _isEditing ? 'Editar Transação' : 'Adicionar Transação',
            style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _transactionType = TransactionType.buy),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _transactionType == TransactionType.buy
                    ? const Color(0xFF00FF88)
                    : const Color(0xFF22282F),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'COMPRA',
                  style: TextStyle(
                    color: _transactionType == TransactionType.buy
                        ? const Color(0xFF111418)
                        : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () =>
                setState(() => _transactionType = TransactionType.sell),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _transactionType == TransactionType.sell
                    ? Colors.red
                    : const Color(0xFF22282F),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'VENDA',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCoinSearch() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Moeda',
            style: TextStyle(color: Color(0xFF9ca3af), fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Buscar moeda...',
            hintStyle: const TextStyle(color: Color(0xFF9ca3af)),
            prefixIcon: const Icon(Icons.search, color: Color(0xFF9ca3af)),
            suffixIcon: _isSearching
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF00FF88),
                      ),
                    ),
                  )
                : null,
            filled: true,
            fillColor: const Color(0xFF1a1f25),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: _searchCoins,
        ),
        if (_searchResults.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: const Color(0xFF1a1f25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final coin = _searchResults[index];
                return ListTile(
                  leading: coin['thumb'] != null
                      ? Image.network(coin['thumb'],
                          width: 32, height: 32, errorBuilder: (_, __, ___) =>
                              const Icon(Icons.monetization_on,
                                  color: Color(0xFF00FF88)))
                      : const Icon(Icons.monetization_on,
                          color: Color(0xFF00FF88)),
                  title: Text(coin['name'] ?? '',
                      style: const TextStyle(color: Colors.white)),
                  subtitle: Text(
                    (coin['symbol'] ?? '').toUpperCase(),
                    style: const TextStyle(color: Color(0xFF9ca3af)),
                  ),
                  onTap: () => _selectCoin(coin),
                );
              },
            ),
          ),
        if (_selectedCoin != null && _searchResults.isEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF22282F),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF00FF88)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle,
                    color: Color(0xFF00FF88), size: 20),
                const SizedBox(width: 8),
                Text(
                  '${_selectedCoin!['name']} (${(_selectedCoin!['symbol'] ?? '').toUpperCase()})',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Color(0xFF9ca3af), fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF9ca3af)),
            filled: true,
            fillColor: const Color(0xFF1a1f25),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Data',
            style: TextStyle(color: Color(0xFF9ca3af), fontSize: 14)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF1a1f25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                  style: const TextStyle(color: Colors.white),
                ),
                const Icon(Icons.calendar_today,
                    color: Color(0xFF9ca3af), size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoteField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Nota (opcional)',
            style: TextStyle(color: Color(0xFF9ca3af), fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          controller: _noteController,
          style: const TextStyle(color: Colors.white),
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'Adicione uma nota...',
            hintStyle: const TextStyle(color: Color(0xFF9ca3af)),
            filled: true,
            fillColor: const Color(0xFF1a1f25),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalDisplay() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF22282F),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Total',
              style: TextStyle(color: Color(0xFF9ca3af), fontSize: 16)),
          Text(
            '\$${_totalValue.toStringAsFixed(2)}',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveTransaction,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00FF88),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Color(0xFF111418)),
              )
            : Text(
                _isEditing ? 'SALVAR ALTERAÇÕES' : 'ADICIONAR TRANSAÇÃO',
                style: const TextStyle(
                  color: Color(0xFF111418),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
