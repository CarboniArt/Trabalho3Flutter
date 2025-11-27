//certo
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:patrimonio_investimentos/service/firestore_service.dart';
import 'package:patrimonio_investimentos/model/patrimonio.dart';
import 'package:patrimonio_investimentos/view/components/barra_tecnologica.dart';
import 'patrimonio_page.dart';
import 'patrimonio_details_page.dart';
import 'package:intl/intl.dart';
import 'package:patrimonio_investimentos/utils/app_colors.dart';

class PatrimonioHomePage extends StatefulWidget {
  @override
  _PatrimonioHomePageState createState() => _PatrimonioHomePageState();
}

class _PatrimonioHomePageState extends State<PatrimonioHomePage> {
  final FirestoreService firestoreService = FirestoreService();

  void _openPatrimonioDetails(Patrimonio patrimonio, String docID) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PatrimonioDetailsPage(patrimonio: patrimonio, docID: docID),
      ),
    );

    if (result != null) {
      setState(() {});
    }
  }

  void _showPatrimonioPage({Patrimonio? patrimonio, String? docID}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PatrimonioPage(patrimonio: patrimonio, docID: docID),
      ),
    );
  }

  double _calcularTotal(List<QueryDocumentSnapshot> patrimonios) {
    double total = 0.0;
    for (var doc in patrimonios) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      total += (data['valorEstimado'] ?? 0.0);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: CoresApp.textoBranco),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: CoresApp.fundoCard,
        elevation: 0,
        title: const Text(
          "Meus Investimentos",
          style: TextStyle(
            color: CoresApp.textoBranco,
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.5,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: CoresApp.fundoEscuro,
        child: Icon(Icons.add, color: CoresApp.textoBranco),
        onPressed: () => _showPatrimonioPage(),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: firestoreService.read(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<QueryDocumentSnapshot<Object?>> patrimoniosList = snapshot
                    .data!
                    .docs
                    .cast<QueryDocumentSnapshot<Object?>>();
                double total = _calcularTotal(patrimoniosList);

                return Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: CoresApp.textoBranco,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 2,
                        ),
                      ),
                      child: Text(
                        "Total: ${NumberFormat.currency(locale: 'pt_BR', symbol: r'R$').format(total)}",
                        style: const TextStyle(
                          color: CoresApp.fundoEscuro,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    BarraTecnologica(color: CoresApp.fundoEscuro),
                  ],
                );
              } else {
                return Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: CoresApp.textoBranco,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 2,
                        ),
                      ),
                      child: Text(
                        "Total: R\$ 0,00",
                        style: const TextStyle(
                          color: CoresApp.fundoEscuro,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    BarraTecnologica(color: CoresApp.fundoEscuro),
                  ],
                );
              }
            },
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestoreService.read(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            "Carregando patrimônios...",
                            style: TextStyle(
                              color: CoresApp.fundoEscuro,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  default:
                    if (snapshot.hasData) {
                      List patrimoniosList = snapshot.data!.docs;

                      if (patrimoniosList.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.account_balance_wallet,
                                color: CoresApp.fundoEscuro,
                                size: 60,
                              ),
                              SizedBox(height: 15),
                              Text(
                                "Nenhum patrimônio cadastrado!",
                                style: TextStyle(
                                  color: CoresApp.fundoCard,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: EdgeInsets.all(20),
                        itemCount: patrimoniosList.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot document = patrimoniosList[index];
                          String docID = document.id;
                          Map<String, dynamic> data =
                              document.data() as Map<String, dynamic>;

                          Patrimonio patrimonio = Patrimonio.fromMap(
                            docID,
                            data,
                          );

                          return _buildPatrimonioCard(patrimonio, docID);
                        },
                      );
                    } else {
                      return Center(
                        child: Text(
                          "Nenhum patrimônio encontrado...",
                          style: TextStyle(
                            color: CoresApp.textoClaro54,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatrimonioCard(Patrimonio patrimonio, String docID) {
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: r'R$');

    return GestureDetector(
      onTap: () => _openPatrimonioDetails(patrimonio, docID),
      child: Container(
        margin: EdgeInsets.only(bottom: 15),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: CoresApp.textoBranco,
          border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
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
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              padding: patrimonio.fotos != null
                  ? EdgeInsets.zero
                  : const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: CoresApp.fundoEscuro.withOpacity(0.1),
                border: Border.all(color: CoresApp.fundoEscuro, width: 1.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: patrimonio.fotos != null && patrimonio.fotos!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.file(
                        File(patrimonio.fotos!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            _getIconForTipo(patrimonio.tipoItem),
                            color: CoresApp.fundoEscuro,
                            size: 30,
                          );
                        },
                      ),
                    )
                  : Icon(
                      _getIconForTipo(patrimonio.tipoItem),
                      color: CoresApp.fundoEscuro,
                      size: 30,
                    ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patrimonio.tipoItem,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: CoresApp.fundoCard,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    patrimonio.descricao,
                    style: const TextStyle(
                      fontSize: 10,
                      color: CoresApp.textoClaro54,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    formatter.format(patrimonio.valorEstimado),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: CoresApp.fundoEscuro,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward,
              color: CoresApp.fundoEscuro,
              size: 24,
            ),
          ],
        ),
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
