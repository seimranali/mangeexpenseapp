import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/categories.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/entry.dart';
import '../../providers/app_providers.dart';
import '../../widgets/category_avatar.dart';

class AddEditEntryScreen extends ConsumerStatefulWidget {
  final String? entryId;
  final String? initialCategoryId;

  const AddEditEntryScreen({super.key, this.entryId, this.initialCategoryId});

  @override
  ConsumerState<AddEditEntryScreen> createState() =>
      _AddEditEntryScreenState();
}

class _AddEditEntryScreenState extends ConsumerState<AddEditEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _recipientController = TextEditingController();

  late String _categoryId;
  DateTime _date = DateTime.now();
  bool _loading = false;
  bool _initializing = true;

  bool get _isEditing => widget.entryId != null;

  @override
  void initState() {
    super.initState();
    _categoryId = widget.initialCategoryId ?? kCategories.first.id;
    if (_isEditing) {
      _loadExisting();
    } else {
      _initializing = false;
    }
  }

  Future<void> _loadExisting() async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    final entry = await ref
        .read(entryRepositoryProvider)
        .getEntry(uid, widget.entryId!);
    if (entry != null && mounted) {
      setState(() {
        _categoryId = entry.categoryId;
        _amountController.text = entry.amount.toString();
        _noteController.text = entry.note ?? '';
        _recipientController.text = entry.recipient ?? '';
        _date = entry.date;
        _initializing = false;
      });
    } else if (mounted) {
      setState(() => _initializing = false);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _recipientController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;

    setState(() => _loading = true);
    final repo = ref.read(entryRepositoryProvider);
    final amount = double.parse(_amountController.text.trim());
    final info = categoryById(_categoryId);

    try {
      if (_isEditing) {
        final entry = Entry(
          id: widget.entryId!,
          categoryId: _categoryId,
          amount: amount,
          date: _date,
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
          recipient: info.supportsRecipient && _recipientController.text.trim().isNotEmpty
              ? _recipientController.text.trim()
              : null,
          createdAt: DateTime.now(),
        );
        await repo.updateEntry(uid, entry);
      } else {
        final entry = Entry(
          id: const Uuid().v4(),
          categoryId: _categoryId,
          amount: amount,
          date: _date,
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
          recipient: info.supportsRecipient && _recipientController.text.trim().isNotEmpty
              ? _recipientController.text.trim()
              : null,
          createdAt: DateTime.now(),
        );
        await repo.addEntry(uid, entry);
      }
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final selected = categoryById(_categoryId);

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit entry' : 'New entry')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
            children: [
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: Theme.of(context).textTheme.headlineSmall,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '\$ ',
                ),
                validator: (v) {
                  final value = double.tryParse((v ?? '').trim());
                  if (value == null || value <= 0) {
                    return 'Enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Text('Category', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final c in kCategories)
                    ChoiceChip(
                      selected: c.id == _categoryId,
                      onSelected: (_) => setState(() => _categoryId = c.id),
                      avatar: CategoryAvatar(info: c, size: 24),
                      label: Text(c.label),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_rounded),
                title: const Text('Date'),
                trailing: Text(Formatters.dayMonthYear.format(_date)),
                onTap: _pickDate,
              ),
              const Divider(),
              if (selected.supportsRecipient) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _recipientController,
                  decoration: const InputDecoration(
                    labelText: 'Recipient',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Note (optional)',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _save,
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEditing ? 'Save changes' : 'Add entry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
