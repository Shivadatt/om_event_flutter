part of '../experience_form_dialog.dart';

extension _ExperienceFormFields on _ExperienceFormDialogState {
  Widget _buildFormFields(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(labelText: "Name"),
          onChanged: (val) {
            if (!isEdit) {
              slugCtrl.text = val
                  .toLowerCase()
                  .trim()
                  .replaceAll(RegExp(r'\s+'), '-')
                  .replaceAll(RegExp(r'[^a-z0-9\-]'), '');
            }
          },
        ),
        TextField(
          controller: slugCtrl,
          decoration: const InputDecoration(labelText: "Slug"),
          enabled: !isEdit,
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Select Categories",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            children: widget.controller.rxCategories.map((cat) {
              final isChecked = selectedCategoryIds.contains(cat.id);
              return CheckboxListTile(
                title: Text(cat.name),
                value: isChecked,
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                onChanged: (bool? val) {
                  updateState(() {
                    if (val == true) {
                      selectedCategoryIds.add(cat.id);
                    } else {
                      if (selectedCategoryIds.length > 1) {
                        selectedCategoryIds.remove(cat.id);
                      } else {
                        Get.snackbar(
                          "Validation Error",
                          "At least one category must be selected.",
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      }
                    }
                  });
                },
              );
            }).toList(),
          ),
        ),
        TextField(
          controller: descCtrl,
          decoration: const InputDecoration(labelText: "Description"),
        ),
        TextField(
          controller: priceCtrl,
          decoration: const InputDecoration(labelText: "Price"),
          keyboardType: TextInputType.number,
        ),
        TextField(
          controller: offerCtrl,
          decoration: const InputDecoration(
            labelText: "Offer Price (Discounted, Optional)",
          ),
          keyboardType: TextInputType.number,
        ),
        TextField(
          controller: durCtrl,
          decoration: const InputDecoration(
            labelText: "Duration (Hours)",
          ),
          keyboardType: TextInputType.number,
        ),
        DropdownButtonFormField<String>(
          value: availability,
          decoration: const InputDecoration(
            labelText: "Availability",
          ),
          items: const [
            DropdownMenuItem(
              value: 'available',
              child: Text("Available"),
            ),
            DropdownMenuItem(
              value: 'unavailable',
              child: Text("Unavailable"),
            ),
            DropdownMenuItem(value: 'booked', child: Text("Booked")),
          ],
          onChanged: (val) {
            if (val != null) {
              updateState(() {
                availability = val;
              });
            }
          },
        ),
        TextField(
          controller: tagsCtrl,
          decoration: const InputDecoration(
            labelText: "Tags (comma-separated)",
          ),
        ),
        TextField(
          controller: colorsCtrl,
          decoration: const InputDecoration(
            labelText: "Colors (comma-separated)",
          ),
        ),
        TextField(
          controller: themesCtrl,
          decoration: const InputDecoration(
            labelText: "Themes (comma-separated)",
          ),
        ),
      ],
    );
  }
}
