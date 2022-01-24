import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:harusnyabisa/utility/repository.dart';
import 'package:harusnyabisa/models/product.dart';
import 'package:harusnyabisa/constants.dart';
import 'package:harusnyabisa/screens/detailproduct.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:http/http.dart' as http;

List<ProductList> listProduct = [];
List<ProductList> _searchProduct = [];

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: kDefaultPaddin),
            child: Text(
              "Martha Tilaar Products",
              style: Theme.of(context)
                  .textTheme
                  .headline5!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 20,
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
                      return InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => DetailProduct(
                                    product: b,
                                  )));
                        },
                        child: Column(
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
                        ),
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
                      return InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => DetailProduct(
                                    product: a,
                                  )));
                        },
                        child: Column(
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
                        ),
                      );
                    }),
          ))
        ],
      ),
    );
  }
}

class PemesananProduct extends StatefulWidget {
  const PemesananProduct({Key? key}) : super(key: key);

  @override
  _PemesananProductState createState() => _PemesananProductState();
}

class _PemesananProductState extends State<PemesananProduct> {
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
        title: Text("Pemesanan Produk", style: TextStyle(color: kTextColor)),
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
                      return InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => DetailProductBA(
                                    product: b,
                                  )));
                        },
                        child: Column(
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
                        ),
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
                      return InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => DetailProductBA(
                                    product: a,
                                  )));
                        },
                        child: Column(
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
                        ),
                      );
                    }),
          ))
        ],
      ),
    );
  }
}
