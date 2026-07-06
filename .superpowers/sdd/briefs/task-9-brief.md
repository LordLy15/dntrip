# Task 9: Sudden Expense Sheet

## Overview
Create the bottom sheet widget for adding sudden expenses with category dropdown and over-budget warning.

## Files to Create

### Create: `frontend/lib/features/itinerary/presentation/widgets/sudden_expense_sheet.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/models/expense_category_model.dart';
import '../../domain/itinerary_providers.dart';

class SuddenExpenseSheet extends ConsumerStatefulWidget {
  final int tripId;
  final double? planBudget;
  final double? currentTotal;

  const SuddenExpenseSheet({
    super.key,
    required this.tripId,
    this.planBudget,
    this.currentTotal,
  });

  @override
  ConsumerState<SuddenExpenseSheet> createState() => _SuddenExpenseSheetState();
}

class _SuddenExpenseSheetState extends ConsumerState<SuddenExpenseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _newCategoryController = TextEditingController();
  
  ExpenseCategory? _selectedCategory;
  bool _isAddingNewCategory = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _newCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(expenseCategoriesProvider);
    
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.flash_on, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    'Pengeluaran Mendadak',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Pengeluaran *',
                  hintText: 'Contoh: Tambal Ban',
                  prefixIcon: Icon(Icons.label),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              
              categoriesAsync.when(
                data: (categories) {
                  final allCategories = [
                    ...ExpenseCategory.defaultCategories,
                    ...categories.where((c) => c.isCustom),
                  ];
                  
                  return Column(
                    children: [
                      if (!_isAddingNewCategory)
                        DropdownButtonFormField<ExpenseCategory>(
                          value: _selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'Kategori',
                            prefixIcon: Icon(Icons.category),
                          ),
                          items: [
                            ...allCategories.map((c) => DropdownMenuItem(
                              value: c,
                              child: Row(
                                children: [
                                  Icon(_getIconData(c.icon), size: 20),
                                  const SizedBox(width: 8),
                                  Text(c.name),
                                ],
                              ),
                            )),
                            const DropdownMenuItem(
                              value: null,
                              child: Row(
                                children: [
                                  Icon(Icons.add, size: 20),
                                  SizedBox(width: 8),
                                  Text('Tambah Kategori Baru'),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) {
                              setState(() => _isAddingNewCategory = true);
                            } else {
                              setState(() => _selectedCategory = value);
                            }
                          },
                        ),
                      if (_isAddingNewCategory)
                        TextFormField(
                          controller: _newCategoryController,
                          decoration: InputDecoration(
                            labelText: 'Nama Kategori Baru',
                            prefixIcon: const Icon(Icons.add),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  _isAddingNewCategory = false;
                                  _newCategoryController.clear();
                                });
                              },
                            ),
                          ),
                          validator: (v) => v?.isEmpty ?? true 
                              ? 'Wajib diisi' 
                              : null,
                        ),
                    ],
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('Gagal memuat kategori'),
              ),
              const SizedBox(height: 12),
              
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Nominal *',
                  hintText: '0',
                  prefixIcon: Icon(Icons.attach_money),
                  prefixText: 'Rp ',
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v?.isEmpty ?? true) return 'Wajib diisi';
                  if (double.tryParse(v!) == null) return 'Format tidak valid';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Keterangan (opsional)',
                  hintText: 'Tambahkan catatan...',
                  prefixIcon: Icon(Icons.notes),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Simpan'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'hotel': return Icons.hotel;
      case 'directions_car': return Icons.directions_car;
      case 'restaurant': return Icons.restaurant;
      case 'attractions': return Icons.attractions;
      case 'schedule': return Icons.schedule;
      case 'phone': return Icons.phone;
      default: return Icons.category;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final amount = double.parse(_amountController.text);
    
    // Check over-budget warning
    if (widget.planBudget != null && widget.currentTotal != null) {
      final newTotal = widget.currentTotal! + amount;
      if (newTotal > widget.planBudget!) {
        final proceed = await _showOverBudgetWarning(
          newTotal - widget.planBudget!,
        );
        if (!proceed) return;
      }
    }
    
    setState(() => _isLoading = true);
    
    try {
      final notifier = ref.read(suddenExpenseNotifierProvider(widget.tripId).notifier);
      
      // Create custom category if needed
      int? categoryId = _selectedCategory?.id;
      if (_isAddingNewCategory) {
        final category = await ref.read(customCategoryProvider(
          name: _newCategoryController.text,
        ).future);
        categoryId = category.id;
      }
      
      await notifier.addExpense(
        name: _nameController.text,
        categoryId: categoryId,
        amount: amount,
        description: _descriptionController.text.isEmpty 
            ? null 
            : _descriptionController.text,
      );
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pengeluaran mendadak berhasil ditambahkan')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<bool> _showOverBudgetWarning(double overAmount) async {
    final currency = NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0);
    
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Perhatian'),
          ],
        ),
        content: Text(
          'Pengeluaran ini membuat total biaya trip Anda '
          'melebihi rencana anggaran sebesar ${currency.format(overAmount)}.\n\n'
          'Lanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Lanjutkan'),
          ),
        ],
      ),
    ) ?? false;
  }
}
```

## Acceptance Criteria

- [ ] SuddenExpenseSheet widget created with form
- [ ] Category dropdown with default + custom categories
- [ ] "Tambah Kategori Baru" option that shows text field
- [ ] Over-budget warning dialog when expense exceeds plan
- [ ] Successful save with snackbar notification

## Notes

- Uses Icons.flash_on for the sudden expense theme (orange color)
- Follows the spec for the over-budget warning dialog
