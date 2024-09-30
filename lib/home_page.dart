import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _ingredientesController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();

  final List<Map<String, String>> _receitas = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _carregarReceitas();
  }

  void _adicionarReceita() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _receitas.add({
          'titulo': _tituloController.text,
          'descricao': _descricaoController.text,
          'ingredientes': _ingredientesController.text,
        });
        _tituloController.clear();
        _descricaoController.clear();
        _ingredientesController.clear();
        _salvarReceitas();
      });
    }
  }

  void _carregarReceitas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? receitaJson = prefs.getString('receitas');

    if (receitaJson != null) {
      setState(() {
        _receitas
            .addAll(List<Map<String, String>>.from(json.decode(receitaJson)));
      });
    }
  }

  void _salvarReceitas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String receitaJson = json.encode(_receitas);
    await prefs.setString('receitas', receitaJson);
  }

  void _removerReceita(int index) {
    setState(() {
      _receitas.removeAt(index);
      _salvarReceitas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        title: const Text('Minhas Receitas'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _tituloController,
                    decoration: const InputDecoration(
                      labelText: 'Título da Receita',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Por favor digite um título';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _ingredientesController,
                    decoration: const InputDecoration(
                      labelText: 'Ingredientes',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Por favor digite os ingredientes';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _descricaoController,
                    decoration: const InputDecoration(
                      labelText: 'Descrição da Receita',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Por favor digite uma descrição';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: _adicionarReceita,
            child: Container(
              margin: const EdgeInsets.all(10),
              width: double.infinity,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: const Center(
                child: Text(
                  'Adicionar Receita',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _receitas.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const CircleAvatar(
                    backgroundImage: NetworkImage(
                      'https://cdn-icons-png.flaticon.com/512/526/526194.png',
                    ),
                  ),
                  title: Text(_receitas[index]['titulo']!),
                  subtitle: Column(
                    children: [
                      Text(_receitas[index]['descricao']!),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _receitas[index]['ingredientes']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                  trailing: IconButton(
                    onPressed: () => _removerReceita(index),
                    icon: const Icon(Icons.delete),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
