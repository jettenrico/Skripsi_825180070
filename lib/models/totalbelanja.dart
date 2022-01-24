class TotalBelanja {
  final String prodPrice;
  final String qty;

  TotalBelanja({
    required this.prodPrice,
    required this.qty,
  });

  factory TotalBelanja.fromJson(Map<String, dynamic> json) {
    return TotalBelanja(
      prodPrice: json['prod_price'],
      qty: json['qty'],
    );
  }
}
