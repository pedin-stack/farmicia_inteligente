import 'package:flutter/material.dart';

class TabelaRemedios extends StatelessWidget {
  final List<dynamic> dados;
  final Function(Map<String, dynamic> item)? onEdit;
  final Function(Map<String, dynamic> item)? onDelete;
  final VoidCallback? onAdd;

  const TabelaRemedios({
    super.key,
    required this.dados,
    this.onEdit,
    this.onDelete,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 10,
            horizontalMargin: 4,
            headingRowHeight: 40,
            dataRowMinHeight: 48,
            dataRowMaxHeight: 60,
            columns: const [
              DataColumn(label: Text('Remédio', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
              DataColumn(label: Text('Qtd.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13))),
              DataColumn(label: Text('Data', style: TextStyle(fontSize: 13))),
              DataColumn(label: Text('Hora', style: TextStyle(fontSize: 13))),
              DataColumn(label: Text('Ações', textAlign: TextAlign.right, style: TextStyle(fontSize: 13))),
            ],
            rows: dados.map((item) {
              return DataRow(cells: [
                // CORREÇÃO 1: Procura 'nome' (Backend) ou 'remedio' (Legado)
                DataCell(
                  SizedBox(
                    width: 85,
                    child: Text(
                      item['nome'] ?? item['remedio'] ?? '', 
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(Center(child: Text(item['quantidade']?.toString() ?? '-', style: const TextStyle(fontSize: 13)))),
                DataCell(_buildStatusTag(item['proximaCompra'] ?? item['proxCompra'], item['status'])), // Suporte a proxCompra vindo do DTO
                DataCell(Text(item['horario'] ?? '-', style: const TextStyle(fontSize: 12))),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                        onPressed: () => onEdit?.call(item),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                        splashRadius: 20,
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                        onPressed: () => onDelete?.call(item),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                        splashRadius: 20,
                      ),
                    ],
                  ),
                ),
              ]);
            }).toList(),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add, size: 16),
          label: const Text("Adicionar Medicamento"),
          style: OutlinedButton.styleFrom(
            visualDensity: VisualDensity.compact,
            side: BorderSide(color: Colors.grey[300]!),
            foregroundColor: Colors.black87,
          ),
        )
      ],
    );
  }

  Widget _buildStatusTag(String? text, String? status) {
    Color bgColor = const Color(0xFFE6F7FF);
    Color borderColor = const Color(0xFF91D5FF);
    Color textColor = const Color(0xFF1890FF);

    // CORREÇÃO 2: Converter para maiúsculo para garantir compatibilidade com Java Enums (URGENTE vs urgente)
    final safeStatus = status?.toUpperCase() ?? '';

    if (safeStatus == 'URGENTE') {
      bgColor = const Color(0xFFFFF1F0);
      borderColor = const Color(0xFFFFA39E);
      textColor = const Color(0xFFCF1322);
    } else if (safeStatus == 'ATENCAO' || safeStatus == 'ATENÇÃO') {
      bgColor = const Color(0xFFFFFBE6);
      borderColor = const Color(0xFFFFE58F);
      textColor = const Color(0xFFFAAD14);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text ?? '-',
        style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }
}