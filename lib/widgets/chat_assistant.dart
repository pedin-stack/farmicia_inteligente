import 'package:flutter/material.dart';
import '../services/api_service.dart'; 

class ChatAssistant extends StatefulWidget {
  const ChatAssistant({super.key});

  @override
  State<ChatAssistant> createState() => _ChatAssistantState();
}

class _ChatAssistantState extends State<ChatAssistant> {
  final ApiService apiService = ApiService();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  bool isOpen = false;
  bool isLoading = false;

  // Lista de mensagens para exibir na tela
  List<Map<String, dynamic>> messages = [
    {"role": "bot", "text": "Olá! Sou seu assistente farmacêutico. Posso analisar seu estoque. Pergunte algo como:\n'Quais remédios estão acabando?'"}
  ];

  Future<void> _sendMessage() async {
    String text = _textController.text.trim();
    if (text.isEmpty) return;

    // 1. Adiciona mensagem do usuário na tela
    setState(() {
      messages.add({"role": "user", "text": text});
      isLoading = true;
      _textController.clear();
    });
    _scrollToBottom();

    try {
  
      String response = await apiService.enviarMensagemChat(text);

      // 3. Adiciona resposta do bot
      setState(() {
        messages.add({"role": "bot", "text": response});
      });
    } catch (e) {
      setState(() {
        messages.add({"role": "bot", "text": "Erro ao conectar: $e"});
      });
    } finally {
      setState(() {
        isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

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
                // --- Cabeçalho ---
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

                // --- Área de Mensagens ---
                Expanded(
                  child: Container(
                    color: const Color(0xFFF8F9FA),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final isUser = msg['role'] == 'user';
                        return Align(
                          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(12),
                            constraints: const BoxConstraints(maxWidth: 260),
                            decoration: BoxDecoration(
                              color: isUser ? const Color(0xFF7F56D9) : Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(12),
                                topRight: const Radius.circular(12),
                                bottomLeft: isUser ? const Radius.circular(12) : Radius.zero,
                                bottomRight: isUser ? Radius.zero : const Radius.circular(12),
                              ),
                              boxShadow: [
                                if (!isUser)
                                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2, offset: const Offset(0, 1))
                              ],
                            ),
                            child: Text(
                              msg['text'],
                              style: TextStyle(
                                color: isUser ? Colors.white : Colors.black87,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // --- Indicador de carregamento ---
                if (isLoading)
                  Container(
                    color: const Color(0xFFF8F9FA),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF7F56D9)),
                        ),
                        const SizedBox(width: 8),
                        Text("Analisando estoque...", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      ],
                    ),
                  ),

                // --- Input de Texto ---
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Colors.grey[200]!)),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          onSubmitted: (_) => _sendMessage(), 
                          decoration: const InputDecoration(
                            hintText: "Pergunte algo...",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 10),
                            isDense: true,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Color(0xFF7F56D9)),
                        onPressed: _sendMessage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // --- Botão Flutuante (FAB) ---
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