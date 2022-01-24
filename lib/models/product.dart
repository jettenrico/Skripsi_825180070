class ProductList {
  final String prodName;
  final String prodNumber;
  final String prodPrice;
  final String prodImage;
  final String bgColor;
  final String prodCategory;
  final String stock;
  final String terjual;

  ProductList({
    required this.prodName,
    required this.prodNumber,
    required this.prodPrice,
    required this.prodImage,
    required this.bgColor,
    required this.prodCategory,
    required this.stock,
    required this.terjual,
  });

  factory ProductList.fromJson(Map<String, dynamic> json) {
    return ProductList(
      prodName: json['prod_name'],
      prodNumber: json['prod_number'],
      prodPrice: json['prod_base_price'],
      prodImage: json['image'],
      bgColor: json['color'],
      prodCategory: json['brand_name'],
      stock: json['stock'],
      terjual: json['terjual'],
    );
  }
}

class ReviewProduk {
  final String namaUser;
  final String reviewUser;
  final String tanggaltransaksi;

  ReviewProduk({
    required this.namaUser,
    required this.reviewUser,
    required this.tanggaltransaksi,
  });

  factory ReviewProduk.fromJson(Map<String, dynamic> json) {
    return ReviewProduk(
      namaUser: json['user_fullname'],
      reviewUser: json['review'],
      tanggaltransaksi: json['order_date'],
    );
  }
}
