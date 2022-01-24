import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:harusnyabisa/constants.dart';
import 'package:harusnyabisa/models/product.dart';
import 'package:harusnyabisa/utility/repository.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

Url listurl = Url();
List<ReviewProduk> listReview = [];

String convertToAgo(DateTime input) {
  Duration diff = DateTime.now().difference(input);

  if (diff.inDays >= 1) {
    return '${diff.inDays} day(s) ago';
  } else if (diff.inHours >= 1) {
    return '${diff.inHours} hour(s) ago';
  } else if (diff.inMinutes >= 1) {
    return '${diff.inMinutes} minute(s) ago';
  } else if (diff.inSeconds >= 1) {
    return '${diff.inSeconds} second(s) ago';
  } else {
    return 'just now';
  }
}

class DetailProduct extends StatefulWidget {
  final ProductList product;
  const DetailProduct({Key? key, required this.product}) : super(key: key);

  @override
  State<DetailProduct> createState() => _DetailProductState();
}

class _DetailProductState extends State<DetailProduct> {
  int numOfItems = 1;
  var userNumber = "";
  Future getUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      userNumber = preferences.getString('usernumber')!;
    });
  }

  Future inputKeranjang() async {
    final response = await http.post(Uri.parse(listurl.tambahproduk), body: {
      "user_number": userNumber,
      "prod_number": widget.product.prodNumber,
      "prod_price": widget.product.prodPrice.replaceAll(',', ''),
      "qty": numOfItems.toString(),
    });
    final data = jsonDecode(response.body);
    String value = data['value'];
    String message = data['message'];
    if (value == '1') {
      if (!mounted) return;
      setState(() {
        stockProduct = stockProduct - numOfItems;
        print(message);
        Fluttertoast.showToast(msg: message);
        numOfItems = 1;
      });
    } else {
      stockProduct = stockProduct - numOfItems;
      print(message);
      Fluttertoast.showToast(msg: message);
      numOfItems = 1;
    }
  }

  repositoryReview() async {
    try {
      final response = await http.post(Uri.parse(listurl.showreview), body: {
        "prod_number": widget.product.prodNumber,
      });

      if (response.statusCode == 200) {
        Iterable it = jsonDecode(response.body);
        List<ReviewProduk> review =
            it.map((e) => ReviewProduk.fromJson(e)).toList();
        return review;
      }
    } catch (e) {
      print(e.toString());
    }
  }

  getDataReview() async {
    try {
      listReview = await repositoryReview();
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    getDataReview();
    getUser();
    super.initState();
  }

  late int stockProduct = int.parse(widget.product.stock);
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: HexColor("${widget.product.bgColor}"),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: HexColor("${widget.product.bgColor}"),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: kDefaultPaddin / 2),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: size.height,
                  child: Stack(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(top: size.height * 0.35),
                        // height: 500,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(24),
                                topRight: Radius.circular(24))),
                        child: Column(
                          children: [
                            SizedBox(
                              height: kDefaultPaddin * 5,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: kDefaultPaddin),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  btnInput(
                                      icon: Icons.remove,
                                      press: () {
                                        if (numOfItems > 1) {
                                          if (!mounted) return;
                                          setState(() {
                                            numOfItems--;
                                          });
                                        }
                                      }),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: kDefaultPaddin / 2,
                                        vertical: kDefaultPaddin / 4),
                                    child: stockProduct == 0
                                        ? Text(
                                            "0",
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline6,
                                          )
                                        : Text(
                                            numOfItems
                                                .toString()
                                                .padLeft(2, "0"),
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline6,
                                          ),
                                  ),
                                  btnInput(
                                      icon: Icons.add,
                                      press: () {
                                        if (numOfItems < stockProduct) {
                                          if (!mounted) return;
                                          setState(() {
                                            numOfItems++;
                                          });
                                        }
                                      }),
                                  SizedBox(
                                    width: kDefaultPaddin,
                                  ),
                                  Container(
                                    height: 50,
                                    width: 58,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                            width: 4,
                                            color: HexColor(
                                                "${widget.product.bgColor}"))),
                                    child: IconButton(
                                      icon: Icon(Icons.add_shopping_cart),
                                      onPressed: () {
                                        if (stockProduct == 0) {
                                          Fluttertoast.showToast(
                                              msg: "PRODUCT KOSONG!");
                                        } else {
                                          inputKeranjang();
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            listReview.isEmpty
                                ? Container()
                                : Column(
                                    children: [
                                      SizedBox(height: 20),
                                      Text("Ulasan Pembeli",
                                          style: TextStyle(
                                              color: kTextColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20)),
                                      Container(
                                          height: size.height * 0.4,
                                          child: WidgetReview()),
                                    ],
                                  )
                          ],
                        ),
                      ),
                      WidgetFotoProduk(product: widget.product),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WidgetReview extends StatelessWidget {
  const WidgetReview({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: listReview.length,
        itemBuilder: (context, index) {
          return Card(
            child: Column(
              children: [
                ListTile(
                  title: Text("${listReview[index].namaUser}"),
                  subtitle: Text("${listReview[index].reviewUser}"),
                  trailing: Text(convertToAgo(
                      DateTime.parse("${listReview[index].tanggaltransaksi}"))),
                  leading: CircleAvatar(
                      backgroundImage: AssetImage('assets/profile.png'),
                      backgroundColor: Colors.transparent),
                ),
              ],
            ),
          );
        });
  }
}

