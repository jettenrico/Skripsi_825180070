import 'dart:async';
import 'dart:convert';

import 'package:basic_utils/basic_utils.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:harusnyabisa/models/order.dart';
import 'package:harusnyabisa/screens/payment.dart';
import 'package:harusnyabisa/screens/statusbelanja.dart';
import 'package:harusnyabisa/utility/repository.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:harusnyabisa/models/keranjang.dart';
import 'package:harusnyabisa/constants.dart';

List<KeranjangList> listKeranjang = [];
List<OrderList> listOrder = [];
List<OrderListSales> listOrderBA = [];
Url listurl = Url();

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
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
    onRefresh();
    Navigator.pop(context);
    try {
      final response = await http.post(Uri.parse(listurl.deleteproduk), body: {
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

  checkOut() async {
    try {
      final response = await http.post(Uri.parse(listurl.checkout), body: {
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
      final response = await http.post(Uri.parse(listurl.isikeranjang), body: {
        "user_number": userNumber,
      });

      if (response.statusCode == 200) {
        Iterable it = jsonDecode(response.body);
        List<KeranjangList> product =
            it.map((e) => KeranjangList.fromJson(e)).toList();
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
                          CoolAlert.show(
                              context: context,
                              type: CoolAlertType.confirm,
                              title: 'Delete Produk?',
                              cancelBtnText: 'Cancel',
                              cancelBtnTextStyle: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold),
                              confirmBtnText: 'Yes',
                              confirmBtnTextStyle: TextStyle(
                                color: Colors.white,
                              ),
                              confirmBtnColor: Colors.red,
                              onCancelBtnTap: () => Navigator.pop(context),
                              onConfirmBtnTap: () => deleteKeranjang(
                                  listKeranjang[index].prodNumber));
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
                      title: 'Berhasil!',
                      text: 'Silahkan Proses Order di bagian Pesanan',
                      confirmBtnText: 'OK',
                      onConfirmBtnTap: () => Navigator.of(context)
                        ..pop()
                        ..pop());
                  checkOut();
                },
                height: 45,
                color: Colors.black,
                child: Text(
                  "Check Out",
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

class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  var userNumber = "";

  getUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      userNumber = preferences.getString('usernumber')!;
    });
  }

  repositoryOrder() async {
    try {
      final response = await http.post(Uri.parse(listurl.showorder), body: {
        "user_number": userNumber,
      });

      if (response.statusCode == 200) {
        Iterable it = jsonDecode(response.body);
        List<OrderList> order = it.map((e) => OrderList.fromJson(e)).toList();
        return order;
      }
    } catch (e) {
      print(e.toString());
    }
  }

  getDataOrder() async {
    try {
      listOrder = await repositoryOrder();
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
      getDataOrder();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [listOrder.isEmpty ? orderKosong() : order()],
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

  Widget order() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kDefaultPaddin),
        child: RefreshIndicator(
          onRefresh: () => getDataOrder(),
          child: ListView.separated(
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    listOrder[index].status == "1"
                        ? Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => CheckoutScreen(
                                  order: listOrder[index],
                                )))
                        : listOrder[index].status == "2"
                            ? Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => PaymentPage(
                                      order: listOrder[index].orderNumber,
                                    )))
                            : listOrder[index].status == "3"
                                ? Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => DetailBelanja(
                                          order: listOrder[index].orderNumber,
                                        )))
                                : listOrder[index].status == "4" &&
                                        listOrder[index].pickup == "1"
                                    ? Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (context) => TerimaOrder(
                                                  order: listOrder[index]
                                                      .orderNumber,
                                                )))
                                    : listOrder[index].status == "4" &&
                                            listOrder[index].pickup == "0"
                                        ? Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    LacakOrder(
                                                      order: listOrder[index]
                                                          .orderNumber,
                                                    )))
                                        : listOrder[index].status == "5"
                                            ? Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ReviewOrder(
                                                          order:
                                                              listOrder[index],
                                                        )))
                                            : listOrder[index].status == "99"
                                                ? Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            DetailBelanja(
                                                              order: listOrder[
                                                                      index]
                                                                  .orderNumber,
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
                              listOrder[index].status == "1"
                                  ? Text(
                                      "Menunggu Konfirmasi Order",
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold),
                                    )
                                  : listOrder[index].status == "2"
                                      ? Text(
                                          "Menunggu Pembayaran",
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold),
                                        )
                                      : listOrder[index].status == "3"
                                          ? Text("Order Sedang Diproses",
                                              style: TextStyle(
                                                  color: Colors.orangeAccent,
                                                  fontWeight: FontWeight.bold))
                                          : listOrder[index].status == "4" &&
                                                  listOrder[index].pickup == "1"
                                              ? Text(
                                                  "Order Siap Diambil",
                                                  style: TextStyle(
                                                      color: Colors.green,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )
                                              : listOrder[index].status ==
                                                          "4" &&
                                                      listOrder[index].pickup ==
                                                          "0"
                                                  ? Text(
                                                      "Order Sedang Dikirim",
                                                      style: TextStyle(
                                                          color: Colors.green,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    )
                                                  : listOrder[index].status ==
                                                          "5"
                                                      ? Text(
                                                          "Order Selesai",
                                                          style: TextStyle(
                                                              color: kTextColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        )
                                                      : listOrder[index]
                                                                  .status ==
                                                              "99"
                                                          ? Text(
                                                              "Order Dicancel!",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
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

class OrderBA extends StatefulWidget {
  const OrderBA({Key? key}) : super(key: key);

  @override
  _OrderBAState createState() => _OrderBAState();
}

class _OrderBAState extends State<OrderBA> {
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
      final response = await http.post(Uri.parse(listurl.orderba), body: {
        "user_number": userNumber,
      });

      if (response.statusCode == 200) {
        Iterable it = jsonDecode(response.body);
        List<OrderListSales> order =
            it.map((e) => OrderListSales.fromJson(e)).toList();
        return order;
      }
    } catch (e) {
      print(e.toString());
    }
  }

  getDataOrderBA() async {
    try {
      listOrderBA = await repositoryOrderBA();
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [listOrderBA.isEmpty ? orderKosong() : orderBA()],
      ),
    );
  }

  Widget orderKosong() {
    return FutureBuilder(
      future: Future.delayed(Duration(seconds: 1)),
      builder: (c, s) => s.connectionState == ConnectionState.done
          ? listOrderBA.isEmpty
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
                    listOrderBA[index].status == "3"
                        ? Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ProsesOrder(
                                  order: listOrderBA[index],
                                )))
                        : listOrderBA[index].status == "4"
                            ? Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => TerimaOrder(
                                      order: listOrderBA[index].orderNumber,
                                    )))
                            : listOrderBA[index].status == "5"
                                ? Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => CetakInvoice(
                                          order: listOrderBA[index],
                                        )))
                                : Text("Error");
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
                                    "${listOrderBA[index].orderNumber}",
                                    style: TextStyle(
                                        color: kTextColor, fontSize: 16),
                                  ),
                                  Text(
                                    "${listOrderBA[index].tglTransaksi}",
                                    style: TextStyle(
                                        color: kTextLightColor, fontSize: 14),
                                  )
                                ],
                              ),
                              listOrderBA[index].status == "3"
                                  ? Text(
                                      "Proses Order",
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold),
                                    )
                                  : listOrderBA[index].status == "4"
                                      ? Text(
                                          "Order Telah di Proses",
                                          style: TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold),
                                        )
                                      : listOrderBA[index].status == "5"
                                          ? Text(
                                              "Order Telah Selesai",
                                              style: TextStyle(
                                                  color: kTextColor,
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
              itemCount: listOrderBA.length),
        ),
      ),
    );
  }
}
