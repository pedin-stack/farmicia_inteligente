import 'package:flutter/material.dart';
import '../widgets/dialogs/AddPersonDialog.dart';
import '../widgets/dialogs/ConfirmExcludeDialog.dart';
import '../widgets/dialogs/EditMedicineDialog.dart';
import 'package:farmicia_inteligente/widgets/chat_assistant.dart';
import 'package:farmicia_inteligente/widgets/tabela_remedios.dart';
import 'package:farmicia_inteligente/services/api_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Cores
  final Color brandColor = const Color(0xFF7F56D9);
  final Color bgLight = const Color(0xFFF0F2F5);
  final Color successColor = const Color(0xFF52C41A);
  final Color errorColor = const Color(0xFFCF1322);

  // --- Estado e Backend (Lógica do Colega) ---
  final ApiService _apiService = ApiService();
  List<Remedio> _listaRemedios = []; // Usando o Model dele
  int _totalPessoasReal = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  // 1. Carregar Dados da API
  Future<void> _carregarDados() async {
    try {
      setState(() => _isLoading = true);
      
      final lista = await _apiService.getRemedios();
      final qtdPessoas = await _apiService.getQuantidadePessoas(); 

      if (mounted) {
        setState(() {
          _listaRemedios = lista;
          _totalPessoasReal = qtdPessoas;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Erro ao carregar: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 2. Criar Pessoa na API
  Future<void> _criarPessoa(String nome) async {
    try {
      // Exibe loading rápido ou feedback
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Salvando pessoa...")));
      
      await _apiService.createPessoa(nome);
      
      await _carregarDados(); // Atualiza a tela
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pessoa criada com sucesso!")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e"), backgroundColor: Colors.red));
      }
    }
  }

  // 3. Salvar/Editar Remédio na API
  Future<void> _salvarRemedio(Remedio remedio) async {
    try {
      if (remedio.id != null) {
        await _apiService.updateRemedio(remedio); // PUT
      } else {
        await _apiService.addRemedio(remedio); // POST
      }
      
      await _carregarDados(); // Refresh
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Medicamento salvo!")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e"), backgroundColor: Colors.red));
      }
    }
  }

  // 4. Deletar Remédio da API
  Future<void> _deletarRemedio(int id) async {
    try {
      await _apiService.deleteRemedio(id);
      await _carregarDados();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Item removido.")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro ao deletar: $e"), backgroundColor: Colors.red));
      }
    }
  }

  // --- Construção da UI ---

  @override
  Widget build(BuildContext context) {
    // Cálculos estatísticos baseados na lista real
    final int totalMedicamentos = _listaRemedios.length;
    final int totalUrgentes = _listaRemedios.where((r) => r.status?.toUpperCase() == 'URGENTE').length;

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
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Visão Geral", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Text("Conectado ao servidor", style: TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 16),

                // Cards de Estatísticas
                Row(
                  children: [
                    _buildStatCard("Medicamentos", "$totalMedicamentos", Icons.medication_outlined, brandColor),
                    const SizedBox(width: 8),
                    _buildStatCard("Pessoas", "$_totalPessoasReal", Icons.people_outline, successColor),
                    const SizedBox(width: 8),
                    _buildStatCard("Urgente", "$totalUrgentes itens", Icons.warning_amber_rounded, errorColor, textColor: errorColor),
                  ],
                ),

                const SizedBox(height: 24),

                // Botão Nova Pessoa (Usando o Componente AddPersonDialog)
                Center(
                  child: SizedBox(
                    height: 48,
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AddPersonDialog(
                            onSave: (nome) {
                              // Conecta o callback do Dialog à função da API
                              _criarPessoa(nome); 
                            },
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

                // Lista de Itens (Adaptando a lista plana do backend para o visual de Card)
                // Nota: Se o backend retornar lista plana, agrupamos visualmente em um card "Geral"
                // ou iteramos sobre as pessoas se o backend suportar isso. 
                // Assumindo lista plana de remédios por enquanto:
                _buildPersonCard({
                  'nome': 'Estoque Geral',
                  'itens': _listaRemedios.map((r) => r.toMap()).toList(), // Converte Model -> Map para a Tabela
                }),

                const SizedBox(height: 80),
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
                // Botão Excluir Pessoa (Lógica opcional se houver endpoint para isso)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                     // Adicione lógica de excluir pessoa aqui se o backend suportar
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Funcionalidade em desenvolvimento no backend")));
                  },
                ),
              ],
            ),
            const Divider(height: 24),
            
            // Tabela de Remédios
            TabelaRemedios(
              dados: pessoa['itens'],
              
              // 1. ADICIONAR (Abre Dialog -> Converte Map p/ Model -> Chama API)
              onAdd: () {
                showDialog(
                  context: context,
                  builder: (context) => EditMedicineDialog(
                    nomePessoa: pessoa['nome'],
                    itemParaEditar: null,
                    onSave: (novoItemMap) {
                      // Conversão Map -> Model Remedio
                      // O EditMedicineDialog retorna um Map com strings/ints.
                      // Precisamos garantir que o Model do seu colega aceite isso.
                      final novoRemedio = Remedio(
                        nome: novoItemMap['remedio'],
                        quantidade: novoItemMap['quantidade'],
                        usoDiario: double.tryParse(novoItemMap['consumo'].toString()) ?? 0.0,
                        proximaCompra: novoItemMap['proximaCompra'],
                        horario: novoItemMap['horario'],
                        status: 'NORMAL', // Default
                      );
                      
                      _salvarRemedio(novoRemedio);
                    },
                  ),
                );
              },
              
              // 2. EDITAR (Abre Dialog com dados -> Converte -> Chama API)
              onEdit: (itemMap) {
                showDialog(
                  context: context,
                  builder: (context) => EditMedicineDialog(
                    nomePessoa: pessoa['nome'],
                    itemParaEditar: itemMap,
                    onSave: (itemEditadoMap) {
                      
                      final remedioEditado = Remedio(
                        id: itemMap['id'], // IMPORTANTE: Manter o ID original
                        nome: itemEditadoMap['remedio'],
                        quantidade: itemEditadoMap['quantidade'],
                        usoDiario: double.tryParse(itemEditadoMap['consumo'].toString()) ?? 0.0,
                        proximaCompra: itemEditadoMap['proximaCompra'],
                        horario: itemEditadoMap['horario'],
                        status: itemEditadoMap['status'] ?? 'NORMAL',
                      );

                      _salvarRemedio(remedioEditado);
                    },
                  ),
                );
              },
              
              // 3. EXCLUIR (Abre ConfirmDialog -> Chama API)
              onDelete: (itemMap) {
                 showDialog(
                    context: context,
                    builder: (context) => ConfirmExcludeDialog(
                      titulo: "Remover Medicamento?",
                      conteudo: "Deseja remover ${itemMap['remedio']} da lista?",
                      onConfirm: () {
                        if (itemMap['id'] != null) {
                          _deletarRemedio(itemMap['id']);
                        }
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

// Extensão para facilitar a conversão Model -> Map (se seu colega não fez isso no model)
extension RemedioExtension on Remedio {
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'remedio': nome,
      'quantidade': quantidade,
      'consumo': usoDiario, // Mapeando 'usoDiario' do Backend para 'consumo' do Frontend
      'proximaCompra': proximaCompra,
      'horario': horario,
      'status': status,
    };
  }
}