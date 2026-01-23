import 'package:flutter/material.dart';
import '../widgets/dialogs/AddPersonDialog.dart';
import '../widgets/dialogs/ConfirmExcludeDialog.dart';
import '../widgets/dialogs/EditMedicineDialog.dart';
import 'package:farmicia_inteligente/widgets/chat_assistant.dart';
import 'package:farmicia_inteligente/widgets/tabela_remedios.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Cores do Projeto
  final Color brandColor = const Color(0xFF7F56D9);
  final Color bgLight = const Color(0xFFF0F2F5);
  final Color successColor = const Color(0xFF52C41A);
  final Color errorColor = const Color(0xFFCF1322);

  // Dados (Estado da Tela)
  // Nota: Em um app real, isso viria de um banco de dados ou Provider
  final List<Map<String, dynamic>> _dadosVisuais = [
    {
      'id': 1,
      'nome': 'João Silva',
      'itens': [
        {'remedio': 'Losartana 50mg', 'quantidade': 10, 'consumo': 1, 'proximaCompra': '25/01', 'status': 'urgente', 'horario': '08:00'},
        {'remedio': 'Aspirina', 'quantidade': 45, 'consumo': 2, 'proximaCompra': '10/02', 'status': 'normal', 'horario': '20:00'},
      ]
    },
    {
      'id': 2,
      'nome': 'Maria Oliveira',
      'itens': <Map<String, dynamic>>[]
    },
  ];


  int get totalMedicamentos {
    int total = 0;
    for (var pessoa in _dadosVisuais) {
      total += (pessoa['itens'] as List).length;
    }
    return total;
  }

  int get totalPessoas => _dadosVisuais.length;

  int get totalUrgentes {
    int total = 0;
    for (var pessoa in _dadosVisuais) {
      for (var item in pessoa['itens']) {
        if (item['status'] == 'urgente') total++;
      }
    }
    return total;
  }

  void _adicionarPessoa(String nome) {
    setState(() {
      _dadosVisuais.add({
        'id': DateTime.now().millisecondsSinceEpoch, // ID único temporário
        'nome': nome,
        'itens': <Map<String, dynamic>>[],
      });
    });
  }

  void _removerPessoa(Map<String, dynamic> pessoa) {
    setState(() {
      _dadosVisuais.remove(pessoa);
    });
  }

  void _adicionarRemedio(Map<String, dynamic> pessoa, Map<String, dynamic> novoItem) {
    setState(() {
      // Simulação simples de status baseada na quantidade (apenas exemplo)
      if ((novoItem['quantidade'] as int) < 15) {
        novoItem['status'] = 'urgente';
      } else {
        novoItem['status'] = 'normal';
      }
      (pessoa['itens'] as List).add(novoItem);
    });
  }

  void _editarRemedio(Map<String, dynamic> pessoa, Map<String, dynamic> itemAntigo, Map<String, dynamic> itemEditado) {
    setState(() {
      final lista = (pessoa['itens'] as List);
      final index = lista.indexOf(itemAntigo);
      if (index != -1) {
        // Recalcula status
        if ((itemEditado['quantidade'] as int) < 15) {
          itemEditado['status'] = 'urgente';
        } else {
          itemEditado['status'] = 'normal';
        }
        lista[index] = itemEditado;
      }
    });
  }

  void _removerRemedio(Map<String, dynamic> pessoa, Map<String, dynamic> item) {
    setState(() {
      (pessoa['itens'] as List).remove(item);
    });
  }

  // --- Construção da UI ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        title: const Text("Farmácia Inteligente", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () => Navigator.pop(context))
        ],
      ),
      floatingActionButton: const ChatAssistant(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Visão Geral", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Text("Cálculo automático de reposição", style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 16),

            // CARDS DE ESTATÍSTICAS (Atualizam dinamicamente)
            Row(
              children: [
                _buildStatCard("Medicamentos", "$totalMedicamentos", Icons.medication_outlined, brandColor),
                const SizedBox(width: 8),
                _buildStatCard("Pessoas", "$totalPessoas", Icons.people_outline, successColor),
                const SizedBox(width: 8),
                _buildStatCard("Urgente", "$totalUrgentes itens", Icons.warning_amber_rounded, errorColor, textColor: errorColor),
              ],
            ),

            const SizedBox(height: 24),

            // BOTÃO NOVA PESSOA
            Center(
              child: SizedBox(
                height: 48,
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AddPersonDialog(
                        onSave: (nome) => _adicionarPessoa(nome),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Nova Pessoa"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // LISTA DE PESSOAS E TABELAS
            Column(
              children: _dadosVisuais.map((pessoa) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildPersonCard(pessoa),
              )).toList(),
            ),
            
            const SizedBox(height: 80), // Espaço para o FAB não cobrir conteúdo
          ],
        ),
      ),
    );
  }

  // --- Widgets Auxiliares ---

  Widget _buildStatCard(String title, String value, IconData icon, Color color, {Color? textColor}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
             BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
          ]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11), overflow: TextOverflow.ellipsis)),
                Icon(icon, color: color, size: 18),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor ?? Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonCard(Map<String, dynamic> pessoa) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
           BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))
        ]
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CABEÇALHO DO CARD (Nome + Delete Pessoa)
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF87D068),
                  radius: 18,
                  child: const Icon(Icons.person, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(pessoa['nome'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => ConfirmExcludeDialog(
                        titulo: "Excluir Pessoa?",
                        conteudo: "Tem certeza que deseja remover ${pessoa['nome']} e todos os seus medicamentos?",
                        onConfirm: () {
                          _removerPessoa(pessoa);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pessoa removida!")));
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
            const Divider(height: 24),
            
            // TABELA DE REMÉDIOS
            TabelaRemedios(
              dados: pessoa['itens'],
              
              // ADICIONAR REMÉDIO
              onAdd: () {
                showDialog(
                  context: context,
                  builder: (context) => EditMedicineDialog(
                    nomePessoa: pessoa['nome'],
                    itemParaEditar: null,
                    onSave: (novoItem) => _adicionarRemedio(pessoa, novoItem),
                  ),
                );
              },
              
              // EDITAR REMÉDIO
              onEdit: (item) {
                showDialog(
                  context: context,
                  builder: (context) => EditMedicineDialog(
                    nomePessoa: pessoa['nome'],
                    itemParaEditar: item,
                    onSave: (itemEditado) => _editarRemedio(pessoa, item, itemEditado),
                  ),
                );
              },
              
              // EXCLUIR REMÉDIO
              onDelete: (item) {
                 showDialog(
                    context: context,
                    builder: (context) => ConfirmExcludeDialog(
                      titulo: "Remover Medicamento?",
                      conteudo: "Deseja remover ${item['remedio']} da lista?",
                      onConfirm: () {
                        _removerRemedio(pessoa, item);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${item['remedio']} removido!")));
                      },
                    ),
                 );
              },
            ),
          ],
        ),
      ),
    );
  }
}