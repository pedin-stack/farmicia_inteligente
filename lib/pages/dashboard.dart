import 'package:flutter/material.dart';
import '../widgets/tabela_remedios.dart';
import '../widgets/chat_assistant.dart';
import '../services/api_service.dart';

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

  final ApiService _apiService = ApiService();
  List<Remedio> _listaRemedios = [];
  int _totalPessoasReal = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      // Carrega os remédios e a contagem de pessoas ao mesmo tempo
      final lista = await _apiService.getRemedios();
      final qtdPessoas = await _apiService.getQuantidadePessoas(); // <--- CHAMA A API
      final int totalMedicamentos = _listaRemedios.length;

      if (mounted) {
        setState(() {
          
          _listaRemedios = lista;
          _totalPessoasReal = qtdPessoas; // <--- ATUALIZA A VARIÁVEL
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Erro ao carregar: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- Lógica de CRUD ---

  Future<void> _salvarRemedio(Remedio remedio) async {
    try {
      setState(() => _isLoading = true);
      
      // LÓGICA DE DECISÃO:
      if (remedio.id != null) {
        // Se tem ID, é Edição (PUT)
        await _apiService.updateRemedio(remedio);
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Medicamento atualizado!")));
        }
      } else {
        // Se ID é null, é Criação (POST)
        await _apiService.addRemedio(remedio);
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Medicamento criado!")));
        }
      }
      
      await _carregarDados(); // Recarrega tudo
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text("Erro: $e"), backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deletarRemedio(int id) async {
    try {
      await _apiService.deleteRemedio(id);
      await _carregarDados();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Medicamento removido!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao deletar: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- Cálculos Dinâmicos ---
    final int totalMedicamentos = _listaRemedios.length;
    final int totalPessoas = _listaRemedios.isNotEmpty ? 1 : 0; 
    final int totalUrgentes = _listaRemedios.where((r) => r.status == 'URGENTE').length;

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
            const Text("Dados atualizados em tempo real", style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 16),

            // --- Cards de Estatística Conectados ---
            Row(
              children: [
                _buildStatCard("Medicamentos", "$totalMedicamentos", Icons.medication_outlined, brandColor),
                const SizedBox(width: 8),
                _buildStatCard("Pessoas", "$totalPessoas", Icons.people_outline, successColor),
                const SizedBox(width: 8),
                _buildStatCard(
                  "Urgente", 
                  "$totalUrgentes ${totalUrgentes == 1 ? 'item' : 'itens'}", 
                  Icons.warning_amber_rounded, 
                  errorColor, 
                  textColor: errorColor
                ),
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

            // --- Lista de Dados ---
            _isLoading
                ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
                : _buildPersonCard({
                    'nome': 'Estoque Geral',
                    'itens': _listaRemedios.map((r) => {
                      'id': r.id,
                      'remedio': r.nome,
                      'quantidade': r.quantidade,
                      'usoDiario': r.usoDiario, // ADICIONADO PARA EDIÇÃO
                      'proximaCompra': r.proximaCompra,
                      'status': r.status,
                      'horario': r.horario
                    }).toList()
                  }),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // --- Widgets Auxiliares ---

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

  Widget _buildStatCard(String title, String value, IconData icon, Color color, {Color? textColor}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
          ],
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
        ],
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
                      if (item['id'] != null) {
                        _deletarRemedio(item['id']);
                      }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- MODAIS ---

  void _openMedicineModal({required String nomePessoa, Map<String, dynamic>? itemParaEditar}) {
    final bool isEdit = itemParaEditar != null;
    
    // Variável oculta para segurar a data no formato ISO (YYYY-MM-DD) para o Java
    String dataParaOJava = isEdit ? (itemParaEditar['proximaCompra'] ?? '') : '';

    final TextEditingController remedioController = TextEditingController(text: isEdit ? itemParaEditar['remedio'] : '');
    final TextEditingController qtdController = TextEditingController(text: isEdit ? itemParaEditar['quantidade'].toString() : '');
    
    // --- CORREÇÃO 1: Controller do Uso Diário ---
    final TextEditingController usoDiarioController = TextEditingController(
      text: isEdit && itemParaEditar['usoDiario'] != null 
          ? itemParaEditar['usoDiario'].toString() 
          : ''
    );
    
    final TextEditingController dataController = TextEditingController(
      // Exibe visualmente apenas se tiver data, formata DD/MM se possível, mas aqui simplificado
      text: isEdit ? itemParaEditar['proximaCompra'] : ''
    );
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
              
              _buildTextField(label: "Quantidade em Estoque", controller: qtdController, icon: Icons.numbers, isNumber: true),
              const SizedBox(height: 12),
              
              // --- CORREÇÃO 2: Campo Visual do Uso Diário ---
              _buildTextField(label: "Uso Diário (ex: 2.0)", controller: usoDiarioController, icon: Icons.timelapse, isNumber: true),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: "Data Compra",
                      controller: dataController,
                      icon: Icons.calendar_today,
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2030),
                        );
                        if (pickedDate != null) {
                           // Visual (Brasil)
                           dataController.text = "${pickedDate.day.toString().padLeft(2,'0')}/${pickedDate.month.toString().padLeft(2,'0')}";
                           
                           // --- CORREÇÃO 3: Formato para o Java (ISO) ---
                           dataParaOJava = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2,'0')}-${pickedDate.day.toString().padLeft(2,'0')}";
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      label: "Horário",
                      controller: horaController,
                      icon: Icons.access_time,
                      readOnly: true,
                      onTap: () async {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          final hour = pickedTime.hour.toString().padLeft(2, '0');
                          final minute = pickedTime.minute.toString().padLeft(2, '0');
                          horaController.text = "$hour:$minute";
                        }
                      },
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
            onPressed: () {
              // Validação básica
              if (remedioController.text.isEmpty || qtdController.text.isEmpty || usoDiarioController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Preencha nome, quantidade e uso diário!")));
                  return;
              }

              // Criação do objeto para enviar
              final novoRemedio = Remedio(
                id: isEdit ? itemParaEditar['id'] : null, // Passa o ID se for edição
                nome: remedioController.text,
                quantidade: int.tryParse(qtdController.text) ?? 0,
                
                // --- CORREÇÃO 4: Converte String para Double com segurança ---
                usoDiario: double.tryParse(usoDiarioController.text.replaceAll(',', '.')) ?? 0.0,
                
                status: 'NORMAL', // Java geralmente prefere Maiúsculo em Enums
                horario: horaController.text.isEmpty ? "08:00" : horaController.text,
                
                // Envia a data formatada ISO, ou uma data padrão se vazio
                proximaCompra: dataParaOJava.isEmpty ? "2026-01-01" : dataParaOJava,
              );

              _salvarRemedio(novoRemedio);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: brandColor, foregroundColor: Colors.white, elevation: 0),
            child: Text(isEdit ? "Salvar" : "Adicionar"),
          ),
        ],
      ),
    );
  }

  void _openPersonModal() {
    final TextEditingController nomePessoaController = TextEditingController();
    bool isSaving = false; // Para evitar cliques duplos

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder( // StatefulBuilder permite atualizar o loading dentro do modal
        builder: (context, setStateModal) {
          return AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: const Text("Nova Pessoa"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Crie um perfil para separar os medicamentos.",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: "Nome da Pessoa",
                  controller: nomePessoaController,
                  icon: Icons.person_add,
                ),
                if (isSaving) ...[
                  const SizedBox(height: 16),
                  const CircularProgressIndicator(),
                ]
              ],
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(context),
                child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: isSaving ? null : () async {
                  final nome = nomePessoaController.text.trim();
                  
                  if (nome.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Por favor, digite um nome.")),
                    );
                    return;
                  }

                  // Inicia animação de carregamento
                  setStateModal(() => isSaving = true);

                  try {
                    // --- AQUI ACONTECE A MÁGICA REAL ---
                    await _apiService.createPessoa(nome);
                    
                    if (mounted) {
                      Navigator.pop(context); // Fecha o modal
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Pessoa '$nome' salva no banco com sucesso!"),
                          backgroundColor: successColor,
                        ),
                      );
                      
                      _carregarDados(); // Recarrega a tela (refresh)
                    }
                  } catch (e) {
                    setStateModal(() => isSaving = false); // Para o loading se der erro
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Erro: $e"), backgroundColor: errorColor),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Salvar"),
              ),
            ],
          );
        }
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    IconData? icon,
    TextEditingController? controller,
    bool isNumber = false,
    bool readOnly = false,
    VoidCallback? onTap,
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