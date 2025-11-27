// ignore_for_file: deprecated_member_use

//import 'package:firebase_auth/firebase_auth.dart';
import 'package:patrimonio_investimentos/service/auth_service.dart';
import 'package:patrimonio_investimentos/view/Patrimonio_Home_Page.dart';
import 'buscar_cotacao_page.dart';
import 'package:flutter/material.dart';
import 'listar_acoes_page.dart';
import 'comparar_acoes_page.dart';
import '../utils/app_colors.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final _authService = AuthService();

  void signUserOut() async {
    await _authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CoresApp.textoBranco,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.show_chart, color: CoresApp.fundoEscuro, size: 30),
            const SizedBox(width: 10),
            Text(
              'COTAÇÕES B3',
              style: TextStyle(
                color: CoresApp.fundoCard,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.5,
                fontSize: 18,
              ),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: signUserOut,
            icon: Icon(Icons.logout, color: CoresApp.fundoEscuro),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF8FAFC),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              margin: EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                color: CoresApp.textoBranco,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
              ),
              child: Row(
                children: [
                  Icon(Icons.person, color: CoresApp.fundoEscuro),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Usuário: ${user?.displayName ?? user?.email ?? 'Usuário'}",
                      style: TextStyle(
                        color: CoresApp.fundoCard,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            _buildMenuCard(
              context,
              icon: Icons.search,
              title: "BUSCAR COTAÇÃO",
              subtitle: "SISTEMA DE CONSULTA EM TEMPO REAL",
              onTap: () => Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const BuscarCotacaoPage(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              ),
            ),
            const SizedBox(height: 15),
            _buildMenuCard(
              context,
              icon: Icons.list,
              title: "AÇÕES POPULARES",
              subtitle: "VISUALIZE AS PRINCIPAIS AÇÕES DO MERCADO",
              onTap: () => Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => ListarAcoesPage(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              ),
            ),
            const SizedBox(height: 15),
            _buildMenuCard(
              context,
              icon: Icons.compare_arrows,
              title: "COMPARAR AÇÕES",
              subtitle: "COMPARE DUAS AÇÕES LADO A LADO",
              onTap: () => Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const CompararAcoesPage(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              ),
            ),
            const SizedBox(height: 15),
            _buildMenuCard(
              context,
              icon: Icons.account_balance_wallet,
              title: "MEUS INVESTIMENTOS",
              subtitle: "GERENCIE SEU PATRIMÔNIO",
              onTap: () => Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => PatrimonioHomePage(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              ),
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
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
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: CoresApp.fundoEscuro.withOpacity(0.1),
                border: Border.all(color: CoresApp.fundoEscuro, width: 1.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: CoresApp.fundoEscuro, size: 32.0),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: CoresApp.fundoCard,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: CoresApp.fundoEscuro,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
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
}