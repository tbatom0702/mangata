import SwiftUI
import MapKit

enum ShareStyle: String, CaseIterable {
    case single = "单图"
    case palette = "色卡"
    case receipt = "小票"
    case route = "路线"
}

struct ShareView: View {
    @Environment(\.dismiss) private var dismiss
    let walk: Walk

    @State private var selectedStyle: ShareStyle = .single
    @State private var selectedPhotoIndex: Int = 0
    @State private var shareImage: UIImage?
    @State private var showingShareSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.mangataBackground
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    previewSection
                        .padding(.horizontal, 24)
                        .padding(.top, 16)

                    Spacer()

                    styleSelector
                        .padding(.horizontal, 24)

                    Spacer()
                        .frame(height: 20)

                    generateButton
                        .padding(.horizontal, 24)
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
                            Image(systemName: "xmark")
                            Text("关闭")
                        }
                        .font(.system(size: 16))
                        .foregroundStyle(Color.mangataSubtext)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("分享")
                        .font(.system(size: 17, weight: .semibold))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingShareSheet) {
                if let image = shareImage {
                    ShareSheet(items: [image])
                }
            }
        }
    }

    @ViewBuilder
    private var previewSection: some View {
        ZStack {
            Color(.systemBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.08), radius: 10, y: 4)

            switch selectedStyle {
            case .single:
                singlePhotoPreview
            case .palette:
                palettePreview
            case .receipt:
                receiptPreview
            case .route:
                routePreview
            }
        }
        .frame(height: 380)
    }

    private var singlePhotoPreview: some View {
        Group {
            if let photo = walk.photos[safe: selectedPhotoIndex],
               let image = photo.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .overlay(alignment: .bottomLeading) {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(walk.swiftUIColor)
                                .frame(width: 8, height: 8)
                            Text(walk.colorName)
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial, in: Capsule())
                        .padding(12)
                    }
            } else {
                Rectangle()
                    .fill(walk.swiftUIColor.opacity(0.3))
                    .overlay {
                        Text("无照片")
                            .foregroundStyle(Color.mangataSubtext)
                    }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var palettePreview: some View {
        VStack(spacing: 16) {
            if !walk.photos.isEmpty {
                let allColors = walk.photos.flatMap { $0.dominantColors }
                let displayColors = allColors.isEmpty
                    ? ["#87CEEB", "#FFB6C1", "#8FBC5A", "#FFA500", "#9B59B6", "#87CEEB"]
                    : Array(allColors.prefix(6))

                HStack(spacing: 0) {
                    ForEach(Array(displayColors.enumerated()), id: \.offset) { _, hex in
                        Rectangle()
                            .fill(Color(hex: hex))
                    }
                }
                .frame(height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                HStack {
                    ForEach(Array(displayColors.enumerated()), id: \.offset) { index, hex in
                        Circle()
                            .fill(Color(hex: hex))
                            .frame(width: 36, height: 36)
                            .overlay {
                                Circle()
                                    .strokeBorder(.white, lineWidth: 2)
                            }
                            .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                    }
                }
            } else {
                HStack(spacing: 8) {
                    ForEach(["#87CEEB", "#FFB6C1", "#8FBC5A", "#FFA500", "#9B59B6", "#FF6B6B"], id: \.self) { hex in
                        Circle()
                            .fill(Color(hex: hex))
                            .frame(width: 36, height: 36)
                    }
                }
                .frame(height: 120)
            }

            Text("从照片中提取的颜色")
                .font(.system(size: 13))
                .foregroundStyle(Color.mangataSubtext)
        }
        .padding(20)
    }

    private var receiptPreview: some View {
        WalkReceiptView(walk: walk)
    }

    private var routePreview: some View {
        Group {
            if !walk.routeCoordinates.isEmpty {
                Map {
                    MapPolyline(coordinates: walk.routeCoordinates.map { $0.clCoordinate })
                        .stroke(walk.swiftUIColor, lineWidth: 4)
                }
                .allowsHitTesting(false)
            } else {
                Rectangle()
                    .fill(walk.swiftUIColor.opacity(0.2))
                    .overlay {
                        VStack(spacing: 8) {
                            Image(systemName: "map")
                                .font(.system(size: 32))
                            Text("无路线数据")
                                .font(.system(size: 14))
                        }
                        .foregroundStyle(Color.mangataSubtext)
                    }
            }
        }
    }

    private var styleSelector: some View {
        HStack(spacing: 12) {
            ForEach(ShareStyle.allCases, id: \.self) { style in
                Button {
                    withAnimation { selectedStyle = style }
                } label: {
                    Text(style.rawValue)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(selectedStyle == style ? .white : Color.mangataText)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(selectedStyle == style ? Color.mangataBlack : Color(.systemBackground))
                        )
                }
            }
            Spacer()
        }
    }

    private var generateButton: some View {
        Button {
            generateAndShare()
        } label: {
            HStack {
                Image(systemName: "square.and.arrow.up")
                Text("生成分享图")
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.mangataBlack)
            .clipShape(Capsule())
        }
    }

    private func generateAndShare() {
        let view = shareContentView
        let renderer = ImageRenderer(content: view.frame(width: 360, height: 640))
        renderer.scale = 3.0
        if let image = renderer.uiImage {
            shareImage = image
            showingShareSheet = true
        }
    }

    @ViewBuilder
    private var shareContentView: some View {
        switch selectedStyle {
        case .single:
            singleShareView
        case .palette:
            paletteShareView
        case .receipt:
            receiptShareView
        case .route:
            routeShareView
        }
    }

    private var singleShareView: some View {
        ZStack {
            Color(.systemBackground)
            if let photo = walk.photos[safe: selectedPhotoIndex],
               let image = photo.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .overlay(alignment: .bottomTrailing) {
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Mangata")
                                .font(.system(size: 11, design: .serif))
                                .foregroundStyle(.white.opacity(0.8))
                        }
                        .padding(12)
                    }
            }
        }
    }

    private var paletteShareView: some View {
        ZStack {
            Color(.systemBackground)
            VStack(spacing: 24) {
                let colors = walk.photos.flatMap { $0.dominantColors }
                let displayColors = colors.isEmpty
                    ? ["#87CEEB", "#FFB6C1", "#8FBC5A", "#FFA500", "#9B59B6"]
                    : Array(colors.prefix(5))

                HStack(spacing: 0) {
                    ForEach(Array(displayColors.enumerated()), id: \.offset) { _, hex in
                        Rectangle()
                            .fill(Color(hex: hex))
                    }
                }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                Text("Color Walk · \(walk.colorName)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.mangataText)

                Text("Mangata")
                    .font(.system(size: 12, design: .serif))
                    .foregroundStyle(Color.mangataSubtext)
            }
            .padding(24)
        }
    }

    private var receiptShareView: some View {
        WalkReceiptView(walk: walk)
    }

    private var routeShareView: some View {
        ZStack {
            Color(.systemBackground)
            if !walk.routeCoordinates.isEmpty {
                VStack {
                    Map {
                        MapPolyline(coordinates: walk.routeCoordinates.map { $0.clCoordinate })
                            .stroke(walk.swiftUIColor, lineWidth: 4)
                    }
                    .allowsHitTesting(false)

                    Text("Color Walk · \(walk.colorName) · \(String(format: "%.2f km", walk.distanceKm))")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.mangataSubtext)
                        .padding(.top, 8)

                    Text("Mangata")
                        .font(.system(size: 11, design: .serif))
                        .foregroundStyle(Color.mangataSubtext)
                        .padding(.top, 4)
                }
                .padding(24)
            }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    ShareView(walk: Walk(
        colorId: "tianlv",
        colorName: "天蓝",
        hexColor: "#87CEEB",
        stepCount: 500
    ))
}