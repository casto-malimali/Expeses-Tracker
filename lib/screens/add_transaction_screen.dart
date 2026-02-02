import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../providers/transaction_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  String _category = 'General';
  bool _isIncome = false;

  final _uuid = const Uuid();

  final List<String> _categories = [
    'General',
    'Food',
    'Transport',
    'Rent',
    'Salary',
    'Shopping',
  ];

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'id': _uuid.v4(),
      'amount': double.parse(_amountCtrl.text),
      'category': _category,
      'note': _noteCtrl.text,
      'date': DateTime.now().toIso8601String(),
      'isIncome': _isIncome,
    };

    await context.read<TransactionProvider>().add(data);

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: _formKey,

          child: ListView(
            children: [
              // Amount
              TextFormField(
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter amount' : null,
              ),

              const SizedBox(height: 12),

              // Category
              DropdownButtonFormField<String>(
                value: _category,
                items: _categories
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
                decoration: const InputDecoration(labelText: 'Category'),
              ),

              const SizedBox(height: 12),

              // Note
              TextFormField(
                controller: _noteCtrl,
                decoration: const InputDecoration(labelText: 'Note'),
              ),

              const SizedBox(height: 12),

              // Income / Expense
              SwitchListTile(
                title: const Text('Is Income'),
                value: _isIncome,
                onChanged: (v) => setState(() => _isIncome = v),
              ),

              const SizedBox(height: 24),

              // Save Button
              ElevatedButton(onPressed: _save, child: const Text('Save')),
            ],
          ),
        ),
      ),
    );
  }
}
