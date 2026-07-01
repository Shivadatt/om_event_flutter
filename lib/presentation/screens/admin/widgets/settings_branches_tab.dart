import 'package:flutter/material.dart';

/// Configurator tab for listing, creating, and removing registered studio branches.
class SettingsBranchesTab extends StatefulWidget {
  /// Reference to list of configured branch maps.
  final List<Map<String, dynamic>> branches;

  /// Callback action to register a new branch office.
  final VoidCallback onAdd;

  /// Callback action to remove a branch office at index.
  final Function(int) onRemove;

  /// Callback notification when a branch detail is updated.
  final VoidCallback onChanged;

  /// Creates a [SettingsBranchesTab] widget instance.
  const SettingsBranchesTab({
    super.key,
    required this.branches,
    required this.onAdd,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  State<SettingsBranchesTab> createState() => _SettingsBranchesTabState();
}

class _SettingsBranchesTabState extends State<SettingsBranchesTab> {
  Widget _buildBranchField(
    String label,
    Map<String, dynamic> branch,
    String field,
    int index,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: branch[field] ?? '',
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: const InputDecoration(
            fillColor: Color(0xFF0D1915),
            filled: true,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF254235)),
            ),
          ),
          onChanged: (val) {
            branch[field] = val;
            widget.onChanged();
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "REGISTERED BRANCH OFFICES",
              style: TextStyle(
                color: Color(0xFFC8A26A),
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                fontSize: 13,
              ),
            ),
            ElevatedButton.icon(
              onPressed: widget.onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF162822),
                foregroundColor: const Color(0xFFC8A26A),
                side: const BorderSide(color: Color(0xFF254235)),
              ),
              icon: const Icon(Icons.add, size: 16),
              label: const Text("ADD BRANCH"),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (widget.branches.isEmpty)
          const Text(
            "No branches configured. Click ADD BRANCH to register corporate offices.",
            style: TextStyle(color: Colors.grey),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.branches.length,
            itemBuilder: (context, index) {
              final branch = widget.branches[index];
              return Card(
                color: const Color(0xFF162822),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: const BorderSide(color: Color(0xFF254235)),
                ),
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "BRANCH #${index + 1}: ${branch['name']}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFC8A26A),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                              size: 20,
                            ),
                            onPressed: () => widget.onRemove(index),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildBranchField(
                              "Branch Name",
                              branch,
                              'name',
                              index,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildBranchField(
                              "Phone",
                              branch,
                              'phone',
                              index,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildBranchField(
                              "Email",
                              branch,
                              'email',
                              index,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildBranchField(
                              "Address Line",
                              branch,
                              'address_line',
                              index,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildBranchField(
                              "City",
                              branch,
                              'city',
                              index,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildBranchField(
                              "Instagram URL",
                              branch,
                              'instagram_url',
                              index,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
