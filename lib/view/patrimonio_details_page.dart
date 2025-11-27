//certo
import 'dart:io';
import 'package:patrimonio_investimentos/service/firestore_service.dart';
import 'package:patrimonio_investimentos/model/patrimonio.dart';
import 'package:patrimonio_investimentos/utils/app_colors.dart';
import 'package:patrimonio_investimentos/view/patrimonio_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PatrimonioDetailsPage extends StatelessWidget {
  final Patrimonio patrimonio;
  final String docID;
  final FirestoreService firestoreService = FirestoreService();

  PatrimonioDetailsPage({required this.patrimonio, required this.docID});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final dateFormatter = DateFormat('dd/MM/yyyy');

    String? dataAquisicaoString = patrimonio.dataAquisicao;
    DateTime? dataAquisicao;
    if (dataAquisicaoString != null && dataAquisicaoString.isNotEmpty) {
      dataAquisicao = DateTime.tryParse(dataAquisicaoString);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(patrimonio.tipoItem),
        titleTextStyle: const TextStyle(
          color: CoresApp.fundoCard,
          fontWeight: FontWeight.w700,
          fontSize: 20,
          letterSpacing: 2.5,
        ),
        centerTitle: true,
        backgroundColor: CoresApp.textoBranco,
        elevation: 0,
        iconTheme: const IconThemeData(color: CoresApp.fundoEscuro),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (patrimonio.fotos != null && patrimonio.fotos!.isNotEmpty)
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: CoresApp.fundoEscuro, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: CoresApp.azulComOpacity(0.20),
                      blurRadius: 8,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.file(File(patrimonio.fotos!), fit: BoxFit.cover),
                ),
              )
            else
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: CoresApp.textoBranco,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                ),
                child: Icon(
                  _getIconForTipo(patrimonio.tipoItem),
                  color: CoresApp.fundoEscuro,
                  size: 80,
                ),
              ),

            const SizedBox(height: 25),

            Text(
              patrimonio.tipoItem,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: CoresApp.fundoCard,
                letterSpacing: 2.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: CoresApp.textoBranco,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
              ),
              child: Text(
                formatter.format(patrimonio.valorEstimado),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: CoresApp.fundoEscuro,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildInfoTile(
              Icons.category,
              "Categoria",
              patrimonio.categoriaUso,
            ),
            _buildInfoTile(
              Icons.description,
              "Descrição",
              patrimonio.descricao,
            ),
            _buildInfoTile(
              Icons.calendar_today,
              "Data de Aquisição",
              dataAquisicao != null ? dateFormatter.format(dataAquisicao) : "-",
            ),

            if (patrimonio.detalhesExtra != null &&
                patrimonio.detalhesExtra!.isNotEmpty)
              _buildInfoTile(
                Icons.info_outline,
                "Detalhes Extras",
                patrimonio.detalhesExtra!,
              ),

            const SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PatrimonioPage(
                          patrimonio: patrimonio,
                          docID: docID,
                        ),
                      ),
                    );
                    if (result != null) {
                      Navigator.pop(context, result);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CoresApp.fundoEscuro,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 12,
                    ),
                  ),
                  icon: const Icon(Icons.edit, color: CoresApp.textoBranco),
                  label: const Text(
                    "EDITAR",
                    style: TextStyle(
                      color: CoresApp.textoBranco,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final confirm = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: CoresApp.textoBranco,
                        title: const Text(
                          "Excluir Patrimônio",
                          style: TextStyle(color: CoresApp.fundoCard),
                        ),
                        content: Text(
                          "Tem certeza que deseja excluir este ${patrimonio.tipoItem}?",
                          style: const TextStyle(color: CoresApp.textoClaro54),
                        ),
                        actions: [
                          TextButton(
                            child: const Text(
                              "Cancelar",
                              style: TextStyle(color: CoresApp.fundoEscuro),
                            ),
                            onPressed: () => Navigator.pop(context, false),
                          ),
                          TextButton(
                            child: const Text(
                              "Excluir",
                              style: TextStyle(color: CoresApp.vermelho),
                            ),
                            onPressed: () => Navigator.pop(context, true),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await firestoreService.delete(docID);
                      Navigator.pop(context, true);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CoresApp.vermelho,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 12,
                    ),
                  ),
                  icon: const Icon(Icons.delete, color: CoresApp.textoBranco),
                  label: const Text(
                    "EXCLUIR",
                    style: TextStyle(
                      color: CoresApp.textoBranco,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: CoresApp.textoBranco,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: CoresApp.fundoEscuro),
          const SizedBox(width: 10),
          Text(
            "$label:",
            style: const TextStyle(
              color: CoresApp.fundoEscuro,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : "-",
              style: const TextStyle(fontSize: 16, color: CoresApp.fundoCard),
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForTipo(String tipo) {
    switch (tipo) {
      case 'Casa':
        return Icons.home;
      case 'Terreno':
        return Icons.landscape;
      case 'Veículo':
        return Icons.directions_car;
      case 'Ação':
        return Icons.trending_up;
      case 'Outros':
        return Icons.category;
      default:
        return Icons.account_balance_wallet;
    }
  }
}
