import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SortListPage extends StatelessWidget {
  final String selected;
  const SortListPage({super.key, required this.selected});

  @override
  Widget build(BuildContext context) {
    final themeBg = const Color(0xFF1F1D36);
    final accent = const Color(0xFFE9A6A6);
    final textColor = Colors.white;
    final subTextColor = Colors.grey[400];
    final options = [
      {
        'category': 'RELEASE DATE',
        'items': [
          {'label': 'Newest first', 'value': 'release_date.desc'},
          {'label': 'Earliest first', 'value': 'release_date.asc'},
        ]
      },
      {
        'category': 'AVERAGE RATING',
        'items': [
          {'label': 'Highest first', 'value': 'vote_average.desc'},
          {'label': 'Lowest first', 'value': 'vote_average.asc'},
        ]
      },
      {
        'category': 'VOTE COUNT',
        'items': [
          {'label': 'Highest first', 'value': 'vote_count.desc'},
          {'label': 'Lowest first', 'value': 'vote_count.asc'},
        ]
      },
      {
        'category': 'TITLE',
        'items': [
          {'label': 'A-Z', 'value': 'title.asc'},
          {'label': 'Z-A', 'value': 'title.desc'},
        ]
      },
      {
        'category': 'FILM LENGTH',
        'items': [
          {'label': 'Shortest first', 'value': 'length.asc'},
          {'label': 'Longest first', 'value': 'length.desc'},
        ]
      },
    ];
    return Scaffold(
      backgroundColor: themeBg,
      appBar: AppBar(
        backgroundColor: themeBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Sort By', style: GoogleFonts.openSans(color: textColor, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(selected),
          ),
        ],
      ),
      body: ListView(
        children: options.map((cat) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 0, 8),
                child: Text(
                  cat['category'] as String,
                  style: GoogleFonts.openSans(
                    color: subTextColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              ...List.generate((cat['items'] as List).length, (i) {
                final item = (cat['items'] as List)[i];
                final isSelected = selected == item['value'];
                return ListTile(
                  title: Text(
                    item['label'],
                    style: GoogleFonts.openSans(
                      color: isSelected ? accent : textColor,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check, color: accent)
                      : null,
                  onTap: () => Navigator.of(context).pop(item['value']),
                );
              }),
            ],
          );
        }).toList(),
      ),
    );
  }
} 