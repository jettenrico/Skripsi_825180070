import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:harusnyabisa/constants.dart';
import 'package:harusnyabisa/models/absensi.dart';
import 'package:harusnyabisa/models/order.dart';
import 'package:harusnyabisa/models/product.dart';
import 'package:harusnyabisa/screens/restock.dart';
import 'package:harusnyabisa/screens/statusbelanja.dart';
import 'package:harusnyabisa/utility/repository.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<ProductList> listProduct = [];
List<ProductList> _searchProduct = [];
List<ProductList> listTerlaris = [];
List<AbsensiSales> listAbsen = [];
List<TransactionLog> listTransaksi = [];
Url listurl = Url();

class ReportPrinciple extends StatefulWidget {
  const ReportPrinciple({Key? key}) : super(key: key);

  @override
  _ReportPrincipleState createState() => _ReportPrincipleState();
}

class _ReportPrincipleState extends State<ReportPrinciple> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(children: [
            MaterialButton(
              onPressed: () async {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => StockProduct()));
              },
              height: 30,
              minWidth: 300,
              color: Colors.white70,
              child: Text(
                "Report Stock",
                style: TextStyle(
                    color: kTextColor,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold),
              ),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            MaterialButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ReportPenjualan()));
              },
              height: 30,
              minWidth: 300,
              color: Colors.white70,
              child: Text(
                "Report Transaksi",
                style: TextStyle(
                    color: kTextColor,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold),
              ),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            MaterialButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ReportAbsen()));
              },
              height: 30,
              minWidth: 300,
              color: Colors.white70,
              child: Text(
                "Report Absensi",
                style: TextStyle(
                    color: kTextColor,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold),
              ),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            MaterialButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ProdukTerlaris()));
              },
              height: 30,
              minWidth: 300,
              color: Colors.white70,
              child: Text(
                "10 Produk Terlaris",
                style: TextStyle(
                    color: kTextColor,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold),
              ),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class StockProduct extends StatefulWidget {
  const StockProduct({Key? key}) : super(key: key);

  @override
  _StockProductState createState() => _StockProductState();
}

class _StockProductState extends State<StockProduct> {
  TextEditingController controller = new TextEditingController();

  Future<Null> fetchData() async {
    listProduct.clear();
    final response = await http.get(Uri.parse(Url().url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        for (Map<String, dynamic> i in data) {
          listProduct.add(ProductList.fromJson(i));
        }
      });
    }
  }

  onSearch(String text) async {
    _searchProduct.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    listProduct.forEach((f) {
      if (f.prodName.toLowerCase().contains(text) ||
          f.prodCategory.toLowerCase().contains(text)) _searchProduct.add(f);
    });

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Report Stock", style: TextStyle(color: kTextColor)),
        iconTheme: IconThemeData(color: kTextColor),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(10.0),
            child: Card(
              child: TextFormField(
                enableInteractiveSelection: false,
                controller: controller,
                onChanged: onSearch,
                decoration: InputDecoration(
                  hintText: "Cari Produk",
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.black54,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      controller.clear();
                      onSearch('');
                    },
                    icon: Icon(
                      Icons.cancel,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: kDefaultPaddin),
            child: _searchProduct.length != 0 || controller.text.isNotEmpty
                ? GridView.builder(
                    itemCount: _searchProduct.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        mainAxisSpacing: kDefaultPaddin,
                        crossAxisSpacing: kDefaultPaddin),
                    itemBuilder: (context, index) {
                      final b = _searchProduct[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 160,
                            width: 180,
                            padding: EdgeInsets.only(
                                left: kDefaultPaddin / 4,
                                right: kDefaultPaddin / 4),
                            decoration: BoxDecoration(
                                color: HexColor(b.bgColor),
                                borderRadius: BorderRadius.circular(16)),
                            child: Hero(
                              tag: b.prodName,
                              child: Image.network(
                                listurl.fotoproduk + b.prodImage,
                                fit: BoxFit.contain,
                                scale: 2.55,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: kDefaultPaddin / 4),
                            child: Text(
                              StringUtils.capitalize(b.prodName,
                                  allWords: true),
                              style: TextStyle(
                                  color: kTextLightColor, fontSize: 13),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Rp " +
                                  "${b.prodPrice.replaceAll(',', '.')}"),
                              Text("Sisa : " + "${b.stock}")
                            ],
                          ),
                        ],
                      );
                    })
                : GridView.builder(
                    itemCount: listProduct.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        mainAxisSpacing: kDefaultPaddin,
                        crossAxisSpacing: kDefaultPaddin),
                    itemBuilder: (context, index) {
                      final a = listProduct[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 160,
                            width: 180,
                            padding: EdgeInsets.only(
                                left: kDefaultPaddin / 4,
                                right: kDefaultPaddin / 4),
                            decoration: BoxDecoration(
                                color: HexColor("${a.bgColor}"),
                                borderRadius: BorderRadius.circular(16)),
                            child: Hero(
                              tag: "${a.prodName}",
                              child: Image.network(
                                listurl.fotoproduk + "${a.prodImage}",
                                fit: BoxFit.contain,
                                scale: 2.55,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: kDefaultPaddin / 4),
                            child: Text(
                              StringUtils.capitalize(a.prodName,
                                  allWords: true),
                              style: TextStyle(
                                  color: kTextLightColor, fontSize: 13),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Rp " +
                                  "${a.prodPrice.replaceAll(',', '.')}"),
                              Text("Sisa : " + "${a.stock}")
                            ],
                          ),
                        ],
                      );
                    }),
          ))
        ],
      ),
    );
  }
}

