import 'package:flutter/material.dart';

class EditMedicineDialog extends StatefulWidget {
  final String nomePessoa;
  final Map<String, dynamic>? itemParaEditar;
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
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nomeController;
  late TextEditingController _qtdController;
  late TextEditingController _usoDiarioController;
  // REMOVIDO: _dataController
  late TextEditingController _horaController;

  @override
  void initState() {
    super.initState();
    final item = widget.itemParaEditar;

    _nomeController = TextEditingController(text: item?['remedio'] ?? item?['nome'] ?? '');
    _qtdController = TextEditingController(text: item?['quantidade']?.toString() ?? '');
    _usoDiarioController = TextEditingController(text: item?['usoDiario']?.toString() ?? item?['consumo']?.toString() ?? '');
    // REMOVIDO: Inicialização de data
    _horaController = TextEditingController(text: item?['horario'] ?? '');
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _qtdController.dispose();
    _usoDiarioController.dispose();
    // REMOVIDO: dispose de data
    _horaController.dispose();
    super.dispose();
  }

  // REMOVIDO: _selectDate()

  Future<void> _selectTime() async {
    TimeOfDay initialTime = TimeOfDay.now();
    if (_horaController.text.isNotEmpty) {
      try {
        final parts = _horaController.text.split(':');
        initialTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      } catch (_) {}
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        // Força modo 24h visualmente se o dispositivo permitir
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        final hour = picked.hour.toString().padLeft(2, '0');
        final minute = picked.minute.toString().padLeft(2, '0');
        _horaController.text = "$hour:$minute";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.itemParaEditar != null;

    return AlertDialog(
      title: Text(isEditing ? "Editar Medicamento" : "Novo Medicamento"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Paciente: ${widget.nomePessoa}", 
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: "Nome do Remédio"),
                validator: (v) => v!.isEmpty ? "Campo obrigatório" : null,
              ),
              const SizedBox(height: 10),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _qtdController,
                      decoration: const InputDecoration(labelText: "Qtd Atual"),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? "Obrigatório" : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _usoDiarioController,
                      decoration: const InputDecoration(labelText: "Uso Diário"),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? "Obrigatório" : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // CAMPO DE DATA REMOVIDO COMPLETAMENTE DAQUI

              TextFormField(
                controller: _horaController,
                decoration: const InputDecoration(
                  labelText: "Horário de Consumo",
                  suffixIcon: Icon(Icons.access_time),
                  hintText: "00:00"
                ),
                readOnly: true,
                validator: (v) => v!.isEmpty ? "Horário é obrigatório" : null,
                onTap: _selectTime,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final map = {
                'remedio': _nomeController.text, // UI Legada
                'nome': _nomeController.text,    // API
                'quantidade': double.tryParse(_qtdController.text) ?? 0.0,
                'usoDiario': double.tryParse(_usoDiarioController.text) ?? 0.0,
                // Garantimos que hora vai no formato HH:mm
                'horario': _horaController.text, 
                // Enviamos null explicitamente na proximaCompra
                'proximaCompra': null, 
              };
              
              widget.onSave(map);
              Navigator.pop(context);
            }
          },
          child: const Text("Salvar"),
        ),
      ],
    );
  }
}