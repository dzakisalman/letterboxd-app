import 'dart:ui';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import '../models/diary_entry.dart';

class DiaryController extends GetxController {
  final RxMap<String, List<DiaryEntry>> entriesByMonth = <String, List<DiaryEntry>>{}.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDiaryEntries();
  }

  Future<void> loadDiaryEntries() async {
    try {
      isLoading.value = true;
      
      // Read CSV file
      final String csvString = await rootBundle.loadString('assets/csv/diary.csv');
      
      // Parse CSV with proper field delimiter and eol
      final List<List<dynamic>> csvTable = const CsvToListConverter(
        shouldParseNumbers: false, // Keep everything as strings for proper parsing
        fieldDelimiter: ',',
        eol: '\n',
      ).convert(csvString);
      
      if (csvTable.isEmpty) {
        print('CSV file is empty');
        return;
      }

      // Get headers
      final headers = csvTable[0].map((e) => e.toString().trim()).toList();
      
      // Convert rows to maps with headers as keys
      final List<Map<String, dynamic>> csvMaps = [];
      for (var i = 1; i < csvTable.length; i++) {
        if (csvTable[i].length != headers.length) {
          print('Skipping invalid row: ${csvTable[i]}');
          continue;
        }
        
        final map = <String, dynamic>{};
        for (var j = 0; j < headers.length; j++) {
          var value = csvTable[i][j];
          // Ensure the value is a string
          map[headers[j]] = value?.toString() ?? '';
        }
        csvMaps.add(map);
      }
      
      // Convert maps to DiaryEntry objects
      final entries = csvMaps.map((map) {
        try {
          return DiaryEntry.fromCsv(map);
        } catch (e) {
          print('Error creating DiaryEntry from map: $map');
          print('Error: $e');
          return null;
        }
      }).whereType<DiaryEntry>().toList(); // Filter out null entries
      
      if (entries.isEmpty) {
        print('No valid entries found in CSV');
        return;
      }

      // Sort entries by watched date (most recent first)
      entries.sort((a, b) => b.watchedDate.compareTo(a.watchedDate));
      
      // Group entries by month
      final grouped = <String, List<DiaryEntry>>{};
      for (var entry in entries) {
        final monthKey = DateFormat('MMMM yyyy').format(entry.watchedDate).toUpperCase();
        if (!grouped.containsKey(monthKey)) {
          grouped[monthKey] = [];
        }
        grouped[monthKey]!.add(entry);
      }
      
      entriesByMonth.value = grouped;
    } catch (e, stackTrace) {
      print('Error loading diary entries: $e');
      print('Stack trace: $stackTrace');
      Get.snackbar(
        'Error',
        'Failed to load diary entries',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE9A6A6),
        colorText: const Color(0xFF1F1D36),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addDiaryEntry(DiaryEntry entry) async {
    try {
      // TODO: Implement API call to add diary entry
      final monthKey = DateFormat('MMMM yyyy').format(entry.watchedDate).toUpperCase();
      if (!entriesByMonth.containsKey(monthKey)) {
        entriesByMonth[monthKey] = [];
      }
      entriesByMonth[monthKey]!.add(entry);
      entriesByMonth.refresh();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add diary entry',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE9A6A6),
        colorText: const Color(0xFF1F1D36),
      );
    }
  }
} 