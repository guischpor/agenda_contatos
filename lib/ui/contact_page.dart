import 'dart:async';
import 'dart:io';

import 'package:agenda_contatos/helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

  Contact _editedContact;

  @override
  void initState() {
    super.initState();

    if (widget.contact == null) {
      _editedContact = Contact();
    } else {
      _editedContact = Contact.fromMap(widget.contact.toMap());

      _nameController.text = _editedContact.name;
      _emailController.text = _editedContact.email;
      _phoneController.text = _editedContact.phone;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _text.dispose();
    super.dispose();
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
            if (_editedContact.name != null && _editedContact.name.isNotEmpty) {
              Navigator.pop(context, _editedContact);
            } else {
              FocusScope.of(context).requestFocus(_nameFocus);
              /*
              setState(() {
                _nameController.text.isEmpty
                    ? _validate = true
                    : _validate = false;
              });
              */
            }

            /*
            if (_nameController.text.length > 0 &&
                _emailController.text.length > 0 &&
                _phoneController.text.length > 0) {
              Navigator.pop(context, _editedContact);
            } else {
              setState(() {
                _nameController.text.isEmpty
                    ? _validate = true
                    : _validate = false;
                _emailController.text.isEmpty
                    ? _validate = true
                    : _validate = false;
              });
            }
            */
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
                onChanged: (text) {
                  _userEdited = true;
                  setState(() {
                    _editedContact.name = text;
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
                onChanged: (text) {
                  _userEdited = true;
                  _editedContact.email = text;
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
                onChanged: (text) {
                  _userEdited = true;
                  _editedContact.phone = text;
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
                            onPressed: () {
                              ImagePicker.pickImage(source: ImageSource.camera)
                                  .then((file) {
                                if (file == null) return;
                                setState(() {
                                  _editedContact.img = file.path;
                                });
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
                            onPressed: () {
                              ImagePicker.pickImage(source: ImageSource.gallery)
                                  .then((file) {
                                if (file == null) return;
                                setState(() {
                                  _editedContact.img = file.path;
                                });
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
