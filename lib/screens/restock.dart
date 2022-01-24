import 'dart:async';
import 'dart:convert';

import 'package:basic_utils/basic_utils.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:harusnyabisa/constants.dart';
import 'package:harusnyabisa/models/keranjang.dart';
import 'package:harusnyabisa/models/order.dart';
import 'package:harusnyabisa/screens/explore.dart';
import 'package:harusnyabisa/utility/repository.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

Url listurl = Url();
List<PemesananBA> listKeranjang = [];
List<PenerimaanOrder> listOrder = [];

class RestockPage extends StatefulWidget {
  const RestockPage({Key? key}) : super(key: key);

  @override
  _RestockPageState createState() => _RestockPageState();
}

class _RestockPageState extends State<RestockPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(children: [
            MaterialButton(
              onPressed: () async {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => PemesananProduct()));
              },
              height: 30,
              minWidth: 300,
              color: Colors.white70,
              child: Text(
                "Pemesanan Produk",
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
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => PenerimaanProduk()));
              },
              height: 30,
              minWidth: 300,
              color: Colors.white70,
              child: Text(
                "Penerimaan Produk",
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

class PemesananProduk extends StatefulWidget {
  const PemesananProduk({Key? key}) : super(key: key);

  @override
  _PemesananProdukState createState() => _PemesananProdukState();
}

class _PemesananProdukState extends State<PemesananProduk> {
  var userNumber = "";
  int _subTotal = 0;

  getUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      userNumber = preferences.getString('usernumber')!;
    });
  }

  deleteKeranjang(String productNumber) async {
    try {
      final response =
          await http.post(Uri.parse(listurl.deleteprodukba), body: {
        "user_number": userNumber,
        "prod_number": productNumber,
      });

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        var value = data['value'];
        var message = data['message'];
        if (value == 0) {
          print(message);
        } else {
          print(message);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  prosesPesanan() async {
    try {
      final response = await http.post(Uri.parse(listurl.purchaselog), body: {
        "user_number": userNumber,
      });

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        var value = data['value'];
        var message = data['message'];
        if (!mounted) return;
        setState(() {});
        if (value == 0) {
          print(message);
        } else {
          print(message);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  repositoryKeranjang() async {
    try {
      final response =
          await http.post(Uri.parse(listurl.pemesananproduct), body: {
        "user_number": userNumber,
      });

      if (response.statusCode == 200) {
        Iterable it = jsonDecode(response.body);
        List<PemesananBA> product =
            it.map((e) => PemesananBA.fromJson(e)).toList();
        return product;
      }
    } catch (e) {
      print(e.toString());
    }
  }

  getDataKeranjang() async {
    try {
      listKeranjang = await repositoryKeranjang();
    } catch (e) {
      print(e);
    }

    int subtotal = 0;

    for (int i = 0; i < listKeranjang.length; i++) {
      if (listKeranjang[i].prodPrice.trim() != "0") {
        subtotal += (int.parse(listKeranjang[i].qty) *
            int.parse(listKeranjang[i].prodPrice.replaceAll(',', '')));
      }
    }
    if (!mounted) return;
    setState(() {
      _subTotal = subtotal;
    });
  }

  refresh() {
    return Future.delayed(Duration(milliseconds: 1000), () {
      if (!mounted) return;
      setState(() {
        Navigator.of(context).pop();
      });
    });
  }

  onRefresh() {
    return Future.delayed(Duration(milliseconds: 100), () {
      if (!mounted) return;
      setState(() {
        getDataKeranjang();
      });
    });
  }

  @override
  void initState() {
    getUser();
    super.initState();
    Timer(Duration(milliseconds: 500), () {
      getDataKeranjang();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Keranjang", style: TextStyle(color: kTextColor)),
          iconTheme: IconThemeData(color: kTextColor),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: listKeranjang.isEmpty ? _keranjangKosong() : _widgetKeranjang());
  }

  Widget _keranjangKosong() {
    return FutureBuilder(
      future: Future.delayed(Duration(seconds: 1)),
      builder: (c, s) => s.connectionState == ConnectionState.done
          ? listKeranjang.isEmpty
              ? SafeArea(
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
                                      'Keranjang Kosong',
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

  Widget _widgetKeranjang() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: ListView.separated(
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: kDefaultPaddin / 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        child: Image.network(
                          listurl.fotoproduk + "${listKeranjang[index].imgurl}",
                          width: 80,
                          height: 80,
                          fit: BoxFit.fill,
                        ),
                      ),
                      Container(
                        width: 250,
                        height: 80,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              StringUtils.capitalize(
                                  "${listKeranjang[index].prodName}",
                                  allWords: true),
                              style: TextStyle(
                                  color: kTextLightColor, fontSize: 13),
                            ),
                            Text("Rp " +
                                "${listKeranjang[index].prodPrice.replaceAll(',', '.')}"),
                            Text("Jumlah : " + "${listKeranjang[index].qty}")
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          deleteKeranjang(listKeranjang[index].prodNumber);
                          onRefresh();
                        },
                        icon: Icon(Icons.highlight_remove_sharp),
                      )
                    ],
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return Divider(
                  thickness: 2,
                );
              },
              itemCount: listKeranjang.length),
        ),
        Padding(
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
                    "Total : ",
                    style: TextStyle(color: kTextColor, fontSize: 18),
                  ),
                  Text(
                    "Rp. " +
                        NumberFormat.currency(
                                locale: 'ID', symbol: "", decimalDigits: 0)
                            .format(_subTotal),
                    style: TextStyle(color: Colors.red, fontSize: 18),
                  ),
                ],
              ),
              MaterialButton(
                onPressed: () async {
                  CoolAlert.show(
                      context: context,
                      type: CoolAlertType.success,
                      title: 'Pemesanan Berhasil!',
                      text: 'Lihat Order Di Penerimaan Produk',
                      confirmBtnText: 'OK',
                      onConfirmBtnTap: () => Navigator.of(context)
                        ..pop()
                        ..pop());
                  prosesPesanan();
                },
                height: 45,
                color: Colors.black,
                child: Text(
                  "Proses",
                  style: TextStyle(color: Colors.white, fontSize: 16.0),
                ),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PenerimaanProduk extends StatefulWidget {
  const PenerimaanProduk({Key? key}) : super(key: key);

  @override
  _PenerimaanProdukState createState() => _PenerimaanProdukState();
}

class _PenerimaanProdukState extends State<PenerimaanProduk> {
  var userNumber = "";

  getUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      userNumber = preferences.getString('usernumber')!;
    });
  }

  repositoryOrderBA() async {
    try {
      final response =
          await http.post(Uri.parse(listurl.penerimaanbarang), body: {
        "user_number": userNumber,
      });

      if (response.statusCode == 200) {
        Iterable it = jsonDecode(response.body);
        List<PenerimaanOrder> order =
            it.map((e) => PenerimaanOrder.fromJson(e)).toList();
        return order;
      }
    } catch (e) {
      print(e.toString());
    }
  }

  getDataOrderBA() async {
    try {
      listOrder = await repositoryOrderBA();
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    getUser();
    Timer(Duration(milliseconds: 200), () {
      getDataOrderBA();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Penerimaan Produk", style: TextStyle(color: kTextColor)),
        iconTheme: IconThemeData(color: kTextColor),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [listOrder.isEmpty ? orderKosong() : orderBA()],
      ),
    );
  }

  Widget orderKosong() {
    return FutureBuilder(
      future: Future.delayed(Duration(seconds: 1)),
      builder: (c, s) => s.connectionState == ConnectionState.done
          ? listOrder.isEmpty
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
                                      'Tidak ada Daftar Order',
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

  Widget orderBA() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kDefaultPaddin),
        child: RefreshIndicator(
          onRefresh: () => getDataOrderBA(),
          child: ListView.separated(
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    listOrder[index].status == "2"
                        ? Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ProsesTerima(
                                  order: listOrder[index].orderNumber,
                                )))
                        : listOrder[index].status == "3"
                            ? Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => DetailPemesanan(
                                      order: listOrder[index].orderNumber,
                                    )))
                            : Text("ERROR");
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: kDefaultPaddin / 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 350,
                          height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "${listOrder[index].orderNumber}",
                                    style: TextStyle(
                                        color: kTextColor, fontSize: 16),
                                  ),
                                  Text(
                                    "${listOrder[index].tglTransaksi}",
                                    style: TextStyle(
                                        color: kTextLightColor, fontSize: 14),
                                  )
                                ],
                              ),
                              listOrder[index].status == "2"
                                  ? Text(
                                      "Proses Terima",
                                      style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold),
                                    )
                                  : listOrder[index].status == "3"
                                      ? Text(
                                          'Pesanan Telah Diterima',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        )
                                      : Text("Error!")
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
              itemCount: listOrder.length),
        ),
      ),
    );
  }
}

