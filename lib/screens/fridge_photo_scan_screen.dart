import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../config/app_constants.dart';
import '../models/fridge_scan_candidate.dart';
import '../models/ingredient.dart';
import '../providers/auth_provider.dart';
import '../providers/fridge_provider.dart';
import '../services/fridge_image_analysis_service.dart';
import '../utils/date_utils.dart' as app_date_utils;
import '../widgets/dashboard_card.dart';

class FridgePhotoScanScreen extends StatefulWidget {
  const FridgePhotoScanScreen({super.key});

  @override
  State<FridgePhotoScanScreen> createState() => _FridgePhotoScanScreenState();
}

class _FridgePhotoScanScreenState extends State<FridgePhotoScanScreen> {
  final _picker = ImagePicker();
  final _service = FridgeImageAnalysisService();
  final _pageController = PageController();

  Uint8List? _imageBytes;
  List<_EditableScanCandidate> _items = [];
  int _index = 0;
  bool _isBusy = false;
  String? _error;

  @override
  void dispose() {
    _pageController.dispose();
    for (final item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  Future<void> _pickAndAnalyze(ImageSource source) async {
    setState(() {
      _isBusy = true;
      _error = null;
      _index = 0;
    });

    try {
      final image = await _picker.pickImage(
        source: source,
        imageQuality: 78,
        maxWidth: 1600,
      );

      if (image == null) {
        setState(() => _isBusy = false);
        return;
      }

      final bytes = await image.readAsBytes();
      final candidates = await _service.analyzeImage(image);

      for (final item in _items) {
        item.dispose();
      }

      setState(() {
        _imageBytes = bytes;
        _items = candidates.map(_EditableScanCandidate.new).toList();
        _isBusy = false;
      });
    } catch (_) {
      setState(() {
        _isBusy = false;
        _error =
            'Analyse mislukt. Probeer een scherpere foto of upload opnieuw.';
      });
    }
  }

  Future<void> _pickDate(_EditableScanCandidate item) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          item.expirationDate ?? DateTime.now().add(const Duration(days: 3)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (picked == null) return;
    setState(() => item.expirationDate = picked);
  }

  Future<void> _saveCurrent() async {
    if (_items.isEmpty) return;

    final item = _items[_index];
    final ingredient = Ingredient(
      id: const Uuid().v4(),
      userId: context.read<AuthProvider>().userId,
      name: item.name.text.trim().isEmpty
          ? 'Onbekend product'
          : item.name.text.trim(),
      category: item.category,
      quantity: item.quantity.text.trim().isEmpty
          ? '1 stuk'
          : item.quantity.text.trim(),
      expirationDate: item.expirationDate,
      estimatedPrice: 0,
      isOpened: item.isOpened,
      storageLocation: item.storageLocation,
      createdAt: DateTime.now(),
    );

    await context.read<FridgeProvider>().addIngredient(ingredient);

    if (!mounted) return;
    _goNext(message: '${ingredient.name} toegevoegd');
  }

  void _skipCurrent() {
    _goNext(message: 'Overgeslagen');
  }

  void _goNext({required String message}) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));

    if (_index >= _items.length - 1) {
      Navigator.of(context).pop();
      return;
    }

    setState(() => _index += 1);
    _pageController.animateToPage(
      _index,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Koelkast scannen')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            _PhotoPanel(
              imageBytes: _imageBytes,
              isBusy: _isBusy,
              onCamera: () => _pickAndAnalyze(ImageSource.camera),
              onGallery: () => _pickAndAnalyze(ImageSource.gallery),
            ),
            if (_error != null) ...[
              const SizedBox(height: 14),
              _ErrorPanel(message: _error!),
            ],
            const SizedBox(height: 18),
            if (_isBusy)
              const _BusyPanel()
            else if (_items.isEmpty)
              const _EmptyScanPanel()
            else
              _CandidatePager(
                controller: _pageController,
                items: _items,
                index: _index,
                onDate: _pickDate,
                onSave: _saveCurrent,
                onSkip: _skipCurrent,
              ),
          ],
        ),
      ),
    );
  }
}

class _PhotoPanel extends StatelessWidget {
  const _PhotoPanel({
    required this.imageBytes,
    required this.isBusy,
    required this.onCamera,
    required this.onGallery,
  });

