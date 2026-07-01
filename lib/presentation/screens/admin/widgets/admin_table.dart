import 'package:flutter/material.dart';
import '../../../../core/config/app_theme.dart';

/// Reusable Admin Table layout widget.
class AdminTable extends StatelessWidget {
  final List<String> columns;
  final List<TableRow> rows;

  const AdminTable({super.key, required this.columns, required this.rows});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        constraints: const BoxConstraints(minWidth: 800),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(2),
            3: FlexColumnWidth(1.5),
            4: FlexColumnWidth(1.5),
            5: FlexColumnWidth(1),
          },
          children: [
            TableRow(
              decoration: const BoxDecoration(
                color: Color(0xFF0F1E19),
                border: Border(
                  bottom: BorderSide(color: Color(0x21FFFFFF), width: 1),
                ),
              ),
              children:
                  columns.map((col) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Text(
                        col.toUpperCase(),
                        style: AppTheme.sansBody(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFC8A26A),
                          letterSpacing: 1.3,
                        ),
                      ),
                    );
                  }).toList(),
            ),
            ...rows,
          ],
        ),
      ),
    );
  }
}
