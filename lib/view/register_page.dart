//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:patrimonio_investimentos/service/auth_service.dart';
import 'package:patrimonio_investimentos/service/user_service.dart';
import 'components/my_button.dart';
import 'components/my_textfield.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final userNameController = TextEditingController();
  final nameController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final passwordController = TextEditingController();
  final _authService = AuthService();
  final _userService = UserService();
  bool _loading = false;

  @override
  void dispose() {
    userNameController.dispose();
    nameController.dispose();
    confirmPasswordController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void showAlert(String mensagem) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Aviso"),
          content: Text(mensagem),
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

  void register() async {
    if (userNameController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty ||
        nameController.text.isEmpty) {
      showAlert('Por favor, preencha todos os campos');
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      showAlert('Senhas não conferem!');
      return;
    }

    if (passwordController.text.length < 6) {
      showAlert('A senha deve ter pelo menos 6 caracteres');
      return;
    }

    setState(() => _loading = true);

    try {
      final email = userNameController.text.trim();
      final password = passwordController.text;
      final name = nameController.text.trim();

      final user = await _authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (user == null) throw Exception('Erro ao criar usuário');

      await _authService.updateDisplayName(name);

      await _userService.createUserDocument(name: name, email: email);

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      showAlert(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
                Text(
                  'Crie seu Cadastro!',
                  style: TextStyle(color: Colors.grey[700], fontSize: 18),
                ),
                const SizedBox(height: 25),
                MyTextField(
                  controller: nameController,
                  hintText: "Nome Completo",
                  obscureText: false,
                ),
                const SizedBox(height: 15),
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
                MyTextField(
                  controller: confirmPasswordController,
                  hintText: "Confirmação de Senha",
                  obscureText: true,
                ),
                const SizedBox(height: 15),
                _loading
                    ? const CircularProgressIndicator()
                    : MyButton(onTap: register, text: "Registrar"),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Já tem uma conta?',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Entrar',
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
