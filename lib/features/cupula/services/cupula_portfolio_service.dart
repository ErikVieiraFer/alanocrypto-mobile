import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/portfolio_models.dart';

class CupulaPortfolioService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentoderId => _auth.currentUser?.uid;

  CollectionReference get _transactionsCollection =>
      _firestore.collection('cupula_portfolio_transactions');

  Future<String> addTransaction(PortfolioTransaction transaction) async {
    final docRef = await _transactionsCollection.add(transaction.toFirestore());
    return docRef.id;
  }

  Future<void> updateTransaction(String id, PortfolioTransaction transaction) async {
    await _transactionsCollection.doc(id).update(transaction.toFirestore());
  }

  Future<void> deleteTransaction(String id) async {
    await _transactionsCollection.doc(id).delete();
  }

  Stream<List<PortfolioTransaction>> getTransactions(String oderId) {
    return _transactionsCollection
        .where('oderId', isEqualTo: oderId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => PortfolioTransaction.fromFirestore(
                  doc.data() as Map<String, dynamic>, doc.id))
              .toList();
          list.sort((a, b) => b.date.compareTo(a.date));
          return list;
        });
  }

  Future<List<PortfolioTransaction>> getTransactionsOnce(String oderId) async {
    final snapshot = await _transactionsCollection
        .where('oderId', isEqualTo: oderId)
        .get();
    final list = snapshot.docs
        .map((doc) => PortfolioTransaction.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id))
        .toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  List<PortfolioHolding> calculateHoldings(List<PortfolioTransaction> transactions) {
    final Map<String, PortfolioHolding> holdingsMap = {};

    for (final tx in transactions) {
      final key = tx.coinSymbol;

      if (!holdingsMap.containsKey(key)) {
        holdingsMap[key] = PortfolioHolding(
          coin: tx.coin,
          coinSymbol: tx.coinSymbol,
          assetType: tx.assetType,
          quantity: 0,
          averagePrice: 0,
          totalInvested: 0,
        );
      }

      final holding = holdingsMap[key]!;

      if (tx.type == TransactionType.buy) {
        final newQuantity = holding.quantity + tx.quantity;
        final newTotalInvested = holding.totalInvested + tx.totalValue + tx.fee;
        final double newAveragePrice = newQuantity > 0 ? newTotalInvested / newQuantity : 0.0;

        holdingsMap[key] = PortfolioHolding(
          coin: holding.coin,
          coinSymbol: holding.coinSymbol,
          assetType: holding.assetType,
          quantity: newQuantity,
          averagePrice: newAveragePrice,
          totalInvested: newTotalInvested,
        );
      } else {
        final newQuantity = holding.quantity - tx.quantity;
        final soldRatio = tx.quantity / holding.quantity;
        final newTotalInvested = holding.totalInvested * (1 - soldRatio);

        holdingsMap[key] = PortfolioHolding(
          coin: holding.coin,
          coinSymbol: holding.coinSymbol,
          assetType: holding.assetType,
          quantity: newQuantity > 0 ? newQuantity : 0,
          averagePrice: holding.averagePrice,
          totalInvested: newTotalInvested > 0 ? newTotalInvested : 0,
        );
      }
    }

    return holdingsMap.values.where((h) => h.quantity > 0).toList();
  }

  Future<Portfolio> getPortfolio(String oderId) async {
    final transactions = await getTransactionsOnce(oderId);
    final holdings = calculateHoldings(transactions);

    double totalInvested = 0;
    double totalValue = 0;

    for (final holding in holdings) {
      totalInvested += holding.totalInvested;
      totalValue += holding.currentValue ?? holding.totalInvested;
    }

    final totalProfitLoss = totalValue - totalInvested;
    final double totalProfitLossPercentage =
        totalInvested > 0 ? (totalProfitLoss / totalInvested) * 100 : 0.0;

    return Portfolio(
      oderId: oderId,
      holdings: holdings,
      totalInvested: totalInvested,
      totalValue: totalValue,
      totalProfitLoss: totalProfitLoss,
      totalProfitLossPercentage: totalProfitLossPercentage,
      lastUpdated: DateTime.now(),
    );
  }
}
