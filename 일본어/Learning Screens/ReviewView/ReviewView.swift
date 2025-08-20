import SwiftUI

struct ReviewView: View {
    let days = ["Day 1", "Day 2", "Day 3", "Day 4", "Day 5", "Day 6"]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 1.0, green: 0.9, blue: 0.9)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("복습하기")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.top, 30)
                    
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(days, id: \.self) { day in
                            NavigationLink(destination: LearningFlowView()) {
                                Text(day)
                                    .font(.title)
                                    .fontWeight(.medium)
                                    .frame(width: 170, height: 170)
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
                                    .foregroundColor(.black)
                                    .padding(.bottom, 10)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
