import 'dart:convert';
import 'package:http/http.dart' as http;

class Remedio {
  final int? id;
  final String nome;
  final int quantidade;
  final double usoDiario;
  final String status;
  final String horario;      
  final String? proximaCompra; 
  final int? pessoaId;

  Remedio({
    this.id,
    required this.nome,
    required this.quantidade,
    required this.usoDiario,
    required this.status,
    required this.horario,
    this.proximaCompra,
    this.pessoaId,
  });

  factory Remedio.fromJson(Map<String, dynamic> json) {
    // Tenta pegar o horário em várias chaves possíveis
    var rawHorario = json['horario'] ?? json['horaConsumo'] ?? json['hora_consumo'];
    
    // Tenta pegar a data em várias chaves possíveis
    var rawData = json['proximaCompra'] ?? json['proxCompra'] ?? json['prox_compra'];

    return Remedio(
      id: json['id'],
      nome: json['nome'] ?? 'Sem nome',
      quantidade: json['quantidade'] ?? 0,
      usoDiario: (json['usoDiario'] ?? 0).toDouble(),
      status: json['status'] ?? 'NORMAL',
      
      horario: _formatarHora(rawHorario?.toString()),
      proximaCompra: _formatarData(rawData?.toString()),
      
      pessoaId: json['pessoaId'] ?? (json['pessoa'] != null ? json['pessoa']['id'] : null),
    );
  }

  Map<String, dynamic> toJson() {
    String horaFormatada = horario;
    if (horaFormatada.length > 5) {
      horaFormatada = horaFormatada.substring(0, 5);
    }

    return {
      'id': id, 
      'nome': nome,
      'quantidade': quantidade,
      'usoDiario': usoDiario,
      'status': status,
      'horario': horaFormatada,     
      'proximaCompra': null, 
      if (pessoaId != null) 'pessoaId': pessoaId,
    };
  }

  // --- CORREÇÃO AQUI ---
  
  static String? _formatarData(String? data) {
    if (data == null || data.isEmpty || data == 'null') return null; 
    
    // CASO 1: O Backend já mandou formatado (Ex: 10/02/2026)
    // Se tiver barra, retorna direto, pois já está bonito para exibir.
    if (data.contains('/')) {
      return data;
    }

    // CASO 2: O Backend mandou ISO (Ex: 2026-02-10)
    try {
      DateTime dt = DateTime.parse(data);
      String dia = dt.day.toString().padLeft(2, '0');
      String mes = dt.month.toString().padLeft(2, '0');
      String ano = dt.year.toString();
      return '$dia/$mes/$ano';
    } catch (e) {
      print("ERRO AO FORMATAR DATA: $data -> $e");
      // Se falhar o parse, retorna o dado original para não quebrar a tela
      return data; 
    }
  }

  // Mudei o tipo de entrada para 'dynamic' para aceitar tanto Texto quanto Lista
  static String _formatarHora(dynamic horaRaw) {
    if (horaRaw == null || horaRaw.toString() == 'null') return '--:--';
    
    String horaStr = horaRaw.toString();

    // CENÁRIO 1: Array [20, 0] (Formato legado ou erro de serialização)
    if (horaStr.trim().startsWith("[")) {
      try {
        String limpo = horaStr.replaceAll('[', '').replaceAll(']', '');
        List<String> partes = limpo.split(',');
        
        if (partes.isNotEmpty) {
          int h = int.parse(partes[0].trim());
          int m = partes.length > 1 ? int.parse(partes[1].trim()) : 0;
          return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
        }
      } catch (e) {
        return '--:--';
      }
    }

    // CENÁRIO 2: String "14:10" ou "14:10:00" (Formato correto vindo do seu JSON)
    try {
      if (horaStr.length >= 5) {
        return horaStr.substring(0, 5); 
      }
      return horaStr;
    } catch (e) {
      return '--:--';
    }
  }
}

