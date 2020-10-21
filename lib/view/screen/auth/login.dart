import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ngobrol_ah/network/services/user.dart';
import 'package:ngobrol_ah/view/screen/auth/forgot_password.dart';
import 'package:ngobrol_ah/view/screen/auth/regis.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  String _email, _password;
  GlobalKey<FormState> _form = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Container(
            height: double.infinity,
            width: double.infinity,
            child: Form(
              key: _form,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      height: 150,
                      width: 150,
                      child: Center(
                        child: Image(
                          image: AssetImage("asset/logo.png"),
                        ),
                      ),
                    ),
                    Text(
                      "NGOBROL KUY",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Card(
                      color: Colors.grey[100],
                      elevation: 0.5,
                      shadowColor: Theme.of(context).primaryColor,
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: TextFormField(
                          onSaved: (newValue) {
                            _email = newValue;
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return "Email harus di isi";
                            }
                            if (!EmailValidator.validate(value)) {
                              return "Format email salah";
                            }
                            return null;
                          },
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            labelText: "Email",
                            labelStyle: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                            prefixIcon: Icon(
                              Icons.mail_outline,
                              color: Theme.of(context).primaryColor,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Card(
                      color: Colors.grey[100],
                      elevation: 0.5,
                      shadowColor: Theme.of(context).primaryColor,
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: TextFormField(
                          onSaved: (newValue) {
                            _password = newValue;
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return "Password harus di isi";
                            }
                            return null;
                          },
                          obscureText: true,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            labelText: "Password",
                            labelStyle: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: Theme.of(context).primaryColor,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          Get.to(
                            ForgotPasswordScreen(),
                            transition: Transition.rightToLeftWithFade,
                          );
                        },
                        child: Text(
                          "Lupa Password ?",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    MaterialButton(
                      color: Theme.of(context).primaryColor,
                      minWidth: double.infinity,
                      height: 60,
                      child: (_isLoading)
                          ? CircularProgressIndicator(
                              valueColor: new AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            )
                          : Text(
                              "LOGIN",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                      onPressed: () async {
                        if (_form.currentState.validate()) {
                          _form.currentState.save();
                          setState(() {
                            _isLoading = true;
                          });
                          try {
                            await UserServices.signIn(
                              email: _email,
                              password: _password,
                            );
                          } catch (e) {
                            setState(() {
                              _isLoading = false;
                            });
                            Alert(
                              context: context,
                              title: "Gagal",
                              type: AlertType.error,
                              desc: "Gagal login",
                              buttons: [
                                DialogButton(
                                  child: Text(
                                    "Tutup",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                  color: Colors.red,
                                ),
                              ],
                            ).show();
                          }
                        }
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Belum punya akun ?"),
                        GestureDetector(
                          onTap: () {
                            Get.to(
                              RegistrasiScreen(),
                              transition: Transition.rightToLeftWithFade,
                            );
                          },
                          child: Text(
                            "  Registrasi sekarang",
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
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
      ),
    );
  }
}
