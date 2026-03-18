import 'dart:convert';
import 'package:http/http.dart' as http;

class CoingeckoPortfolioService {
  static const String _baseUrl = 'https://api.coingecko.com/api/v3';

  Future<List<Map<String, dynamic>>> searchCoins(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/search?query=$query'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final coins = data['coins'] as List<dynamic>;
        return coins.take(10).map((coin) => {
              'id': coin['id'],
              'name': coin['name'],
              'symbol': coin['symbol'],
              'thumb': coin['thumb'],
            }).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<double?> getCoinPrice(String coinId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/simple/price?ids=$coinId&vs_currencies=usd'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data[coinId]?['usd']?.toDouble();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, double>> getMultiplePrices(List<String> coinIds) async {
    if (coinIds.isEmpty) return {};

    try {
      final ids = coinIds.join(',');
      final response = await http.get(
        Uri.parse(
            '$_baseUrl/simple/price?ids=$ids&vs_currencies=usd&include_24hr_change=true'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final Map<String, double> prices = {};

        for (final entry in data.entries) {
          prices[entry.key] = (entry.value['usd'] ?? 0).toDouble();
        }

        return prices;
      }
      return {};
    } catch (e) {
      return {};
    }
  }
}
