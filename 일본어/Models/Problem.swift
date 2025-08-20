import Foundation

struct Problem: Identifiable, Equatable {
    let id = UUID()
    let question: String
    let answer: String
}
