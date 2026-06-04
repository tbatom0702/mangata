import SwiftUI
import SwiftData

@main
struct MangataApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Walk.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        ZStack {
            if hasCompletedOnboarding {
                MainTabView()
            } else {
                ColorPickerView()
            }
        }
        .onAppear {
            configureAppearance()
        }
    }

    private func configureAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.mangataBackground)
        appearance.titleTextAttributes = [.foregroundColor: UIColor(Color.mangataText)]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(Color.mangataText)]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance

        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(Color.mangataBackground)
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
}

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("首页", systemImage: "figure.walk")
                }
                .tag(0)

            HistoryView()
                .tabItem {
                    Label("历史", systemImage: "clock.arrow.circlepath")
                }
                .tag(1)

            SettingsView()
                .tabItem {
                    Label("设置", systemImage: "gearshape")
                }
                .tag(2)
        }
        .tint(Color.mangataBlack)
    }
}

struct HomeView: View {
    @State private var navigateToColorPicker = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.mangataBackground
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    VStack(spacing: 16) {
                        HStack(spacing: 6) {
                            ForEach(["#87CEEB", "#FFB6C1", "#8FBC5A", "#FFA500", "#9B59B6"], id: \.self) { hex in
                                Circle()
                                    .fill(Color(hex: hex))
                                    .frame(width: 10, height: 10)
                            }
                        }

                        Text("Mangata")
                            .font(.system(size: 36, weight: .bold, design: .serif))
                            .foregroundStyle(Color.mangataText)

                        Text("用色彩记录每一次散步")
                            .font(.system(size: 15))
                            .foregroundStyle(Color.mangataSubtext)
                    }

                    Spacer()
                        .frame(height: 60)

                    NavigationLink {
                        ColorPickerView()
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("开始新的散步")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.mangataBlack)
                        .clipShape(Capsule())
                    }
                    .padding(.horizontal, 40)
                }
                .padding(.bottom, 60)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ContentView()
}