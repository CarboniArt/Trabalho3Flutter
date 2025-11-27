// ignore_for_file: deprecated_member_use
import 'dart:io';
import 'package:patrimonio_investimentos/service/firestore_service.dart';
import 'package:patrimonio_investimentos/model/patrimonio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:patrimonio_investimentos/utils/app_colors.dart';

class PatrimonioPage extends StatefulWidget {
  final Patrimonio? patrimonio;
  final String? docID;

  const PatrimonioPage({Key? key, this.patrimonio, this.docID})
    : super(key: key);

  @override
  _PatrimonioPageState createState() => _PatrimonioPageState();
}

class BrazilianRealInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return TextEditingValue(text: '');
    }

    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.isEmpty) {
      return TextEditingValue(text: '');
    }

    int value = int.parse(digitsOnly);
    double realValue = value / 100;

    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$ ',
      decimalDigits: 2,
    );

    String formatted = formatter.format(realValue);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _PatrimonioPageState extends State<PatrimonioPage> {
  final FirestoreService firestoreService = FirestoreService();
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();
  final _detalhesController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  String? _selectedTipo;
  String? _selectedCategoria;
  String? _imagePath;
  DateTime? _dataAquisicao;

  bool _isSaving = false;

  final List<String> _tipos = ["Casa", "Terreno", "Veículo", "Ação", "Outros"];
  final List<String> _categorias = ["Pessoal", "Investimento", "Comercial"];

  @override
  void initState() {
    super.initState();
    if (widget.patrimonio != null) {
      _descricaoController.text = widget.patrimonio!.descricao;
      _valorController.text = _formatarValorParaExibicao(
        widget.patrimonio!.valorEstimado,
      );
      _detalhesController.text = widget.patrimonio!.detalhesExtra ?? '';
      _selectedTipo = widget.patrimonio!.tipoItem;
      _selectedCategoria = widget.patrimonio!.categoriaUso;
      _imagePath = widget.patrimonio!.fotos;

      String? dataString = widget.patrimonio!.dataAquisicao;
      if (dataString != null && dataString.isNotEmpty) {
        _dataAquisicao = DateTime.tryParse(dataString);
      }
    }
  }

  String _formatarValorParaExibicao(double valor) {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$ ',
      decimalDigits: 2,
    );
    return formatter.format(valor).replaceAll('R\$', '').trim();
  }

  double _converterTextoParaValor(String texto) {
    if (texto.isEmpty) return 0.0;

    final limpo = texto
        .replaceAll('R\$', '')
        .replaceAll(' ', '')
        .replaceAll('.', '')
        .replaceAll(',', '.');

    return double.tryParse(limpo) ?? 0.0;
  }

  bool _canHavePhotos() {
    return _selectedTipo == 'Casa' ||
        _selectedTipo == 'Terreno' ||
        _selectedTipo == 'Veículo';
  }

  Future<void> _pickImage() async {
    if (!_canHavePhotos()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Fotos não permitidas para ${_selectedTipo}")),
      );
      return;
    }

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataAquisicao ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(primary: Colors.green[700]!),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dataAquisicao = picked;
      });
    }
  }

  Future<void> _savePatrimonio() async {
    if (_formKey.currentState!.validate()) {
      if (_dataAquisicao == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Selecione a data de aquisição")),
        );
        return;
      }

      setState(() => _isSaving = true);

      try {
        final valor = _converterTextoParaValor(_valorController.text.trim());

        if (valor < 0) {
          throw Exception("Valor não pode ser negativo");
        }
        if (_dataAquisicao!.isAfter(DateTime.now())) {
          throw Exception("Data de aquisição não pode ser futura");
        }

        Patrimonio patrimonio = Patrimonio(
          id: widget.docID,
          descricao: _descricaoController.text.trim(),
          valorEstimado: valor,
          tipoItem: _selectedTipo ?? '',
          categoriaUso: _selectedCategoria ?? '',
          dataAquisicao: _dataAquisicao!.toIso8601String(),
          fotos: _canHavePhotos() ? _imagePath : null,
          detalhesExtra: _detalhesController.text.trim(),
        );

        if (widget.docID != null) {
          await firestoreService.update(widget.docID!, patrimonio);
        } else {
          await firestoreService.create(patrimonio);
        }

        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Erro ao salvar: $e")));
      } finally {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          widget.docID == null ? "Novo Patrimônio" : "Editar Patrimônio",
          style: const TextStyle(
            color: CoresApp.fundoCard,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: CoresApp.textoBranco,
        iconTheme: const IconThemeData(color: CoresApp.fundoEscuro),
        elevation: 0,
      ),
      body: _isSaving
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Salvando...",
                    style: TextStyle(color: CoresApp.fundoEscuro, fontSize: 16),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (_canHavePhotos() || _selectedTipo == null) ...[
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: CoresApp.textoBranco,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 2,
                            ),
                          ),
                          child: _imagePath != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.file(
                                    File(_imagePath!),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Icon(
                                  Icons.add_a_photo,
                                  color: CoresApp.fundoEscuro,
                                  size: 35,
                                ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        _imagePath == null ? "Adicionar Foto" : "Alterar Foto",
                        style: const TextStyle(
                          color: CoresApp.textoClaro54,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 15),
                    ],

                    _buildDropdown("Tipo de Item", _tipos, _selectedTipo, (
                      val,
                    ) {
                      setState(() {
                        _selectedTipo = val;
                        if (!_canHavePhotos()) {
                          _imagePath = null;
                        }
                      });
                    }),
                    SizedBox(height: 15),

                    _buildDropdown(
                      "Categoria de Uso",
                      _categorias,
                      _selectedCategoria,
                      (val) {
                        setState(() => _selectedCategoria = val);
                      },
                    ),
                    SizedBox(height: 15),

                    _buildTextField(
                      _descricaoController,
                      "Descrição",
                      Icons.description,
                    ),
                    SizedBox(height: 15),

                    _buildTextField(
                      _valorController,
                      "Valor Estimado (R\$)",
                      Icons.attach_money,
                      keyboard: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        BrazilianRealInputFormatter(),
                      ],
                    ),
                    SizedBox(height: 15),

                    GestureDetector(
                      onTap: _selectDate,
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: CoresApp.textoBranco,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: CoresApp.fundoEscuro,
                            ),
                            SizedBox(width: 10),
                            Text(
                              _dataAquisicao == null
                                  ? "Selecionar Data de Aquisição"
                                  : "Data: ${DateFormat('dd/MM/yyyy').format(_dataAquisicao!)}",
                              style: TextStyle(
                                color: _dataAquisicao == null
                                    ? const Color(0xFF64748B)
                                    : const Color(0xFF1E293B),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 15),

                    _buildTextField(
                      _detalhesController,
                      "Detalhes Extras",
                      Icons.info_outline,
                      maxLines: 3,
                      required: false,
                    ),
                    SizedBox(height: 30),

                    ElevatedButton.icon(
                      onPressed: _isSaving ? null : _savePatrimonio,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CoresApp.fundoEscuro,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.save, color: CoresApp.textoBranco),
                      label: const Text(
                        "SALVAR",
                        style: TextStyle(
                          color: CoresApp.textoBranco,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
    bool required = true,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      validator: (value) {
        if (required && (value == null || value.isEmpty)) {
          return "Preencha o campo $label";
        }
        if (label.contains("Valor") && value != null && value.isNotEmpty) {
          final valorConvertido = _converterTextoParaValor(value);
          if (valorConvertido <= 0) {
            return "O valor deve ser maior que zero";
          }
        }
        return null;
      },
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: CoresApp.fundoEscuro),
        labelText: label,
        labelStyle: const TextStyle(color: CoresApp.fundoEscuro),
        filled: true,
        fillColor: CoresApp.textoBranco,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: CoresApp.fundoEscuro, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: CoresApp.vermelho),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: CoresApp.vermelho, width: 2),
        ),
      ),
      style: const TextStyle(color: CoresApp.fundoCard),
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    String? value,
    Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      isExpanded: true,
      dropdownColor: CoresApp.textoBranco,
      borderRadius: BorderRadius.circular(8),
      validator: (val) =>
          val == null || val.isEmpty ? "Selecione $label" : null,
      items: items
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: Text(
                e,
                style: const TextStyle(fontSize: 16, color: CoresApp.fundoCard),
              ),
            ),
          )
          .toList(),
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.arrow_drop_down_circle,
          color: CoresApp.fundoEscuro,
        ),
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF60A5FA)),
        filled: true,
        fillColor: CoresApp.textoBranco,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 15,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: CoresApp.textoClaro54, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: CoresApp.vermelho),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: CoresApp.vermelho, width: 2),
        ),
      ),
      style: const TextStyle(color: CoresApp.fundoCard),
    );
  }
}
