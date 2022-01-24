class KeranjangList {
  final String prodName;
  final String prodNumber;
  final String prodPrice;
  final String qty;
  final String imgurl;

  KeranjangList({
    required this.prodName,
    required this.prodNumber,
    required this.prodPrice,
    required this.qty,
    required this.imgurl,
  });

  factory KeranjangList.fromJson(Map<String, dynamic> json) {
    return KeranjangList(
      prodName: json['prod_name'],
      prodNumber: json['prod_number'],
      prodPrice: json['prod_price'],
      qty: json['qty'],
      imgurl: json['image'],
    );
  }
}

class PemesananBA {
  final String prodName;
  final String prodNumber;
  final String prodPrice;
  final String qty;
  final String imgurl;

  PemesananBA({
    required this.prodName,
    required this.prodNumber,
    required this.prodPrice,
    required this.qty,
    required this.imgurl,
  });

  factory PemesananBA.fromJson(Map<String, dynamic> json) {
    return PemesananBA(
      prodName: json['prod_name'],
      prodNumber: json['prod_number'],
      prodPrice: json['prod_request_base_price'],
      qty: json['prod_request_quantity'],
      imgurl: json['image'],
    );
  }
}
