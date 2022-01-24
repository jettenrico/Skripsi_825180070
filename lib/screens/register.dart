import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:harusnyabisa/utility/repository.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../main.dart';

Url listurl = Url();

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  late String fullname, email, username, pass1, nohp, tgllahir;
  TextEditingController tgllahirctl = TextEditingController();
  bool _secureText = true;
  final _key = new GlobalKey<FormState>();

  showPassword() {
    if (!mounted) return;
    setState(() {
      _secureText = !_secureText;
    });
  }

  check() {
    final form = _key.currentState;
    if (form!.validate()) {
      form.save();
      save();
    }
  }

  save() async {
    final response = await http.post(Uri.parse(listurl.register), body: {
      "user_fullname": fullname,
      "user_phone": nohp,
      "user_email": email,
      "user_name": username,
      "user_password": pass1,
      "tgl_lahir": tgllahir,
    });
    final data = jsonDecode(response.body);
    String value = data['value'];
    String message = data['message'];
    if (value == '1') {
      if (!mounted) return;
      CoolAlert.show(
        context: context,
        type: CoolAlertType.success,
        title: 'Berhasil Register!',
        confirmBtnText: 'Ok',
        onConfirmBtnTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => LoginPage())),
      );
    } else {
      Fluttertoast.showToast(msg: message);
      print(message);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [Colors.blue.shade100, Colors.blue.shade400])),
          padding: EdgeInsets.symmetric(horizontal: 20),
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: <Widget>[
              SizedBox(height: 90),
              Column(
                children: <Widget>[
                  Text(
                    "Sign up",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Create an account, It's free",
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Form(
                key: _key,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      validator: (e) {
                        if (e!.isEmpty) {
                          return "Nama Tidak Boleh Kosong!";
                        }
                      },
                      onSaved: (e) => fullname = e!,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.person,
                          color: Colors.black54,
                        ),
                        labelText: "Nama Lengkap",
                        labelStyle: TextStyle(color: Colors.black54),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(8.00)),
                      ),
                    ),
                    separator(panjang: 10),
                    TextFormField(
                      validator: (e) {
                        if (e!.isEmpty) {
                          return "Email Tidak Boleh Kosong!";
                        }
                      },
                      onSaved: (e) => email = e!,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.mail,
                          color: Colors.black54,
                        ),
                        labelText: "Email",
                        labelStyle: TextStyle(color: Colors.black54),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(8.00)),
                      ),
                    ),
                    separator(panjang: 10),
                    TextFormField(
                      validator: (e) {
                        if (e!.isEmpty) {
                          return "Username Tidak Boleh Kosong!";
                        }
                      },
                      onSaved: (e) => username = e!,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.person,
                          color: Colors.black54,
                        ),
                        labelText: "Username",
                        labelStyle: TextStyle(color: Colors.black54),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(8.00)),
                      ),
                    ),
                    separator(panjang: 10),
                    TextFormField(
                      validator: (e) {
                        if (e!.isEmpty) {
                          return "Password Tidak Boleh Kosong!";
                        }
                      },
                      onSaved: (e) => pass1 = e!,
                      obscureText: _secureText,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.lock,
                          color: Colors.black54,
                        ),
                        labelText: "Password",
                        suffixIcon: IconButton(
                          onPressed: showPassword,
                          icon: Icon(_secureText
                              ? Icons.visibility_off
                              : Icons.visibility),
                        ),
                        labelStyle: TextStyle(color: Colors.black54),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(8.00)),
                      ),
                    ),
                    separator(panjang: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: TextFormField(
                            validator: (e) {
                              if (e!.isEmpty) {
                                return "Nomor HP Tidak Boleh Kosong!";
                              }
                            },
                            onSaved: (e) => nohp = e!,
                            maxLength: 13,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9]')),
                            ],
                            decoration: InputDecoration(
                              counterText: "",
                              labelText: 'Nomor HP',
                              labelStyle: TextStyle(color: Colors.black54),
                              prefixIcon: Icon(
                                Icons.phone,
                                color: Colors.black54,
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black)),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 12,
                        ),
                        Flexible(
                          child: TextFormField(
                            controller: tgllahirctl,
                            onSaved: (e) => tgllahir = e!,
                            validator: (e) {
                              if (e!.isEmpty) {
                                return "Tanggal Lahir";
                              }
                            },
                            decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.calendar_today,
                                  color: Colors.black54,
                                ), //icon of text field
                                labelText: "Tanggal Lahir",
                                labelStyle: TextStyle(color: Colors.black54),
                                focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.black)),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                  borderRadius: BorderRadius.circular(8),
                                )),
                            readOnly: true,
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(1940),
                                  lastDate: DateTime.now());

                              if (pickedDate != null) {
                                print(pickedDate);
                                String formattedDate =
                                    DateFormat('yyyy-MM-dd').format(pickedDate);
                                print(formattedDate);
                                if (!mounted) return;
                                setState(() {
                                  tgllahirctl.text = formattedDate;
                                  tgllahir = formattedDate;
                                });
                              } else {
                                print("Date is not selected");
                              }
                            },
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              MaterialButton(
                onPressed: () {
                  check();
                  /* Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LoginPage()));*/
                },
                height: 45,
                color: Colors.black,
                child: Text(
                  "Register",
                  style: TextStyle(color: Colors.white, fontSize: 16.0),
                ),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Already have an account?",
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => LoginPage()));
                    },
                    child: Text(
                      " Login",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget separator({required double panjang}) {
    return SizedBox(
      height: panjang,
    );
  }
}

