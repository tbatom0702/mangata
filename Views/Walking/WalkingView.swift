import SwiftUI
import MapKit

struct WalkingView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = WalkViewModel()
    @State private var showingFinishAlert = false
    @State private var navigateToDetail = false

    let theme: ColorTheme

    var body: some View {
        ZStack {
            Color.mangataBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                headerSection
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                Spacer()
                    .frame(height: 24)

                timerSection
                    .padding(.horizontal, 24)

                Spacer()
                    .frame(height: 32)

                Divider()
                    .background(Color.mangataDivider)
                    .padding(.horizontal, 24)

                Spacer()
                    .frame(height: 24)

                photoSection
                    .padding(.horizontal, 24)

                Spacer()

                finishButton
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
            }
        }
        .onAppear {
            viewModel.startWalk(theme: theme)
        }
        .alert("结束散步？", isPresented: $showingFinishAlert) {
            Button("继续散步", role: .cancel) {}
            Button("结束散步", role: .destructive) {
                viewModel.finishWalk()
                navigateToDetail = true
            }
        } message: {
            Text("确认结束本次散步，生成你的彩色记录。")
        }
        .fullScreenCover(isPresented: $viewModel.showingCamera) {
            CameraView { image in
                viewModel.addPhoto(image)
            }
        }
        .navigationDestination(isPresented: $navigateToDetail) {
            if let walk = viewModel.completedWalk {
                WalkDetailView(walk: walk)
            }
        }
    }

    private var headerSection: some View {
        HStack {
            Text("WALKING")
                .font(.system(size: 12, design: .monospaced))
                .tracking(4)
                .foregroundStyle(Color.mangataSubtext)

            Spacer()

            Text("\(viewModel.photos.count)/\(viewModel.maxPhotos)")
                .font(.system(size: 13))
                .foregroundStyle(Color.mangataSubtext)
        }
    }

    private var timerSection: some View {
        let time = viewModel.durationString
        return HStack(alignment: .center, spacing: 0) {
            Text(time.hours)
                .opacity(1.0)
            Text(":")
                .opacity(1.0)
            Text(time.minutes)
                .opacity(1.0)
            Text(":")
                .opacity(0.4)
            Text(time.seconds)
                .opacity(0.4)
        }
        .font(.system(size: 72, weight: .bold, design: .serif))
        .foregroundStyle(Color.mangataText)
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("拍下你遇见的颜色")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.mangataText)
                Spacer()
                Text("\(viewModel.photos.count)/\(viewModel.maxPhotos)")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.mangataSubtext)
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                ForEach(viewModel.photos) { photo in
                    PhotoThumbnailView(photo: photo)
                        .aspectRatio(1, contentMode: .fill)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .contextMenu {
                            Button(role: .destructive) {
                                viewModel.removePhoto(photo)
                            } label: {
                                Label("删除", systemImage: "trash")
                            }
                        }
                }

                if viewModel.photos.count < viewModel.maxPhotos {
                    AddPhotoButton {
                        viewModel.showingCamera = true
                    }
                    .aspectRatio(1, contentMode: .fill)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
        }
    }

    private var finishButton: some View {
        Button {
            showingFinishAlert = true
        } label: {
            Text("完成")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.mangataBlack)
                .clipShape(Capsule())
        }
    }
}

struct PhotoThumbnailView: View {
    let photo: WalkPhoto

    var body: some View {
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
    }
}

struct AddPhotoButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                    .foregroundStyle(Color.mangataDivider)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.mangataBackground)
                    )

                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color.mangataSubtext)
            }
        }
    }
}

#Preview {
    WalkingView(theme: ColorTheme.allThemes[0])
}