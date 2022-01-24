import 'dart:convert';

import 'package:basic_utils/basic_utils.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:harusnyabisa/utility/repository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:get_ip_address/get_ip_address.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants.dart';
import 'package:harusnyabisa/models/help.dart';
import '../main.dart';

List<Help> listHelp = [];

Future logOut(BuildContext context) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.clear();
  Fluttertoast.showToast(
      msg: "Logout berhasil!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0);
  Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => WelcomePage()));
  // Navigator.push(
  //     context, MaterialPageRoute(builder: (context) => WelcomePage()));
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  var nama = "", iduser = "", nik = "", ip = "";

  Future getUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      nama = preferences.getString('namauser')!;
      iduser = preferences.getString('usernumber')!;
      nik = preferences.getString('usernik')!;
    });
  }

  Future getIp() async {
    try {
      var ipAddress = IpAddress(type: RequestType.text);
      dynamic data = await ipAddress.getIpAddress();
      if (!mounted) return;
      setState(() {
        ip = data.toString();
      });
    } on IpAddressException catch (exception) {
      print(exception.message);
    }
  }

  File? image;

  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) return;

      final imageTemp = File(image.path);
      if (!mounted) return;
      setState(() => this.image = imageTemp);
    } on PlatformException catch (e) {
      print('Failed to send Image: $e');
    }
  }

  Future uploadAbsen() async {
    var inpt = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(inpt);

    final uri = Uri.parse(listurl.absen);
    var request = http.MultipartRequest('POST', uri);
    request.fields['name'] = nama;
    request.fields['user_number'] = iduser;
    request.fields['user_nik'] = nik;
    request.fields['time'] = formattedDate;
    request.fields['ipuser'] = ip;
    var pict = await http.MultipartFile.fromPath('file_photo', image!.path);
    request.files.add(pict);
    var response = await request.send();

    if (response.statusCode == 200) {
      CoolAlert.show(
          context: context,
          type: CoolAlertType.success,
          title: 'Absen Berhasil!',
          confirmBtnText: 'OK',
          onConfirmBtnTap: () => Navigator.of(context)..pop());
      print('Image Uploaded');
    } else {
      print('Upload Failed');
    }
  }

  @override
  void initState() {
    getUser();
    getIp();
    super.initState();
  }

  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              InkWell(
                onTap: () {
                  pickImage();
                },
                child: CircleAvatar(
                  foregroundImage: image != null
                      ? Image.file(image!).image
                      : Image.asset('assets/profile.png').image,
                  radius: 80,
                  backgroundColor: Colors.transparent,
                ),
              ),
              SizedBox(
                height: 24,
              ),
              Text("Selamat Datang",
                  style: TextStyle(
                      color: kTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 26)),
              Text(StringUtils.capitalize(nama, allWords: true) + "!",
                  style: TextStyle(
                      color: kTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 26)),
              SizedBox(height: 20),
              MaterialButton(
                onPressed: () {
                  launch('http://178.1.77.123/skripsi/usermanualsales.pdf');
                },
                height: 45,
                color: Colors.green,
                child: Text(
                  "  Help  ",
                  style: TextStyle(color: Colors.white, fontSize: 16.0),
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
                  image == null
                      ? CoolAlert.show(
                          context: context,
                          type: CoolAlertType.error,
                          title: 'Upload Foto Dahulu!',
                          confirmBtnText: 'OK',
                          onConfirmBtnTap: () => Navigator.of(context)..pop())
                      : uploadAbsen();
                },
                height: 45,
                color: Colors.black,
                child: Text(
                  "Absen",
                  style: TextStyle(color: Colors.white, fontSize: 16.0),
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
                  CoolAlert.show(
                      context: context,
                      type: CoolAlertType.confirm,
                      title: 'Anda Yakin ingin Logout?',
                      cancelBtnText: 'Yes',
                      cancelBtnTextStyle: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),
                      confirmBtnText: 'Cancel',
                      confirmBtnTextStyle: TextStyle(
                        color: Colors.white,
                      ),
                      confirmBtnColor: Colors.green,
                      onCancelBtnTap: () => logOut(context),
                      onConfirmBtnTap: () => Navigator.of(context)..pop());
                },
                height: 45,
                color: Colors.red,
                child: Text(
                  "  Log Out  ",
                  style: TextStyle(color: Colors.white, fontSize: 16.0),
                ),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileCust extends StatefulWidget {
  const ProfileCust({Key? key}) : super(key: key);

  @override
  _ProfileCustState createState() => _ProfileCustState();
}

class _ProfileCustState extends State<ProfileCust> {
  var nama = "", typeuser = "";
  Url listurl = Url();

  void dispose() {
    super.dispose();
  }

