import 'package:flutter/material.dart';

class ConfirmExcludeDialog extends StatelessWidget {
  final String titulo;
  final String conteudo;
  final VoidCallback onConfirm;

  const ConfirmExcludeDialog({
    super.key,
    required this.titulo,
    required this.conteudo,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
    );
  }
}