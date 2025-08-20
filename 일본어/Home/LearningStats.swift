// LearningStats.swift
import Foundation

struct LearningStats: Identifiable {
    let id = UUID()
    var username: String
    var streakDays: Int
    var wordsLearnedTotal: Int
    var minutesLearnedTotal: Int
    var todayGoalMinutes: Int
    var todayLearnedMinutes: Int
    var totalProblems: Int
    var jpyRate: Double

    var todayProgress: Double {
        guard todayGoalMinutes > 0 else { return 0 }
        return min(Double(todayLearnedMinutes) / Double(todayGoalMinutes), 1.0)
    }
}

extension LearningStats {
    static let preview = LearningStats(
        username: "환둥이",
        streakDays: 3,
        wordsLearnedTotal: 128,
        minutesLearnedTotal: 94,
        todayGoalMinutes: 20,
        todayLearnedMinutes: 0,
        totalProblems: 14,
        jpyRate: 934.79
    )
}
