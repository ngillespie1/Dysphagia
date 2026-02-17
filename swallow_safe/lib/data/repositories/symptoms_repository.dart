import 'package:hive_flutter/hive_flutter.dart';

import '../models/symptom_entry.dart';

/// Repository for managing symptom tracking data
class SymptomsRepository {
  static const String _boxName = 'symptoms';
  
  Box<dynamic>? _box;
  
  /// Initialize Hive box
  Future<void> initialize() async {
    _box = await Hive.openBox(_boxName);
  }
  
  /// Save a symptom entry
  Future<void> saveEntry(SymptomEntry entry) async {
    if (_box == null) await initialize();
    await _box?.put(entry.dateKey, entry.toJson());
  }
  
  /// Get entry for a specific date
  Future<SymptomEntry?> getEntryForDate(DateTime date) async {
    if (_box == null) await initialize();
    
    final key = _dateKey(date);
    final data = _box?.get(key);
    
    if (data != null) {
      return SymptomEntry.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }
  
  /// Get today's entry
  Future<SymptomEntry?> getTodayEntry() async {
    return getEntryForDate(DateTime.now());
  }
  
  /// Get all entries
  Future<List<SymptomEntry>> getAllEntries() async {
    if (_box == null) await initialize();
    
    final entries = <SymptomEntry>[];
    for (final key in _box?.keys ?? []) {
      final data = _box?.get(key);
      if (data != null) {
        entries.add(SymptomEntry.fromJson(Map<String, dynamic>.from(data)));
      }
    }
    
    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }
  
  /// Get entries for a date range
  Future<List<SymptomEntry>> getEntriesInRange(DateTime start, DateTime end) async {
    final allEntries = await getAllEntries();
    return allEntries.where((e) {
      return e.date.isAfter(start.subtract(const Duration(days: 1))) && 
             e.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }
  
  /// Get entries for the last N days
  Future<List<SymptomEntry>> getRecentEntries(int days) async {
    final end = DateTime.now();
    final start = end.subtract(Duration(days: days));
    return getEntriesInRange(start, end);
  }
  
  /// Get weekly average for a symptom type
  Future<double> getWeeklyAverage(SymptomType type) async {
    final entries = await getRecentEntries(7);
    if (entries.isEmpty) return 0;
    
    double sum = 0;
    for (final entry in entries) {
      switch (type) {
        case SymptomType.pain:
          sum += entry.painLevel;
          break;
        case SymptomType.swallowingEase:
          sum += entry.swallowingEase;
          break;
        case SymptomType.dryMouth:
          sum += entry.dryMouth;
          break;
      }
    }
    
    return sum / entries.length;
  }
  
  /// Check if user has logged today
  Future<bool> hasLoggedToday() async {
    final today = await getTodayEntry();
    return today != null;
  }
  
  /// Delete an entry
  Future<void> deleteEntry(String dateKey) async {
    if (_box == null) await initialize();
    await _box?.delete(dateKey);
  }
  
  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

enum SymptomType {
  pain,
  swallowingEase,
  dryMouth,
}
