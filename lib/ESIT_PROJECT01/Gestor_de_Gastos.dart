import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const ExpenseApp());
}

class ExpenseApp extends StatelessWidget {
  const ExpenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ExpenseHomePage(),
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
            title: Text(index == null ? 'Nuevo Gasto' : 'Editar Gasto'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                  ),
                  TextField(
                    controller: amountController,
                    decoration: const InputDecoration(labelText: 'Monto'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(DateFormat.yMMMd().format(selectedDate)),
                      const SizedBox(width: 10),
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
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    items:
                        _categories
                            .map(
                              (cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(cat),
                              ),
                            )
                            .toList(),
                    onChanged: (String? value) {
                      selectedCategory = value!;
                    },
                    decoration: const InputDecoration(labelText: 'Categoría'),
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
          ),
    );
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
              color: Colors.amber[100],
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'Gasto Total: \$${totalGastos.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
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
                          return ListTile(
                            title: Text(tx['title']),
                            subtitle: Text(
                              '\$${(tx['amount'] as num).toStringAsFixed(2)} - ${tx['category']} - ${DateFormat.yMMMd().format(tx['date'])}',
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
                                      () =>
                                          _showTransactionDialog(index: index),
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
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTransactionDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
