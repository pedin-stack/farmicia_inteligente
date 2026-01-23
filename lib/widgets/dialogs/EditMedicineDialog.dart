import 'package:flutter/material.dart';

class EditMedicineDialog extends StatefulWidget {
  final String nomePessoa;
  final Map<String, dynamic>? itemParaEditar; // Se null, é adição
  final Function(Map<String, dynamic>) onSave;

  const EditMedicineDialog({
    super.key,
    required this.nomePessoa,
    this.itemParaEditar,
    required this.onSave,
  });

  @override
  State<EditMedicineDialog> createState() => _EditMedicineDialogState();
}

class _EditMedicineDialogState extends State<EditMedicineDialog> {
  late TextEditingController _remedioController;
  late TextEditingController _qtdController;
  late TextEditingController _consumoController;
  late TextEditingController _dataController;
  late TextEditingController _horaController;

  @override
  void initState() {
    super.initState();
    final item = widget.itemParaEditar;
    
    _remedioController = TextEditingController(text: item?['remedio'] ?? '');
    _qtdController = TextEditingController(text: item?['quantidade']?.toString() ?? '');
    
    // Verifica se existe consumo, senão vazio
    _consumoController = TextEditingController(
      text: (item != null && item.containsKey('consumo')) 
          ? item['consumo'].toString() 
          : ''
    );
    
    _dataController = TextEditingController(text: item?['proximaCompra'] ?? '');
    _horaController = TextEditingController(text: item?['horario'] ?? '');
  }

  @override
  void dispose() {
    _remedioController.dispose();
    _qtdController.dispose();
    _consumoController.dispose();
    _dataController.dispose();
    _horaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.itemParaEditar != null;

    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(isEdit ? "Editar Remédio" : "Adicionar Remédio"),
      scrollable: true,
      content: SizedBox(
        width: 400, // Garante largura em telas maiores/web
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Para: ${widget.nomePessoa}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 16),

            _buildField("Nome do Medicamento", _remedioController, Icons.medication),
            const SizedBox(height: 12),
            _buildField("Quantidade Atual", _qtdController, Icons.numbers, isNumber: true),
            const SizedBox(height: 12),
            _buildField("Consumo Diário (qtd)", _consumoController, Icons.autorenew, isNumber: true),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildField("Data", _dataController, Icons.calendar_today, readOnly: true, onTap: _pickDate),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildField("Hora", _horaController, Icons.access_time, readOnly: true, onTap: _pickTime),
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
            // Cria o mapa de retorno
            final novoItem = {
              'remedio': _remedioController.text,
              'quantidade': int.tryParse(_qtdController.text) ?? 0,
              'consumo': int.tryParse(_consumoController.text) ?? 0,
              'proximaCompra': _dataController.text,
              'horario': _horaController.text,
              'status': 'normal', // Você pode implementar logica de status aqui
            };
            
            widget.onSave(novoItem);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7F56D9),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          child: Text(isEdit ? "Salvar" : "Adicionar"),
        ),
      ],
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon,
      {bool isNumber = false, bool readOnly = false, VoidCallback? onTap}) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        isDense: true,
      ),
    );
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dataController.text = "${picked.day}/${picked.month}";
      });
    }
  }

  Future<void> _pickTime() async {
    TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      setState(() {
        _horaController.text = "${picked.hour}:${picked.minute.toString().padLeft(2, '0')}";
      });
    }
  }
}