import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'db_helper.dart';
import 'add_expense_screen.dart';

class Gasto {
  int? id;
  final String descripcion;
  final String categoria;
  final double monto;
  final DateTime fecha;

  Gasto({
    this.id,
    required this.descripcion,
    required this.categoria,
    required this.monto,
    required this.fecha,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'descripcion': descripcion,
      'categoria': categoria,
      'monto': monto,
      'fecha': fecha.toIso8601String(),
    };
  }

  factory Gasto.fromMap(Map<String, dynamic> map) {
    return Gasto(
      id: map['id'],
      descripcion: map['descripcion'],
      categoria: map['categoria'],
      monto: map['monto'],
      fecha: DateTime.parse(map['fecha']),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Gasto> _gastos = [];

  @override
  void initState() {
    super.initState();
    _cargarGastos();
  }

  Future<void> _cargarGastos() async {
    final gastos = await DBHelper.obtenerGastos();
    setState(() {
      _gastos = gastos;
    });
  }

  double get _totalGastos => _gastos.fold(0.0, (sum, g) => sum + g.monto);

  Future<void> _eliminarGasto(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: const Text('¿Deseas eliminar este gasto?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await DBHelper.eliminarGasto(id);
      _cargarGastos();
    }
  }

  void _agregarOEditarGasto({Gasto? gastoExistente}) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddExpenseScreen(gasto: gastoExistente),
      ),
    );
    if (resultado == true) {
      _cargarGastos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestor de Gastos')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Total Gastado: \$${_totalGastos.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child:
                _gastos.isEmpty
                    ? const Center(child: Text('No hay gastos registrados.'))
                    : ListView.builder(
                      itemCount: _gastos.length,
                      itemBuilder: (context, index) {
                        final gasto = _gastos[index];
                        return ListTile(
                          title: Text(gasto.descripcion),
                          subtitle: Text(
                            '${gasto.categoria} - ${DateFormat('dd/MM/yyyy').format(gasto.fecha)}',
                          ),
                          trailing: Text('\$${gasto.monto.toStringAsFixed(2)}'),
                          onTap:
                              () => _agregarOEditarGasto(gastoExistente: gasto),
                          onLongPress: () => _eliminarGasto(gasto.id!),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _agregarOEditarGasto(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
