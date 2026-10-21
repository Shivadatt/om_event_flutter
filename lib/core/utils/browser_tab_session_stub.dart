final Map<String, String> _stubSessionStorage = {};

bool isTabSessionActiveImpl(String key) => _stubSessionStorage[key] == 'true';

void setTabSessionActiveImpl(String key) {
  _stubSessionStorage[key] = 'true';
}

void clearTabSessionImpl(String key) {
  _stubSessionStorage.remove(key);
}

String? getTabSessionStringImpl(String key) => _stubSessionStorage[key];

void setTabSessionStringImpl(String key, String value) {
  _stubSessionStorage[key] = value;
}

void resetStubTabSessionForTesting() {
  _stubSessionStorage.clear();
}

