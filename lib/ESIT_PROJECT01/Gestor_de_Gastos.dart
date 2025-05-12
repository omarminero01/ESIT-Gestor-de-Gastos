// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const GastosApp());
}

class GastosApp extends StatelessWidget {
  const GastosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "GastosApp",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        hintColor: Colors.tealAccent,
        fontFamily: 'Montserrat',
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        textTheme: TextTheme(
          titleLarge: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black87,
          ),
          titleMedium: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16,
            color: Colors.grey[700],
          ),
          bodyMedium: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            color: Colors.black87,
          ),
          bodySmall: TextStyle(color: Colors.grey[600]),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.indigo,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: Colors.indigo),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.indigo, width: 2.0),
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
      home: const ExpenseHomePage(),
    );
  }
}

class ExpenseHomePage extends StatefulWidget {
  const ExpenseHomePage({super.key});

  @override
  State<ExpenseHomePage> createState() => _ExpenseHomePageState();
}

class _ExpenseHomePageState extends State<ExpenseHomePage> {
  final List<Map<String, dynamic>> _transactions = [];

  final List<String> _categories = [
    'Alimentación',
    'Transporte',
    'Entretenimiento',
    'Ropa y Otros', // Agregada la nueva categoría
  ];

  void _addTransaction(
    String title,
    double amount,
    DateTime date,
    String category,
  ) {
    setState(() {
      _transactions.add({
        'title': title,
        'amount': amount,
        'date': date,
        'category': category,
      });
    });
  }

  void _editTransaction(
    int index,
    String title,
    double amount,
    DateTime date,
    String category,
  ) {
    setState(() {
      _transactions[index] = {
        'title': title,
        'amount': amount,
        'date': date,
        'category': category,
      };
    });
  }

  void _deleteTransaction(int index) {
    setState(() {
      _transactions.removeAt(index);
    });
  }

  double get totalGastos {
    return _transactions.fold(
      0.0,
      (sum, item) => sum + (item['amount'] as num),
    );
  }

  void _showTransactionDialog({int? index}) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    String selectedCategory = _categories[0];

    if (index != null) {
      final tx = _transactions[index];
      titleController.text = tx['title'];
      amountController.text = tx['amount'].toString();
      selectedDate = tx['date'];
      selectedCategory = tx['category'];
    }

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(
              index == null ? 'Nuevo Gasto' : 'Editar Gasto',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountController,
                    decoration: const InputDecoration(
                      labelText: 'Monto',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Fecha: ${DateFormat.yMMMd().format(selectedDate)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              selectedDate = pickedDate;
                            });
                          }
                        },
                        child: const Text('Elegir fecha'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    items:
                        _categories
                            .map<DropdownMenuItem<String>>(
                              (cat) => DropdownMenuItem<String>(
                                value: cat,
                                child: Text(cat),
                              ),
                            )
                            .toList(),
                    onChanged: (String? value) {
                      if (value != null) {
                        selectedCategory = value;
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Categoría',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  final title = titleController.text;
                  final amount = double.tryParse(amountController.text) ?? 0.0;
                  if (title.isNotEmpty && amount > 0) {
                    if (index == null) {
                      _addTransaction(
                        title,
                        amount,
                        selectedDate,
                        selectedCategory,
                      );
                    } else {
                      _editTransaction(
                        index,
                        title,
                        amount,
                        selectedDate,
                        selectedCategory,
                      );
                    }
                  }
                  Navigator.pop(context);
                },
                child: const Text('Guardar'),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
          ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Alimentación':
        return Colors.orange[300]!;
      case 'Transporte':
        return Colors.blue[300]!;
      case 'Entretenimiento':
        return Colors.purple[300]!;
      case 'Ropa y Otros': // Nuevo caso para la categoría "Ropa y Otros"
        return Colors.green[300]!; // Puedes elegir el color que prefieras
      default:
        return Colors.grey[400]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resumen de Gastos')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              color: Theme.of(context).colorScheme.secondary.withAlpha(204),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Gasto Total',
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(color: Colors.white),
                    ),
                    Text(
                      '\$${totalGastos.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child:
                  _transactions.isEmpty
                      ? const Center(child: Text('No hay transacciones aún.'))
                      : ListView.builder(
                        itemCount: _transactions.length,
                        itemBuilder: (_, index) {
                          final tx = _transactions[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getCategoryColor(
                                  tx['category'],
                                ),
                                radius: 25,
                                child: Text(
                                  tx['category'][0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                tx['title'],
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                '\$${(tx['amount'] as num).toStringAsFixed(2)} - ${tx['category']} - ${DateFormat.yMMMd().format(tx['date'])}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    onPressed:
                                        () => _showTransactionDialog(
                                          index: index,
                                        ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _deleteTransaction(index),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTransactionDialog(),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 6,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