class WidgetFotoProduk extends StatefulWidget {
  const WidgetFotoProduk({
    Key? key,
    required this.product,
  }) : super(key: key);

  final ProductList product;

  @override
  State<WidgetFotoProduk> createState() => _WidgetFotoProdukState();
}

class _WidgetFotoProdukState extends State<WidgetFotoProduk> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kDefaultPaddin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            StringUtils.capitalize("${widget.product.prodCategory}",
                allWords: true),
            style: Theme.of(context)
                .textTheme
                .headline4!
                .copyWith(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          Text(
            StringUtils.capitalize("${widget.product.prodName}",
                allWords: true),
            style: TextStyle(color: Colors.black),
          ),
          Text(
            "Terjual : " + "${widget.product.terjual}",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.only(top: kDefaultPaddin * 2),
            child: Hero(
              tag: "${widget.product.prodName}",
              child: Container(
                width: 350,
                height: 270,
                child: Image.network(
                  listurl.fotoproduk + "${widget.product.prodImage}",
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

SizedBox btnInput({required IconData icon, required VoidCallback press}) {
  return SizedBox(
    width: 40,
    height: 32,
    child: OutlinedButton(
      style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          padding: EdgeInsets.zero),
      onPressed: press,
      child: Icon(icon),
    ),
  );
}

class DetailProductBA extends StatefulWidget {
  final ProductList product;
  const DetailProductBA({Key? key, required this.product}) : super(key: key);

  @override
  State<DetailProductBA> createState() => _DetailProductBAState();
}

class _DetailProductBAState extends State<DetailProductBA> {
  int numOfItems = 1;
  var userNumber = "";
  TextEditingController _controller = TextEditingController();
  Future getUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      userNumber = preferences.getString('usernumber')!;
    });
  }

  Future inputOrder() async {
    final response = await http.post(Uri.parse(listurl.productpurchase), body: {
      "user_number": userNumber,
      "prod_number": widget.product.prodNumber,
      "prod_price": widget.product.prodPrice.replaceAll(',', ''),
      "prod_name": widget.product.prodName,
      "qty": _controller.text,
    });
    final data = jsonDecode(response.body);
    String value = data['value'];
    String message = data['message'];
    if (value == '1') {
      if (!mounted) return;
      setState(() {
        stockProduct = stockProduct - numOfItems;
        print(message);
        Fluttertoast.showToast(msg: message);
        numOfItems = 1;
      });
    } else {
      stockProduct = stockProduct - numOfItems;
      print(message);
      Fluttertoast.showToast(msg: message);
      numOfItems = 1;
    }
  }

  @override
  void initState() {
    getUser();
    super.initState();
    _controller.text = "1";
  }

  late int stockProduct = int.parse(widget.product.stock);
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: HexColor("${widget.product.bgColor}"),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: HexColor("${widget.product.bgColor}"),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: kDefaultPaddin / 2),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: size.height,
                  child: Stack(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(top: size.height * 0.35),
                        // height: 500,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(24),
                                topRight: Radius.circular(24))),
                        child: Column(
                          children: [
                            SizedBox(
                              height: kDefaultPaddin * 9,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: kDefaultPaddin),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      btnInput(
                                          icon: Icons.remove,
                                          press: () {
                                            int currentValue =
                                                int.parse(_controller.text);
                                            if (!mounted) return;
                                            setState(() {
                                              print("Setting state");
                                              currentValue--;
                                              _controller.text =
                                                  (currentValue > 0
                                                          ? currentValue
                                                          : 0)
                                                      .toString();
                                            });
                                          }),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: kDefaultPaddin / 2,
                                            vertical: kDefaultPaddin / 4),
                                        child: Container(
                                          width: 64.0,
                                          child: TextFormField(
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline6,
                                            textAlign: TextAlign.center,
                                            decoration: InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.all(8.0),
                                                border: InputBorder.none),
                                            controller: _controller,
                                            keyboardType:
                                                TextInputType.numberWithOptions(
                                              decimal: false,
                                              signed: true,
                                            ),
                                          ),
                                        ),
                                      ),
                                      btnInput(
                                          icon: Icons.add,
                                          press: () {
                                            int currentValue =
                                                int.parse(_controller.text);
                                            if (!mounted) return;
                                            setState(() {
                                              currentValue++;
                                              _controller.text =
                                                  (currentValue).toString();
                                            });
                                          }),
                                      SizedBox(
                                        width: kDefaultPaddin,
                                      ),
                                      Container(
                                        height: 50,
                                        width: 58,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(18),
                                            border: Border.all(
                                                width: 4,
                                                color: HexColor(
                                                    "${widget.product.bgColor}"))),
                                        child: IconButton(
                                          icon: Icon(Icons.add_shopping_cart),
                                          onPressed: () {
                                            inputOrder();
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      WidgetFotoProduk(product: widget.product),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
