// ignore_for_file: avoid_print

import 'package:dio/dio.dart';

class BrapiService {
  final String _baseUrl = "https://brapi.dev/api";

  final String _apiKey = "3kSPaBfEAABS9Trd5qR962";

  final dio = Dio();

  Future<Map<String, dynamic>> buscarCotacao(String? ticker) async {
    try {
      if (ticker == null || ticker.isEmpty) {
        throw Exception('Por favor, insira um código de ação válido.');
      }

      final response = await dio.get(
        "$_baseUrl/quote/$ticker",
        queryParameters: {'token': _apiKey, 'range': '1d'},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['results'] != null && data['results'].isNotEmpty) {
          return data['results'][0];
        } else {
          throw Exception('Ação não encontrada.');
        }
      } else {
        throw Exception(
          'Erro ${response.statusCode}: Falha ao buscar cotação.',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Tempo de conexão esgotado.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Erro de conexão com a internet.');
      } else {
        throw Exception('Erro ao buscar cotação: ${e.message}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> listarAcoesPopulares() async {
    try {
      final response = await dio.get(
        "$_baseUrl/quote/list",
        queryParameters: {
          'token': _apiKey,
          'sortBy': 'volume',
          'sortOrder': 'desc',
          'limit': 50,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['stocks'] != null) {
          return data['stocks'];
        } else {
          throw Exception('Nenhuma ação encontrada.');
        }
      } else {
        throw Exception('Erro ${response.statusCode}: Falha ao listar ações.');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Tempo de conexão esgotado.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Erro de conexão com a internet.');
      } else {
        throw Exception('Erro ao listar ações: ${e.message}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> buscarMultiplasCotacoes(List<String> tickers) async {
    try {
      if (tickers.isEmpty) {
        throw Exception('Por favor, forneça pelo menos um código de ação.');
      }

      List<dynamic> results = [];


      for (String ticker in tickers) {
        try {
          print('Buscando cotação para: $ticker'); 

          final response = await dio.get(
            "$_baseUrl/quote/$ticker",
            queryParameters: {'token': _apiKey, 'range': '1d'},
            options: Options(
              validateStatus: (status) {
                return status != null && status < 500;
              },
            ),
          );

          print('Status code para $ticker: ${response.statusCode}');

          if (response.statusCode == 200) {
            final data = response.data;
            if (data['results'] != null && data['results'].isNotEmpty) {
              results.add(data['results'][0]);
            }
          } else if (response.statusCode == 429) {
            throw Exception(
              'Limite de requisições excedido. Aguarde alguns segundos.',
            );
          }

          await Future.delayed(Duration(milliseconds: 300));
        } catch (e) {
          print('Erro ao buscar $ticker: $e');
        }
      }

      if (results.isEmpty) {
        throw Exception('Nenhuma ação encontrada.');
      }

      return results;
    } on DioException catch (e) {
      print('DioException: ${e.type}');
      print('DioException response: ${e.response?.data}');

      if (e.response?.statusCode == 429) {
        throw Exception(
          'Limite de requisições excedido. Aguarde alguns segundos e tente novamente.',
        );
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Tempo de conexão esgotado.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Erro de conexão com a internet.');
      } else if (e.response != null) {
        throw Exception('Erro ao buscar cotações.');
      } else {
        throw Exception('Erro ao buscar cotações: ${e.message}');
      }
    } catch (e) {
      print('Erro geral: $e');
      rethrow;
    }
  }
}
