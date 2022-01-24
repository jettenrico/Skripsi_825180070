import 'dart:async';
import 'dart:convert';

import 'package:basic_utils/basic_utils.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:harusnyabisa/models/keranjang.dart';
import 'package:harusnyabisa/models/order.dart';
import 'package:harusnyabisa/utility/mobile.dart';
import 'package:harusnyabisa/utility/repository.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../constants.dart';

List<KeranjangList> listKeranjang = [];
Url listurl = Url();

class DetailBelanja extends StatefulWidget {
  const DetailBelanja({Key? key, required this.order}) : super(key: key);
  final String order;

  @override
  _DetailBelanjaState createState() => _DetailBelanjaState();
}

class _DetailBelanjaState extends State<DetailBelanja> {
  int _subTotal = 0;

  repositoryDetOrder() async {
    try {
      final response = await http.post(Uri.parse(listurl.detailorder), body: {
        "order_number": widget.order,
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

class ProsesOrder extends StatefulWidget {
  const ProsesOrder({Key? key, required this.order}) : super(key: key);
  final OrderListSales order;

  @override
  _ProsesOrderState createState() => _ProsesOrderState();
}

class _ProsesOrderState extends State<ProsesOrder> {
  var alamat = "", userNumber = "";

  repositoryDetOrder() async {
    try {
      final response = await http.post(Uri.parse(listurl.detailorder), body: {
        "order_number": widget.order.orderNumber,
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

  getDetOrder() async {
    try {
      listKeranjang = await repositoryDetOrder();
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  getUserLocation() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          double.parse(widget.order.lat), double.parse(widget.order.long));
      Placemark place = placemarks[0];
      print(place);
      setState(() {
        alamat = place.thoroughfare! +
            ", " +
            place.subAdministrativeArea! +
            ", " +
            place.postalCode!;
      });
    } catch (e) {
      print(e);
    }
  }

  cancelOrder() async {
    Fluttertoast.showToast(msg: 'Berhasil Cancel Order!');
    Navigator.of(context).pop();
    try {
      final response = await http.post(Uri.parse(listurl.cancelorder), body: {
        "order_number": widget.order.orderNumber,
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

  Future getUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      userNumber = preferences.getString('usernumber')!;
    });
  }

  prosesOrder() async {
    try {
      final response = await http.post(Uri.parse(listurl.prosesorder), body: {
        "order_number": widget.order.orderNumber,
        "sales_number": userNumber,
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

  @override
  void initState() {
    Timer(Duration(milliseconds: 200), () {
      getUser();
      getDetOrder();
      getUserLocation();
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    widget.order.pickup == "1"
                        ? Padding(
                            padding: const EdgeInsets.only(
                                left: kDefaultPaddin,
                                right: kDefaultPaddin,
                                bottom: 15),
                            child: Text(
                              "Pick Up",
                              style: TextStyle(
                                  color: kTextColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.only(
                                left: kDefaultPaddin,
                                right: kDefaultPaddin,
                                bottom: 8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Delivery",
                                  style: TextStyle(
                                      color: kTextColor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  alamat + '\n' + widget.order.detailalamat,
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 14),
                                ),
                                SizedBox(
                                  height: 5,
                                )
                              ],
                            ),
                          )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    MaterialButton(
                      onPressed: () async {
                        prosesOrder();
                        CoolAlert.show(
                            context: context,
                            type: CoolAlertType.success,
                            title: 'Order Berhasil di Proses!',
                            confirmBtnText: 'OK',
                            onConfirmBtnTap: () => Navigator.of(context)
                              ..pop()
                              ..pop());
                      },
                      height: 45,
                      color: Colors.black,
                      child: Text(
                        "Proses",
                        style: TextStyle(color: Colors.white, fontSize: 16.0),
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    MaterialButton(
                      onPressed: () async {
                        CoolAlert.show(
                            context: context,
                            type: CoolAlertType.confirm,
                            title: 'Cancel Order?',
                            cancelBtnText: 'Yes',
                            cancelBtnTextStyle: TextStyle(
                                color: Colors.red, fontWeight: FontWeight.bold),
                            confirmBtnText: 'Cancel',
                            confirmBtnTextStyle: TextStyle(
                              color: Colors.white,
                            ),
                            confirmBtnColor: Colors.green,
                            onCancelBtnTap: () => cancelOrder(),
                            onConfirmBtnTap: () =>
                                Navigator.of(context)..pop());
                      },
                      height: 45,
                      color: Colors.red,
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: Colors.white, fontSize: 16.0),
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TerimaOrder extends StatefulWidget {
  const TerimaOrder({Key? key, required this.order}) : super(key: key);
  final String order;

  @override
  _TerimaOrderState createState() => _TerimaOrderState();
}

class _TerimaOrderState extends State<TerimaOrder> {
  var tipeuser = "";
  int _subTotal = 0;

  repositoryDetOrder() async {
    try {
      final response = await http.post(Uri.parse(listurl.detailorder), body: {
        "order_number": widget.order,
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

  Future getTipe() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      tipeuser = preferences.getString('tipeuser')!;
    });
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

  prosesTerima() async {
    try {
      final response = await http.post(Uri.parse(listurl.terimaorder), body: {
        "order_number": widget.order,
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

  @override
  void initState() {
    getTipe();
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
                MaterialButton(
                  onPressed: () {
                    prosesTerima();
                    tipeuser == "BA"
                        ? CoolAlert.show(
                            context: context,
                            type: CoolAlertType.success,
                            title: 'Berhasil!',
                            text: 'Order Selesai',
                            confirmBtnText: 'OK',
                            onConfirmBtnTap: () => Navigator.of(context)
                              ..pop()
                              ..pop())
                        : CoolAlert.show(
                            context: context,
                            type: CoolAlertType.success,
                            title: 'Berhasil!',
                            text: 'Terima kasih sudah berbelanja',
                            confirmBtnText: 'OK',
                            onConfirmBtnTap: () => Navigator.of(context)
                              ..pop()
                              ..pop());
                  },
                  height: 45,
                  color: Colors.green,
                  child: tipeuser == "BA"
                      ? Text(
                          "Pesanan Selesai",
                          style: TextStyle(color: Colors.white, fontSize: 16.0),
                        )
                      : Text(
                          "Pesanan Diterima",
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
      ),
    );
  }
}

class LacakOrder extends StatefulWidget {
  const LacakOrder({Key? key, required this.order}) : super(key: key);
  final String order;

  @override
  _LacakOrderState createState() => _LacakOrderState();
}

class _LacakOrderState extends State<LacakOrder> {
  var tipeuser = "";
  int _subTotal = 0;

  repositoryDetOrder() async {
    try {
      final response = await http.post(Uri.parse(listurl.detailorder), body: {
        "order_number": widget.order,
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

  Future getTipe() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      tipeuser = preferences.getString('tipeuser')!;
    });
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

  prosesTerima() async {
    CoolAlert.show(
        context: context,
        type: CoolAlertType.success,
        title: 'Terima Kasih Telah Berbelanja!',
        onConfirmBtnTap: () => Navigator.of(context).pop());
    try {
      final response = await http.post(Uri.parse(listurl.terimaorder), body: {
        "order_number": widget.order,
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

  @override
  void initState() {
    getTipe();
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
                MaterialButton(
                  onPressed: () async {
                    tipeuser == "BA"
                        ? prosesTerima()
                        : Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => OrderLocation()));
                  },
                  height: 45,
                  color: tipeuser == "BA" ? Colors.green : Colors.black,
                  child: tipeuser == "BA"
                      ? Text(
                          "Pesanan Selesai",
                          style: TextStyle(color: Colors.white, fontSize: 16.0),
                        )
                      : Text(
                          "Lacak Pesanan",
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
      ),
    );
  }
}

class OrderLocation extends StatefulWidget {
  const OrderLocation({Key? key}) : super(key: key);

  @override
  _OrderLocationState createState() => _OrderLocationState();
}

class _OrderLocationState extends State<OrderLocation> {
  static const _initialCameraPosition = CameraPosition(
      target: LatLng(-6.168777761085537, 106.79041927085332), zoom: 14.5);

  late GoogleMapController _googleMapController;
  List<Marker> allMarkers = [];

  @override
  void initState() {
    super.initState();
    allMarkers.add(Marker(
        markerId: MarkerId('Driver'),
        draggable: false,
        // icon: await BitmapDescriptor.fromAssetImage(
        //     ImageConfiguration(size: Size(24, 24)), 'assets/delivery.png'),
        onTap: () {},
        position: LatLng(-6.16690045082166, 106.79010816105746)));
  }

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text("Lacak Pesanan", style: TextStyle(color: kTextColor)),
        iconTheme: IconThemeData(color: kTextColor),
        actions: [
          IconButton(
              icon: Icon(Icons.map_sharp),
              onPressed: () => _googleMapController.animateCamera(
                    CameraUpdate.newCameraPosition(_initialCameraPosition),
                  ))
        ],
      ),
      body: GoogleMap(
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          onMapCreated: (controller) => _googleMapController = controller,
          initialCameraPosition: _initialCameraPosition,
          markers: Set.from(allMarkers)),
      floatingActionButton: FloatingActionButton(
        onPressed: Navigator.of(context).pop,
        child: const Icon(Icons.done),
      ),
    );
  }
}

class ReviewOrder extends StatefulWidget {
  const ReviewOrder({Key? key, required this.order}) : super(key: key);
  final OrderList order;

  @override
  _ReviewOrderState createState() => _ReviewOrderState();
}

class _ReviewOrderState extends State<ReviewOrder> {
  var userNumber = "", nama = "";
  int _subTotal = 0;
  TextEditingController review = new TextEditingController();

  repositoryDetOrder() async {
    try {
      final response = await http.post(Uri.parse(listurl.detailorder), body: {
        "order_number": widget.order.orderNumber,
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

  Future getUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      userNumber = preferences.getString('usernumber')!;
      nama = preferences.getString('namauser')!;
    });
  }

  reviewProduk(String prodnum) async {
    try {
      final response = await http.post(Uri.parse(listurl.review), body: {
        "user_number": userNumber,
        "prod_number": prodnum,
        "order_number": widget.order,
        "review": review.text,
      });

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        var value = data['value'];
        var message = data['message'];
        if (!mounted) return;
        setState(() {});
        if (value == 1) {
          CoolAlert.show(
              context: context,
              type: CoolAlertType.success,
              title: message,
              onConfirmBtnTap: () => Navigator.of(context)
                ..pop()
                ..pop());
          print(message);
        } else {
          CoolAlert.show(
              context: context,
              type: CoolAlertType.warning,
              title: message,
              onConfirmBtnTap: () => Navigator.of(context)
                ..pop()
                ..pop());
          print(message);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    Timer(Duration(milliseconds: 200), () {
      getUser();
      getDetOrder();
    });
    super.initState();
  }

  void dispose() {
    review.dispose();
    super.dispose();
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
                  return InkWell(
                    onTap: () {
                      showMaterialModalBottomSheet(
                          context: context,
                          builder: (context) => Scaffold(
                                body: SingleChildScrollView(
                                  child: Center(
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 50,
                                        ),
                                        CircleAvatar(
                                            foregroundImage: Image.network(listurl
                                                        .fotoproduk +
                                                    "${listKeranjang[index].imgurl}")
                                                .image,
                                            radius: 120,
                                            backgroundColor:
                                                Colors.transparent),
                                        Center(
                                          child: Text(
                                              StringUtils.capitalize(
                                                "${listKeranjang[index].prodName}",
                                                allWords: true,
                                              ),
                                              style: TextStyle(
                                                  color: kTextColor,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.center),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: kDefaultPaddin / 2,
                                              right: kDefaultPaddin / 2,
                                              top: kDefaultPaddin),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Container(
                                                height: 70,
                                                child: Text("Review Produk :",
                                                    style: TextStyle(
                                                        color: kTextColor,
                                                        fontSize: 16)),
                                              ),
                                              SizedBox(
                                                height: 100,
                                                width: 220,
                                                child: Expanded(
                                                  child: TextFormField(
                                                    keyboardType:
                                                        TextInputType.multiline,
                                                    maxLines: 3,
                                                    decoration: InputDecoration(
                                                        contentPadding:
                                                            EdgeInsets
                                                                .symmetric(
                                                                    vertical: 5,
                                                                    horizontal:
                                                                        10),
                                                        border: OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .black),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.00))),
                                                    controller: review,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        MaterialButton(
                                          onPressed: () {
                                            review.text.isEmpty
                                                ? CoolAlert.show(
                                                    context: context,
                                                    type: CoolAlertType.error,
                                                    title: 'Isi Review Dahulu!',
                                                    onConfirmBtnTap: () =>
                                                        Navigator.of(context)
                                                            .pop())
                                                : reviewProduk(
                                                    "${listKeranjang[index].prodNumber}");
                                          },
                                          height: 45,
                                          color: Colors.green,
                                          child: Text(
                                            "Kirim Review",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16.0),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 50),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ));
                    },
                    child: Padding(
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
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                right: kDefaultPaddin / 2),
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
                  onPressed: () => generateInvoice(),
                  height: 45,
                  color: Colors.green,
                  child: Text(
                    "Invoice",
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
      ),
    );
  }

  Future<void> generateInvoice() async {
    PdfDocument document = PdfDocument();
    final page = document.pages.add();

    final Size pageSize = page.getClientSize();
    page.graphics.drawRectangle(
        bounds: Rect.fromLTWH(0, 0, pageSize.width, pageSize.height),
        pen: PdfPen(PdfColor(142, 170, 219, 255)));

    final PdfGrid grid = _getGrid();
    //Draw the header section by creating text element
    final PdfLayoutResult result = _drawHeader(page, pageSize, grid);
    //Draw grid
    _drawGrid(page, grid, result);
    //Add invoice footer
    _drawFooter(page, pageSize);
    List<int> bytes = document.save();
    document.dispose();

    saveAndLaunchFile(bytes, 'Invoice.pdf');
  }

  PdfLayoutResult _drawHeader(PdfPage page, Size pageSize, PdfGrid grid) {
    //Draw rectangle
    page.graphics.drawRectangle(
        brush: PdfSolidBrush(PdfColor(91, 126, 215, 255)),
        bounds: Rect.fromLTWH(0, 0, pageSize.width - 115, 90));
    //Draw string
    page.graphics.drawString(
        'INVOICE', PdfStandardFont(PdfFontFamily.helvetica, 30),
        brush: PdfBrushes.white,
        bounds: Rect.fromLTWH(25, 0, pageSize.width - 115, 90),
        format: PdfStringFormat(lineAlignment: PdfVerticalAlignment.middle));
    page.graphics.drawRectangle(
        bounds: Rect.fromLTWH(400, 0, pageSize.width - 400, 90),
        brush: PdfSolidBrush(PdfColor(65, 104, 205)));
    page.graphics.drawString(
        r'Rp. ' +
            NumberFormat.currency(locale: 'ID', symbol: "", decimalDigits: 0)
                .format(grandtotal),
        PdfStandardFont(PdfFontFamily.helvetica, 18),
        bounds: Rect.fromLTWH(400, 0, pageSize.width - 400, 100),
        brush: PdfBrushes.white,
        format: PdfStringFormat(
            alignment: PdfTextAlignment.center,
            lineAlignment: PdfVerticalAlignment.middle));
    final PdfFont contentFont = PdfStandardFont(PdfFontFamily.helvetica, 9);
    //Draw string
    page.graphics.drawString('Jumlah Terbayar', contentFont,
        brush: PdfBrushes.white,
        bounds: Rect.fromLTWH(400, 0, pageSize.width - 400, 33),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.center,
            lineAlignment: PdfVerticalAlignment.bottom));
    //Create data foramt and convert it to text.

    final String address = 'Pemesan: ' +
        nama +
        '\r\n\r\nNomor Invoice: ' +
        widget.order.orderNumber +
        '\r\n\r\nTanggal Transaksi:' +
        widget.order.tglTransaksi;

    return PdfTextElement(text: address, font: contentFont).draw(
        page: page,
        bounds: Rect.fromLTWH(30, 120, pageSize.width, pageSize.height - 120))!;
  }

  //Draws the grid
  void _drawGrid(PdfPage page, PdfGrid grid, PdfLayoutResult result) {
    Rect? totalPriceCellBounds;
    Rect? quantityCellBounds;
    //Invoke the beginCellLayout event.
    grid.beginCellLayout = (Object sender, PdfGridBeginCellLayoutArgs args) {
      final PdfGrid grid = sender as PdfGrid;
      if (args.cellIndex == grid.columns.count - 1) {
        totalPriceCellBounds = args.bounds;
      } else if (args.cellIndex == grid.columns.count - 2) {
        quantityCellBounds = args.bounds;
      }
    };
    //Draw the PDF grid and get the result.
    result = grid.draw(
        page: page, bounds: Rect.fromLTWH(0, result.bounds.bottom + 40, 0, 0))!;
    //Draw grand total.
    page.graphics.drawString('Grand Total',
        PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.bold),
        bounds: Rect.fromLTWH(
            quantityCellBounds!.left,
            result.bounds.bottom + 10,
            quantityCellBounds!.width,
            quantityCellBounds!.height));
    page.graphics.drawString(
        NumberFormat.currency(locale: 'ID', symbol: "", decimalDigits: 0)
            .format(grandtotal),
        PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.bold),
        bounds: Rect.fromLTWH(
            totalPriceCellBounds!.left,
            result.bounds.bottom + 10,
            totalPriceCellBounds!.width,
            totalPriceCellBounds!.height));
  }

  //Draw the invoice footer data.
  void _drawFooter(PdfPage page, Size pageSize) {
    final PdfPen linePen =
        PdfPen(PdfColor(142, 170, 219, 255), dashStyle: PdfDashStyle.custom);
    linePen.dashPattern = <double>[3, 3];
    //Draw line
    page.graphics.drawLine(linePen, Offset(0, pageSize.height - 100),
        Offset(pageSize.width, pageSize.height - 100));
    const String footerContent =
        'PT. Sinergi Global Servis\r\n\r\nJl. Pulo Kambing II No 2\r\n\r\nAny Questions? sgsapplicationtester@gmail.com';
    //Added 30 as a margin for the layout
    page.graphics.drawString(
        footerContent, PdfStandardFont(PdfFontFamily.helvetica, 9),
        format: PdfStringFormat(alignment: PdfTextAlignment.right),
        bounds: Rect.fromLTWH(pageSize.width - 30, pageSize.height - 70, 0, 0));
  }

  int grandtotal = 0;

  PdfGrid _getGrid() {
    final PdfGrid grid = PdfGrid();
    grid.columns.add(count: 5);
    //Create the header row of the grid.
    final PdfGridRow headerRow = grid.headers.add(1)[0];
    //Set style
    headerRow.style.backgroundBrush = PdfSolidBrush(PdfColor(68, 114, 196));
    headerRow.style.textBrush = PdfBrushes.white;
    headerRow.cells[0].value = 'No';
    headerRow.cells[0].stringFormat.alignment = PdfTextAlignment.center;
    headerRow.cells[1].value = 'Product Name';
    headerRow.cells[2].value = 'Price';
    headerRow.cells[3].value = 'Quantity';
    headerRow.cells[4].value = 'Total';
    for (int i = 0; i < listKeranjang.length; i++) {
      int total = int.parse(listKeranjang[i]
              .prodPrice
              .replaceAll(new RegExp(r'[^\w\s]+'), '')) *
          int.parse(listKeranjang[i].qty);
      grandtotal += total;
      _addProducts(
          (1 + i).toString(),
          listKeranjang[i].prodName,
          listKeranjang[i].prodPrice.replaceAll(',', '.'),
          listKeranjang[i].qty,
          NumberFormat.currency(locale: 'ID', symbol: "", decimalDigits: 0)
              .format(total),
          grid);
    }

    grid.applyBuiltInStyle(PdfGridBuiltInStyle.listTable4Accent5);
    grid.columns[1].width = 200;
    for (int i = 0; i < headerRow.cells.count; i++) {
      headerRow.cells[i].style.cellPadding =
          PdfPaddings(bottom: 5, left: 5, right: 5, top: 5);
    }
    for (int i = 0; i < grid.rows.count; i++) {
      final PdfGridRow row = grid.rows[i];
      for (int j = 0; j < row.cells.count; j++) {
        final PdfGridCell cell = row.cells[j];
        if (j == 0) {
          cell.stringFormat.alignment = PdfTextAlignment.center;
        }
        cell.style.cellPadding =
            PdfPaddings(bottom: 5, left: 5, right: 5, top: 5);
      }
    }
    return grid;
  }

  //Create and row for the grid.
  void _addProducts(String no, String productName, String price,
      String quantity, String total, PdfGrid grid) {
    final PdfGridRow row = grid.rows.add();
    row.cells[0].value = no;
    row.cells[1].value = productName;
    row.cells[2].value = price;
    row.cells[3].value = quantity;
    row.cells[4].value = total;
  }
}

class CetakInvoice extends StatefulWidget {
  final OrderListSales order;

  const CetakInvoice({Key? key, required this.order}) : super(key: key);
  @override
  _CetakInvoiceState createState() => _CetakInvoiceState();
}

class _CetakInvoiceState extends State<CetakInvoice> {
  var userNumber = "", nama = "";
  int _subTotal = 0;
  TextEditingController review = new TextEditingController();

  repositoryDetOrder() async {
    try {
      final response = await http.post(Uri.parse(listurl.detailorder), body: {
        "order_number": widget.order.orderNumber,
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

  Future getUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      userNumber = preferences.getString('usernumber')!;
      nama = preferences.getString('namauser')!;
    });
  }

  reviewProduk(String prodnum) async {
    try {
      final response = await http.post(Uri.parse(listurl.review), body: {
        "user_number": userNumber,
        "prod_number": prodnum,
        "order_number": widget.order,
        "review": review.text,
      });

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        var value = data['value'];
        var message = data['message'];
        if (!mounted) return;
        setState(() {});
        if (value == 1) {
          CoolAlert.show(
              context: context,
              type: CoolAlertType.success,
              title: message,
              onConfirmBtnTap: () => Navigator.of(context)
                ..pop()
                ..pop());
          print(message);
        } else {
          CoolAlert.show(
              context: context,
              type: CoolAlertType.warning,
              title: message,
              onConfirmBtnTap: () => Navigator.of(context)
                ..pop()
                ..pop());
          print(message);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    Timer(Duration(milliseconds: 200), () {
      getUser();
      getDetOrder();
    });
    super.initState();
  }

  void dispose() {
    review.dispose();
    super.dispose();
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
                  return InkWell(
                    onTap: () {
                      showMaterialModalBottomSheet(
                          context: context,
                          builder: (context) => Scaffold(
                                body: SingleChildScrollView(
                                  child: Center(
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 50,
                                        ),
                                        CircleAvatar(
                                            foregroundImage: Image.network(listurl
                                                        .fotoproduk +
                                                    "${listKeranjang[index].imgurl}")
                                                .image,
                                            radius: 120,
                                            backgroundColor:
                                                Colors.transparent),
                                        Center(
                                          child: Text(
                                              StringUtils.capitalize(
                                                "${listKeranjang[index].prodName}",
                                                allWords: true,
                                              ),
                                              style: TextStyle(
                                                  color: kTextColor,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.center),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: kDefaultPaddin / 2,
                                              right: kDefaultPaddin / 2,
                                              top: kDefaultPaddin),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Container(
                                                height: 70,
                                                child: Text("Review Produk :",
                                                    style: TextStyle(
                                                        color: kTextColor,
                                                        fontSize: 16)),
                                              ),
                                              SizedBox(
                                                height: 100,
                                                width: 220,
                                                child: Expanded(
                                                  child: TextFormField(
                                                    keyboardType:
                                                        TextInputType.multiline,
                                                    maxLines: 3,
                                                    decoration: InputDecoration(
                                                        contentPadding:
                                                            EdgeInsets
                                                                .symmetric(
                                                                    vertical: 5,
                                                                    horizontal:
                                                                        10),
                                                        border: OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .black),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.00))),
                                                    controller: review,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        MaterialButton(
                                          onPressed: () {
                                            review.text.isEmpty
                                                ? CoolAlert.show(
                                                    context: context,
                                                    type: CoolAlertType.error,
                                                    title: 'Isi Review Dahulu!',
                                                    onConfirmBtnTap: () =>
                                                        Navigator.of(context)
                                                            .pop())
                                                : reviewProduk(
                                                    "${listKeranjang[index].prodNumber}");
                                          },
                                          height: 45,
                                          color: Colors.green,
                                          child: Text(
                                            "Kirim Review",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16.0),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 50),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ));
                    },
                    child: Padding(
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
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                right: kDefaultPaddin / 2),
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
                  onPressed: () => generateInvoice(),
                  height: 45,
                  color: Colors.green,
                  child: Text(
                    "Invoice",
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
      ),
    );
  }

  Future<void> generateInvoice() async {
    PdfDocument document = PdfDocument();
    final page = document.pages.add();

    final Size pageSize = page.getClientSize();
    page.graphics.drawRectangle(
        bounds: Rect.fromLTWH(0, 0, pageSize.width, pageSize.height),
        pen: PdfPen(PdfColor(142, 170, 219, 255)));

    final PdfGrid grid = _getGrid();
    //Draw the header section by creating text element
    final PdfLayoutResult result = _drawHeader(page, pageSize, grid);
    //Draw grid
    _drawGrid(page, grid, result);
    //Add invoice footer
    _drawFooter(page, pageSize);
    List<int> bytes = document.save();
    document.dispose();

    saveAndLaunchFile(bytes, 'Invoice.pdf');
  }

  PdfLayoutResult _drawHeader(PdfPage page, Size pageSize, PdfGrid grid) {
    //Draw rectangle
    page.graphics.drawRectangle(
        brush: PdfSolidBrush(PdfColor(91, 126, 215, 255)),
        bounds: Rect.fromLTWH(0, 0, pageSize.width - 115, 90));
    //Draw string
    page.graphics.drawString(
        'INVOICE', PdfStandardFont(PdfFontFamily.helvetica, 30),
        brush: PdfBrushes.white,
        bounds: Rect.fromLTWH(25, 0, pageSize.width - 115, 90),
        format: PdfStringFormat(lineAlignment: PdfVerticalAlignment.middle));
    page.graphics.drawRectangle(
        bounds: Rect.fromLTWH(400, 0, pageSize.width - 400, 90),
        brush: PdfSolidBrush(PdfColor(65, 104, 205)));
    page.graphics.drawString(
        r'Rp. ' +
            NumberFormat.currency(locale: 'ID', symbol: "", decimalDigits: 0)
                .format(grandtotal),
        PdfStandardFont(PdfFontFamily.helvetica, 18),
        bounds: Rect.fromLTWH(400, 0, pageSize.width - 400, 100),
        brush: PdfBrushes.white,
        format: PdfStringFormat(
            alignment: PdfTextAlignment.center,
            lineAlignment: PdfVerticalAlignment.middle));
    final PdfFont contentFont = PdfStandardFont(PdfFontFamily.helvetica, 9);
    //Draw string
    page.graphics.drawString('Jumlah Terbayar', contentFont,
        brush: PdfBrushes.white,
        bounds: Rect.fromLTWH(400, 0, pageSize.width - 400, 33),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.center,
            lineAlignment: PdfVerticalAlignment.bottom));
    //Create data foramt and convert it to text.

    final String address = 'Nomor Invoice: ' +
        widget.order.orderNumber +
        '\r\n\r\nTanggal Transaksi:' +
        widget.order.tglTransaksi;

    return PdfTextElement(text: address, font: contentFont).draw(
        page: page,
        bounds: Rect.fromLTWH(30, 120, pageSize.width, pageSize.height - 120))!;
  }

  //Draws the grid
  void _drawGrid(PdfPage page, PdfGrid grid, PdfLayoutResult result) {
    Rect? totalPriceCellBounds;
    Rect? quantityCellBounds;
    //Invoke the beginCellLayout event.
    grid.beginCellLayout = (Object sender, PdfGridBeginCellLayoutArgs args) {
      final PdfGrid grid = sender as PdfGrid;
      if (args.cellIndex == grid.columns.count - 1) {
        totalPriceCellBounds = args.bounds;
      } else if (args.cellIndex == grid.columns.count - 2) {
        quantityCellBounds = args.bounds;
      }
    };
    //Draw the PDF grid and get the result.
    result = grid.draw(
        page: page, bounds: Rect.fromLTWH(0, result.bounds.bottom + 40, 0, 0))!;
    //Draw grand total.
    page.graphics.drawString('Grand Total',
        PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.bold),
        bounds: Rect.fromLTWH(
            quantityCellBounds!.left,
            result.bounds.bottom + 10,
            quantityCellBounds!.width,
            quantityCellBounds!.height));
    page.graphics.drawString(
        NumberFormat.currency(locale: 'ID', symbol: "", decimalDigits: 0)
            .format(grandtotal),
        PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.bold),
        bounds: Rect.fromLTWH(
            totalPriceCellBounds!.left,
            result.bounds.bottom + 10,
            totalPriceCellBounds!.width,
            totalPriceCellBounds!.height));
  }

  //Draw the invoice footer data.
  void _drawFooter(PdfPage page, Size pageSize) {
    final PdfPen linePen =
        PdfPen(PdfColor(142, 170, 219, 255), dashStyle: PdfDashStyle.custom);
    linePen.dashPattern = <double>[3, 3];
    //Draw line
    page.graphics.drawLine(linePen, Offset(0, pageSize.height - 100),
        Offset(pageSize.width, pageSize.height - 100));
    const String footerContent =
        'PT. Sinergi Global Servis\r\n\r\nJl. Pulo Kambing II No 2\r\n\r\nAny Questions? sgsapplicationtester@gmail.com';
    //Added 30 as a margin for the layout
    page.graphics.drawString(
        footerContent, PdfStandardFont(PdfFontFamily.helvetica, 9),
        format: PdfStringFormat(alignment: PdfTextAlignment.right),
        bounds: Rect.fromLTWH(pageSize.width - 30, pageSize.height - 70, 0, 0));
  }

  int grandtotal = 0;

  PdfGrid _getGrid() {
    final PdfGrid grid = PdfGrid();
    grid.columns.add(count: 5);
    //Create the header row of the grid.
    final PdfGridRow headerRow = grid.headers.add(1)[0];
    //Set style
    headerRow.style.backgroundBrush = PdfSolidBrush(PdfColor(68, 114, 196));
    headerRow.style.textBrush = PdfBrushes.white;
    headerRow.cells[0].value = 'No';
    headerRow.cells[0].stringFormat.alignment = PdfTextAlignment.center;
    headerRow.cells[1].value = 'Product Name';
    headerRow.cells[2].value = 'Price';
    headerRow.cells[3].value = 'Quantity';
    headerRow.cells[4].value = 'Total';
    for (int i = 0; i < listKeranjang.length; i++) {
      int total = int.parse(listKeranjang[i]
              .prodPrice
              .replaceAll(new RegExp(r'[^\w\s]+'), '')) *
          int.parse(listKeranjang[i].qty);
      grandtotal += total;
      _addProducts(
          (1 + i).toString(),
          listKeranjang[i].prodName,
          listKeranjang[i].prodPrice.replaceAll(',', '.'),
          listKeranjang[i].qty,
          NumberFormat.currency(locale: 'ID', symbol: "", decimalDigits: 0)
              .format(total),
          grid);
    }

    grid.applyBuiltInStyle(PdfGridBuiltInStyle.listTable4Accent5);
    grid.columns[1].width = 200;
    for (int i = 0; i < headerRow.cells.count; i++) {
      headerRow.cells[i].style.cellPadding =
          PdfPaddings(bottom: 5, left: 5, right: 5, top: 5);
    }
    for (int i = 0; i < grid.rows.count; i++) {
      final PdfGridRow row = grid.rows[i];
      for (int j = 0; j < row.cells.count; j++) {
        final PdfGridCell cell = row.cells[j];
        if (j == 0) {
          cell.stringFormat.alignment = PdfTextAlignment.center;
        }
        cell.style.cellPadding =
            PdfPaddings(bottom: 5, left: 5, right: 5, top: 5);
      }
    }
    return grid;
  }

  //Create and row for the grid.
  void _addProducts(String no, String productName, String price,
      String quantity, String total, PdfGrid grid) {
    final PdfGridRow row = grid.rows.add();
    row.cells[0].value = no;
    row.cells[1].value = productName;
    row.cells[2].value = price;
    row.cells[3].value = quantity;
    row.cells[4].value = total;
  }
}
