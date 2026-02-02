import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../providers/transaction_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  final Map? transaction; // null = add, not null = edit

  const AddTransactionScreen({super.key, this.transaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  String _category = 'General';
  bool _isIncome = false;

  int? _hiveKey;

  final _uuid = const Uuid();

  final List<String> _categories = [
    'General',
    'Food',
    'Transport',
    'Rent',
    'Salary',
    'Shopping',
  ];

  @override
  void initState() {
    super.initState();

    if (widget.transaction != null) {
      final t = widget.transaction!;

      _amountCtrl.text = t['amount'].toString();
      _noteCtrl.text = t['note'];
      _category = t['category'];
      _isIncome = t['isIncome'];
      _hiveKey = t['_key'];
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'id': widget.transaction?['id'] ?? _uuid.v4(),
      'amount': double.parse(_amountCtrl.text),
      'category': _category,
      'note': _noteCtrl.text,
      'date': widget.transaction?['date'] ?? DateTime.now().toIso8601String(),
      'isIncome': _isIncome,
    };

    final provider = context.read<TransactionProvider>();

    if (_hiveKey == null) {
      await provider.add(data);
    } else {
      await provider.update(_hiveKey!, data);
    }

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
    final isEdit = widget.transaction != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Transaction' : 'Add Transaction'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: _formKey,

          child: ListView(
            children: [
              TextFormField(
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter amount' : null,
              ),

              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: _category,
                items: _categories
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
                decoration: const InputDecoration(labelText: 'Category'),
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _noteCtrl,
                decoration: const InputDecoration(labelText: 'Note'),
              ),

              const SizedBox(height: 12),

              SwitchListTile(
                title: const Text('Is Income'),
                value: _isIncome,
                onChanged: (v) => setState(() => _isIncome = v),
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _save,
                child: Text(isEdit ? 'Update' : 'Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
