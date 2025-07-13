// lib/features/settings/data/models/exchange_rate_model.dart
class ExchangeRateModel {
  final int id;
  final DateTime rateTimestamp;
  final double rateUsdToSyp;

  ExchangeRateModel({
    required this.id,
    required this.rateTimestamp,
    required this.rateUsdToSyp,
  });

  factory ExchangeRateModel.fromJson(Map<String, dynamic> json) {
    return ExchangeRateModel(
      id: json['id'],
      rateTimestamp: DateTime.parse(json['rate_timestamp']),
      rateUsdToSyp: (json['rate_usd_to_syp'] as num).toDouble(),
    );
  }
}