class Pessoa {
  final int? id;
  final String nome;
  final List<Remedio> remedios;

  Pessoa({this.id, required this.nome, required this.remedios});

  factory Pessoa.fromJson(Map<String, dynamic> json) {
    List<Remedio> meds = [];
    if (json['remedios'] is List) {
      meds = (json['remedios'] as List)
          .map((e) => Remedio.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return Pessoa(
      id: json['id'],
      nome: json['nome'] ?? 'Sem nome',
      remedios: meds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
      'remedios': remedios.map((r) => r.toJson()).toList(),
    };
  }
}

class ApiService {
  static const String baseUrl = 'http://localhost:8080';

  Future<List<Remedio>> getRemedios() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/remedios'));

      if (response.statusCode == 200) {
        // --- LOG IMPORTANTE: MOSTRA O QUE O JAVA ESTÁ MANDANDO ---
        print("RESPOSTA DO JAVA (GET REMEDIOS): ${utf8.decode(response.bodyBytes)}");
        // ---------------------------------------------------------

        var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        List<dynamic> lista;

        if (jsonResponse is List) {
          lista = jsonResponse;
        } else if (jsonResponse is Map && jsonResponse.containsKey('content')) {
          lista = jsonResponse['content'];
        } else {
          return [];
        }
        return lista.map((item) => Remedio.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Falha ao buscar remédios: ${response.statusCode}'); 
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<List<Pessoa>> getPessoas() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/pessoas'));
      if (response.statusCode == 200) {
        // --- LOG IMPORTANTE: MOSTRA O QUE O JAVA ESTÁ MANDANDO ---
        // print("RESPOSTA DO JAVA (GET PESSOAS): ${utf8.decode(response.bodyBytes)}");
        
        var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        List<dynamic> lista;
        if (jsonResponse is List) {
          lista = jsonResponse;
        } else if (jsonResponse is Map && jsonResponse.containsKey('content')) {
          lista = jsonResponse['content'];
        } else {
          return [];
        }
        return lista.map((p) => Pessoa.fromJson(p as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Falha ao buscar pessoas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<void> addRemedio(Remedio remedio) async {
    final response = await http.post(
      Uri.parse('$baseUrl/remedios'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(remedio.toJson()),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
       print("ERRO BACKEND BODY: ${response.body}");
       print("O QUE EU ENVIEI: ${jsonEncode(remedio.toJson())}");
      throw Exception('Erro ao salvar: ${response.body}');
    }
  }

  Future<void> deleteRemedio(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/remedios/$id'));
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Erro ao deletar: ${response.statusCode}');
    }
  }

  Future<bool> login(String email, String senha) async {
    try {
      final url = Uri.parse('$baseUrl/users/login');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": senha}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false; 
    }
  }

  Future<void> createPessoa(String nome) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/pessoas'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"nome": nome}),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Erro ao criar pessoa: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão ao criar pessoa: $e');
    }
  }

  Future<void> updateRemedio(Remedio remedio) async {
    final url = Uri.parse('$baseUrl/remedios/${remedio.id}');
    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(remedio.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar: ${response.statusCode}');
    }
  }

  Future<int> getQuantidadePessoas() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/pessoas'));
      if (response.statusCode == 200) {
        List<dynamic> lista = jsonDecode(utf8.decode(response.bodyBytes));
        return lista.length;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<String> enviarMensagemChat(String pergunta) async {
    try {
      List<Remedio> remedios = await getRemedios();
      String dadosEstoque = jsonEncode(remedios.map((e) => e.toJson()).toList());
      final body = {
        "pergunta": pergunta,
        "dadosJson": dadosEstoque
      };
      final response = await http.post(
        Uri.parse('$baseUrl/chat'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        return utf8.decode(response.bodyBytes);
      } else {
        return "Erro ${response.statusCode}";
      }
    } catch (e) {
      return "Erro de conexão: $e";
    }
  }
}