import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:convert';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _listaTarefas = [];
  TextEditingController _controllerTarefa = TextEditingController();
  Map<String, dynamic> _ultimoTarefaRemovida = Map();

  @override
  void initState() {
    super.initState();
    _lerArquivo().then((dados) {
      setState(() {
        _listaTarefas = json.decode(dados);
      });
    });
  }

  Future<File> _getFile() async {
    final diretorio = await getApplicationDocumentsDirectory();
    return File("${diretorio.path}/datas.json");
  }

  _salvarArquivo() async {
    var arquivo = await _getFile();

    String dados = json.encode(_listaTarefas);
    arquivo.writeAsString(dados);
  }

  _salvarTarefa() {
    String textoDigitado = _controllerTarefa.text;
    //Criar dados
    Map<String, dynamic> tarefa = Map();
    tarefa["titulo"] = textoDigitado;
    tarefa["realizada"] = false;
    setState(() {
      _listaTarefas.add(tarefa);
    });

    _salvarArquivo();
    _controllerTarefa.text = "";
  }

  _lerArquivo() async {
    try {
      final arquivo = await _getFile();
      return arquivo.readAsString();
    } catch (e) {
      return null;
    }
  }

  Widget criarItemLista(context, index) {
    // final item = _listaTarefas[index]['titulo'];
    return Dismissible(
      key: Key(DateTime.now()
          .millisecondsSinceEpoch
          .toString()), //gera uma key totalmente diferente a cada vez, evitando o erro de key igual quando desfaz a retirada de uma tarefa
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        //recuperar úçtimo item excluído
        _ultimoTarefaRemovida = _listaTarefas[index];
        //Remove item da lista
        _listaTarefas.removeAt(index);
        _salvarArquivo();
        //snackbar
        final snackBar = SnackBar(
          duration: Duration(
            seconds: 5,
          ),
          action: SnackBarAction(
            label: "Desfazer",
            onPressed: () {
              //Insere novamente item removido na lista
              setState(() {
                _listaTarefas.insert(index, _ultimoTarefaRemovida);
              });

              _salvarArquivo();
            },
          ),
          content: Text('Tarefa removida!!'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      },
      background: Container(
        color: Colors.red,
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ],
        ),
      ),
      child: CheckboxListTile(
        title: Text(_listaTarefas[index]['titulo']),
        value: _listaTarefas[index]['realizada'],
        onChanged: (valorAlterado) {
          setState(() {
            _listaTarefas[index]['realizada'] = valorAlterado;
          });

          _salvarArquivo();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Tarefas'),
        centerTitle: true,
        backgroundColor: Colors.purple[400],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Adicionar Tarefa'),
                  content: TextField(
                    controller: _controllerTarefa,
                    decoration: InputDecoration(
                      labelText: "Digite sua tarefa",
                    ),
                    onChanged: (text) {},
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancelar',
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        //salvar
                        _salvarTarefa();
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Salvar',
                      ),
                    ),
                  ],
                );
              });
        },
        backgroundColor: Colors.purple[400],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _listaTarefas.length,
              itemBuilder: criarItemLista,
            ),
          )
        ],
      ),
    );
  }
}
