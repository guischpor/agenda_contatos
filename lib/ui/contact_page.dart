import 'dart:async';
import 'dart:io';

import 'package:agenda_contatos/helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ContactPage extends StatefulWidget {
  final Contact contact;

  ContactPage({this.contact});
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _text = TextEditingController();

  bool _validate = false;

  final _nameFocus = FocusNode();

  bool _userEdited = false;

  bool _isComposing = false;

  Contact _editedContact;

  final googleSignIn = GoogleSignIn();
  final auth = FirebaseAuth.instance;

//função que verifica se o usuario está online ou faca o login
  Future<Null> _ensureLoggedIn() async {
    GoogleSignInAccount user = googleSignIn.currentUser;
    if (user == null) {
      user = await googleSignIn.signInSilently();
    }

    if (user == null) {
      user = await googleSignIn.signIn();
    }
    if (await auth.currentUser() == null) {
      GoogleSignInAuthentication credentials =
          await googleSignIn.currentUser.authentication;
      await auth.signInWithGoogle(
          idToken: credentials.idToken, accessToken: credentials.accessToken);
    }
  }

  _handleSubmitted(String name, String email, String phone) async {
    await _ensureLoggedIn();
    _saveContact(name: name, email: email, phone: phone);
  }

  void _saveContact({String name, String email, String phone, String imgUrl}) {
    Firestore.instance.collection('contatos').add({
      'name': name,
      'email': email,
      'phone': phone,
      'imgUrl': imgUrl,
      'senderNamer': googleSignIn.currentUser.displayName,
      'senderPhotoUrl': googleSignIn.currentUser.photoUrl
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text(_editedContact.name ?? 'Novo Contato'),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_nameController.text != null &&
                _nameController.text.isNotEmpty) {
              _handleSubmitted(_nameController.text, _emailController.text,
                  _phoneController.text);
              Navigator.pop(context);
            } else {
              FocusScope.of(context).requestFocus(_nameFocus);
            }
          },
          child: Icon(
            Icons.save,
            size: 30,
          ),
          backgroundColor: Colors.red,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              GestureDetector(
                child: Container(
                  width: 140.0,
                  height: 140.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: _editedContact.img != null
                            ? FileImage(File(_editedContact.img))
                            : AssetImage('images/avatarNeutro.png')),
                  ),
                ),
                onTap: () {
                  _showOptions(context);
                },
              ),
              TextField(
                controller: _nameController,
                focusNode: _nameFocus,
                decoration: InputDecoration(
                  labelText: 'Nome',
                  labelStyle: TextStyle(fontSize: 20.0, color: Colors.red),
                  errorText: _validate ? 'Preencha o seu nome' : null,
                ),
                onChanged: (name) {
                  _userEdited = true;
                  setState(() {
                    _nameController.text = name;
                  });
                },
                style: TextStyle(fontSize: 25.0, color: Colors.red),
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(fontSize: 20.0, color: Colors.red),
                  errorText: _validate ? 'Preencha o seu email' : null,
                ),
                onChanged: (email) {
                  _userEdited = true;
                  _emailController.text = email;
                },
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(fontSize: 25.0, color: Colors.red),
              ),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone',
                  labelStyle: TextStyle(fontSize: 20.0, color: Colors.red),
                  errorText: _validate ? 'Preencha o seu phone' : null,
                ),
                onChanged: (phone) {
                  _userEdited = true;
                  _phoneController.text = phone;
                },
                keyboardType: TextInputType.phone,
                style: TextStyle(fontSize: 25.0, color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //função retorna uma informação alertando se desaja sair sem salvar o contato
  Future<bool> _requestPop() async {
    if (_userEdited) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Descartar Alterações'),
              content: Text('Se sair as alterações serão perdidas.'),
              actions: <Widget>[
                FlatButton(
                  child: Text('Cancelar'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text('Sim'),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          });
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
            onClosing: () {},
            builder: (context) {
              return Container(
                padding: EdgeInsets.all(10.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          FlatButton(
                            child: Icon(
                              Icons.camera,
                              size: 80,
                              color: Colors.red,
                            ),
                            onPressed: () async {
                              await _ensureLoggedIn();
                              ImagePicker.pickImage(source: ImageSource.camera)
                                  .then((imgFile) async {
                                if (imgFile == null) return;
                                StorageUploadTask task = FirebaseStorage
                                    .instance
                                    .ref()
                                    .child(
                                        googleSignIn.currentUser.id.toString() +
                                            DateTime.now()
                                                .millisecondsSinceEpoch
                                                .toString())
                                    .putFile(imgFile);
                                StorageTaskSnapshot taskSnapshot =
                                    await task.onComplete;
                                String url =
                                    await taskSnapshot.ref.getDownloadURL();
                                _saveContact(imgUrl: url);
                                Navigator.pop(context);
                              });
                            },
                          ),
                          Text(
                            'Câmera',
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          FlatButton(
                            child: Icon(
                              Icons.photo_library,
                              size: 80,
                              color: Colors.red,
                            ),
                            onPressed: () async {
                              await _ensureLoggedIn();
                              ImagePicker.pickImage(source: ImageSource.gallery)
                                  .then((imgFile) async {
                                if (imgFile == null) return;
                                StorageUploadTask task = FirebaseStorage
                                    .instance
                                    .ref()
                                    .child(
                                        googleSignIn.currentUser.id.toString() +
                                            DateTime.now()
                                                .millisecondsSinceEpoch
                                                .toString())
                                    .putFile(imgFile);
                                StorageTaskSnapshot taskSnapshot =
                                    await task.onComplete;
                                String url =
                                    await taskSnapshot.ref.getDownloadURL();
                                _saveContact(imgUrl: url);
                                Navigator.pop(context);
                              });
                            },
                          ),
                          Text(
                            'Galeria',
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        });
  }
}
