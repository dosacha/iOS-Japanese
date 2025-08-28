// LearningInsightsView.swift
import SwiftUI

struct LearningInsightsView: View {
    var stats: LearningStats
    
    var body: some View {
        List {
            Section("오늘") {
                LabeledContent("학습 시간", value: "\(stats.todayLearnedMinutes)분 / \(stats.todayGoalMinutes)분")
                ProgressView(value: stats.todayProgress) {
                    Text("목표 달성도")
                }
            }
            
            Section("누적") {
                LabeledContent("연속 학습", value: "\(stats.streakDays)일")
                LabeledContent("누적 단어", value: "\(stats.wordsLearnedTotal)개")
                LabeledContent("누적 시간", value: "\(stats.minutesLearnedTotal)분")
            }
        }
        .navigationTitle("학습 정보")
    }
}