class ProsesTerima extends StatefulWidget {
  const ProsesTerima({Key? key, required this.order}) : super(key: key);
  final String order;

  @override
  _ProsesTerimaState createState() => _ProsesTerimaState();
}

class _ProsesTerimaState extends State<ProsesTerima> {
  var userNumber = "";
  int _subTotal = 0;
  TextEditingController suratjalan = new TextEditingController();

  repositoryDetOrder() async {
    try {
      final response = await http.post(Uri.parse(listurl.detailpesanan),
          body: {"purchase_number": widget.order});

      if (response.statusCode == 200) {
        Iterable it = jsonDecode(response.body);
        List<PemesananBA> product =
            it.map((e) => PemesananBA.fromJson(e)).toList();
        return product;
      }
    } catch (e) {
      print(e.toString());
    }
  }

  getDetOrder() async {
    try {
      listKeranjang = await repositoryDetOrder();
    } catch (e) {
      print(e);
    }

    int subtotal = 0;

    for (int i = 0; i < listKeranjang.length; i++) {
      if (listKeranjang[i].prodPrice.trim() != "0") {
        subtotal += (int.parse(listKeranjang[i].qty) *
            int.parse(listKeranjang[i].prodPrice.replaceAll(',', '')));
      }
    }
    if (!mounted) return;
    setState(() {
      _subTotal = subtotal;
    });
  }

