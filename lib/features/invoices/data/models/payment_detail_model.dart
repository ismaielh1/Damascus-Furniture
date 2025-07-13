class PaymentDetailModel {
  double amount;
  String currency; // 'USD' or 'SYP'
  double? exchangeRate;
  int? fundId; // -- تمت الإضافة --

  PaymentDetailModel({
    required this.amount,
    required this.currency,
    this.exchangeRate,
    this.fundId, // -- تمت الإضافة --
  });
}
