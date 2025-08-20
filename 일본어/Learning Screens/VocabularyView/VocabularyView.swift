import SwiftUI

// 한 항목(리스트 셀) 모델
struct Word: Identifiable, Equatable {
    let id = UUID()
    let hiragana: String
    let kanji: String
    let meaning: String
    let day: String
    var isSelected: Bool = false
}

struct VocabularyView: View {
    private var currentList: [Word] {
        selectedTab == .learning ? learningWords : conversationWords
    }
    private var anySelected: Bool {
        currentList.contains { $0.isSelected }
    }
    private var listIsEmpty: Bool {
        currentList.isEmpty
    }
    enum TabType {
        case learning
        case conversation
    }

    @State private var selectedTab: TabType = .learning
    @State private var isAllSelected: Bool = false

    @State private var learningWords: [Word] = []
    @State private var conversationWords: [Word] = []

    var body: some View {
        VStack(spacing: 0) {
            // 상단 제목
            ZStack {
                Text("나만의 단어장")
                    .bold()
                    .font(.title)
                    .padding()
            }
            .frame(maxWidth: .infinity)
            .background(Color.pink.opacity(0.2))

            // 세그먼트 버튼 (요청한 스타일)
            HStack {
                Spacer()
                HStack(spacing: 0) {
                    Button(action: { selectedTab = .learning }) {
                        Text("오늘의 학습")
                            .font(.system(size: 14))
                            .fontWeight(selectedTab == .learning ? .bold : .regular)
                            .frame(width: 100, height: 20)
                            .background(selectedTab == .learning ? Color.white : Color.clear)
                            .cornerRadius(5)
                            .foregroundColor(.black)
                    }

                    Button(action: { selectedTab = .conversation }) {
                        Text("오늘의 회화")
                            .font(.system(size: 14))
                            .fontWeight(selectedTab == .conversation ? .bold : .regular)
                            .frame(width: 100, height: 20)
                            .background(selectedTab == .conversation ? Color.white : Color.clear)
                            .cornerRadius(5)
                            .foregroundColor(.black)
                    }
                }
                .padding(3)
                .background(Color.gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
                Spacer()
            }
            .padding(.top, 10)

            // 툴바: 삭제/전체선택
            HStack(spacing: 12) {
                // 삭제 버튼 (원형 핑크)
                Button {
                    deleteSelectedWords()
                } label: {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.pink)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)

                Spacer()

                // 전체선택 토글 버튼
                Button {
                    isAllSelected.toggle()
                    selectAll(isAllSelected)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: isAllSelected ? "checkmark.circle.fill" : "checkmark.circle")
                        Text("전체선택")
                            .font(.footnote)
                    }
                    .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)

            // 리스트
            List {
                if selectedTab == .learning {
                    ForEach(learningWords) { word in
                        rowView(word)
                    }
                    .onDelete { indexSet in
                        learningWords.remove(atOffsets: indexSet)
                        persistLearning()
                    }
                } else {
                    ForEach(conversationWords) { word in
                        rowView(word)
                    }
                    .onDelete { indexSet in
                        conversationWords.remove(atOffsets: indexSet)
                        persistConversation()
                    }
                }
            }
            .listStyle(PlainListStyle())
        }
        // 첫 진입 시 저장소에서 초기 로드 + 중복 제거
        .onAppear {
            loadFromStorage()
        }
        // 알림 수신: Step5 → 학습, KeywordsScreen → 회화
        .onReceive(NotificationCenter.default.publisher(for: AppNotification.vocabBookmarkChanged)) { note in
            guard
                let info = note.userInfo,
                let hiragana = info["hiragana"] as? String,
                let kanji = info["kanji"] as? String,
                let meaning = info["meaning"] as? String,
                let day = info["day"] as? String,
                let isOn = info["isOn"] as? Bool
            else { return }

            let source = (info["source"] as? String) ?? ""
            let targetIsConversation = (source == "keywords")
            let newWord = Word(hiragana: hiragana, kanji: kanji, meaning: meaning, day: day)

            if targetIsConversation {
                if isOn {
                    if !conversationWords.contains(where: { $0.kanji == kanji && $0.hiragana == hiragana && $0.meaning == meaning }) {
                        conversationWords.insert(newWord, at: 0)
                    }
                } else {
                    conversationWords.removeAll { $0.kanji == kanji && $0.hiragana == hiragana && $0.meaning == meaning }
                }
                persistConversation()
            } else {
                if isOn {
                    if !learningWords.contains(where: { $0.kanji == kanji && $0.hiragana == hiragana && $0.meaning == meaning }) {
                        learningWords.insert(newWord, at: 0)
                    }
                } else {
                    learningWords.removeAll { $0.kanji == kanji && $0.hiragana == hiragana && $0.meaning == meaning }
                }
                persistLearning()
            }
        }
    }

    // MARK: - Row

    @ViewBuilder
    private func rowView(_ word: Word) -> some View {
        HStack(spacing: 12) {
            // 선택 체크
            Button {
                toggleSelect(word)
            } label: {
                Image(systemName: word.isSelected ? "checkmark.circle.fill" : "checkmark.circle")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)

            // 일본어(후리가나 위) + 한국어 뜻
            VStack(alignment: .leading, spacing: 2) {
                if !word.hiragana.isEmpty {
                    Text(word.hiragana)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text(word.kanji)
                    .font(.headline)
                Text(word.meaning)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Day 표시
            Text(word.day)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            toggleSelect(word)
        }
    }

    // MARK: - Helpers (선택/삭제/중복 방지/저장)

    private var currentWordsBinding: Binding<[Word]> {
        selectedTab == .learning ? $learningWords : $conversationWords
    }

    private func toggleSelect(_ word: Word) {
        if selectedTab == .learning {
            if let idx = learningWords.firstIndex(where: { $0.id == word.id }) {
                learningWords[idx].isSelected.toggle()
            }
            isAllSelected = !learningWords.contains(where: { !$0.isSelected })
        } else {
            if let idx = conversationWords.firstIndex(where: { $0.id == word.id }) {
                conversationWords[idx].isSelected.toggle()
            }
            isAllSelected = !conversationWords.contains(where: { !$0.isSelected })
        }
    }

    private func selectAll(_ select: Bool) {
        if selectedTab == .learning {
            learningWords = learningWords.map { var c = $0; c.isSelected = select; return c }
        } else {
            conversationWords = conversationWords.map { var c = $0; c.isSelected = select; return c }
        }
    }

    private func deleteSelectedWords() {
        if selectedTab == .learning {
            learningWords.removeAll { $0.isSelected }
            persistLearning()
        } else {
            conversationWords.removeAll { $0.isSelected }
            persistConversation()
        }
        isAllSelected = false
    }

    private func persistLearning() {
        let back = learningWords.map {
            VocabItem(kanji: $0.kanji,
                      furigana: $0.hiragana.isEmpty ? nil : $0.hiragana,
                      korean: $0.meaning,
                      dayTag: $0.day)
        }
        let uniq = dedup(back)
        VocabularyStorage.shared.saveLearning(uniq)
        learningWords = uniq.map {
            Word(hiragana: $0.furigana ?? "", kanji: $0.kanji, meaning: $0.korean, day: $0.dayTag ?? "Day1")
        }
    }

    private func persistConversation() {
        let back = conversationWords.map {
            VocabItem(kanji: $0.kanji,
                      furigana: $0.hiragana.isEmpty ? nil : $0.hiragana,
                      korean: $0.meaning,
                      dayTag: $0.day)
        }
        let uniq = dedup(back)
        VocabularyStorage.shared.saveConversation(uniq)
        conversationWords = uniq.map {
            Word(hiragana: $0.furigana ?? "", kanji: $0.kanji, meaning: $0.korean, day: $0.dayTag ?? "Day1")
        }
    }

    private func loadFromStorage() {
        // 학습
        let learningSaved = dedup(VocabularyStorage.shared.loadLearning())
        learningWords = learningSaved.map {
            Word(hiragana: $0.furigana ?? "",
                 kanji: $0.kanji,
                 meaning: $0.korean,
                 day: $0.dayTag ?? "Day1")
        }
        // 회화
        let convoSaved = dedup(VocabularyStorage.shared.loadConversation())
        conversationWords = convoSaved.map {
            Word(hiragana: $0.furigana ?? "",
                 kanji: $0.kanji,
                 meaning: $0.korean,
                 day: $0.dayTag ?? "Day1")
        }
    }

    /// (kanji, furigana, korean) 조합으로 중복 제거 – 첫 항목 유지
    private func dedup(_ items: [VocabItem]) -> [VocabItem] {
        var seen = Set<String>()
        var out: [VocabItem] = []
        out.reserveCapacity(items.count)
        for it in items {
            let key = "\(it.kanji)|\(it.furigana ?? "")|\(it.korean)"
            if !seen.contains(key) {
                seen.insert(key)
                out.append(it)
            }
        }
        return out
    }
}