  terimaFaktur() async {
    try {
      final response = await http.post(Uri.parse(listurl.pesanansales), body: {
        "order_number": widget.order,
        "suratjalan": suratjalan.text,
      });

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        var value = data['value'];
        var message = data['message'];
        if (!mounted) return;
        setState(() {});
        if (value == 0) {
          print(message);
        } else {
          Fluttertoast.showToast(msg: message);
          Future.delayed(new Duration(milliseconds: 1500), () {
            Navigator.of(context).pop();
          });
          print(message);
        }
      }
    } catch (e) {
      CoolAlert.show(
          context: context,
          type: CoolAlertType.success,
          title: 'Berhasil!',
          text: 'Produk Berhasil Diterima',
          confirmBtnText: 'OK',
          onConfirmBtnTap: () => Navigator.of(context)
            ..pop()
            ..pop());
    }
  }

  @override
  void initState() {
    Timer(Duration(milliseconds: 200), () {
      getDetOrder();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detail Order", style: TextStyle(color: kTextColor)),
        iconTheme: IconThemeData(color: kTextColor),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: ListView.separated(
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: kDefaultPaddin / 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          child: Image.network(
                            listurl.fotoproduk +
                                "${listKeranjang[index].imgurl}",
                            width: 80,
                            height: 80,
                            fit: BoxFit.fill,
                          ),
                        ),
                        Container(
                          width: 230,
                          height: 80,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                StringUtils.capitalize(
                                    "${listKeranjang[index].prodName}",
                                    allWords: true),
                                style: TextStyle(
                                    color: kTextLightColor, fontSize: 13),
                              ),
                              Text("Rp " +
                                  "${listKeranjang[index].prodPrice.replaceAll(',', '.')}"),
                            ],
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(right: kDefaultPaddin / 2),
                          child: Text(
                            "${listKeranjang[index].qty} X",
                            style: TextStyle(
                                fontSize: 16,
                                color: kTextColor,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return Divider(
                    thickness: 2,
                  );
                },
                itemCount: listKeranjang.length),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                vertical: kDefaultPaddin / 2, horizontal: kDefaultPaddin),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Total : ",
                          style: TextStyle(
                              color: kTextColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
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
                        SizedBox(
                          height: 5,
                        )
                      ],
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: kDefaultPaddin / 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: TextFormField(
                          maxLength: 8,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          ],
                          decoration: InputDecoration(
                              counterText: "",
                              labelText: "Nomor Surat Jalan",
                              labelStyle: TextStyle(color: Colors.black54),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                                borderRadius: BorderRadius.circular(8),
                              )),
                          controller: suratjalan,
                        ),
                        width: 180,
                        height: 50,
                      ),
                      MaterialButton(
                        onPressed: () async {
                          suratjalan.text.length > 4
                              ? terimaFaktur()
                              : Fluttertoast.showToast(msg: 'Isi Surat Jalan!');
                        },
                        height: 45,
                        color: Colors.green,
                        child: Text(
                          "Proses",
                          style: TextStyle(color: Colors.white, fontSize: 16.0),
                        ),
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class DetailPemesanan extends StatefulWidget {
  const DetailPemesanan({Key? key, required this.order}) : super(key: key);
  final String order;

  @override
  _DetailPemesananState createState() => _DetailPemesananState();
}

class _DetailPemesananState extends State<DetailPemesanan> {
  var userNumber = "";
  int _subTotal = 0;

  repositoryDetOrder() async {
    try {
      final response = await http.post(Uri.parse(listurl.detailpesanan),
          body: {"purchase_number": widget.order});

      if (response.statusCode == 200) {
        Iterable it = jsonDecode(response.body);
        List<PemesananBA> product =
            it.map((e) => PemesananBA.fromJson(e)).toList();
        return product;
      }
    } catch (e) {
      print(e.toString());
    }
  }

  getDetOrder() async {
    try {
      listKeranjang = await repositoryDetOrder();
    } catch (e) {
      print(e);
    }

    int subtotal = 0;

    for (int i = 0; i < listKeranjang.length; i++) {
      if (listKeranjang[i].prodPrice.trim() != "0") {
        subtotal += (int.parse(listKeranjang[i].qty) *
            int.parse(listKeranjang[i].prodPrice.replaceAll(',', '')));
      }
    }
    if (!mounted) return;
    setState(() {
      _subTotal = subtotal;
    });
  }

  @override
  void initState() {
    Timer(Duration(milliseconds: 200), () {
      getDetOrder();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detail Order", style: TextStyle(color: kTextColor)),
        iconTheme: IconThemeData(color: kTextColor),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: ListView.separated(
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: kDefaultPaddin / 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          child: Image.network(
                            listurl.fotoproduk +
                                "${listKeranjang[index].imgurl}",
                            width: 80,
                            height: 80,
                            fit: BoxFit.fill,
                          ),
                        ),
                        Container(
                          width: 230,
                          height: 80,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                StringUtils.capitalize(
                                    "${listKeranjang[index].prodName}",
                                    allWords: true),
                                style: TextStyle(
                                    color: kTextLightColor, fontSize: 13),
                              ),
                              Text("Rp " +
                                  "${listKeranjang[index].prodPrice.replaceAll(',', '.')}"),
                            ],
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(right: kDefaultPaddin / 2),
                          child: Text(
                            "${listKeranjang[index].qty} X",
                            style: TextStyle(
                                fontSize: 16,
                                color: kTextColor,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return Divider(
                    thickness: 2,
                  );
                },
                itemCount: listKeranjang.length),
          ),
          Padding(
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
                      "Total : ",
                      style: TextStyle(color: kTextColor, fontSize: 18),
                    ),
                    Text(
                      "Rp. " +
                          NumberFormat.currency(
                                  locale: 'ID', symbol: "", decimalDigits: 0)
                              .format(_subTotal),
                      style: TextStyle(color: Colors.red, fontSize: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
