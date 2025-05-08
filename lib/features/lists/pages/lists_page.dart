import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:letterboxd/features/lists/controllers/lists_controller.dart';
import 'package:letterboxd/features/lists/pages/create_list_page.dart';
import 'package:letterboxd/features/lists/pages/list_details_page.dart';
import 'package:intl/intl.dart';

class ListsPage extends StatelessWidget {
  const ListsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ListsController());

    return Scaffold(
      backgroundColor: const Color(0xFF1F1D36),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1D36),
        elevation: 0,
        title: Text(
          'Lists',
          style: GoogleFonts.openSans(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE9A6A6)),
            ),
          );
        }

        if (controller.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error loading lists',
                  style: GoogleFonts.openSans(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: controller.refreshLists,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE9A6A6),
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        if (controller.lists.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'No lists yet',
                  style: GoogleFonts.openSans(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create your first list!',
                  style: GoogleFonts.openSans(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => controller.refreshLists(),
          color: const Color(0xFFE9A6A6),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.lists.length,
            itemBuilder: (context, index) {
              final list = controller.lists[index];
              final createdAt = list['created_at'] != null 
                  ? DateTime.parse(list['created_at'])
                  : DateTime.now();
              final formattedDate = DateFormat('MMM d, y').format(createdAt);

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                color: const Color(0xFF3D3B54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () {
                    Get.to(() => ListDetailsPage(list: list));
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          list['name'] ?? 'Untitled List',
                          style: GoogleFonts.openSans(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          list['description'] ?? 'No description',
                          style: GoogleFonts.openSans(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.movie_outlined,
                              color: Colors.grey[400],
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${list['item_count'] ?? 0} movies',
                              style: GoogleFonts.openSans(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.calendar_today_outlined,
                              color: Colors.grey[400],
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Created $formattedDate',
                              style: GoogleFonts.openSans(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Get.to(() => const CreateListPage());
          if (result == true) {
            controller.refreshLists();
          }
        },
        backgroundColor: const Color(0xFFE9A6A6),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
} 