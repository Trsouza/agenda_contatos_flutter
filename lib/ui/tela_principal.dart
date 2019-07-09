import 'dart:io';
import 'package:agenda_contatos_flutter/model/contato_helpers.dart';
import 'package:agenda_contatos_flutter/ui/detalhes_contato.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions {ordemAz, ordemZa}

class TelaPrincipal extends StatefulWidget {
  @override
  _TelaPrincipalState createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {

  ContatoHelper helper = ContatoHelper();
  List<Contato> contatos = List();

  @override
   void initState(){
     super.initState();

     _getTodosContatos();
   }

  // @override
  // void initState(){
  //   super.initState();
  //   Contato c = Contato();
  //   c.nome="ma";
  //   c.email="taaaa";
  //   c.telefone="5464";
  //   c.imagem="dsf";
  //   helper.salvarContato(c);
  //   helper.getContatos().then((list){
  //       print(list);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contatos"),
        backgroundColor: Colors.purple,
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar A-Z"),
                value: OrderOptions.ordemAz,),
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar Z-A"),
                value: OrderOptions.ordemZa,)
            ],
            onSelected: _ordenaLista,
            )
        ],
      ),
      backgroundColor: Colors.purple[50],
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _showDetalheContato();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.purple,
        ),
        body: ListView.builder(
          padding: EdgeInsets.all(10.0),
           itemCount: contatos.length,
          itemBuilder: (context, index){
            return _contatosCard(context, index);

          },
        ),
    );
  }

  Widget _contatosCard(BuildContext contexto, int index){
    return GestureDetector(
      child: Card(
        child: Padding(padding: EdgeInsets.all(10.0),
        child: Row(
          children: <Widget>[
            Container(
              width: 80.0,
              height: 80.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: contatos[index].imagem != null ?
                  FileImage(File(contatos[index].imagem)) :
                  AssetImage("images/icon.png")
                  
                  ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // alinha a esquerda
                children: <Widget>[
                  Text(contatos[index].nome ?? "",
                  style: TextStyle(fontSize: 18.0),
                  ),
                  Text(contatos[index].email ?? "",
                  style: TextStyle(fontSize: 18.0),
                  ),
                  Text(contatos[index].telefone?? "",
                  style: TextStyle(fontSize: 18.0),
                  ),
                ],
              ),
            )
          ],
        ),
        ),
    ),
    onTap: (){
      //_showDetalheContato(contat: contatos[index]);
      _showOpcoes(context, index);
    },
    );
  }

  void _showOpcoes(BuildContext context, int index){
    showModalBottomSheet(
      context: context,
      builder: (context){
        return BottomSheet(
          onClosing: (){},
          builder: (context){
            return Container(
              padding: EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,// tetara ocupar o minimo do tamanho no eixo principal
                children: <Widget>[
                  FlatButton(
                    child: Text("Ligar", 
                      style: TextStyle(color: Colors.purple, fontSize: 20.0),
                    ),
                    onPressed: (){
                      launch("tel:${contatos[index].telefone}");
                      Navigator.pop(context);
                    },
                  ),
                  Divider(),
                  FlatButton(
                    child: Text("Editar", 
                      style: TextStyle(color: Colors.purple, fontSize: 20.0),
                    ),
                    onPressed: (){
                      Navigator.pop(context);// desempilha a tela
                      _showDetalheContato(contat: contatos[index]);
                    },
                  ),
                  FlatButton(
                    child: Text("Excluir", 
                      style: TextStyle(color: Colors.purple, fontSize: 20.0),
                    ),
                    onPressed: (){
                      Navigator.pop(context);// desempilha a tela
                      helper.excluirContato(contatos[index].id);
                      setState(() {
                        contatos.removeAt(index); //remove contato da lista 
                      });
                    },
                  ),
                ],
              ),
            );
        });
      }
    );
  }

  void _showDetalheContato({Contato contat}) async{
    final recebendoContatoDaTela = await Navigator.push(context,
    MaterialPageRoute(builder: (context) => DetalheContato(contato: contat,)));
    if(recebendoContatoDaTela != null){
      if(contat!=null){
        await helper.atualizarContato(recebendoContatoDaTela);
        _getTodosContatos();
      }else{
        await helper.salvarContato(recebendoContatoDaTela);
      }
      _getTodosContatos();
    }
  }
  void _getTodosContatos(){
   helper.getContatos().then((list){
       setState(() {
        contatos = list; 
       });
     }); 
  }
  void _ordenaLista(OrderOptions resultado){
    switch(resultado){
      case OrderOptions.ordemAz:
        contatos.sort((a, b){
          print(resultado);
          return a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
        });
        break;
      case OrderOptions.ordemZa:
        contatos.sort((a, b){
           print(resultado);
           return b.nome.toLowerCase().compareTo(a.nome.toLowerCase());
        });
        break;
    }
    setState(() {
      
    });
  }
}