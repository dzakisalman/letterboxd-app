import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:letterboxd/core/services/tmdb_service.dart';

class CreateListPage extends StatefulWidget {
  const CreateListPage({super.key});

  @override
  State<CreateListPage> createState() => _CreateListPageState();
}

class _CreateListPageState extends State<CreateListPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _isLoading = false.obs;

  Future<void> _createList() async {
    print('\n[CreateList] ===== Starting List Creation =====');
    print('[CreateList] Validating form...');
    
    if (!_formKey.currentState!.validate()) {
      print('[CreateList] Form validation failed');
      return;
    }
    
    print('[CreateList] Form validation successful');
    print('[CreateList] Title: ${_titleController.text}');
    print('[CreateList] Description: ${_descriptionController.text}');

    _isLoading.value = true;
    print('[CreateList] Loading state set to true');

    try {
      print('[CreateList] Calling TMDBService.createList...');
      final result = await TMDBService.createList(
        name: _titleController.text,
        description: _descriptionController.text,
      );

      print('[CreateList] Received response from TMDBService');
      print('[CreateList] Success: ${result['success']}');

      if (result['success']) {
        print('[CreateList] List created successfully');
        print('[CreateList] List ID: ${result['list_id']}');
        Get.back(result: true);
        Get.snackbar(
          'Success',
          'List created successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        print('[CreateList] Failed to create list');
        print('[CreateList] Error code: ${result['error_code']}');
        print('[CreateList] Error message: ${result['error_message']}');
        Get.snackbar(
          'Error',
          result['error_message'] ?? 'Failed to create list',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('[CreateList] Exception occurred: $e');
      Get.snackbar(
        'Error',
        'An unexpected error occurred. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
      print('[CreateList] Loading state set to false');
      print('[CreateList] ===== End List Creation Process =====\n');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1D36),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1D36),
        elevation: 0,
        title: Text(
          'Create List',
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
      body: Obx(() => Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Field
                    Text(
                      'Title',
                      style: GoogleFonts.openSans(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      style: GoogleFonts.openSans(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter list title',
                        hintStyle: GoogleFonts.openSans(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: Colors.grey[800]?.withOpacity(0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Description Field
                    Text(
                      'Description',
                      style: GoogleFonts.openSans(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      style: GoogleFonts.openSans(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Enter list description',
                        hintStyle: GoogleFonts.openSans(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: Colors.grey[800]?.withOpacity(0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Create Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading.value ? null : _createList,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE9A6A6),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          disabledBackgroundColor: Colors.grey[600],
                        ),
                        child: _isLoading.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                ),
                              )
                            : Text(
                                'Create List',
                                style: GoogleFonts.openSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading.value)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE9A6A6)),
                ),
              ),
            ),
        ],
      )),
    );
  }
} 