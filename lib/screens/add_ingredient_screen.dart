import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../config/app_constants.dart';
import '../models/ingredient.dart';
import '../providers/auth_provider.dart';
import '../providers/fridge_provider.dart';
import '../utils/date_utils.dart' as app_date_utils;
import '../utils/validators.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

class AddIngredientScreen extends StatefulWidget {
  const AddIngredientScreen({super.key, this.existingIngredient});

  final Ingredient? existingIngredient;

  @override
  State<AddIngredientScreen> createState() => _AddIngredientScreenState();
}

class _AddIngredientScreenState extends State<AddIngredientScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _priceController;
  late final TextEditingController _dateController;
  late String _category;
  late String _storageLocation;
  late bool _isOpened;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    final ingredient = widget.existingIngredient;
    _nameController = TextEditingController(text: ingredient?.name ?? '');
    _quantityController = TextEditingController(text: ingredient?.quantity ?? '');
    _priceController = TextEditingController(text: ingredient?.estimatedPrice.toStringAsFixed(2) ?? '');
    _dateController = TextEditingController(text: ingredient?.expirationDate == null ? '' : app_date_utils.DateUtils.formatDate(ingredient!.expirationDate));
    _selectedDate = ingredient?.expirationDate;
    _category = ingredient?.category ?? AppConstants.categories.first;
    _storageLocation = ingredient?.storageLocation ?? AppConstants.storageLocations.first;
    _isOpened = ingredient?.isOpened ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 3)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked == null) return;
    setState(() {
      _selectedDate = picked;
      _dateController.text = app_date_utils.DateUtils.formatDate(picked);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final ingredient = Ingredient(
      id: widget.existingIngredient?.id ?? const Uuid().v4(),
      userId: context.read<AuthProvider>().userId,
      name: _nameController.text.trim(),
      category: _category,
      quantity: _quantityController.text.trim(),
      expirationDate: _storageLocation == 'pantry' && _selectedDate == null ? null : _selectedDate,
      estimatedPrice: double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0,
      isOpened: _isOpened,
      storageLocation: _storageLocation,
      createdAt: widget.existingIngredient?.createdAt ?? DateTime.now(),
    );

    final fridge = context.read<FridgeProvider>();
    if (widget.existingIngredient == null) {
      await fridge.addIngredient(ingredient);
    } else {
      await fridge.updateIngredient(ingredient);
    }

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingrediënt opgeslagen')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPantry = _storageLocation == 'pantry';

    return Scaffold(
      appBar: AppBar(title: Text(widget.existingIngredient == null ? 'Ingrediënt toevoegen' : 'Ingrediënt bewerken')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                AppTextField(label: 'Naam', controller: _nameController, validator: (value) => Validators.requiredField(value, label: 'Naam'), prefixIcon: Icons.label_rounded),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Categorie'),
                  items: AppConstants.categories.map((category) => DropdownMenuItem(value: category, child: Text(category))).toList(),
                  onChanged: (value) => setState(() => _category = value ?? AppConstants.categories.first),
                ),
                const SizedBox(height: 14),
                AppTextField(label: 'Hoeveelheid', controller: _quantityController, validator: (value) => Validators.requiredField(value, label: 'Hoeveelheid'), prefixIcon: Icons.scale_rounded),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Houdbaarheidsdatum',
                  controller: _dateController,
                  readOnly: true,
                  onTap: _pickDate,
                  validator: (value) {
                    if (isPantry) return null;
                    if (_selectedDate == null) return 'Houdbaarheidsdatum is verplicht.';
                    return null;
                  },
                  prefixIcon: Icons.event_rounded,
                ),
                const SizedBox(height: 14),
                AppTextField(label: 'Geschatte prijs', controller: _priceController, validator: Validators.price, keyboardType: const TextInputType.numberWithOptions(decimal: true), prefixIcon: Icons.euro_rounded),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _storageLocation,
                  decoration: const InputDecoration(labelText: 'Opslag'),
                  items: AppConstants.storageLocations.map((location) => DropdownMenuItem(value: location, child: Text(location))).toList(),
                  onChanged: (value) => setState(() => _storageLocation = value ?? AppConstants.storageLocations.first),
                ),
                const SizedBox(height: 10),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Geopend'),
                  value: _isOpened,
                  onChanged: (value) => setState(() => _isOpened = value),
                ),
                const SizedBox(height: 20),
                AppButton(label: 'Opslaan', onPressed: _save, icon: Icons.save_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