class ReportAbsen extends StatefulWidget {
  const ReportAbsen({Key? key}) : super(key: key);

  @override
  _ReportAbsenState createState() => _ReportAbsenState();
}

class _ReportAbsenState extends State<ReportAbsen> {
  var bulan = "", tahun = "";
  bool _load = false;

  getMetode() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('bulan', bulan);
    preferences.setString('tahun', tahun);
  }

  getAbsen() async {
    try {
      final response = await http.post(Uri.parse(listurl.absensi), body: {
        "bulan": bulan,
        "tahun": tahun,
      });

      if (response.statusCode == 200) {
        Iterable it = jsonDecode(response.body);
        List<AbsensiSales> product =
            it.map((e) => AbsensiSales.fromJson(e)).toList();
        return product;
      }
    } catch (e) {
      print(e.toString());
    }
  }

  getDataAbsen() async {
    try {
      listAbsen = await getAbsen();
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: Text("Report Absensi", style: TextStyle(color: kTextColor)),
          iconTheme: IconThemeData(color: kTextColor),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: kDefaultPaddin),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      DropdownButton<String>(
                        items: [
                          DropdownMenuItem<String>(
                              value: "Januari", child: Text("Januari")),
                          DropdownMenuItem<String>(
                              value: "Februari", child: Text("Februari")),
                          DropdownMenuItem<String>(
                              value: "Maret", child: Text("Maret")),
                          DropdownMenuItem<String>(
                              value: "April", child: Text("April")),
                          DropdownMenuItem<String>(
                              value: "Mei", child: Text("Mei")),
                          DropdownMenuItem<String>(
                              value: "Juni", child: Text("Juni")),
                          DropdownMenuItem<String>(
                              value: "Juli", child: Text("Juli")),
                          DropdownMenuItem<String>(
                              value: "Agustus", child: Text("Agustus")),
                          DropdownMenuItem<String>(
                              value: "September", child: Text("September")),
                          DropdownMenuItem<String>(
                              value: "Oktober", child: Text("Oktober")),
                          DropdownMenuItem<String>(
                              value: "November", child: Text("November")),
                          DropdownMenuItem<String>(
                              value: "Desember", child: Text("Desember")),
                        ],
                        onChanged: (_value) => {
                          print(_value.toString()),
                          setState(() {
                            bulan = _value!;
                            getMetode();
                            _load = false;
                          })
                        },
                        hint: bulan == "" ? Text("Bulan") : Text(bulan),
                      ),
                      DropdownButton<String>(
                        items: [
                          DropdownMenuItem<String>(
                              value: "2021", child: Text("2021")),
                          DropdownMenuItem<String>(
                              value: "2022", child: Text("2022")),
                          DropdownMenuItem<String>(
                              value: "2023", child: Text("2023")),
                          DropdownMenuItem<String>(
                              value: "2024", child: Text("2024")),
                          DropdownMenuItem<String>(
                              value: "2025", child: Text("2025")),
                        ],
                        onChanged: (_value) => {
                          print(_value.toString()),
                          setState(() {
                            tahun = _value!;
                            getMetode();
                            _load = false;
                          })
                        },
                        hint: tahun == "" ? Text("Tahun") : Text(tahun),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: kDefaultPaddin / 2),
              child: Center(
                child: MaterialButton(
                  onPressed: () async {
                    if (bulan == "") {
                      Fluttertoast.showToast(msg: "Pilih Bulan Dahulu!");
                    } else if (tahun == "") {
                      Fluttertoast.showToast(msg: "Pilih Tahun Dahulu!");
                    } else {
                      await getDataAbsen();
                      _load = true;
                    }
                  },
                  height: 45,
                  color: Colors.black,
                  child: Text(
                    "Lihat Laporan",
                    style: TextStyle(color: Colors.white, fontSize: 16.0),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            ),
            listAbsen.isEmpty
                ? Visibility(visible: _load, child: absenKosong())
                : absen()
          ],
        ));
  }

  Widget absenKosong() {
    return FutureBuilder(
      future: Future.delayed(Duration(seconds: 1)),
      builder: (c, s) => s.connectionState == ConnectionState.done
          ? listAbsen.isEmpty
              ? Expanded(
                  child: new Container(
                    color: Colors.white,
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: Center(
                            child: Container(
                                padding:
                                    EdgeInsets.only(left: 25.0, right: 25.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Tidak ada Daftar Absen',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ],
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Center(
                  child: CircularProgressIndicator(),
                )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Widget absen() {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: () => getDataAbsen(),
        child: ListView.builder(
            itemCount: listAbsen.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () async {
                  await showDialog(
                      context: context,
                      builder: (_) => Dialog(
                            child: Container(
                              width: 350,
                              height: 350,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: Image.network(listurl.fotoabsen +
                                              "${listAbsen[index].filephoto}")
                                          .image,
                                      fit: BoxFit.cover)),
                            ),
                          ));
                },
                child: Card(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text("${listAbsen[index].namaUser}"),
                        subtitle: Text("${listAbsen[index].tanggalabsen}"),
                        leading: CircleAvatar(
                            backgroundImage: Image.network(listurl.fotoabsen +
                                    "${listAbsen[index].filephoto}")
                                .image,
                            backgroundColor: Colors.transparent),
                        trailing: Text("${listAbsen[index].jam}"),
                      ),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }
}

class ReportPenjualan extends StatefulWidget {
  const ReportPenjualan({Key? key}) : super(key: key);

  @override
  ReportPenjualanState createState() => ReportPenjualanState();
}

class ReportPenjualanState extends State<ReportPenjualan> {
  var tipetrans = "", bulan = "", tahun = "";
  int _subTotal = 0, totaltrans = 0;
  bool _load = false;

  getMetode() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('bulan', bulan);
    preferences.setString('tahun', tahun);
    preferences.setString('tipetransaksi', tipetrans);
  }

  repositoryPenjualan() async {
    try {
      final response = await http.post(Uri.parse(listurl.penjualan), body: {
        "bulan": bulan,
        "tahun": tahun,
        "tipetrans": tipetrans,
      });

      if (response.statusCode == 200) {
        Iterable it = jsonDecode(response.body);
        List<TransactionLog> order =
            it.map((e) => TransactionLog.fromJson(e)).toList();
        return order;
      }
    } catch (e) {
      print(e.toString());
    }
  }

  getDataPenjualan() async {
    try {
      listTransaksi = await repositoryPenjualan();
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      print(e);
    }
    int subtotal = 0, trans = 0;

    for (int i = 0; i < listTransaksi.length; i++) {
      if (listTransaksi[i].value.trim() != "0") {
        subtotal += int.parse(listTransaksi[i].value.replaceAll(',', ''));
        trans = i;
      }
    }
    if (!mounted) return;
    setState(() {
      _subTotal = subtotal;
      totaltrans = trans + 1;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Report Transaksi", style: TextStyle(color: kTextColor)),
        iconTheme: IconThemeData(color: kTextColor),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: kDefaultPaddin),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    DropdownButton<String>(
                      items: [
                        DropdownMenuItem<String>(
                            value: "Januari", child: Text("Januari")),
                        DropdownMenuItem<String>(
                            value: "Februari", child: Text("Februari")),
                        DropdownMenuItem<String>(
                            value: "Maret", child: Text("Maret")),
                        DropdownMenuItem<String>(
                            value: "April", child: Text("April")),
                        DropdownMenuItem<String>(
                            value: "Mei", child: Text("Mei")),
                        DropdownMenuItem<String>(
                            value: "Juni", child: Text("Juni")),
                        DropdownMenuItem<String>(
                            value: "Juli", child: Text("Juli")),
                        DropdownMenuItem<String>(
                            value: "Agustus", child: Text("Agustus")),
                        DropdownMenuItem<String>(
                            value: "September", child: Text("September")),
                        DropdownMenuItem<String>(
                            value: "Oktober", child: Text("Oktober")),
                        DropdownMenuItem<String>(
                            value: "November", child: Text("November")),
                        DropdownMenuItem<String>(
                            value: "Desember", child: Text("Desember")),
                      ],
                      onChanged: (_value) => {
                        print(_value.toString()),
                        setState(() {
                          bulan = _value!;
                          getMetode();
                          _load = false;
                        })
                      },
                      hint: bulan == "" ? Text("Bulan") : Text(bulan),
                    ),
                    DropdownButton<String>(
                      items: [
                        DropdownMenuItem<String>(
                            value: "2021", child: Text("2021")),
                        DropdownMenuItem<String>(
                            value: "2022", child: Text("2022")),
                        DropdownMenuItem<String>(
                            value: "2023", child: Text("2023")),
                        DropdownMenuItem<String>(
                            value: "2024", child: Text("2024")),
                        DropdownMenuItem<String>(
                            value: "2025", child: Text("2025")),
                      ],
                      onChanged: (_value) => {
                        print(_value.toString()),
                        setState(() {
                          tahun = _value!;
                          getMetode();
                          _load = false;
                        })
                      },
                      hint: tahun == "" ? Text("Tahun") : Text(tahun),
                    ),
                    DropdownButton<String>(
                      items: [
                        DropdownMenuItem<String>(
                            value: "Purchase Order",
                            child: Text("Purchase Order")),
                        DropdownMenuItem<String>(
                            value: "Sales Order", child: Text("Sales Order")),
                      ],
                      onChanged: (_value) => {
                        print(_value.toString()),
                        setState(() {
                          tipetrans = _value!;
                          getMetode();
                          _load = false;
                        })
                      },
                      hint: tipetrans == ""
                          ? Text("Tipe Transaksi")
                          : Text(tipetrans),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: kDefaultPaddin / 2),
            child: Center(
              child: MaterialButton(
                onPressed: () async {
                  if (bulan == "") {
                    Fluttertoast.showToast(msg: "Pilih Bulan Dahulu!");
                  } else if (tahun == "") {
                    Fluttertoast.showToast(msg: "Pilih Tahun Dahulu!");
                  } else if (tipetrans == "") {
                    Fluttertoast.showToast(msg: "Pilih Tipe Transaksi Dahulu!");
                  } else {
                    await getDataPenjualan();
                    setState(() {
                      _load = true;
                    });
                  }
                },
                height: 45,
                color: Colors.black,
                child: Text(
                  "Lihat Laporan",
                  style: TextStyle(color: Colors.white, fontSize: 16.0),
                ),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          listTransaksi.isEmpty
              ? Visibility(visible: _load, child: orderKosong())
              : order(),
          listTransaksi.isEmpty
              ? Container()
              : Visibility(
                  visible: _load,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: kDefaultPaddin, horizontal: kDefaultPaddin),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Value : ",
                              style: TextStyle(color: kTextColor, fontSize: 18),
                            ),
                            Text(
                              "Rp. " +
                                  NumberFormat.currency(
                                          locale: 'ID',
                                          symbol: "",
                                          decimalDigits: 0)
                                      .format(_subTotal),
                              style: TextStyle(color: Colors.red, fontSize: 18),
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Total Transaksi : ",
                              style: TextStyle(color: kTextColor, fontSize: 18),
                            ),
                            Text(
                              totaltrans.toString(),
                              style: TextStyle(color: Colors.red, fontSize: 18),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget orderKosong() {
    return FutureBuilder(
      future: Future.delayed(Duration(seconds: 1)),
      builder: (c, s) => s.connectionState == ConnectionState.done
          ? listTransaksi.isEmpty
              ? Expanded(
                  child: new Container(
                    color: Colors.white,
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: Center(
                            child: Container(
                                padding:
                                    EdgeInsets.only(left: 25.0, right: 25.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Tidak ada Daftar Transaksi',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ],
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Center(
                  child: CircularProgressIndicator(),
                )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Widget order() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kDefaultPaddin),
        child: RefreshIndicator(
          onRefresh: () => getDataPenjualan(),
          child: ListView.separated(
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    listTransaksi[index].tipeTrans == 'Penjualan'
                        ? Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => DetailBelanja(
                                  order: listTransaksi[index]
                                      .purchaseNumber, // kalo penjualan
                                )))
                        : Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => DetailPemesanan(
                                  order: listTransaksi[index].purchaseNumber,
                                )));
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: kDefaultPaddin / 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 350,
                          height: 65,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "${listTransaksi[index].transNumber}" +
                                            " (" +
                                            "${listTransaksi[index].tipeTrans}" +
                                            ")",
                                        style: TextStyle(
                                            color: kTextColor,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      listTransaksi[index].tipeTrans ==
                                              "Pemesanan"
                                          ? Text(
                                              "Sales : " +
                                                  "${listTransaksi[index].sales}",
                                              style: TextStyle(
                                                  color: kTextColor,
                                                  fontWeight: FontWeight.w700),
                                            )
                                          : Text(
                                              "Customer : " +
                                                  "${listTransaksi[index].customer}",
                                              style: TextStyle(
                                                  color: kTextColor,
                                                  fontWeight: FontWeight.w700)),
                                      Text(
                                        "Rp. " +
                                            NumberFormat.currency(
                                                    locale: 'ID',
                                                    symbol: "",
                                                    decimalDigits: 0)
                                                .format(int.parse(
                                                    "${listTransaksi[index].value}")),
                                        style: TextStyle(
                                            color: Colors.red, fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Text(
                                "${listTransaksi[index].tglTransaksi}",
                                style: TextStyle(
                                    color: kTextLightColor, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return Divider(
                  thickness: 2,
                );
              },
              itemCount: listTransaksi.length),
        ),
      ),
    );
  }
}

class ProdukTerlaris extends StatefulWidget {
  const ProdukTerlaris({Key? key}) : super(key: key);

  @override
  _ProdukTerlarisState createState() => _ProdukTerlarisState();
}

class _ProdukTerlarisState extends State<ProdukTerlaris> {
  Future<Null> fetchData() async {
    final response = await http.get(Uri.parse(Url().terlaris));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        for (Map<String, dynamic> i in data) {
          listTerlaris.add(ProductList.fromJson(i));
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("10 Produk Terlaris", style: TextStyle(color: kTextColor)),
        iconTheme: IconThemeData(color: kTextColor),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: kDefaultPaddin),
              child: GridView.builder(
                  itemCount: listTerlaris.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      mainAxisSpacing: kDefaultPaddin,
                      crossAxisSpacing: kDefaultPaddin),
                  itemBuilder: (context, index) {
                    final a = listTerlaris[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 160,
                          width: 180,
                          padding: EdgeInsets.only(
                              left: kDefaultPaddin / 4,
                              right: kDefaultPaddin / 4),
                          decoration: BoxDecoration(
                              color: HexColor("${a.bgColor}"),
                              borderRadius: BorderRadius.circular(16)),
                          child: Hero(
                            tag: "${a.prodName}",
                            child: Image.network(
                              listurl.fotoproduk + "${a.prodImage}",
                              fit: BoxFit.contain,
                              scale: 2.55,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: kDefaultPaddin / 4),
                          child: Text(
                            StringUtils.capitalize(a.prodName, allWords: true),
                            style:
                                TextStyle(color: kTextLightColor, fontSize: 13),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Rp " + "${a.prodPrice.replaceAll(',', '.')}"),
                            Text("Terjual : " + "${a.terjual}")
                          ],
                        ),
                      ],
                    );
                  }),
            ),
          )
        ],
      ),
    );
  }
}
