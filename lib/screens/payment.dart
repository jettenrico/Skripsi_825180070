import 'dart:convert';
import 'dart:io';

import 'package:cool_alert/cool_alert.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:harusnyabisa/models/order.dart';
import 'package:harusnyabisa/models/totalbelanja.dart';
import 'package:harusnyabisa/screens/landing.dart';
import 'package:harusnyabisa/utility/repository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';

Url listurl = Url();
var lat = "", long = "";

class CheckoutScreen extends StatefulWidget {
  final OrderList order;
  const CheckoutScreen({Key? key, required this.order}) : super(key: key);

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  var metodepembayaran = "", metodeorder = "", iduser = "", alamat = "";
  int metpem = 0, metord = 0;
  TextEditingController detailalamat = TextEditingController();

  getMetode() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setInt('metodepembayaran', metpem);
    preferences.setInt('metodeorder', metord);
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

  Future getUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      iduser = preferences.getString('usernumber')!;
    });
  }

  Future proses() async {
    var response = await http.post(Uri.parse(listurl.metode), body: {
      "user_number": iduser,
      "order_number": widget.order.orderNumber,
      "metode_pembayaran": metpem.toString(),
      "metode_order": metord.toString(),
      "detail_alamat": detailalamat.text
    });

    var data = json.decode(response.body);
    var msg = data['message'];

    print(msg);
  }

  cancelOrder() async {
    Navigator.of(context)
      ..pop()
      ..pop();
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

  @override
  void initState() {
    getUser();
    getUserLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scaffold(
        appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Text("Checkout", style: TextStyle(color: kTextColor)),
            iconTheme: IconThemeData(color: kTextColor)),
        body: RefreshIndicator(
          onRefresh: () => getUserLocation(),
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: kDefaultPaddin),
              child: Column(
                children: [
                  Container(
                    height: 50,
                    width: 350,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Metode Pembayaran :",
                          style: TextStyle(color: kTextColor, fontSize: 16),
                        ),
                        Container(
                          height: 50,
                          width: 180,
                          child: DropdownButton<String>(
                            items: [
                              DropdownMenuItem<String>(
                                  value: "BCA Virtual Account",
                                  child: Text("BCA Virtual Account")),
                              DropdownMenuItem<String>(
                                  value: "GOPAY", child: Text("GOPAY")),
                            ],
                            onChanged: (_value) => {
                              print(_value.toString()),
                              setState(() {
                                metodepembayaran = _value!;
                                metodepembayaran == "BCA Virtual Account"
                                    ? metpem = 1
                                    : metodepembayaran == "GOPAY"
                                        ? metpem = 2
                                        : print("Error");
                                getMetode();
                              })
                            },
                            hint: metodepembayaran == ""
                                ? Text("Pilih Pembayaran")
                                : Text(metodepembayaran),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 50,
                    width: 350,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Metode Pemesanan :",
                          style: TextStyle(color: kTextColor, fontSize: 16),
                        ),
                        Container(
                          height: 50,
                          width: 180,
                          child: DropdownButton<String>(
                            items: [
                              DropdownMenuItem<String>(
                                  value: "Pick Up", child: Text("Pick Up")),
                              DropdownMenuItem<String>(
                                  value: "Delivery", child: Text("Delivery")),
                            ],
                            onChanged: (_value) => {
                              print(_value.toString()),
                              setState(() {
                                metodeorder = _value!;
                                metodeorder == "Pick Up"
                                    ? metord = 1
                                    : metodeorder == "Delivery"
                                        ? metord = 0
                                        : print("Error");
                                getMetode();
                              })
                            },
                            hint: metodeorder == ""
                                ? Text("Pilih Pemesanan")
                                : Text(metodeorder),
                          ),
                        )
                      ],
                    ),
                  ),
                  metodeorder == "Delivery"
                      ? Column(
                          children: [
                            Container(
                              height: 50,
                              width: 350,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Alamat :",
                                    style: TextStyle(
                                        color: kTextColor, fontSize: 16),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: kDefaultPaddin / 4),
                                    child: Container(
                                        height: 50,
                                        width: 200,
                                        child: MaterialButton(
                                          child: Text(
                                            double.parse(widget.order.lat) == 0
                                                ? "Buka Peta"
                                                : alamat.toString(),
                                            textAlign: TextAlign.justify,
                                          ),
                                          onPressed: () {
                                            Navigator.of(context)
                                                .push(MaterialPageRoute(
                                                    builder: (context) => Gmaps(
                                                          order: widget.order
                                                              .orderNumber,
                                                        )));
                                          },
                                        )),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              height: 100,
                              width: 350,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Detail Alamat :",
                                    style: TextStyle(
                                        color: kTextColor, fontSize: 16),
                                  ),
                                  SizedBox(
                                    height: 60,
                                    width: 220,
                                    child: Expanded(
                                      child: TextFormField(
                                          keyboardType: TextInputType.multiline,
                                          maxLines: 2,
                                          decoration: InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 5,
                                                      horizontal: 10),
                                              labelText: "Blok/RT/RW/Nomor",
                                              labelStyle: TextStyle(
                                                  color: Colors.black54),
                                              border: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.black),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8))),
                                          controller: detailalamat),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: kDefaultPaddin),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  MaterialButton(
                                    onPressed: () async {
                                      if (metodeorder == "") {
                                        Fluttertoast.showToast(
                                            msg: "Pilih Metode Order Dahulu!");
                                      } else if (metodepembayaran == "") {
                                        Fluttertoast.showToast(
                                            msg:
                                                "Pilih Metode Pemesanan Dahulu!");
                                      } else if (detailalamat.text == "") {
                                        Fluttertoast.showToast(
                                            msg: "Isi Detail Alamat!");
                                      } else if (metodeorder == "" &&
                                          metodepembayaran == "") {
                                        Fluttertoast.showToast(
                                            msg: "Pilih Form Diatas Dahulu!");
                                      } else {
                                        proses();
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    PaymentPage(
                                                      order: widget
                                                          .order.orderNumber,
                                                    )));
                                      }
                                    },
                                    height: 45,
                                    color: Colors.green,
                                    child: Text(
                                      "Proses",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16.0),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                  MaterialButton(
                                    onPressed: () async {
                                      CoolAlert.show(
                                          context: context,
                                          type: CoolAlertType.warning,
                                          title: 'Cancel Order?',
                                          cancelBtnText: 'Yes',
                                          cancelBtnTextStyle: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold),
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
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16.0),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : metodeorder == "Pick Up"
                          ? Padding(
                              padding:
                                  const EdgeInsets.only(top: kDefaultPaddin),
                              child: Column(
                                children: [
                                  Container(
                                    height: 50,
                                    width: 350,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Alamat Pick up :",
                                          style: TextStyle(
                                              color: kTextColor, fontSize: 16),
                                        ),
                                        Container(
                                          height: 50,
                                          width: 200,
                                          child: Text(
                                              "Jl. Pulo kambing II no.2, Kawasan Industri Pulogadung, Gedung Holding",
                                              style: TextStyle(
                                                color: kTextColor,
                                                fontSize: 14,
                                              ),
                                              textAlign: TextAlign.start),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      MaterialButton(
                                        onPressed: () async {
                                          if (metodeorder == "") {
                                            Fluttertoast.showToast(
                                                msg:
                                                    "Pilih Metode Order Dahulu!");
                                          } else if (metodepembayaran == "") {
                                            Fluttertoast.showToast(
                                                msg:
                                                    "Pilih Metode Pemesanan Dahulu!");
                                          } else if (metodeorder == "" &&
                                              metodepembayaran == "") {
                                            Fluttertoast.showToast(
                                                msg:
                                                    "Pilih Form Diatas Dahulu!");
                                          } else {
                                            proses();
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        PaymentPage(
                                                          order: widget.order
                                                              .orderNumber,
                                                        )));
                                          }
                                        },
                                        height: 45,
                                        color: Colors.green,
                                        child: Text(
                                          "Proses",
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
                                      MaterialButton(
                                        onPressed: () async {
                                          CoolAlert.show(
                                            context: context,
                                            type: CoolAlertType.confirm,
                                            title: 'Cancel Order?',
                                            cancelBtnText: 'Yes',
                                            cancelBtnTextStyle: TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold),
                                            confirmBtnText: 'Cancel',
                                            confirmBtnTextStyle: TextStyle(
                                              color: Colors.white,
                                            ),
                                            confirmBtnColor: Colors.green,
                                            onCancelBtnTap: () => cancelOrder(),
                                            onConfirmBtnTap: () =>
                                                Navigator.of(context)..pop(),
                                          );
                                        },
                                        height: 45,
                                        color: Colors.red,
                                        child: Text(
                                          "Cancel",
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
                                ],
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MaterialButton(
                                  onPressed: () async {
                                    if (metodeorder == "") {
                                      Fluttertoast.showToast(
                                          msg: "Pilih Metode Order Dahulu!");
                                    } else if (metodepembayaran == "") {
                                      Fluttertoast.showToast(
                                          msg:
                                              "Pilih Metode Pemesanan Dahulu!");
                                    } else if (metodeorder == "" &&
                                        metodepembayaran == "") {
                                      Fluttertoast.showToast(
                                          msg: "Pilih Form Diatas Dahulu!");
                                    } else {
                                      proses();
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (context) => PaymentPage(
                                                    order: widget
                                                        .order.orderNumber,
                                                  )));
                                    }
                                  },
                                  height: 45,
                                  color: Colors.green,
                                  child: Text(
                                    "Proses",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16.0),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 50),
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
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold),
                                      confirmBtnText: 'Cancel',
                                      confirmBtnTextStyle: TextStyle(
                                        color: Colors.white,
                                      ),
                                      confirmBtnColor: Colors.green,
                                      onCancelBtnTap: () => cancelOrder(),
                                      onConfirmBtnTap: () =>
                                          Navigator.of(context)..pop(),
                                    );
                                  },
                                  height: 45,
                                  color: Colors.red,
                                  child: Text(
                                    "Cancel",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16.0),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                              ],
                            ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

