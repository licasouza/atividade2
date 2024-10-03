import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Classe principal da página
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState(); // Cria o estado associado
}

// Estado da HomePage
class _HomePageState extends State<HomePage> {
  // Controladores de texto para os campos de entrada
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _ingredientesController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();

  // Lista para armazenar as receitas
  final List<Map<String, dynamic>> _receitas = [];

  // Chave global para validação do formulário
  final _formKey = GlobalKey<FormState>();

  // Método chamado ao inicializar o estado
  @override
  void initState() {
    super.initState();
    _carregarReceitas(); // Carrega receitas armazenadas
  }

  // Método para adicionar uma nova receita
  void _adicionarReceita() {
    if (_formKey.currentState!.validate()) {
      // Valida o formulário
      setState(() {
        // Adiciona a receita à lista
        _receitas.add({
          'titulo': _tituloController.text,
          'descricao': _descricaoController.text,
          'ingredientes': _ingredientesController.text,
        });
        // Limpa os campos de entrada
        _tituloController.clear();
        _descricaoController.clear();
        _ingredientesController.clear();
        // Salva as receitas
        _salvarReceitas();
      });
    }
  }

  // Método para carregar receitas do armazenamento
  void _carregarReceitas() async {
    SharedPreferences prefs = await SharedPreferences
        .getInstance(); // Obtém a instância do SharedPreferences
    String? receitaJson =
        prefs.getString('receitas'); // Tenta obter a string de receitas

    if (receitaJson != null) {
      // Se houver receitas armazenadas

      _receitas
          .addAll(List<Map<String, dynamic>>.from(json.decode(receitaJson)));
      setState(() {});
    }
  }

  // Método para salvar as receitas no armazenamento
  void _salvarReceitas() async {
    SharedPreferences prefs = await SharedPreferences
        .getInstance(); // Obtém a instância do SharedPreferences
    String receitaJson =
        json.encode(_receitas); // Codifica a lista de receitas em JSON
    await prefs.setString(
        'receitas', receitaJson); // Salva a string no armazenamento
  }

  // Método para remover uma receita pelo índice
  void _removerReceita(int index) {
    setState(() {
      _receitas.removeAt(index); // Remove a receita da lista
      _salvarReceitas(); // Atualiza o armazenamento
    });
  }

  // Método para construir a interface
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange, // Cor de fundo da AppBar
        foregroundColor: Colors.white, // Cor do texto na AppBar
        title: const Text('Minhas Receitas'), // Título da AppBar
      ),
      body: Column(
        children: [
          // Formulário para adicionar uma receita
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Form(
              key: _formKey, // Atribui a chave do formulário
              child: Column(
                children: [
                  // Campo para título da receita
                  TextFormField(
                    controller: _tituloController,
                    decoration: const InputDecoration(
                      labelText: 'Título da Receita',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      // Valida se o campo está vazio
                      if (value!.isEmpty) {
                        return 'Por favor digite um título';
                      }
                      return null; // Retorna null se válido
                    },
                  ),
                  const SizedBox(height: 10), // Espaçamento entre os campos
                  // Campo para ingredientes
                  TextFormField(
                    controller: _ingredientesController,
                    decoration: const InputDecoration(
                      labelText: 'Ingredientes',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      // Valida se o campo está vazio
                      if (value!.isEmpty) {
                        return 'Por favor digite os ingredientes';
                      }
                      return null; // Retorna null se válido
                    },
                  ),
                  const SizedBox(height: 10), // Espaçamento entre os campos
                  // Campo para descrição da receita
                  TextFormField(
                    controller: _descricaoController,
                    decoration: const InputDecoration(
                      labelText: 'Descrição da Receita',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      // Valida se o campo está vazio
                      if (value!.isEmpty) {
                        return 'Por favor digite uma descrição';
                      }
                      return null; // Retorna null se válido
                    },
                  ),
                ],
              ),
            ),
          ),
          // Botão para adicionar a receita
          InkWell(
            onTap: _adicionarReceita, // Chama o método ao clicar
            child: Container(
              margin: const EdgeInsets.all(10),
              width: double.infinity,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.orange, // Cor de fundo do botão
                borderRadius: BorderRadius.all(
                    Radius.circular(10)), // Bordas arredondadas
              ),
              child: const Center(
                child: Text(
                  'Adicionar Receita',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold), // Estilo do texto
                ),
              ),
            ),
          ),
          // Lista de receitas
          Expanded(
            child: ListView.builder(
              itemCount: _receitas.length, // Número de receitas na lista
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const CircleAvatar(
                    backgroundImage: NetworkImage(
                      'https://cdn-icons-png.flaticon.com/512/526/526194.png', // Imagem do avatar
                    ),
                  ),
                  title: Text(_receitas[index]['titulo']!), // Título da receita
                  subtitle: Column(
                    children: [
                      Text(_receitas[index]
                          ['descricao']!), // Descrição da receita
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _receitas[index]
                              ['ingredientes']!, // Ingredientes da receita
                          style: const TextStyle(
                            fontWeight: FontWeight
                                .bold, // Estilo do texto dos ingredientes
                          ),
                        ),
                      )
                    ],
                  ),
                  trailing: IconButton(
                    onPressed: () => _removerReceita(
                        index), // Chama método para remover receita
                    icon: const Icon(Icons.delete), // Ícone de exclusão
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
