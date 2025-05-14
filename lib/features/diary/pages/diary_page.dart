import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/diary_controller.dart';
import '../widgets/diary_entry_item.dart';

class DiaryPage extends StatelessWidget {
  const DiaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DiaryController>();
    
    return Scaffold(
      backgroundColor: const Color(0xFF1F1D36),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1D36),
        elevation: 0,
        title: Text(
          'Diary',
          style: GoogleFonts.openSans(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: GetBuilder<DiaryController>(
        builder: (controller) {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFE9A6A6),
              ),
            );
          }

          if (controller.entriesByMonth.isEmpty) {
            return Center(
              child: Text(
                'No diary entries yet',
                style: GoogleFonts.openSans(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 16, bottom: 80),
            itemCount: controller.entriesByMonth.length,
            itemBuilder: (context, index) {
              final monthKey = controller.entriesByMonth.keys.elementAt(index);
              final entries = controller.entriesByMonth[monthKey]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Text(
                      monthKey,
                      style: GoogleFonts.openSans(
                        color: const Color(0xFFE9A6A6),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  ...entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DiaryEntryItem(
                        entry: entry,
                        dayNumber: entry.watchedDate.day,
                      ),
                    );
                  }).toList(),
                  if (index < controller.entriesByMonth.length - 1)
                    const SizedBox(height: 24),
                ],
              );
            },
          );
        },
      ),
    );
  }
} 