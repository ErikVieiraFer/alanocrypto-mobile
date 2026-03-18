import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType { buy, sell }

enum AssetType { crypto, forex }

class PortfolioTransaction {
  final String id;
  final String oderId;
  final String coin;
  final String coinSymbol;
  final AssetType assetType;
  final TransactionType type;
  final double quantity;
  final double pricePerUnit;
  final double totalValue;
  final double fee;
  final String? note;
  final DateTime date;
  final DateTime createdAt;

  PortfolioTransaction({
    required this.id,
    required this.oderId,
    required this.coin,
    required this.coinSymbol,
    this.assetType = AssetType.crypto,
    required this.type,
    required this.quantity,
    required this.pricePerUnit,
    required this.totalValue,
    this.fee = 0,
    this.note,
    required this.date,
    required this.createdAt,
  });

  factory PortfolioTransaction.fromFirestore(Map<String, dynamic> data, String id) {
    return PortfolioTransaction(
      id: id,
      oderId: data['oderId'] ?? '',
      coin: data['coin'] ?? '',
      coinSymbol: data['coinSymbol'] ?? '',
      assetType: data['assetType'] == 'forex' ? AssetType.forex : AssetType.crypto,
      type: data['type'] == 'sell' ? TransactionType.sell : TransactionType.buy,
      quantity: (data['quantity'] ?? 0).toDouble(),
      pricePerUnit: (data['pricePerUnit'] ?? 0).toDouble(),
      totalValue: (data['totalValue'] ?? 0).toDouble(),
      fee: (data['fee'] ?? 0).toDouble(),
      note: data['note'],
      date: (data['date'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'oderId': oderId,
      'coin': coin,
      'coinSymbol': coinSymbol,
      'assetType': assetType == AssetType.forex ? 'forex' : 'crypto',
      'type': type == TransactionType.sell ? 'sell' : 'buy',
      'quantity': quantity,
      'pricePerUnit': pricePerUnit,
      'totalValue': totalValue,
      'fee': fee,
      'note': note,
      'date': Timestamp.fromDate(date),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class PortfolioHolding {
  final String coin;
  final String coinSymbol;
  final AssetType assetType;
  final double quantity;
  final double averagePrice;
  final double totalInvested;
  double? currentPrice;
  double? currentValue;
  double? profitLoss;
  double? profitLossPercentage;

  PortfolioHolding({
    required this.coin,
    required this.coinSymbol,
    this.assetType = AssetType.crypto,
    required this.quantity,
    required this.averagePrice,
    required this.totalInvested,
    this.currentPrice,
    this.currentValue,
    this.profitLoss,
    this.profitLossPercentage,
  });

  void updateCurrentPrice(double price) {
    currentPrice = price;
    currentValue = quantity * price;
    profitLoss = currentValue! - totalInvested;
    profitLossPercentage = totalInvested > 0 ? (profitLoss! / totalInvested) * 100 : 0;
  }
}

class Portfolio {
  final String oderId;
  final List<PortfolioHolding> holdings;
  final double totalInvested;
  final double totalValue;
  final double totalProfitLoss;
  final double totalProfitLossPercentage;
  final DateTime? lastUpdated;

  Portfolio({
    required this.oderId,
    required this.holdings,
    required this.totalInvested,
    required this.totalValue,
    required this.totalProfitLoss,
    required this.totalProfitLossPercentage,
    this.lastUpdated,
  });
}
