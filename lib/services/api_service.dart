import 'dart:convert';
import 'package:http/http.dart' as http;

class Remedio {
  final int? id;
  final String nome;
  final int quantidade;
  final double usoDiario;
  final String status;
  final String horario;
  final String proximaCompra;
  final int? pessoaId;

  Remedio({
    this.id,
    required this.nome,
    required this.quantidade,
    required this.usoDiario,
    required this.status,
    required this.horario,
    required this.proximaCompra,
    this.pessoaId,
  });

  factory Remedio.fromJson(Map<String, dynamic> json) {
    return Remedio(
      id: json['id'],
      nome: json['nome'] ?? 'Sem nome',
      quantidade: json['quantidade'] ?? 0,
      // CORREÇÃO 1: Conversão segura de número para double
      usoDiario: (json['usoDiario'] ?? 0).toDouble(),
      status: json['status'] ?? 'NORMAL',
      horario: json['horario'] ?? '--:--',
      proximaCompra: json['proximaCompra'] ?? '--/--',
      pessoaId: json['pessoaId'] ?? json['pessoa'] ?? null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'quantidade': quantidade,
      'usoDiario': usoDiario,
      'status': status,
      'horario': horario,
      'proximaCompra': proximaCompra,
      if (pessoaId != null) 'pessoaId': pessoaId,
    };
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
  // Se estiver no Emulador Android, use 'http://10.0.2.2:8080'
  // Se estiver na Web, use 'http://localhost:8080'
  static const String baseUrl = 'http://localhost:8080';

  Future<List<Remedio>> getRemedios() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/remedios'));

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));

        List<dynamic> listaParaConverter;

        if (jsonResponse is List) {
          listaParaConverter = jsonResponse;
        } else if (jsonResponse is Map && jsonResponse.containsKey('content')) {
          listaParaConverter = jsonResponse['content'];
        } else {
          return [];
        }

        return listaParaConverter
            .map((item) => Remedio.fromJson(item))
            .toList();
      } else {
        throw Exception('Falha: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<List<Pessoa>> getPessoas() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/pessoas'));

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        List<dynamic> lista;
        if (jsonResponse is List) {
          lista = jsonResponse;
        } else if (jsonResponse is Map && jsonResponse.containsKey('content')) {
          lista = jsonResponse['content'];
        } else {
          return [];
        }

        return lista
            .map((p) => Pessoa.fromJson(p as Map<String, dynamic>))
            .toList();
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
      // CORREÇÃO 4: Verifique se sua rota no Java é /auth/login ou /users/login
      // Geralmente em tutoriais Spring Security é /auth/login
      final url = Uri.parse('$baseUrl/users/login');

      print("Tentando logar em: $url com $email"); // Debug

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": senha}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print("Erro Login: ${response.body}"); // Debug para ver o erro real
        return false;
      }
    } catch (e) {
      print("Exceção Login: $e");
      return false; // Retorna false em vez de crashar o app
    }
  }

  Future<void> createPessoa(String nome) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/pessoas'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nome": nome,
          // Se exigir mais campos (ex: cpf, idade), adicione aqui.
          // Por enquanto, vou mandar só o nome.
        }),
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
        // Assume que retorna uma Lista [{}, {}]
        List<dynamic> lista = jsonDecode(utf8.decode(response.bodyBytes));
        return lista.length;
      }
      return 0;
    } catch (e) {
      print("Erro ao contar pessoas: $e");
      return 0;
    }
  }

Future<String> enviarMensagemChat(String pergunta) async {
    try {
      // 1. Busca os dados atuais para dar contexto à IA
      List<Remedio> remedios = await getRemedios();
      
      // 2. Transforma a lista de remédios em uma String JSON
      // Isso permite que o Gemini saiba o que tem no estoque
      String dadosEstoque = jsonEncode(remedios.map((e) => e.toJson()).toList());

      // 3. Monta o DTO esperado pelo Java (ChatRequestDTO)
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
        // O backend retorna a String da resposta diretamente
        return utf8.decode(response.bodyBytes);
      } else {
        return "Desculpe, tive um erro ao processar sua solicitação. (Erro ${response.statusCode})";
      }
    } catch (e) {
      return "Erro de conexão: $e";
    }
  }

}