  final Uint8List? imageBytes;
  final bool isBusy;
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: DecoratedBox(
                decoration:
                    BoxDecoration(color: Colors.black.withValues(alpha: 0.04)),
                child: imageBytes == null
                    ? const Center(
                        child: Icon(Icons.kitchen_outlined, size: 42))
                    : Image.memory(imageBytes!, fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: isBusy ? null : onCamera,
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Maak foto'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isBusy ? null : onGallery,
                  icon: const Icon(Icons.upload_file_outlined),
                  label: const Text('Upload'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CandidatePager extends StatelessWidget {
  const _CandidatePager({
    required this.controller,
    required this.items,
    required this.index,
    required this.onDate,
    required this.onSave,
    required this.onSkip,
  });

  final PageController controller;
  final List<_EditableScanCandidate> items;
  final int index;
  final ValueChanged<_EditableScanCandidate> onDate;
  final VoidCallback onSave;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product ${index + 1} van ${items.length}',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 560,
          child: PageView.builder(
            controller: controller,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, pageIndex) {
              final item = items[pageIndex];
              return _CandidateCard(
                item: item,
                onDate: () => onDate(item),
                onSave: onSave,
                onSkip: onSkip,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CandidateCard extends StatelessWidget {
  const _CandidateCard({
    required this.item,
    required this.onDate,
    required this.onSave,
    required this.onSkip,
  });

  final _EditableScanCandidate item;
  final VoidCallback onDate;
  final VoidCallback onSave;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final isExpired = item.expirationDate != null &&
        app_date_utils.DateUtils.daysUntil(item.expirationDate) < 0;
    final statusColor = item.couldBeExpired || isExpired
        ? AppConstants.dangerColor
        : AppConstants.successColor;
    final statusText = item.couldBeExpired || isExpired
        ? 'Mogelijk vervallen'
        : 'Lijkt bruikbaar';

    return DashboardCard(
      child: StatefulBuilder(
        builder: (context, setInnerState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Klopt dit product?',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  Chip(
                    avatar: Icon(Icons.circle, size: 10, color: statusColor),
                    label: Text(statusText),
                    side: BorderSide.none,
                    backgroundColor: statusColor.withValues(alpha: 0.12),
                  ),
                ],
              ),
              if (item.notes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  item.notes,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.black.withValues(alpha: 0.62),
                      ),
                ),
              ],
              const SizedBox(height: 16),
              TextField(
                controller: item.name,
                decoration: const InputDecoration(
                  labelText: 'Product',
                  prefixIcon: Icon(Icons.label_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: item.quantity,
                decoration: const InputDecoration(
                  labelText: 'Hoeveelheid',
                  prefixIcon: Icon(Icons.scale_outlined),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: item.category,
                decoration: const InputDecoration(labelText: 'Categorie'),
                items: AppConstants.categories
                    .map((category) => DropdownMenuItem(
                        value: category, child: Text(category)))
                    .toList(),
                onChanged: (value) =>
                    setInnerState(() => item.category = value ?? item.category),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: item.storageLocation,
                decoration: const InputDecoration(labelText: 'Opslag'),
                items: AppConstants.storageLocations
                    .map((location) => DropdownMenuItem(
                        value: location, child: Text(location)))
                    .toList(),
                onChanged: (value) => setInnerState(
                    () => item.storageLocation = value ?? item.storageLocation),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  onDate();
                  setInnerState(() {});
                },
                icon: const Icon(Icons.event_outlined),
                label: Text(
                    'Datum: ${app_date_utils.DateUtils.formatDate(item.expirationDate)}'),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Geopend'),
                value: item.isOpened,
                onChanged: (value) =>
                    setInnerState(() => item.isOpened = value),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onSkip,
                      icon: const Icon(Icons.close_outlined),
                      label: const Text('Nee'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onSave,
                      icon: const Icon(Icons.check_outlined),
                      label: const Text('Bevestig'),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BusyPanel extends StatelessWidget {
  const _BusyPanel();

  @override
  Widget build(BuildContext context) {
    return const DashboardCard(
      child: Column(
        children: [
          LinearProgressIndicator(),
          SizedBox(height: 14),
          Text('AI analyseert de foto...'),
        ],
      ),
    );
  }
}

class _EmptyScanPanel extends StatelessWidget {
  const _EmptyScanPanel();

  @override
  Widget build(BuildContext context) {
    return const DashboardCard(
      child: Row(
        children: [
          Icon(Icons.photo_camera_back_outlined),
          SizedBox(width: 12),
          Expanded(child: Text('Nog geen producten gevonden.')),
        ],
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppConstants.dangerColor),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

class _EditableScanCandidate {
  _EditableScanCandidate(FridgeScanCandidate candidate)
      : name = TextEditingController(text: candidate.name),
        quantity = TextEditingController(text: candidate.quantity),
        category = AppConstants.categories.contains(candidate.category)
            ? candidate.category
            : 'Overig',
        storageLocation =
            AppConstants.storageLocations.contains(candidate.storageLocation)
                ? candidate.storageLocation
                : 'fridge',
        expirationDate = candidate.suggestedExpirationDate,
        isOpened = candidate.isOpened,
        couldBeExpired = candidate.couldBeExpired,
        confidence = candidate.confidence,
        notes = candidate.notes;

  final TextEditingController name;
  final TextEditingController quantity;
  String category;
  String storageLocation;
  DateTime? expirationDate;
  bool isOpened;
  final bool couldBeExpired;
  final double confidence;
  final String notes;

  void dispose() {
    name.dispose();
    quantity.dispose();
  }
}