class LupaPassword extends StatefulWidget {
  const LupaPassword({Key? key}) : super(key: key);

  @override
  _LupaPasswordState createState() => _LupaPasswordState();
}

class _LupaPasswordState extends State<LupaPassword> {
  late String email;
  TextEditingController tgllahirctl = TextEditingController();
  final _key = new GlobalKey<FormState>();

  check() {
    final form = _key.currentState;
    if (form!.validate()) {
      form.save();
      sendEmail();
    } else {
      Fluttertoast.showToast(
          msg: 'Isi Email Dahulu!', gravity: ToastGravity.CENTER);
    }
  }

  sendEmail() async {
    final response = await http.post(Uri.parse(listurl.lupapass), body: {
      "user_email": email,
    });
    final data = jsonDecode(response.body);
    String value = data['value'];
    String message = data['message'];
    if (value == '1') {
      if (!mounted) return;
      CoolAlert.show(
        context: context,
        type: CoolAlertType.success,
        title: 'Silahkan Cek Email Anda!',
        confirmBtnText: 'Ok',
        onConfirmBtnTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => LoginPage())),
      );
    } else {
      CoolAlert.show(
        context: context,
        type: CoolAlertType.error,
        title: message,
        confirmBtnText: 'Ok',
        onConfirmBtnTap: () => Navigator.pop(context),
      );
      print(message);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [Colors.blue.shade100, Colors.blue.shade400])),
          padding: EdgeInsets.symmetric(horizontal: 20),
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: <Widget>[
              SizedBox(height: 90),
              Column(
                children: <Widget>[
                  Text(
                    "Forgot Password",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Relax, we're here to help!",
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Form(
                key: _key,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      validator: (e) {
                        if (e!.isEmpty) {
                          return "Email Tidak Boleh Kosong!";
                        }
                      },
                      onSaved: (e) => email = e!,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.mail,
                          color: Colors.black54,
                        ),
                        labelText: "Email",
                        labelStyle: TextStyle(color: Colors.black54),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(8.00)),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              MaterialButton(
                onPressed: () {
                  check();
                },
                height: 45,
                color: Colors.black,
                child: Text(
                  "Reset Password",
                  style: TextStyle(fontSize: 16.0, color: Colors.white),
                ),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Remember your password?",
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => LoginPage()));
                    },
                    child: Text(
                      " Login",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
