// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'home_screen.dart';
import 'db_helper.dart';

class AddExpenseScreen extends StatefulWidget {
  final Gasto? gasto;

  const AddExpenseScreen({super.key, this.gasto});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descripcionController;
  late TextEditingController _montoController;
  String? _categoriaSeleccionada;
  DateTime? _fechaSeleccionada;

  final List<String> _categorias = [
    'Comida',
    'Transporte',
    'Entretenimiento',
    'Otros',
  ];

  @override
  void initState() {
    super.initState();
    final gasto = widget.gasto;
    _descripcionController = TextEditingController(
      text: gasto?.descripcion ?? '',
    );
    _montoController = TextEditingController(
      text: gasto != null ? gasto.monto.toString() : '',
    );
    _categoriaSeleccionada = gasto?.categoria;
    _fechaSeleccionada = gasto?.fecha;
  }

  void _seleccionarFecha() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _fechaSeleccionada = picked;
      });
    }
  }

  void _guardarGasto() async {
    if (_formKey.currentState!.validate() && _fechaSeleccionada != null) {
      final nuevoGasto = Gasto(
        id: widget.gasto?.id,
        descripcion: _descripcionController.text,
        monto: double.parse(_montoController.text),
        categoria: _categoriaSeleccionada!,
        fecha: _fechaSeleccionada!,
      );

      if (widget.gasto == null) {
        await DBHelper.insertarGasto(nuevoGasto);
      } else {
        await DBHelper.actualizarGasto(nuevoGasto);
      }

      Navigator.pop(context, true);
    }
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    _montoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.gasto != null;

    return Scaffold(
      appBar: AppBar(title: Text(esEdicion ? 'Editar Gasto' : 'Agregar Gasto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Campo requerido'
                            : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _categoriaSeleccionada,
                items:
                    _categorias
                        .map(
                          (cat) =>
                              DropdownMenuItem(value: cat, child: Text(cat)),
                        )
                        .toList(),
                onChanged:
                    (value) => setState(() => _categoriaSeleccionada = value),
                decoration: const InputDecoration(labelText: 'Categoría'),
                validator:
                    (value) =>
                        value == null ? 'Seleccione una categoría' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _montoController,
                decoration: const InputDecoration(labelText: 'Monto'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo requerido';
                  final num? parsed = num.tryParse(value);
                  return parsed == null ? 'Ingrese un número válido' : null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _fechaSeleccionada == null
                          ? 'Seleccione una fecha'
                          : 'Fecha: ${DateFormat('dd/MM/yyyy').format(_fechaSeleccionada!)}',
                    ),
                  ),
                  TextButton(
                    onPressed: _seleccionarFecha,
                    child: const Text('Elegir Fecha'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _guardarGasto,
                child: Text(esEdicion ? 'Actualizar Gasto' : 'Guardar Gasto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
