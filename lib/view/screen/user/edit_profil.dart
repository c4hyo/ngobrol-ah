import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ngobrol_ah/network/model/user_model.dart';
import 'package:ngobrol_ah/network/services/user.dart';
import 'package:ngobrol_ah/utilities/storage.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class UserEditProfil extends StatefulWidget {
  final UserModel userModel;
  final User user;

  const UserEditProfil({Key key, this.userModel, this.user}) : super(key: key);
  @override
  _UserEditProfilState createState() => _UserEditProfilState();
}

class _UserEditProfilState extends State<UserEditProfil> {
  File _foto;
  String _nama, _telepon, _fotoProfil, _bio;
  ImagePicker _picker = new ImagePicker();
  bool _isLoading = false;

  GlobalKey<FormState> _form = GlobalKey<FormState>();

  _handleImage() async {
    final imageFile = await _picker.getImage(source: ImageSource.gallery);
    if (imageFile != null) {
      setState(() {
        _foto = File(imageFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Form(
            key: _form,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _handleImage,
                      child: Container(
                        height: 200,
                        width: 200,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.center,
                                child: CircleAvatar(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  maxRadius: 200,
                                  backgroundImage: (_foto != null)
                                      ? FileImage(_foto)
                                      : (widget.userModel.fotoProfil == "")
                                          ? AssetImage("asset/logo.png")
                                          : NetworkImage(
                                              widget.userModel.fotoProfil,
                                            ),
                                ),
                              ),
                            ),
                            (_foto == null)
                                ? Positioned.fill(
                                    top: 5,
                                    right: 15,
                                    child: Align(
                                      alignment: Alignment.topRight,
                                      child: Icon(
                                        Icons.create,
                                        size: 40,
                                      ),
                                    ),
                                  )
                                : SizedBox.shrink(),
                          ],
                        ),
                      ),
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
                        initialValue: widget.userModel.nama,
                        onSaved: (newValue) {
                          _nama = newValue;
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Nama harus di isi";
                          }
                          return null;
                        },
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          labelText: "Nama",
                          labelStyle: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                          prefixIcon: Icon(
                            Icons.person_outline,
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
                  Card(
                    color: Colors.grey[100],
                    elevation: 0.5,
                    shadowColor: Theme.of(context).primaryColor,
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        initialValue: widget.userModel.telepon,
                        onSaved: (newValue) {
                          _telepon = newValue;
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Nomor telepon harus di isi";
                          }
                          return null;
                        },
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          labelText: "Nomor Telepon",
                          labelStyle: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                          prefixIcon: Icon(
                            Icons.phone,
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
                  Card(
                    color: Colors.grey[100],
                    elevation: 0.5,
                    shadowColor: Theme.of(context).primaryColor,
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: TextFormField(
                        keyboardType: TextInputType.multiline,
                        maxLength: null,
                        initialValue: widget.userModel.bio,
                        onSaved: (newValue) {
                          _bio = newValue;
                        },
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          labelText: "Bio",
                          labelStyle: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                          prefixIcon: Icon(
                            Icons.description,
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
                  MaterialButton(
                    child: (_isLoading)
                        ? CircularProgressIndicator(
                            valueColor: new AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          )
                        : Text(
                            "Ubah Profil",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                    onPressed: () async {
                      if (_form.currentState.validate()) {
                        _form.currentState.save();
                        if (_foto == null) {
                          _fotoProfil = widget.userModel.fotoProfil;
                        } else {
                          _fotoProfil =
                              await StorageService.uploadUserPhotoImage(
                            widget.userModel.fotoProfil,
                            _foto,
                            category: "users",
                          );
                        }
                        setState(() {
                          _isLoading = true;
                        });
                        UserModel model = UserModel(
                          bio: _bio,
                          fotoProfil: _fotoProfil,
                          nama: _nama,
                          telepon: _telepon,
                        );
                        try {
                          await UserServices.updateProfil(
                            user: widget.user,
                            userModel: model,
                          );
                          Get.back();
                        } catch (e) {
                          setState(() {
                            _isLoading = false;
                          });
                          Alert(
                            context: context,
                            title: "Gagal",
                            type: AlertType.error,
                          ).show();
                        }
                      }
                    },
                    minWidth: double.infinity,
                    height: 60,
                    color: Theme.of(context).primaryColor,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
