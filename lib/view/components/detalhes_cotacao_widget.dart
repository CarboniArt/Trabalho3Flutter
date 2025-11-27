import 'package:flutter/material.dart';
import 'package:patrimonio_investimentos/utils/app_colors.dart';

class DetalhesCotacaoWidget extends StatelessWidget {
  final Map<String, dynamic> data;


  const DetalhesCotacaoWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final preco = data['regularMarketPrice']?.toStringAsFixed(2) ?? '-';
    final variacao = data['regularMarketChange']?.toStringAsFixed(2) ?? '-';
    final variacaoPercent =
        data['regularMarketChangePercent']?.toStringAsFixed(2) ?? '-';
    final isPositive = (data['regularMarketChange'] ?? 0) >= 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 10.0),
      child: Column(
        children: [
          // CARD PRINCIPAL
          Container(
            decoration: BoxDecoration(
              color: CoresApp.textoBranco,
              border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  // Símbolo da ação
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: CoresApp.textoBranco,
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      data['symbol'] ?? '-',
                      style: const TextStyle(
                        color: CoresApp.fundoEscuro,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    (data['shortName'] ?? data['longName'] ?? '-')
                        .toUpperCase(),
                    style: const TextStyle(
                      color: CoresApp.textoClaro54,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 25),

                  // PREÇO
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'R\$ ',
                        style: TextStyle(
                          color: CoresApp.textoClaro54,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        preco,
                        style: const TextStyle(
                          color: CoresApp.fundoEscuro,
                          fontSize: 52,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          height: 1,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // VARIAÇÃO
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isPositive
                          ? CoresApp.verdeComOpacity(0.15)
                          : Colors.red.withOpacity(0.15),
                      border: Border.all(
                        color: isPositive
                            ? const Color(0xFF10B981)
                            : Colors.red,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPositive
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color: isPositive
                              ? const Color(0xFF10B981)
                              : Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'R\$ $variacao ($variacaoPercent%)',
                          style: TextStyle(
                            color: isPositive
                                ? const Color(0xFF10B981)
                                : Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 15),

          // INFO EXTRA
          Container(
            decoration: BoxDecoration(
              color: CoresApp.textoBranco,
              border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildInfoRow(
                    'ABERTURA',
                    'R\$ ${data['regularMarketOpen']?.toStringAsFixed(2) ?? '-'}',
                  ),
                  Divider(color: const Color(0xFFE2E8F0)),
                  _buildInfoRow(
                    'MÁXIMA',
                    'R\$ ${data['regularMarketDayHigh']?.toStringAsFixed(2) ?? '-'}',
                  ),
                  Divider(color: const Color(0xFFE2E8F0)),
                  _buildInfoRow(
                    'MÍNIMA',
                    'R\$ ${data['regularMarketDayLow']?.toStringAsFixed(2) ?? '-'}',
                  ),
                  Divider(color: const Color(0xFFE2E8F0)),
                  _buildInfoRow(
                    'FECH. ANTERIOR',
                    'R\$ ${data['regularMarketPreviousClose']?.toStringAsFixed(2) ?? '-'}',
                  ),
                  Divider(color: const Color(0xFFE2E8F0)),
                  _buildInfoRow(
                    'VOLUME',
                    _formatVolume(data['regularMarketVolume']),
                  ),
                  Divider(color: const Color(0xFFE2E8F0)),
                  _buildInfoRow('MOEDA', data['currency'] ?? '-'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: CoresApp.fundoEscuro,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: CoresApp.fundoEscuro,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  String _formatVolume(dynamic volume) {
    if (volume == null) return '-';
    if (volume >= 1000000000) return '${(volume / 1e9).toStringAsFixed(2)}B';
    if (volume >= 1000000) return '${(volume / 1e6).toStringAsFixed(2)}M';
    if (volume >= 1000) return '${(volume / 1e3).toStringAsFixed(2)}K';
    return volume.toString();
  }
}
