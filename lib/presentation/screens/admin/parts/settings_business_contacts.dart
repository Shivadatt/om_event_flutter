part of '../system_settings_screen.dart';

extension _SettingsBusinessContactsExtension on _SystemSettingsScreenState {
  Widget _buildBusinessContactNumbers() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const int maxContactNumbers = 10; // Configurable maximum

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Business Contact Numbers",
              style: GoogleFonts.italiana(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFC9A77E),
              ),
            ),
            if (_contactNumbers.length < maxContactNumbers)
              TextButton.icon(
                onPressed: _showAddContactDialog,
                icon: const Icon(Icons.add, color: Color(0xFFC9A77E)),
                label: Text(
                  "Add Contact Number",
                  style: AppTheme.sansBody(
                    fontSize: 12,
                    color: const Color(0xFFC9A77E),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_contactNumbers.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              "No contact numbers configured. Add at least one.",
              style: AppTheme.sansBody(fontSize: 14, color: Colors.red),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.black12,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _contactNumbers.length,
              onReorderItem: (oldIndex, newIndex) {
                updateState(() {
                  final item = _contactNumbers.removeAt(oldIndex);
                  _contactNumbers.insert(newIndex, item);
                  // Update displayOrder
                  for (int i = 0; i < _contactNumbers.length; i++) {
                    final c = _contactNumbers[i];
                    _contactNumbers[i] = ContactNumberEntity(
                      id: c.id,
                      label: c.label,
                      number: c.number,
                      isPrimary: c.isPrimary,
                      isActive: c.isActive,
                      displayOrder: i + 1,
                    );
                  }
                });
              },
              itemBuilder: (context, index) {
                final cn = _contactNumbers[index];
                return ListTile(
                  key: Key(cn.id),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  title: Row(
                    children: [
                      Text(
                        cn.number,
                        style: AppTheme.sansBody(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2C27),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          cn.label,
                          style: AppTheme.sansBody(
                            fontSize: 10,
                            color: const Color(0xFFC9A77E),
                          ),
                        ),
                      ),
                      if (cn.isPrimary) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC9A77E),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "Primary",
                            style: AppTheme.sansBody(
                              fontSize: 10,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Text(
                    cn.isActive ? "Active" : "Inactive",
                    style: AppTheme.sansBody(
                      fontSize: 12,
                      color: cn.isActive ? Colors.green : Colors.grey,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showEditContactDialog(cn, index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          if (cn.isPrimary) {
                            Get.snackbar(
                              "Validation Error",
                              "Cannot delete primary number. Mark another as primary first.",
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                            return;
                          }
                           updateState(() {
                             _contactNumbers.removeAt(index);
                             for (int i = 0; i < _contactNumbers.length; i++) {
                               final c = _contactNumbers[i];
                               _contactNumbers[i] = ContactNumberEntity(
                                 id: c.id,
                                 label: c.label,
                                 number: c.number,
                                 isPrimary: c.isPrimary,
                                 isActive: c.isActive,
                                 displayOrder: i + 1,
                               );
                             }
                           });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 24),
      ],
    );
  }
}
