import SwiftUI
import MapKit

struct WalkReceiptView: View {
    @Environment(\.dismiss) private var dismiss
    let walk: Walk

    var body: some View {
        ZStack {
            Color.mangataBackground
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    headerSection

                    Spacer().frame(height: 20)
                    dashedDivider
                    Spacer().frame(height: 20)
                    receiptItems
                    Spacer().frame(height: 20)

                    if !walk.routeCoordinates.isEmpty {
                        miniMapSection
                        Spacer().frame(height: 20)
                    }

                    dashedDivider

                    if !walk.photos.isEmpty {
                        Spacer().frame(height: 20)
                        photoRow
                        Spacer().frame(height: 20)
                        dashedDivider
                    }

                    Spacer().frame(height: 20)
                    footerSection
                }
                .padding(24)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "xmark")
                        Text("关闭")
                    }
                    .font(.system(size: 16))
                    .foregroundStyle(Color.mangataSubtext)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerSection: some View {
        VStack(spacing: 6) {
            Text("散步小票")
                .font(.system(size: 24, weight: .bold, design: .serif))
                .foregroundStyle(Color.mangataText)
            Text("COLOR WALK RECEIPT")
                .font(.system(size: 10, design: .monospaced))
                .tracking(3)
                .foregroundStyle(Color.mangataSubtext)
            Spacer().frame(height: 8)
            Text("NO.\(receiptNumber)")
                .font(.system(size: 12, design: .monospaced))
                .foregroundStyle(Color.mangataSubtext)
        }
        .frame(maxWidth: .infinity)
    }

    private var dashedDivider: some View {
        DashedLine().frame(height: 1)
    }

    private var receiptItems: some View {
        VStack(alignment: .leading, spacing: 14) {
            ReceiptItem(label: "日期", value: dateString)
            ReceiptItem(label: "颜色", value: walk.colorName, colorValue: walk.hexColor)
            ReceiptItem(label: "时长", value: "\(walk.durationMinutes) min")
            ReceiptItem(label: "照片", value: "\(String(format: "%02d", walk.photos.count)) 张")
            if !walk.routeCoordinates.isEmpty {
                ReceiptItem(label: "地点", value: "杭州市·滨江区")
                ReceiptItem(label: "距离", value: String(format: "%.2f mi", walk.distanceMiles))
            }
        }
    }

    @ViewBuilder
    private var miniMapSection: some View {
        if !walk.routeCoordinates.isEmpty {
            Map {
                MapPolyline(coordinates: walk.routeCoordinates.map { $0.clCoordinate })
                    .stroke(walk.swiftUIColor, lineWidth: 3)
            }
            .frame(height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .allowsHitTesting(false)
        }
    }

    private var photoRow: some View {
        HStack(spacing: 8) {
            ForEach(walk.photos.prefix(3)) { photo in
                Group {
                    if let image = photo.image {
                        Image(uiImage: image).resizable().scaledToFill()
                    } else {
                        Rectangle().fill(Color.mangataDivider)
                    }
                }
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fill)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }

    private var footerSection: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Circle().fill(Color(hex: "#87CEEB")).frame(width: 6, height: 6)
                Circle().fill(Color(hex: "#FFB6C1")).frame(width: 6, height: 6)
                Circle().fill(Color(hex: "#8FBC5A")).frame(width: 6, height: 6)
            }
            Text("Mangata")
                .font(.system(size: 14, weight: .semibold, design: .serif))
                .foregroundStyle(Color.mangataText)
            Text("完整记录每一次散步")
                .font(.system(size: 11))
                .foregroundStyle(Color.mangataSubtext)
        }
        .frame(maxWidth: .infinity)
    }

    private var receiptNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let datePart = formatter.string(from: walk.startTime)
        let randomPart = String(format: "%04d", Int(walk.startTime.timeIntervalSince1970) % 10000)
        return "\(datePart)\(randomPart)"
    }

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        let datePart = formatter.string(from: walk.startTime)
        formatter.dateFormat = "EEE"
        let weekdayPart = formatter.string(from: walk.startTime).uppercased()
        return "\(datePart) · \(weekdayPart)"
    }
}

struct ReceiptItem: View {
    let label: String
    let value: String
    var colorValue: String? = nil

    var body: some View {
        HStack {
            HStack(spacing: 6) {
                Circle()
                    .fill(Color(hex: "#D0C8BB"))
                    .frame(width: 4, height: 4)
                Text(label)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.mangataSubtext)
            }
            .frame(width: 80, alignment: .leading)

            Spacer()

            if let hex = colorValue, hex != "gradient" {
                Text(value)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color(hex: hex))
            } else if colorValue == "gradient" {
                Text(value)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.purple)
            } else {
                Text(value)
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundStyle(Color.mangataText)
            }
        }
    }
}

struct DashedLine: View {
    var body: some View {
        Path { path in
            let width = UIScreen.main.bounds.width - 48
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: width, y: 0))
        }
        .stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
        .foregroundStyle(Color(hex: "#D0C8BB"))
        .frame(height: 1)
    }
}

#Preview {
    NavigationStack {
        WalkReceiptView(walk: Walk(
            colorId: "caihong",
            colorName: "彩虹",
            hexColor: "gradient",
            stepCount: 888,
            photos: []
        ))
    }
}