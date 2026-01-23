import 'package:flutter/material.dart';

class AddPersonDialog extends StatefulWidget {
  final Function(String) onSave;

  const AddPersonDialog({super.key, required this.onSave});

  @override
  State<AddPersonDialog> createState() => _AddPersonDialogState();
}

class _AddPersonDialogState extends State<AddPersonDialog> {
  final _nomeController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text("Nova Pessoa"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Crie uma nova categoria para organizar os remédios.",
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nomeController,
            decoration: InputDecoration(
              labelText: "Nome da Pessoa",
              prefixIcon: const Icon(Icons.person_outline, color: Colors.grey),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              isDense: true,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nomeController.text.isNotEmpty) {
              widget.onSave(_nomeController.text);
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7F56D9), 
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          child: const Text("Criar"),
        ),
      ],
    );
  }
}