List<TotalBelanja> listTotal = [];

class PaymentPage extends StatefulWidget {
  const PaymentPage({Key? key, required this.order}) : super(key: key);
  final String order;

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage>
    with SingleTickerProviderStateMixin {
  late AnimationController loadingController;
  int _subTotal = 0;
  String vAaccount = "12001234567", gPay = "081234567890", nama = "";
  File? image;

  repositoryTotal() async {
    try {
      final response = await http.post(Uri.parse(listurl.total), body: {
        "order_num": widget.order,
      });

      if (response.statusCode == 200) {
        Iterable it = jsonDecode(response.body);
        List<TotalBelanja> product =
            it.map((e) => TotalBelanja.fromJson(e)).toList();
        return product;
      }
    } catch (e) {
      print(e.toString());
    }
  }

  getDataBelanja() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        nama = preferences.getString('namauser')!;
      });
      listTotal = await repositoryTotal();
    } catch (e) {
      print(e);
    }

    int subtotal = 0;

    for (int i = 0; i < listTotal.length; i++) {
      if (listTotal[i].prodPrice.trim() != "0") {
        subtotal += (int.parse(listTotal[i].qty) *
            int.parse(listTotal[i].prodPrice.replaceAll(',', '')));
      }
    }
    if (!mounted) return;
    setState(() {
      _subTotal = subtotal;
    });
  }

  Future selectFile(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;

      final imageTemp = File(image.path);
      if (!mounted) return;
      setState(() => this.image = imageTemp);
    } on PlatformException catch (e) {
      print('Failed to send Image: $e');
    }
  }

  Future<ImageSource?> showImageSource(BuildContext context) async {
    return showModalBottomSheet(
        context: context,
        builder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.camera_alt),
                  title: Text('Camera'),
                  onTap: () => Navigator.of(context).pop(ImageSource.camera),
                ),
                ListTile(
                  leading: Icon(Icons.image),
                  title: Text('Gallery'),
                  onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                ),
              ],
            ));
  }

  Future uploadPembayaran() async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => HomePage()));
    final uri = Uri.parse(listurl.uploadbayar);
    var request = http.MultipartRequest('POST', uri);
    request.fields['name'] = nama;
    request.fields['order_num'] = widget.order;
    var pict = await http.MultipartFile.fromPath('buktibayar', image!.path);
    request.files.add(pict);
    var response = await request.send();

    if (response.statusCode == 200) {
      print('Image Uploaded');
    } else {
      print('Upload Failed');
    }
  }

  cancelOrder() async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => HomePage()));
    try {
      final response = await http.post(Uri.parse(listurl.cancelorder), body: {
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
    loadingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addListener(() {
        if (!mounted) return;
        setState(() {});
      });
    getDataBelanja();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text("Pembayaran", style: TextStyle(color: kTextColor)),
        iconTheme: IconThemeData(color: kTextColor),
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kDefaultPaddin * 1.3),
        child: Column(
          children: [
            DottedBorder(
              borderType: BorderType.RRect,
              radius: Radius.circular(10),
              dashPattern: [10, 4],
              strokeCap: StrokeCap.round,
              color: Colors.red.shade400,
              child: Container(
                width: 320,
                height: 140,
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Total Belanja : Rp." +
                            NumberFormat.currency(
                                    locale: 'ID', symbol: "", decimalDigits: 0)
                                .format(_subTotal),
                        style: TextStyle(
                            color: kTextColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Biaya Pengiriman : Free",
                        style: TextStyle(
                            color: kTextColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      Divider(
                        thickness: 2,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            "Total Pembayaran : Rp." +
                                NumberFormat.currency(
                                        locale: 'ID',
                                        symbol: "",
                                        decimalDigits: 0)
                                    .format(_subTotal),
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: 17,
                                fontWeight: FontWeight.bold),
                          ),
                          InkWell(
                            onTap: () {
                              Clipboard.setData(
                                  ClipboardData(text: _subTotal.toString()));
                              Fluttertoast.showToast(
                                  msg: "Total Belanja Berhasil di Copy");
                            },
                            child: Icon(
                              Icons.copy,
                              size: 16,
                            ),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            "Virtual Account : " + vAaccount,
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: 17,
                                fontWeight: FontWeight.bold),
                          ),
                          InkWell(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: vAaccount));
                              Fluttertoast.showToast(
                                  msg: "Virtual Account Berhasil di Copy");
                            },
                            child: Icon(
                              Icons.copy,
                              size: 16,
                            ),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            "GOPAY Transfer : " + gPay,
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: 17,
                                fontWeight: FontWeight.bold),
                          ),
                          InkWell(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: gPay));
                              Fluttertoast.showToast(
                                msg: "Nomor GOPAY Berhasil di Copy",
                              );
                            },
                            child: Icon(
                              Icons.copy,
                              size: 16,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 35,
            ),
            Text(
              'Upload Bukti Bayar',
              style: TextStyle(
                  fontSize: 25, color: kTextColor, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: () async {
                final source = await showImageSource(context);
                if (source == null) return;

                selectFile(source);
              },
              child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
                  child: DottedBorder(
                      borderType: BorderType.RRect,
                      radius: Radius.circular(10),
                      dashPattern: [10, 4],
                      strokeCap: StrokeCap.round,
                      color: Colors.blue.shade400,
                      child: image == null
                          ? Container(
                              height: 250,
                              width: 250,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.folder_open_outlined),
                                  Text(
                                    'Upload',
                                    style: TextStyle(
                                        fontSize: 15, color: kTextLightColor),
                                  ),
                                ],
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                image!,
                                fit: BoxFit.fill,
                                width: 250,
                                height: 250,
                              ),
                            ))),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MaterialButton(
                  onPressed: () async {
                    if (image == null) {
                      Fluttertoast.showToast(
                          msg: "Masukkan Bukti Pembayaran Dahulu!");
                    } else {
                      CoolAlert.show(
                        context: context,
                        type: CoolAlertType.success,
                        title: 'Pembayaran Sukses!',
                        confirmBtnText: 'Ok',
                        onConfirmBtnTap: () => uploadPembayaran(),
                      );
                    }
                  },
                  height: 45,
                  color: Colors.green,
                  child: Text(
                    "Kirim Bukti",
                    style: TextStyle(color: Colors.white, fontSize: 16.0),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 50),
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
                        onConfirmBtnTap: () => Navigator.of(context)..pop());
                  },
                  height: 45,
                  color: Colors.red,
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: Colors.white, fontSize: 16.0),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ],
            ),
          ],
        ),
      )),
    );
  }
}

