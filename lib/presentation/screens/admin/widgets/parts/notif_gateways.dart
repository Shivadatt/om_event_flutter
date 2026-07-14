part of '../settings_notifications_tab.dart';

extension _NotifGatewaysExtension on _SettingsNotificationsTabState {
  Widget _buildApiGatewaysCredentials() {
    return _buildCard(
      title: "API GATEWAYS CREDENTIALS",
      children: [
        _buildTextField(
          "Resend Email API Key",
          resendKeyCtrl,
          isObscure: true,
        ),
        const SizedBox(height: 12),
        _buildTextField("Verified Sender Email Address", senderEmailCtrl),
        const SizedBox(height: 16),
        const Divider(color: Colors.white10),
        const SizedBox(height: 8),
        _buildTextField(
          "Meta WhatsApp Temporary Token",
          whatsappTokenCtrl,
          isObscure: true,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                "WhatsApp Phone Number ID",
                whatsappPhoneIdCtrl,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                "WhatsApp Business Account ID",
                whatsappBusinessIdCtrl,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFC9A77E),
            foregroundColor: const Color(0xFF091210),
          ),
          icon: const Icon(Icons.save),
          label: const Text("Save Gateway Configuration"),
          onPressed: _saveGatewaySettings,
        ),
      ],
    );
  }

  Widget _buildNotificationDispatchChannels() {
    return _buildCard(
      title: "NOTIFICATION DISPATCH CHANNELS",
      children: [
        SwitchListTile(
          title: const Text(
            "Enable FCM Push Notifications",
            style: TextStyle(color: Colors.white),
          ),
          subtitle: const Text(
            "Deliver in-app and device pushes",
            style: TextStyle(color: Colors.white54, fontSize: 11),
          ),
          value: isPushEnabled,
          activeThumbColor: const Color(0xFFC9A77E),
          onChanged: (val) => updateState(() => isPushEnabled = val),
        ),
        SwitchListTile(
          title: const Text(
            "Enable Email Notifications (Resend)",
            style: TextStyle(color: Colors.white),
          ),
          subtitle: const Text(
            "Deliver custom HTML templates to customers",
            style: TextStyle(color: Colors.white54, fontSize: 11),
          ),
          value: isEmailEnabled,
          activeThumbColor: const Color(0xFFC9A77E),
          onChanged: (val) => updateState(() => isEmailEnabled = val),
        ),
        SwitchListTile(
          title: const Text(
            "Enable WhatsApp Message Alerts",
            style: TextStyle(color: Colors.white),
          ),
          subtitle: const Text(
            "Deliver official Meta API templates to phones",
            style: TextStyle(color: Colors.white54, fontSize: 11),
          ),
          value: isWhatsappEnabled,
          activeThumbColor: const Color(0xFFC9A77E),
          onChanged: (val) => updateState(() => isWhatsappEnabled = val),
        ),
      ],
    );
  }
}
