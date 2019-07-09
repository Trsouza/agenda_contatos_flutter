import 'dart:io';

import 'package:agenda_contatos_flutter/model/contato_helpers.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DetalheContato extends StatefulWidget {
  final Contato contato;
  DetalheContato({this.contato}); // ESSE construtor vai servir

  @override
  _DetalheContatoState createState() => _DetalheContatoState();
}

class _DetalheContatoState extends State<DetalheContato> {
  Contato _contatoEditado;
  bool _usuarioEditou = false; // indica se o usuário editou algum campo
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _nomeFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _telefoneFocus = FocusNode();

  GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // serve para validar os forms

  @override
  void initState() {
    super.initState();

    if (widget.contato == null) {
      _contatoEditado = Contato();
    } else {
      _contatoEditado = Contato.fromMap(widget.contato.toMap());

      _nomeController.text = _contatoEditado.nome;
      _emailController.text = _contatoEditado.email;
      _telefoneController.text = _contatoEditado.telefone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope( //permite chamar uma função ao clicar na seta voltar
      onWillPop: _perguntaPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_contatoEditado.nome ?? "Novo Contato"),
          backgroundColor: Colors.purple,
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_contatoEditado.nome != null &&
                _contatoEditado.nome.isNotEmpty) {
              Navigator.pop(context, _contatoEditado); // fecha uma janela
              // }
              // else if (
              //     !_contatoEditado.email.isNotEmpty) {
              //   FocusScope.of(context).requestFocus(_emailFocus);
              // }else  if (
              //     !_contatoEditado.telefone.isNotEmpty) {
              //   FocusScope.of(context).requestFocus(_telefoneFocus);
            } else {
              FocusScope.of(context).requestFocus(_nomeFocus);
            }
          },
          child: Icon(Icons.save),
          backgroundColor: Colors.purple,
        ),
        body: SingleChildScrollView(
            padding: EdgeInsets.all(10.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  GestureDetector(
                    child: Container(
                      width: 80.0,
                      height: 80.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: _contatoEditado.imagem != null
                                ? FileImage(File(_contatoEditado.imagem))
                                : AssetImage("images/icon.png")),
                      ),
                    ),
                    onTap: () {
                      ImagePicker.pickImage(source: ImageSource.camera).then((file){
                        if(file == null){
                          return;
                        }
                        setState(() {
                         _contatoEditado.imagem = file.path; 
                        });
                      });
                    },
                  ),
                  TextField(
                    controller: _nomeController,
                    focusNode: _nomeFocus,
                    decoration: InputDecoration(labelText: "Nome"),
                    onChanged: (texto) {
                      _usuarioEditou = true;
                      setState(() {
                        // a medida que digita o nome altera no titlo do appBar
                        _contatoEditado.nome = texto;
                      });
                    },
                    // validator: (value){
                    //   if(value.isEmpty)
                    //   return"Insira o nome";
                    // },
                  ),
                  TextField(
                    controller: _telefoneController,
                    focusNode: _telefoneFocus,
                    decoration: InputDecoration(labelText: "Telefone"),
                    onChanged: (texto) {
                      _usuarioEditou = true;
                      _contatoEditado.telefone = texto;
                    },
                    keyboardType: TextInputType.phone,
                    // validator: (value){
                    //   if(value.isEmpty)
                    //   return"Insira o telefone";
                    // },
                  ),
                  TextField(
                    controller: _emailController,
                    focusNode: _emailFocus,
                    decoration: InputDecoration(labelText: "Email"),
                    //onChanged: (texto){
                    onChanged: (texto) {
                      _usuarioEditou = true;
                      _contatoEditado.email = texto;
                    },
                    keyboardType: TextInputType.emailAddress,
                    // validator: (value){
                    //   if(value.isEmpty)
                    //   return"Insira o email";
                    // },
                  ),
                ],
              ),
            )),
      ),
    );
  }
  Future<bool> _perguntaPop(){
    if(_usuarioEditou){
      showDialog(context: context,
        builder: (context){
          return AlertDialog(
            title: Text("Descartar Alterações"),
            content: Text("Se sair as alterações serão perdidas"),
            actions: <Widget>[
              FlatButton(
                child: Text("Cancelar"),
                onPressed: (){
                  Navigator.pop(context);
                },
                ),
              FlatButton(
                child: Text("Sim"),
                onPressed: (){
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                ),
            ],
          );
        }
      );
      return Future.value(false);
    }else{
      return Future.value(true);
    }
  }
}
