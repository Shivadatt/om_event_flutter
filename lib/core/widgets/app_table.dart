import 'package:flutter/material.dart';
import '../../core/config/app_theme.dart';

/// Centralized Custom Table grid layout.
class AppTable extends StatelessWidget {
  final List<String> columns;
  final List<TableRow> rows;

  const AppTable({super.key, required this.columns, required this.rows});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCream : AppTheme.lightCream,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? AppTheme.darkLine : AppTheme.lightLine,
                    width: 1,
                  ),
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
                          color:
                              isDark ? AppTheme.darkGold : AppTheme.lightGold,
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
