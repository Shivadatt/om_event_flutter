part of '../system_settings_screen.dart';

extension _SettingsTemplatesFormExtension on _SystemSettingsScreenState {
  Widget _buildNotificationsForm() {
    return const SettingsNotificationsTab();
  }

  Widget _buildEmailTemplatesForm() {
    final formKey = GlobalKey<FormState>();
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "EMAIL TEMPLATES CONFIG",
            style: GoogleFonts.italiana(fontSize: 24),
          ),
          const SizedBox(height: 24),
          _jsonField("Templates JSON Map", _emailTemplatesJson),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                _saveAndPublish('email_templates', () async {
                  final decoded =
                      jsonDecode(_emailTemplatesJson.text)
                          as Map<String, dynamic>;
                  await _repository.saveEmailTemplates(
                    EmailTemplatesSettings(templates: decoded),
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

  Widget _buildSmsTemplatesForm() {
    final formKey = GlobalKey<FormState>();
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "SMS TEMPLATES CONFIG",
            style: GoogleFonts.italiana(fontSize: 24),
          ),
          const SizedBox(height: 24),
          _jsonField("Templates JSON Map", _smsTemplatesJson),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                _saveAndPublish('sms_templates', () async {
                  final decoded =
                      jsonDecode(_smsTemplatesJson.text)
                          as Map<String, dynamic>;
                  await _repository.saveSmsTemplates(
                    SmsTemplatesSettings(templates: decoded),
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
