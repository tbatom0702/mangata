import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @AppStorage("selectedLanguage") private var selectedLanguage = "跟随系统"
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.mangataBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 32) {
                        appHeader

                        plusCard

                        settingsGroups

                        aboutSection
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
                        Text("完成")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.mangataText)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("设置")
                        .font(.system(size: 17, weight: .semibold))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var appHeader: some View {
        VStack(spacing: 12) {
            HStack(spacing: 4) {
                Circle().fill(Color(hex: "#87CEEB")).frame(width: 8, height: 8)
                Circle().fill(Color(hex: "#FFB6C1")).frame(width: 8, height: 8)
                Circle().fill(Color(hex: "#8FBC5A")).frame(width: 8, height: 8)
            }

            Text("Mangata")
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundStyle(Color.mangataText)

            Text("完整记录每一次散步")
                .font(.system(size: 14))
                .foregroundStyle(Color.mangataSubtext)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    private var plusCard: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Mangata Plus")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)

                    Text("解锁更多配色方案和高级功能")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.8))
                }

                Spacer()

                Image(systemName: "sparkles")
                    .font(.system(size: 24))
                    .foregroundStyle(.white)
            }

            Button {
            } label: {
                Text("立即解锁")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color(hex: "#87CEEB"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(.white, in: Capsule())
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color(hex: "#FF6B6B"), Color(hex: "#9B59B6")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var settingsGroups: some View {
        VStack(spacing: 12) {
            SettingsGroupHeader(title: "通用")

            VStack(spacing: 0) {
                SettingsItem(
                    icon: "globe",
                    title: "更换语言",
                    value: selectedLanguage
                ) {
                }

                Divider()
                    .background(Color.mangataDivider)
                    .padding(.leading, 52)

                SettingsItem(
                    icon: "envelope",
                    title: "联系开发者",
                    value: ""
                ) {
                }

                Divider()
                    .background(Color.mangataDivider)
                    .padding(.leading, 52)

                SettingsItem(
                    icon: "square.and.arrow.up",
                    title: "分享 Mangata",
                    value: ""
                ) {
                }

                Divider()
                    .background(Color.mangataDivider)
                    .padding(.leading, 52)

                SettingsItem(
                    icon: "arrow.counterclockwise",
                    title: "重新引导",
                    value: ""
                ) {
                    hasCompletedOnboarding = false
                    dismiss()
                }
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private var aboutSection: some View {
        VStack(spacing: 12) {
            SettingsGroupHeader(title: "关于 Mangata")

            VStack(spacing: 0) {
                HStack {
                    Text("版本")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.mangataText)
                    Spacer()
                    Text("1.0.0")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.mangataSubtext)
                }
                .padding(16)

                Divider()
                    .background(Color.mangataDivider)
                    .padding(.leading, 16)

                HStack {
                    Text("构建")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.mangataText)
                    Spacer()
                    Text("2026.06.03")
                        .font(.system(size: 15, design: .monospaced))
                        .foregroundStyle(Color.mangataSubtext)
                }
                .padding(16)
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            Text("用色彩记录每一步行走")
                .font(.system(size: 12))
                .foregroundStyle(Color.mangataSubtext)
                .padding(.top, 8)
        }
    }
}

struct SettingsGroupHeader: View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.mangataSubtext)
            Spacer()
        }
    }
}

struct SettingsItem: View {
    let icon: String
    let title: String
    let value: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(Color.mangataSubtext)
                    .frame(width: 24)

                Text(title)
                    .font(.system(size: 15))
                    .foregroundStyle(Color.mangataText)

                Spacer()

                if !value.isEmpty {
                    Text(value)
                        .font(.system(size: 14))
                        .foregroundStyle(Color.mangataSubtext)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.mangataDivider)
            }
            .padding(16)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SettingsView()
}