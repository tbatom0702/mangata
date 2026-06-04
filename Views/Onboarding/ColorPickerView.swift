import SwiftUI

struct ColorPickerView: View {
    @StateObject private var viewModel = ColorViewModel()
    @State private var floatOffset: CGFloat = 0
    @State private var currentIndex: Int = 0
    @State private var dragOffset: CGFloat = 0
    @State private var showingWalk = false

    var body: some View {
        ZStack {
            Color.mangataBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                headerBar

                Spacer()
                    .frame(height: 40)

                colorCircle
                    .frame(width: 180, height: 180)

                Spacer()
                    .frame(height: 16)

                dateLabel

                Spacer()
                    .frame(height: 12)

                colorNameLabel

                Spacer()
                    .frame(height: 20)

                poemText

                Spacer()
                    .frame(height: 40)

                startButton
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .fullScreenCover(isPresented: $showingWalk) {
            WalkingView(theme: viewModel.selectedTheme)
        }
    }

    private var headerBar: some View {
        HStack {
            Text("重新选色")
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .tracking(2)
                .foregroundStyle(Color.mangataSubtext)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .stroke(Color.mangataDivider, lineWidth: 1)
                )
            Spacer()
        }
    }

    private var colorCircle: some View {
        let theme = viewModel.allThemes[currentIndex]
        return ZStack {
            if theme.hex == "gradient" {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: "#FF6B6B"),
                                Color(hex: "#FFA500"),
                                Color(hex: "#FFD700"),
                                Color(hex: "#87CEEB"),
                                Color(hex: "#9B59B6")
                            ],
                            center: .init(x: 0.3, y: 0.3),
                            startRadius: 0,
                            endRadius: 120
                        )
                    )
                    .frame(width: 180, height: 180)
                    .shadow(color: .black.opacity(0.1), radius: 20, y: 10)
                    .offset(y: floatOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                dragOffset = value.translation.height
                            }
                            .onEnded { value in
                                if value.translation.height < -30 {
                                    withAnimation { currentIndex = (currentIndex + 1) % viewModel.allThemes.count }
                                } else if value.translation.height > 30 {
                                    withAnimation { currentIndex = (currentIndex - 1 + viewModel.allThemes.count) % viewModel.allThemes.count }
                                }
                                dragOffset = 0
                            }
                    )
            } else {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                theme.color.opacity(0.7),
                                theme.color
                            ],
                            center: .init(x: 0.35, y: 0.35),
                            startRadius: 0,
                            endRadius: 90
                        )
                    )
                    .frame(width: 180, height: 180)
                    .shadow(color: theme.color.opacity(0.3), radius: 20, y: 10)
                    .offset(y: floatOffset + dragOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                dragOffset = value.translation.height
                            }
                            .onEnded { value in
                                if value.translation.height < -30 {
                                    withAnimation { currentIndex = (currentIndex + 1) % viewModel.allThemes.count }
                                } else if value.translation.height > 30 {
                                    withAnimation { currentIndex = (currentIndex - 1 + viewModel.allThemes.count) % viewModel.allThemes.count }
                                }
                                dragOffset = 0
                            }
                    )
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                floatOffset = -8
            }
        }
        .onChange(of: currentIndex) { newIndex in
            viewModel.selectedIndex = newIndex
            viewModel.selectedTheme = viewModel.allThemes[newIndex]
        }
    }

    private var dateLabel: some View {
        Text("今天 · TODAY")
            .font(.system(size: 12, design: .monospaced))
            .tracking(3)
            .foregroundStyle(Color.mangataSubtext)
    }

    private var colorNameLabel: some View {
        Text(viewModel.allThemes[currentIndex].name)
            .font(.system(size: 36, weight: .bold, design: .serif))
            .foregroundStyle(Color.mangataText)
    }

    private var poemText: some View {
        let theme = viewModel.allThemes[currentIndex]
        return VStack(spacing: 8) {
            Text(theme.poem)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(Color.mangataText)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
            Text("— \(theme.author)")
                .font(.system(size: 14))
                .foregroundStyle(Color.mangataSubtext)
        }
        .padding(.horizontal, 12)
    }

    private var startButton: some View {
        Button {
            viewModel.selectedIndex = currentIndex
            viewModel.selectedTheme = viewModel.allThemes[currentIndex]
            showingWalk = true
        } label: {
            Text("开始散步")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.mangataBlack)
                .clipShape(Capsule())
        }
    }
}

#Preview {
    ColorPickerView()
}