  Future getUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      nama = preferences.getString('namauser')!;
      typeuser = preferences.getString('tipeuser')!;
    });
  }

  @override
  void initState() {
    getUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height / 3,
              decoration: BoxDecoration(
                  image: DecorationImage(image: AssetImage('assets/sgs.png'))),
            ),
            Text("Selamat Datang",
                style: TextStyle(
                    color: kTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 26)),
            Text(StringUtils.capitalize(nama, allWords: true) + "!",
                style: TextStyle(
                    color: kTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 26)),
            SizedBox(
              height: 30,
            ),
            MaterialButton(
              onPressed: () {
                typeuser == "Customer"
                    ? launch('http://178.1.77.123/skripsi/usermanual.pdf')
                    : launch(
                        'http://178.1.77.123/skripsi/usermanualprinciple.pdf');
              },
              height: 45,
              color: Colors.green,
              child: Text(
                "    Help    ",
                style: TextStyle(color: Colors.white, fontSize: 16.0),
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
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => EditProfil()));
              },
              height: 45,
              color: Colors.black,
              child: Text(
                "Edit Profil",
                style: TextStyle(color: Colors.white, fontSize: 16.0),
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
                CoolAlert.show(
                    context: context,
                    type: CoolAlertType.confirm,
                    title: 'Anda Yakin ingin Logout?',
                    cancelBtnText: 'Yes',
                    cancelBtnTextStyle: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                    confirmBtnText: 'Cancel',
                    confirmBtnTextStyle: TextStyle(
                      color: Colors.white,
                    ),
                    confirmBtnColor: Colors.green,
                    onCancelBtnTap: () => logOut(context),
                    onConfirmBtnTap: () => Navigator.of(context)..pop());
              },
              height: 45,
              color: Colors.red,
              child: Text(
                "    Log Out    ",
                style: TextStyle(color: Colors.white, fontSize: 16.0),
              ),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditProfil extends StatefulWidget {
  const EditProfil({Key? key}) : super(key: key);

  @override
  _EditProfilState createState() => _EditProfilState();
}

class _EditProfilState extends State<EditProfil> {
  String email = "", pass = "", phone = "", userNumber = "";
  final _key = new GlobalKey<FormState>();

  check() async {
    final form = _key.currentState;
    if (form!.validate()) {
      form.save();
      updatePrefs();
      save();
    }
  }

  updatePrefs() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('useremail', email);
    preferences.setString('pass', pass);
    preferences.setString('userphone', phone);
  }

  generateMd5(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

  save() async {
    final response = await http.post(Uri.parse(listurl.editprofil), body: {
      "user_email": email,
      "pass": generateMd5(pass),
      "phone": phone,
      "user_number": userNumber,
    });

    final data = jsonDecode(response.body);
    int value = data['value'];
    String message = data['message'];
    if (value == 1) {
      if (!mounted) return;
      CoolAlert.show(
          context: context,
          type: CoolAlertType.success,
          title: 'Edit Profil Berhasil!',
          confirmBtnText: 'Ok',
          onConfirmBtnTap: () => Navigator.of(context)
            ..pop()
            ..pop());
      setState(() {
        print(message);
      });
    } else {
      print(message);
    }
  }

  Future getUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      email = preferences.getString('useremail')!;
      pass = preferences.getString('pass')!;
      phone = preferences.getString('userphone')!;
      userNumber = preferences.getString('usernumber')!;
    });
  }

  @override
  void initState() {
    getUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController emailctrl = TextEditingController(text: email);
    TextEditingController passctrl = TextEditingController(text: pass);
    TextEditingController phonectrl = TextEditingController(text: phone);
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Edit Profil",
            style: TextStyle(color: kTextColor),
          ),
          iconTheme: IconThemeData(color: kTextColor),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: SingleChildScrollView(
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                height: MediaQuery.of(context).size.height / 2,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Form(
                        key: _key,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: emailctrl,
                              validator: (e) {
                                if (e!.isEmpty) {
                                  return "Email Tidak Boleh Kosong!";
                                }
                              },
                              onSaved: (e) => email = e!,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    emailctrl.clear();
                                  },
                                  icon: Icon(Icons.clear),
                                ),
                                labelText: 'Email',
                                labelStyle: TextStyle(color: Colors.black54),
                                prefixIcon: Icon(
                                  Icons.mail,
                                  color: Colors.black54,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 10),
                                focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.black)),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                    borderRadius: BorderRadius.circular(8.00)),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              validator: (e) {
                                if (e!.isEmpty) {
                                  return "Password Tidak Boleh Kosong!";
                                }
                              },
                              controller: passctrl,
                              onSaved: (e) => pass = e!,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.lock,
                                  color: Colors.black54,
                                ),
                                labelText: "Password",
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    passctrl.clear();
                                  },
                                  icon: Icon(Icons.clear),
                                ),
                                labelStyle: TextStyle(color: Colors.black54),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 10),
                                focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.black)),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                    borderRadius: BorderRadius.circular(8.00)),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              controller: phonectrl,
                              validator: (e) {
                                if (e!.isEmpty) {
                                  return "Nomor HP Tidak Boleh Kosong!";
                                }
                              },
                              onSaved: (e) => phone = e!,
                              maxLength: 13,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9]')),
                              ],
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                counterText: "",
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    phonectrl.clear();
                                  },
                                  icon: Icon(Icons.clear),
                                ),
                                labelText: 'Nomor HP',
                                labelStyle: TextStyle(color: Colors.black54),
                                prefixIcon: Icon(
                                  Icons.phone,
                                  color: Colors.black54,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 10),
                                focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.black)),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                    borderRadius: BorderRadius.circular(8.00)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      MaterialButton(
                        onPressed: () {
                          check();
                        },
                        height: 45,
                        color: Colors.black,
                        child: Text(
                          "Simpan",
                          style: TextStyle(color: Colors.white, fontSize: 16.0),
                        ),
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ]))));
  }
}
