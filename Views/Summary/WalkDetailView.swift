import SwiftUI
import MapKit

struct WalkDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let walk: Walk

    @State private var showingReceipt = false
    @State private var showingShare = false

    var body: some View {
        ZStack {
            Color.mangataBackground
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection

                    Divider()
                        .background(Color.mangataDivider)

                    statsSection

                    routeSection

                    if !walk.photos.isEmpty {
                        photoSection
                    }

                    actionsSection
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 40)
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
                Text("散步记录")
                    .font(.system(size: 17, weight: .semibold))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingReceipt) {
            WalkReceiptView(walk: walk)
        }
        .sheet(isPresented: $showingShare) {
            ShareView(walk: walk)
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Circle()
                    .fill(walk.swiftUIColor)
                    .frame(width: 12, height: 12)

                Text("Color Walk")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.mangataText)
            }

            Text(walk.colorName)
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundStyle(walk.swiftUIColor)

            if let endTime = walk.endTime {
                Text(formatDate(endTime))
                    .font(.system(size: 13))
                    .foregroundStyle(Color.mangataSubtext)
            }
        }
    }

    private var statsSection: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(
                value: formatDuration(walk.duration),
                unit: "min",
                label: "时长"
            )

            StatCard(
                value: String(format: "%.2f", walk.distanceKm),
                unit: "km",
                label: "距离"
            )

            StatCard(
                value: "\(walk.stepCount)",
                unit: "步",
                label: "步数"
            )

            StatCard(
                value: "\(walk.photos.count)",
                unit: "张",
                label: "照片"
            )
        }
    }

    @ViewBuilder
    private var routeSection: some View {
        if !walk.routeCoordinates.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("路线")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.mangataText)

                Map {
                    MapPolyline(coordinates: walk.routeCoordinates.map { $0.clCoordinate })
                        .stroke(walk.swiftUIColor, lineWidth: 4)
                }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .allowsHitTesting(false)
            }
        }
    }

    @ViewBuilder
    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("照片")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.mangataText)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(walk.photos) { photo in
                        Group {
                            if let image = photo.image {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                Rectangle()
                                    .fill(Color.mangataDivider)
                            }
                        }
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
        }
    }

    private var actionsSection: some View {
        VStack(spacing: 12) {
            Button {
                showingReceipt = true
            } label: {
                HStack {
                    Image(systemName: "ticket")
                    Text("查看小票")
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.mangataBlack)
                .clipShape(Capsule())
            }

            Button {
                showingShare = true
            } label: {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("分享")
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.mangataText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    Capsule()
                        .stroke(Color.mangataDivider, lineWidth: 1)
                )
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日 HH:mm"
        return formatter.string(from: date)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        return "\(minutes)"
    }
}

struct StatCard: View {
    let value: String
    let unit: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(Color.mangataText)
                Text(unit)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.mangataSubtext)
            }
            Text(label)
                .font(.system(size: 13))
                .foregroundStyle(Color.mangataSubtext)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    NavigationStack {
        WalkDetailView(walk: Walk(
            colorId: "tianlv",
            colorName: "天蓝",
            hexColor: "#87CEEB",
            stepCount: 1234,
            photos: []
        ))
    }
}