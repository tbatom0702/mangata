import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Walk.startTime, order: .reverse) private var walks: [Walk]
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                Color.mangataBackground
                    .ignoresSafeArea()

                if walks.isEmpty {
                    emptyState
                } else {
                    walkList
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("返回")
                        }
                        .font(.system(size: 16))
                        .foregroundStyle(Color.mangataText)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("历史记录")
                        .font(.system(size: 17, weight: .semibold))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Walk.self) { walk in
                WalkDetailView(walk: walk)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "figure.walk")
                .font(.system(size: 48))
                .foregroundStyle(Color.mangataDivider)

            Text("还没有散步记录")
                .font(.system(size: 16))
                .foregroundStyle(Color.mangataSubtext)

            Text("开始你的第一次色彩散步")
                .font(.system(size: 14))
                .foregroundStyle(Color.mangataSubtext)
        }
    }

    private var walkList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(walks) { walk in
                    WalkHistoryCard(walk: walk) {
                        navigationPath.append(walk)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
    }
}

struct WalkHistoryCard: View {
    let walk: Walk
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                Circle()
                    .fill(walk.swiftUIColor)
                    .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 4) {
                    Text(walk.colorName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.mangataText)

                    Text(formatDate(walk.startTime))
                        .font(.system(size: 12))
                        .foregroundStyle(Color.mangataSubtext)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(walk.durationMinutes) min")
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundStyle(Color.mangataText)

                    Text("\(walk.photos.count) 张")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.mangataSubtext)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.mangataSubtext)
            }
            .padding(16)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM月dd日 HH:mm"
        return formatter.string(from: date)
    }
}

#Preview {
    HistoryView()
}