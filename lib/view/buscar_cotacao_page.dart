// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../service/brapi_service.dart';
import 'components/barra_tecnologica.dart';
import 'components/detalhes_cotacao_widget.dart';
import '../utils/app_colors.dart';

class BuscarCotacaoPage extends StatefulWidget {
  final String? tickerInicial;

  const BuscarCotacaoPage({super.key, this.tickerInicial});

  @override
  State<BuscarCotacaoPage> createState() => _BuscarCotacaoPageState();
}

class _BuscarCotacaoPageState extends State<BuscarCotacaoPage> {
  String? ticker;
  Future<Map<String, dynamic>>? _future;
  final apiService = BrapiService();
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.tickerInicial != null) {
      _textController.text = widget.tickerInicial!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _buscarTicker(widget.tickerInicial!);
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  String? validarTicker(String ticker) {
    if (ticker.isEmpty) {
      return 'Digite o código de uma ação';
    }

    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(ticker)) {
      return 'O código contém caracteres inválidos. Use apenas letras e números.';
    }

    if (ticker.length < 4) {
      return 'O código está muito curto. Ex: PETR4 (mínimo 4 caracteres)';
    }

    if (ticker.length > 6) {
      return 'O código está muito longo. Ex: PETR4 (máximo 6 caracteres)';
    }

    if (!RegExp(r'\d$').hasMatch(ticker)) {
      return 'O código deve terminar com um número. Ex: PETR4, VALE3';
    }

    return null;
  }

  void _buscarTicker(String value) {
    final tickerUpper = value.toUpperCase().trim();
    final erro = validarTicker(tickerUpper);

    if (erro != null) {
      setState(() {
        ticker = tickerUpper;
        _future = Future.error(erro);
      });
    } else {
      setState(() {
        ticker = tickerUpper;
        _future = apiService.buscarCotacao(tickerUpper);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'BUSCAR COTAÇÃO',
          style: TextStyle(
            color: CoresApp.fundoCard,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.5,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: CoresApp.fundoEscuro),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: BarraTecnologica(color: CoresApp.fundoEscuro),
        ),
      ),
      backgroundColor: Color(0xFFF8FAFC),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: CoresApp.fundoEscuro, width: 2),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  labelText: "CÓDIGO DA AÇÃO (EX: PETR4)",
                  labelStyle: TextStyle(
                    color: CoresApp.fundoEscuro,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                  prefixIcon: Icon(Icons.terminal, color: CoresApp.fundoEscuro),
                ),
                style: const TextStyle(
                  color: CoresApp.fundoCard,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
                textCapitalization: TextCapitalization.characters,
                onSubmitted: _buscarTicker,
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: _future == null
                  ? _dicasDeBusca()
                  : FutureBuilder<Map<String, dynamic>>(
                      future: _future,
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                            return const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  CoresApp.fundoEscuro,
                                ),
                                strokeWidth: 3.0,
                              ),
                            );
                          default:
                            if (snapshot.hasError) {
                              return _exibirErro(snapshot.error.toString());
                            } else {
                              return DetalhesCotacaoWidget(
                                data: snapshot.data!,
                              );
                            }
                        }
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dicasDeBusca() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(top: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: CoresApp.fundoEscuro.withOpacity(0.4)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.search, size: 50, color: CoresApp.fundoEscuro),
            SizedBox(height: 15),
            Text(
              "Digite o código de uma ação acima",
              style: TextStyle(
                color: CoresApp.fundoCard,
                fontSize: 14,
                letterSpacing: 1,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Exemplos: PETR4, VALE3, BBAS3...",
              style: TextStyle(color: CoresApp.textoClaro54, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _exibirErro(String errorMsg) {
    String displayMsg;

    if (!errorMsg.contains('Exception:')) {
      displayMsg = errorMsg;
    } else if (errorMsg.contains('404') ||
        errorMsg.contains('não encontrad') ||
        errorMsg.contains('not found')) {
      displayMsg = 'Ação "$ticker" não encontrada na base de dados';
    } else {
      displayMsg = errorMsg.replaceFirst('Exception: ', '');
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: CoresApp.vermelho, size: 70),
          const SizedBox(height: 20),
          const Text(
            "ERRO",
            style: TextStyle(
              color: CoresApp.vermelho,
              fontWeight: FontWeight.w900,
              fontSize: 16,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              displayMsg,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: CoresApp.textoClaro54,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
