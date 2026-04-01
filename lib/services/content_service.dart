import 'dart:convert';
import 'package:flutter/services.dart';

import '../helpers/app_constants.dart';
import '../models/media_item.dart';
import '../utils/app_logger.dart';

class ContentService {
  static Future<List<MediaItem>> loadContent() async {
    try {
      final jsonString = await rootBundle.loadString(AppConstants.jsonPath);
      final Map<String, dynamic> decodedJson = json.decode(jsonString);
      final List<dynamic> resultList = decodedJson['result'] ?? [];
      return resultList.map((item) => MediaItem.fromJson(item)).toList();
    } catch (e) {
      AppLogger.log('Content load failed: $e');
      return [];
    }
  }
}
