import Foundation

enum AppNotification {
    static let vocabBookmarkChanged = Notification.Name("vocabBookmarkChanged")
    static let switchTab            = Notification.Name("switchTab")        // Tab 전환 (index: Int)
    static let homePopToRoot        = Notification.Name("homePopToRoot")    // Home 탭 네비 스택 루트로
}
