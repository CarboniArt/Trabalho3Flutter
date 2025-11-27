import 'package:flutter/material.dart';
import '../service/brapi_service.dart';
import 'components/barra_tecnologica.dart';
import 'buscar_cotacao_page.dart';
import '../utils/app_colors.dart';

class ListarAcoesPage extends StatefulWidget {
  const ListarAcoesPage({super.key});

  @override
  State<ListarAcoesPage> createState() => _ListarAcoesPageState();
}

class _ListarAcoesPageState extends State<ListarAcoesPage> {
  final apiService = BrapiService();
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = apiService.listarAcoesPopulares();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'AÇÕES POPULARES',
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
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: CoresApp.fundoEscuro),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: BarraTecnologica(color: CoresApp.fundoEscuro),
        ),
      ),
      backgroundColor: Color(0xFFF8FAFC),
      body: FutureBuilder<List<dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(CoresApp.fundoEscuro),
                strokeWidth: 3.0,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: CoresApp.vermelho,
                    size: 70,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    snapshot.error.toString().replaceFirst('Exception: ', ''),
                    style: const TextStyle(
                      color: CoresApp.vermelho,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          } else if (snapshot.hasData) {
            final acoes = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: acoes.length > 50 ? 50 : acoes.length,
              itemBuilder: (context, index) {
                final acao = acoes[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Color(0xFFE2E8F0), width: 2),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: CoresApp.fundoEscuro.withOpacity(0.1),
                        border: Border.all(
                          color: CoresApp.fundoEscuro,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          acao['stock']?.substring(0, 2) ?? '??',
                          style: const TextStyle(
                            color: CoresApp.fundoEscuro,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      acao['stock'] ?? '-',
                      style: const TextStyle(
                        color: CoresApp.fundoCard,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 1.5,
                      ),
                    ),
                    subtitle: Text(
                      acao['name'] ?? '-',
                      style: const TextStyle(
                        color: CoresApp.fundoEscuro,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward,
                      color: CoresApp.fundoEscuro,
                      size: 20,
                    ),
                    onTap: () => _navegarParaDetalhes(context, acao['stock']),
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: Text(
                "Nenhuma ação disponível",
                style: TextStyle(color: CoresApp.textoClaro54),
              ),
            );
          }
        },
      ),
    );
  }

  void _navegarParaDetalhes(BuildContext context, String? ticker) {
    if (ticker == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BuscarCotacaoPage(tickerInicial: ticker),
      ),
    );
  }
}
