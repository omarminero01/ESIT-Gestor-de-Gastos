import 'package:flutter/material.dart'; //Esta línea importa la librería principal de Material Design
import 'package:intl/intl.dart'; // Esta línea importa la librería intl, que proporciona funcionalidades para la internacionalización y localización
import 'package:sqflite/sqflite.dart'; // Importa el paquete sqflite
import 'package:path/path.dart' as path; // Importa el paquete path con un alias

void main() {
  runApp(
    const GastosApp(), //Este es el punto de entrada de la aplicación Flutter
  );
}

class GastosApp extends StatelessWidget {
  //Widgets: GastosApp es un StatelessWidget
  const GastosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "GastosApp",
      debugShowCheckedModeBanner: false, // oculta la etiqueta de "Debug"
      theme: ThemeData(
        //Establece el tema de la aplicacion
        primarySwatch:
            Colors.indigo, // El color primario de la aplicación (índigo)
        hintColor:
            Colors
                .tealAccent, // El color de las sugerencias en los campos de texto (tealAccent).
        fontFamily:
            'Montserrat', // La fuente de texto principal ('Montserrat').
        appBarTheme: const AppBarTheme(
          // Estilos específicos para la barra de la aplicación (color del texto, fuente, tamaño, peso).
          titleTextStyle: TextStyle(
            // Estilos de texto predefinidos para diferentes propósitos (títulos grandes, medianos, cuerpo de texto).
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        textTheme: TextTheme(
          //// Estilos de texto predefinidos para diferentes propósitos (títulos grandes, medianos, cuerpo de texto).
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
          // Estilos para los botones elevados (color de fondo, color del texto, forma).
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.indigo,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          // Estilos para los botones de texto (color del texto).
          style: TextButton.styleFrom(foregroundColor: Colors.indigo),
        ),
        inputDecorationTheme: InputDecorationTheme(
          //// Estilos para la decoración de los campos de entrada (bordes).
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
  //final List<Map<String, dynamic>> _transactions = []; // Ya no se usa la lista en memoria
  late Database _database; // Agrega una instancia de la base de datos
  final List<String> _categories = [
    'Alimentación',
    'Transporte',
    'Entretenimiento',
    'Ropa y Otros',
  ];

  @override
  void initState() {
    super.initState();
    _initDatabase(); // Inicializa la base de datos al iniciar el estado
  }

  // Inicializa la base de datos SQLite
  Future<void> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final dbFilePath = path.join(
      dbPath,
      'gastos.db',
    ); // Evita conflicto de nombres

    _database = await openDatabase(
      dbFilePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE transacciones (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          amount REAL,
          date TEXT,
          category TEXT
          )
        ''');
      },
    );
    await _loadTransactions(); // Carga las transacciones desde la base de datos
  }

  // Carga las transacciones desde la base de datos
  Future<void> _loadTransactions() async {
    final List<Map<String, dynamic>> transactionsFromDB = await _database.query(
      'transacciones',
    );
    setState(() {
      _transactions =
          transactionsFromDB; // Asigna los datos cargados a _transactions
    });
  }

  // La variable _transactions ahora debe ser una lista mutable
  List<Map<String, dynamic>> _transactions = [];

  // Agrega una nueva transacción a la base de datos
  Future<void> _addTransaction(
    String title,
    double amount,
    DateTime date,
    String category,
  ) async {
    await _database.insert('transacciones', {
      'title': title,
      'amount': amount,
      'date':
          date.toIso8601String(), // Guarda la fecha como String en formato ISO
      'category': category,
    });
    await _loadTransactions(); // Recarga la lista de transacciones
  }

  // Edita una transacción existente en la base de datos
  Future<void> _editTransaction(
    int id,
    String title,
    double amount,
    DateTime date,
    String category,
  ) async {
    await _database.update(
      'transacciones',
      {
        'title': title,
        'amount': amount,
        'date': date.toIso8601String(),
        'category': category,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    await _loadTransactions();
  }

  // Elimina una transacción de la base de datos
  Future<void> _deleteTransaction(int id) async {
    await _database.delete('transacciones', where: 'id = ?', whereArgs: [id]);
    await _loadTransactions();
  }

  // Calcula el total de gastos
  double get totalGastos {
    return _transactions.fold(
      0.0,
      (sum, item) => sum + (item['amount'] as num),
    );
  }

  // Muestra el diálogo para agregar o editar transacciones
  void _showTransactionDialog({
    int? index,
    Map<String, dynamic>? transactionData,
  }) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    String selectedCategory = _categories[0];

    if (transactionData != null) {
      titleController.text = transactionData['title'];
      amountController.text = transactionData['amount'].toString();
      selectedDate = DateTime.parse(
        transactionData['date'],
      ); // Convierte la cadena de fecha a DateTime
      selectedCategory = transactionData['category'];
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
                onPressed: () async {
                  // Marcar la función como async
                  final title = titleController.text;
                  final amount = double.tryParse(amountController.text) ?? 0.0;
                  if (title.isNotEmpty && amount > 0) {
                    if (index == null) {
                      await _addTransaction(
                        // Esperar a que la transacción se añada
                        title,
                        amount,
                        selectedDate,
                        selectedCategory,
                      );
                    } else {
                      // Pasar el ID de la transacción a _editTransaction
                      await _editTransaction(
                        _transactions[index]['id'],
                        title,
                        amount,
                        selectedDate,
                        selectedCategory,
                      );
                    }
                  }
                  // ignore: use_build_context_synchronously
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
      case 'Ropa y Otros':
        return Colors.green[300]!;
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
                                '\$${(tx['amount'] as num).toStringAsFixed(2)} - ${tx['category']} - ${DateFormat.yMMMd().format(DateTime.parse(tx['date']))}', // Formatea la fecha
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
                                          transactionData: tx,
                                        ), // Pasando el ID
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed:
                                        () => _deleteTransaction(
                                          tx['id'],
                                        ), // Llama a _deleteTransaction con el ID
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

  @override
  void dispose() {
    _database.close();
    super.dispose();
  }
}
