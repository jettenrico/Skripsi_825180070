import 'dart:convert';

import 'package:harusnyabisa/models/product.dart';
import 'package:http/http.dart' as http;

// final ip = 'http://192.168.0.100';
final ip = 'http://178.1.77.123';
// final ip = 'http://192.168.137.245';
// final ip = 'https://cerise-recruiters.000webhostapp.com';
// final ip = 'http://10.10.51.121';

class ProdTerlaris {
  Future getProduct() async {
    try {
      final response = await http.get(Uri.parse(Url().terlaris));

      if (response.statusCode == 200) {
        Iterable it = jsonDecode(response.body);
        List<ProductList> product =
            it.map((e) => ProductList.fromJson(e)).toList();
        return product;
      }
    } catch (e) {
      print(e.toString());
    }
  }
}

class Url {
  final url = '$ip' + '/skripsi/products.php';
  final isikeranjang = '$ip' + '/skripsi/showkeranjang.php';
  final fotoproduk = '$ip' + '/skripsi/fotoproduk/';
  final deleteproduk = '$ip' + '/skripsi/deletekeranjang.php';
  final tambahproduk = '$ip' + '/skripsi/tambahkeranjang.php';
  final ceklogin = '$ip' + '/skripsi/login.php';
  final absen = '$ip' + '/skripsi/absensi.php';
  final checkout = '$ip' + '/skripsi/checkout.php';
  final showorder = '$ip' + '/skripsi/showorder.php';
  final metode = '$ip' + '/skripsi/metodeorder.php';
  final total = '$ip' + '/skripsi/totalbelanja.php';
  final uploadbayar = '$ip' + '/skripsi/uploadpembayaran.php';
  final detailorder = '$ip' + '/skripsi/detailorder.php';
  final register = '$ip' + '/skripsi/register.php';
  final editprofil = '$ip' + '/skripsi/updateprofil.php';
  final orderba = '$ip' + '/skripsi/orderba.php';
  final cancelorder = '$ip' + '/skripsi/cancelorder.php';
  final prosesorder = '$ip' + '/skripsi/prosesorder.php';
  final terimaorder = '$ip' + '/skripsi/terimaorder.php';
  final productpurchase = '$ip' + '/skripsi/productpurchase.php';
  final pemesananproduct = '$ip' + '/skripsi/pemesananproduct.php';
  final deleteprodukba = '$ip' + '/skripsi/deletepemesanan.php';
  final purchaselog = '$ip' + '/skripsi/purchaselog.php';
  final penerimaanbarang = '$ip' + '/skripsi/penerimaanbarang.php';
  final listpesanan = '$ip' + '/skripsi/penerimaanbarang.php';
  final pesanansales = '$ip' + '/skripsi/pesanansales.php';
  final detailpesanan = '$ip' + '/skripsi/listpemesanan.php';
  final terlaris = '$ip' + '/skripsi/productterlaris.php';
  final review = '$ip' + '/skripsi/reviewproduk.php';
  final showreview = '$ip' + '/skripsi/showreview.php';
  final lupapass = '$ip' + '/skripsi/resetpassword.php';
  final fotoabsen = '$ip' + '/skripsi/fotoabsen/';
  final absensi = '$ip' + '/skripsi/reportabsensi.php';
  final penjualan = '$ip' + '/skripsi/reportpenjualan.php';
  final setalamat = '$ip' + '/skripsi/setalamat.php';
}