class Gmaps extends StatefulWidget {
  final String order;
  const Gmaps({Key? key, required this.order}) : super(key: key);

  @override
  _GmapsState createState() => _GmapsState();
}

class _GmapsState extends State<Gmaps> {
  static const _initialCameraPosition = CameraPosition(
      target: LatLng(-6.168777761085537, 106.79041927085332), zoom: 14.5);

  late GoogleMapController _googleMapController;
  var alamat = "";

  Map<String, Marker> _markers = {};

  Future proses() async {
    var response = await http.post(Uri.parse(listurl.setalamat), body: {
      "order_number": widget.order,
      "lat": lat,
      "long": long,
    });

    var data = json.decode(response.body);
    var msg = data['message'];
    Navigator.pop(context);
    setState(() {});
    print(msg);
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
        title: Text("Pilih Alamat", style: TextStyle(color: kTextColor)),
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
        markers: _markers.values.toSet(),
        onLongPress: (LatLng latLng) {
          Marker marker = Marker(
            markerId: MarkerId(latLng.toString()),
            position: latLng,
          );
          if (!mounted) return;
          setState(() {
            lat = latLng.latitude.toString();
            long = latLng.longitude.toString();
            _markers[latLng.toString()] = marker;
          });
          print('${latLng.latitude}, ${latLng.longitude}');
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => proses(),
        child: const Icon(Icons.done),
      ),
    );
  }
}
