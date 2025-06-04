import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:letterboxd/core/widgets/custom_bottom_nav.dart';
import 'package:letterboxd/features/explore/controllers/explore_controller.dart';
import 'package:letterboxd/routes/app_routes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:letterboxd/core/models/movie.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  void _showFilterBottomSheet(BuildContext context, ExploreController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F1D36),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Genre Filter Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter by Genre',
                    style: GoogleFonts.openSans(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Obx(() => controller.selectedGenres.isNotEmpty
                    ? TextButton(
                        onPressed: controller.clearGenres,
                        child: Text(
                          'Clear All',
                          style: GoogleFonts.openSans(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Obx(() => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.availableGenres.map((genre) {
                  final isSelected = controller.selectedGenres.contains(genre);
                  return FilterChip(
                    label: Text(
                      genre['name'],
                      style: GoogleFonts.openSans(
                        color: isSelected ? const Color(0xFF1F1D36) : Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) => controller.toggleGenre(genre),
                    backgroundColor: const Color(0xFF3D3B54),
                    selectedColor: const Color(0xFFE9A6A6),
                    checkmarkColor: const Color(0xFF1F1D36),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  );
                }).toList(),
              )),
              
              const SizedBox(height: 24),
              
              // Year Filter Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter by Year',
                    style: GoogleFonts.openSans(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Obx(() => controller.selectedYears.isNotEmpty
                    ? TextButton(
                        onPressed: controller.clearYears,
                        child: Text(
                          'Clear All',
                          style: GoogleFonts.openSans(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Obx(() => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.availableYears.map((year) {
                  final isSelected = controller.selectedYears.contains(year);
                  return FilterChip(
                    label: Text(
                      year.toString(),
                      style: GoogleFonts.openSans(
                        color: isSelected ? const Color(0xFF1F1D36) : Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) => controller.toggleYear(year),
                    backgroundColor: const Color(0xFF3D3B54),
                    selectedColor: const Color(0xFFE9A6A6),
                    checkmarkColor: const Color(0xFF1F1D36),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  );
                }).toList(),
              )),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ExploreController());
    final textController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFF1F1D36),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF3D3B54),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              // Clear button
              Obx(() => controller.searchQuery.isNotEmpty
                ? Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        controller.clearSearch();
                        textController.clear();
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SvgPicture.asset(
                          'assets/icons/close.svg',
                          colorFilter: ColorFilter.mode(
                            Colors.white.withOpacity(0.5),
                            BlendMode.srcIn,
                          ),
                          width: 20,
                          height: 20,
                        ),
                      ),
                    ),
                  )
                : const SizedBox(width: 8),
              ),
              // Search input
              Expanded(
                child: TextField(
                  controller: textController,
                  onChanged: controller.updateSearchQuery,
                  style: GoogleFonts.openSans(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search movies...',
                    hintStyle: GoogleFonts.openSans(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    isDense: true,
                    filled: true,
                    fillColor: Colors.transparent,
                  ),
                ),
              ),
              // Search button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: controller.performSearch,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SvgPicture.asset(
                      'assets/icons/search.svg',
                      colorFilter: ColorFilter.mode(
                        Colors.white.withOpacity(0.5),
                        BlendMode.srcIn,
                      ),
                      width: 20,
                      height: 20,
                    ),
                  ),
                ),
              ),
              // Filter button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showFilterBottomSheet(context, controller),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SvgPicture.asset(
                      'assets/icons/filter.svg',
                      colorFilter: ColorFilter.mode(
                        Colors.white.withOpacity(0.5),
                        BlendMode.srcIn,
                      ),
                      width: 20,
                      height: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Selected Genres Display
          Obx(() => controller.selectedGenres.isNotEmpty
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: controller.selectedGenres.map((genre) {
                    return Chip(
                      label: Text(
                        genre['name'],
                        style: GoogleFonts.openSans(
                          color: const Color(0xFF1F1D36),
                          fontSize: 14,
                        ),
                      ),
                      backgroundColor: const Color(0xFFE9A6A6),
                      deleteIcon: const Icon(Icons.close, size: 18, color: Color(0xFF1F1D36)),
                      onDeleted: () => controller.toggleGenre(genre),
                    );
                  }).toList(),
                ),
              )
            : const SizedBox.shrink(),
          ),
          // Selected Years Display
          Obx(() => controller.selectedYears.isNotEmpty
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: controller.selectedYears.map((year) {
                    return Chip(
                      label: Text(
                        year.toString(),
                        style: GoogleFonts.openSans(
                          color: const Color(0xFF1F1D36),
                          fontSize: 14,
                        ),
                      ),
                      backgroundColor: const Color(0xFFE9A6A6),
                      deleteIcon: const Icon(Icons.close, size: 18, color: Color(0xFF1F1D36)),
                      onDeleted: () => controller.toggleYear(year),
                    );
                  }).toList(),
                ),
              )
            : const SizedBox.shrink(),
          ),
          // Search Results Section
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (controller.hasError.value) {
                return Center(
                  child: Text(
                    controller.errorMessage.value,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }

              if (controller.searchQuery.isEmpty && controller.selectedGenres.isEmpty) {
                return Column(
                  children: [
                    if (controller.searchHistory.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Searches',
                              style: GoogleFonts.openSans(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: controller.clearHistory,
                              child: Text(
                                'Clear All',
                                style: GoogleFonts.openSans(
                                  color: Colors.grey[400],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 8.0),
                        itemCount: controller.searchHistory.length,
                        itemBuilder: (context, index) {
                          final query = controller.searchHistory[index];
                          return ListTile(
                            title: Text(
                              query,
                              style: GoogleFonts.openSans(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            trailing: IconButton(
                              icon: SvgPicture.asset(
                                'assets/icons/close.svg',
                                colorFilter: ColorFilter.mode(
                                  Colors.grey[600]!,
                                  BlendMode.srcIn,
                                ),
                                width: 20,
                                height: 20,
                              ),
                              onPressed: () => controller.removeFromHistory(query),
                            ),
                            onTap: () {
                              textController.text = query;
                              controller.updateSearchQuery(query);
                              controller.performSearch();
                            },
                          );
                        },
                      ),
                    ],
                    if (controller.searchHistory.isEmpty)
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/icons/explore.svg',
                                colorFilter: ColorFilter.mode(
                                  Colors.grey[600]!,
                                  BlendMode.srcIn,
                                ),
                                width: 48,
                                height: 48,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Search for movies or select genres',
                                style: GoogleFonts.openSans(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              }

              if (controller.hasSearched.value && controller.searchResults.isEmpty) {
                return Center(
                  child: Text(
                    'No results found${controller.searchQuery.isNotEmpty ? ' for "${controller.searchQuery.value}"' : ''}',
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }

              if (!controller.hasSearched.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/search.svg',
                        colorFilter: ColorFilter.mode(
                          Colors.grey[600]!,
                          BlendMode.srcIn,
                        ),
                        width: 48,
                        height: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Start typing to search movies or select genres',
                        style: GoogleFonts.openSans(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.searchResults.length,
                itemBuilder: (context, index) {
                  final movie = controller.searchResults[index];
                  return GestureDetector(
                    onTap: () {
                      Get.toNamed(AppRoutes.movieDetailPath(movie.id.toString()));
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: movie.posterUrl,
                              width: 100,
                              height: 150,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[900],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[900],
                                child: const Icon(
                                  Icons.error_outline,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  movie.title,
                                  style: GoogleFonts.openSans(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (movie.releaseDate.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    movie.releaseDate.split('-')[0],
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                                if (movie.overview.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    movie.overview,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 1),
    );
  }
} 