import 'package:flutter/material.dart';
import '../widgets/tabela_remedios.dart';
import '../widgets/chat_assistant.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final Color brandColor = const Color(0xFF7F56D9);
  final Color bgLight = const Color(0xFFF0F2F5);
  final Color successColor = const Color(0xFF52C41A);
  final Color errorColor = const Color(0xFFCF1322);

  // Dados Estáticos
  final List<Map<String, dynamic>> _dadosVisuais = [
    {
      'id': 1,
      'nome': 'João Silva',
      'itens': [
        {'remedio': 'Losartana 50mg', 'quantidade': 10, 'proximaCompra': '25/01', 'status': 'urgente', 'horario': '08:00'},
        {'remedio': 'Aspirina', 'quantidade': 45, 'proximaCompra': '10/02', 'status': 'normal', 'horario': '20:00'},
      ]
    },
    {
      'id': 2,
      'nome': 'Maria Oliveira',
      'itens': <Map<String, dynamic>>[]
    },
  ];

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

            Row(
              children: [
                _buildStatCard("Medicamentos", "12", Icons.medication_outlined, brandColor),
                const SizedBox(width: 8),
                _buildStatCard("Pessoas", "2", Icons.people_outline, successColor),
                const SizedBox(width: 8),
                _buildStatCard("Urgente", "1 item", Icons.warning_amber_rounded, errorColor, textColor: errorColor),
              ],
            ),

            const SizedBox(height: 24),

            Center(
              child: SizedBox(
                height: 48,
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _openPersonModal(),
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

            Column(//uso de column para garantir o tamnanho total 
              children: _dadosVisuais.map((pessoa) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildPersonCard(pessoa),
              )).toList(),
            ),
            
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  void _confirmarExclusao({required String titulo, required String conteudo, required VoidCallback onConfirm}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white, 
        surfaceTintColor: Colors.white, 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(conteudo),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); 
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text("Excluir"),
          ),
        ],
      ),
    );
  }

  // --- Cards ---

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
                    _confirmarExclusao(
                      titulo: "Excluir Pessoa?",
                      conteudo: "Tem certeza que deseja remover ${pessoa['nome']} e todos os seus medicamentos?",
                      onConfirm: () {
                        
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pessoa removida!")));
                      }
                    );
                  },
                ),
              ],
            ),
            const Divider(height: 24),
            
            TabelaRemedios(
              dados: pessoa['itens'],
              onAdd: () => _openMedicineModal(nomePessoa: pessoa['nome']),
              onEdit: (item) => _openMedicineModal(nomePessoa: pessoa['nome'], itemParaEditar: item),
           
              onDelete: (item) {
                 _confirmarExclusao(
                      titulo: "Remover Medicamento?",
                      conteudo: "Deseja remover ${item['remedio']} da lista?",
                      onConfirm: () {
                        
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${item['remedio']} removido!")));
                      }
                    );
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- MODAIS COM FUNDO BRANCO ---

  void _openMedicineModal({required String nomePessoa, Map<String, dynamic>? itemParaEditar}) {
    final bool isEdit = itemParaEditar != null;
    
    final TextEditingController remedioController = TextEditingController(text: isEdit ? itemParaEditar['remedio'] : '');
    final TextEditingController qtdController = TextEditingController(text: isEdit ? itemParaEditar['quantidade'].toString() : '');
    final TextEditingController dataController = TextEditingController(text: isEdit ? itemParaEditar['proximaCompra'] : '');
    final TextEditingController horaController = TextEditingController(text: isEdit ? itemParaEditar['horario'] : '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white, 
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(isEdit ? "Editar Remédio" : "Adicionar Remédio"),
        scrollable: true,
        content: SizedBox(
          width: 400, 
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Para: $nomePessoa", style: const TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 16),
              
              _buildTextField(label: "Nome do Medicamento", controller: remedioController, icon: Icons.medication),
              const SizedBox(height: 12),
              
              _buildTextField(label: "Quantidade Atual", controller: qtdController, icon: Icons.numbers, isNumber: true),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: "Data", 
                      controller: dataController, 
                      icon: Icons.calendar_today,
                      readOnly: true,
                      onTap: () async {
                         // Lógica de DatePicker 
                      }
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      label: "Hora", 
                      controller: horaController, 
                      icon: Icons.access_time,
                      readOnly: true,
                      onTap: () async {
                        // Lógica de TimePicker
                      }
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: brandColor, foregroundColor: Colors.white, elevation: 0),
            child: Text(isEdit ? "Salvar" : "Adicionar"),
          ),
        ],
      ),
    );
  }

  void _openPersonModal() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white, 
        surfaceTintColor: Colors.white,
        title: const Text("Nova Pessoa"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Crie uma nova categoria para organizar os remédios.", style: TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 16),
            _buildTextField(label: "Nome da Pessoa", icon: Icons.person_outline),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: brandColor, foregroundColor: Colors.white, elevation: 0),
            child: const Text("Criar"),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label, 
    IconData? icon, 
    TextEditingController? controller, 
    bool isNumber = false,
    bool readOnly = false,
    VoidCallback? onTap
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        isDense: true,
      ),
    );
  }
}