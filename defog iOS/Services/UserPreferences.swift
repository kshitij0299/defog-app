import Foundation

struct UserPreferences {
    static var onboardingCompleted: Bool {
        get { UserDefaults.standard.bool(forKey: "onboardingCompleted") }
        set { UserDefaults.standard.set(newValue, forKey: "onboardingCompleted") }
    }
    
    static var storageChoiceMade: Bool {
        get { UserDefaults.standard.bool(forKey: "storageChoiceMade") }
        set { UserDefaults.standard.set(newValue, forKey: "storageChoiceMade") }
    }
    
    static var storageMode: StorageMode {
        get {
            if let rawValue = UserDefaults.standard.string(forKey: "storageMode"),
               let mode = StorageMode(rawValue: rawValue) {
                return mode
            }
            return .local
        }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: "storageMode") }
    }
    
    static var darkMode: Bool {
        get { UserDefaults.standard.bool(forKey: "darkMode") }
        set { UserDefaults.standard.set(newValue, forKey: "darkMode") }
    }
    
    static var remindersEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "remindersEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "remindersEnabled") }
    }
    
    // Legacy WhisperKit flags (kept for backward compatibility + future re-enabling).
    static var whisperKitEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "whisperKitEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "whisperKitEnabled") }
    }
    
    // Legacy WhisperKit flags (kept for backward compatibility + future re-enabling).
    static var whisperKitDownloaded: Bool {
        get { UserDefaults.standard.bool(forKey: "whisperKitDownloaded") }
        set { UserDefaults.standard.set(newValue, forKey: "whisperKitDownloaded") }
    }

    static var aiAPIKey: String {
        get {
            if let value = UserDefaults.standard.string(forKey: "aiAPIKey"), !value.isEmpty {
                return value
            }
            // Backward compatibility with prior key name.
            return UserDefaults.standard.string(forKey: "openRouterAPIKey") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "aiAPIKey")
            UserDefaults.standard.set(newValue, forKey: "openRouterAPIKey")
        }
    }

    static var aiModel: String {
        get {
            if let value = UserDefaults.standard.string(forKey: "aiModel"), !value.isEmpty {
                return value
            }
            return UserDefaults.standard.string(forKey: "openRouterModel") ?? "openai/gpt-4o-mini"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "aiModel")
            UserDefaults.standard.set(newValue, forKey: "openRouterModel")
        }
    }

    static var aiEndpoint: String {
        get { UserDefaults.standard.string(forKey: "aiEndpoint") ?? "https://openrouter.ai/api/v1/chat/completions" }
        set { UserDefaults.standard.set(newValue, forKey: "aiEndpoint") }
    }
    
    static var lastActivityDate: Date? {
        get {
            let timestamp = UserDefaults.standard.double(forKey: "lastActivityDate")
            return timestamp > 0 ? Date(timeIntervalSince1970: timestamp) : nil
        }
        set {
            if let newValue = newValue {
                UserDefaults.standard.set(newValue.timeIntervalSince1970, forKey: "lastActivityDate")
            } else {
                UserDefaults.standard.removeObject(forKey: "lastActivityDate")
            }
        }
    }
    
    static var lastDailyPromptDate: Date? {
        get {
            let timestamp = UserDefaults.standard.double(forKey: "lastDailyPromptDate")
            return timestamp > 0 ? Date(timeIntervalSince1970: timestamp) : nil
        }
        set {
            if let newValue = newValue {
                UserDefaults.standard.set(newValue.timeIntervalSince1970, forKey: "lastDailyPromptDate")
            } else {
                UserDefaults.standard.removeObject(forKey: "lastDailyPromptDate")
            }
        }
    }
}
