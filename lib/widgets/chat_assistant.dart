import 'package:flutter/material.dart';

class ChatAssistant extends StatefulWidget {
  const ChatAssistant({super.key});

  @override
  State<ChatAssistant> createState() => _ChatAssistantState();
}

class _ChatAssistantState extends State<ChatAssistant> {
 
  bool isOpen = false; 

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [

        if (isOpen)
          Container(
            width: 350,
            height: 480,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ],
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              children: [
              
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFF7F56D9),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.smart_toy_outlined, color: Colors.white),
                          SizedBox(width: 8),
                          Text("Farmacêutico IA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      InkWell(
                        onTap: () => setState(() => isOpen = false),
                        child: const Icon(Icons.close, color: Colors.white, size: 20),
                      )
                    ],
                  ),
                ),

                // Área de Mensagens 
                Expanded(
                  child: Container(
                    color: const Color(0xFFF8F9FA),
                    padding: const EdgeInsets.all(16),
                    child: const Center(
                      child: Text(
                        "Área de mensagens\n(Conecte ao Backend)",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Colors.grey[200]!)),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Pergunte algo...",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 10),
                            isDense: true,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Color(0xFF7F56D9)),
                        onPressed: () {}, // adicionar lógica aqui
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // --- FAB ---
        FloatingActionButton(
          onPressed: () => setState(() => isOpen = !isOpen),
          backgroundColor: const Color(0xFF7F56D9),
          shape: const CircleBorder(),
          child: Icon(isOpen ? Icons.close : Icons.chat_bubble_outline, color: Colors.white),
        ),
      ],
    );
  }
}