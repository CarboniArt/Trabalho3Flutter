import 'package:flutter/material.dart';
import 'package:patrimonio_investimentos/service/auth_service.dart';
import 'components/my_textfield.dart';
import 'components/my_button.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();
  final _authService = AuthService();
  bool _loading = false;

  @override
  void dispose() {
    userNameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void signUserIn() async {
    if (userNameController.text.isEmpty || passwordController.text.isEmpty) {
      _showErrorDialog('Por favor, preencha todos os campos');
      return;
    }

    setState(() => _loading = true);

    try {
      await _authService.signInWithEmailAndPassword(
        email: userNameController.text.trim(),
        password: passwordController.text,
      );
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Erro"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: <Widget>[
                const SizedBox(height: 50),
                const Icon(Icons.account_balance_wallet, size: 100),
                const SizedBox(height: 50),
                Text(
                  'Seja bem Vindo!',
                  style: TextStyle(color: Colors.black, fontSize: 25),
                ),
                const SizedBox(height: 25),
                MyTextField(
                  controller: userNameController,
                  hintText: "Email",
                  obscureText: false,
                ),
                const SizedBox(height: 15),
                MyTextField(
                  controller: passwordController,
                  hintText: "Senha",
                  obscureText: true,
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final email = userNameController.text.trim();
                          if (email.isEmpty) {
                            _showErrorDialog(
                              'Por favor, digite seu email para recuperar a senha',
                            );
                            return;
                          }
                          try {
                            await _authService.sendPasswordResetEmail(email);
                            if (!mounted) return;
                            _showErrorDialog(
                              'Email de recuperação enviado! Verifique sua caixa de entrada.',
                            );
                          } catch (e) {
                            if (!mounted) return;
                            _showErrorDialog(e.toString());
                          }
                        },
                        child: Text(
                          'Esqueceu a senha?',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                _loading
                    ? const CircularProgressIndicator()
                    : MyButton(onTap: signUserIn, text: "Entrar"),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Não tem Cadastro?',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegisterPage(),
                          ),
                        );
                      },
                      child: const Text(
                        'Registre-se Agora!',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
