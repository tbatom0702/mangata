import Foundation
import SwiftUI

struct ColorTheme: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let hex: String
    let poem: String
    let author: String

    var color: Color {
        if hex == "gradient" {
            return .blue
        }
        return Color(hex: hex)
    }

    var swiftUIColor: Color {
        color
    }
}

extension ColorTheme {
    static let allThemes: [ColorTheme] = [
        ColorTheme(
            id: "tianlv",
            name: "天蓝",
            hex: "#87CEEB",
            poem: "行到水穷处，坐看云起时。",
            author: "王维"
        ),
        ColorTheme(
            id: "fen",
            name: "粉",
            hex: "#FFB6C1",
            poem: "人间四月芳菲尽，山寺桃花始盛开。",
            author: "白居易"
        ),
        ColorTheme(
            id: "chunlv",
            name: "春绿",
            hex: "#8FBC5A",
            poem: "春风又绿江南岸，明月何时照我还。",
            author: "王安石"
        ),
        ColorTheme(
            id: "caihong",
            name: "彩虹",
            hex: "gradient",
            poem: "日照香炉生紫烟，遥看瀑布挂前川。",
            author: "李白"
        ),
        ColorTheme(
            id: "cheng",
            name: "橙",
            hex: "#FFA500",
            poem: "停车坐爱枫林晚，霜叶红于二月花。",
            author: "杜牧"
        ),
        ColorTheme(
            id: "zi",
            name: "紫",
            hex: "#9B59B6",
            poem: "紫气东来三万里，函关初度五千年。",
            author: "徐道泰"
        )
    ]
}

extension Color {
    static let mangataBackground = Color(hex: "#F2EDE4")
    static let mangataText = Color(hex: "#1A1A1A")
    static let mangataSubtext = Color(hex: "#888888")
    static let mangataDivider = Color(hex: "#D0C8BB")
    static let mangataBlack = Color(hex: "#1A1A1A")

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}