import 'dart:convert';

import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../models/fridge_scan_candidate.dart';

class FridgeImageAnalysisService {
  Future<List<FridgeScanCandidate>> analyzeImage(XFile image) async {
    final bytes = await image.readAsBytes();

    if (!SupabaseConfig.isConfigured) {
      return _localFallback();
    }

    final response = await Supabase.instance.client.functions.invoke(
      'analyze-fridge-image',
      body: {
        'imageBase64': base64Encode(bytes),
        'mimeType': image.mimeType ?? _guessMimeType(image.name),
        'fileName': image.name,
      },
    );

    final data = _decodeResponse(response.data);
    return FridgeScanCandidate.listFromJson(data['candidates']);
  }

  Map<String, dynamic> _decodeResponse(Object? data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is String) return jsonDecode(data) as Map<String, dynamic>;
    return const {'candidates': []};
  }

  String _guessMimeType(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  List<FridgeScanCandidate> _localFallback() {
    final today = DateTime.now();
    return [
      FridgeScanCandidate(
        name: 'Yoghurt',
        category: 'Zuivel',
        quantity: '1 pot',
        storageLocation: 'fridge',
        suggestedExpirationDate: today.add(const Duration(days: 4)),
        isOpened: true,
        couldBeExpired: false,
        confidence: 0.68,
        notes: 'Offline voorbeeld',
      ),
      FridgeScanCandidate(
        name: 'Paprika',
        category: 'Groenten',
        quantity: '2 stuks',
        storageLocation: 'fridge',
        suggestedExpirationDate: today.add(const Duration(days: 5)),
        isOpened: false,
        couldBeExpired: false,
        confidence: 0.62,
        notes: 'Offline voorbeeld',
      ),
      FridgeScanCandidate(
        name: 'Kaas',
        category: 'Zuivel',
        quantity: '1 verpakking',
        storageLocation: 'fridge',
        suggestedExpirationDate: today.add(const Duration(days: 7)),
        isOpened: true,
        couldBeExpired: false,
        confidence: 0.58,
        notes: 'Offline voorbeeld',
      ),
    ];
  }
}
