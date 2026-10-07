part of '../system_settings_screen.dart';

extension _SettingsTemplatesFormExtension on _SystemSettingsScreenState {
  Widget _buildNotificationsForm() {
    return const SettingsNotificationsTab();
  }

  Widget _buildEmailTemplatesForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "EMAIL TEMPLATES CONFIG",
          style: GoogleFonts.italiana(fontSize: 24),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF152621),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFC9A77E).withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.mark_email_read_outlined,
                    color: Color(0xFFC9A77E),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Email Templates Managed in Notification Templates CMS",
                      style: AppTheme.sansBody(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                "Email notification templates (subject, variables, body templates, and event triggers) are authoritatively authored with rich preview in the dedicated Notification Templates CMS. Raw JSON editing has been decommissioned to maintain a strict Single Source of Truth.",
                style: AppTheme.sansBody(
                  fontSize: 13,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC9A77E),
                  foregroundColor: const Color(0xFF0F1B18),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.launch_outlined, size: 16),
                label: const Text(
                  "OPEN NOTIFICATION TEMPLATES CMS",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    fontSize: 12,
                  ),
                ),
                onPressed: () => Get.toNamed(AppRoutes.manageNotificationTemplates),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSmsTemplatesForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "SMS TEMPLATES CONFIG",
          style: GoogleFonts.italiana(fontSize: 24),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF152621),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFC9A77E).withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.sms_outlined,
                    color: Color(0xFFC9A77E),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "SMS Templates Managed in Notification Templates CMS",
                      style: AppTheme.sansBody(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                "SMS notification templates (character limits, variables, body templates, and event triggers) are authoritatively authored in the dedicated Notification Templates CMS. Raw JSON editing has been decommissioned to maintain a strict Single Source of Truth.",
                style: AppTheme.sansBody(
                  fontSize: 13,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC9A77E),
                  foregroundColor: const Color(0xFF0F1B18),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.launch_outlined, size: 16),
                label: const Text(
                  "OPEN NOTIFICATION TEMPLATES CMS",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    fontSize: 12,
                  ),
                ),
                onPressed: () => Get.toNamed(AppRoutes.manageNotificationTemplates),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildValidationForm() {
    final formKey = GlobalKey<FormState>();
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "FORMS VALIDATION CONFIG",
            style: GoogleFonts.italiana(fontSize: 24),
          ),
          const SizedBox(height: 24),
          _jsonField("Validation Rules JSON Map", _formsValidationJson),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                _saveAndPublish('validation', () async {
                  final decoded =
                      jsonDecode(_formsValidationJson.text)
                          as Map<String, dynamic>;
                  await _repository.saveValidation(
                    ValidationSettings(validationRules: decoded),
                  );
                });
              }
            },
            child: const Text("Save & Publish Live"),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertMessagesForm() {
    final formKey = GlobalKey<FormState>();
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "ALERT MESSAGES CONFIG",
            style: GoogleFonts.italiana(fontSize: 24),
          ),
          const SizedBox(height: 24),
          _jsonField("Custom Messages JSON Map", _alertMessagesJson),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                _saveAndPublish('messages', () async {
                  final decoded =
                      jsonDecode(_alertMessagesJson.text)
                          as Map<String, dynamic>;
                  await _repository.saveMessages(
                    MessagesSettings(customMessages: decoded),
                  );
                });
              }
            },
            child: const Text("Save & Publish Live"),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeSectionsForm() {
    final formKey = GlobalKey<FormState>();
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "HOME SECTIONS CONFIG",
            style: GoogleFonts.italiana(fontSize: 24),
          ),
          const SizedBox(height: 24),
          _jsonField("Active Sections JSON List", _homeSectionsJson),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                _saveAndPublish('home_sections', () async {
                  final decoded =
                      jsonDecode(_homeSectionsJson.text) as List<dynamic>;
                  await _repository.saveHomeSections(
                    HomeSectionsSettings(activeSections: decoded),
                  );
                });
              }
            },
            child: const Text("Save & Publish Live"),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoFilmsForm() {
    final formKey = GlobalKey<FormState>();
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("VIDEO FILMS CONFIG", style: GoogleFonts.italiana(fontSize: 24)),
          const SizedBox(height: 24),
          _jsonField("Videos JSON List", _videoFilmsJson),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                _saveAndPublish('video_settings', () async {
                  final decoded =
                      jsonDecode(_videoFilmsJson.text) as List<dynamic>;
                  await _repository.saveVideoSettings(
                    VideoSettings(videosList: decoded),
                  );
                });
              }
            },
            child: const Text("Save & Publish Live"),
          ),
        ],
      ),
    );
  }
}
