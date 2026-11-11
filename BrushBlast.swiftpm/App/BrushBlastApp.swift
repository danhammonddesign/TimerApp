import SwiftUI

@main
struct BrushBlastApp: App {
    @StateObject private var rewards = RewardStore()
    @StateObject private var settings = AppSettings()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(rewards)
                .environmentObject(settings)
                .preferredColorScheme(.dark)
                .onAppear { AudioManager.shared.configureSession() }
        }
    }
}

/// Switches between the home screen, the brushing timer and the big finale.
@MainActor
struct RootView: View {
    enum Screen: Equatable {
        case home
        case brushing
        case finale(Sticker)
    }

    @EnvironmentObject var rewards: RewardStore
    @EnvironmentObject var settings: AppSettings
    @State private var screen: Screen = .home

    var body: some View {
        ZStack {
            switch screen {
            case .home:
                HomeView(onStart: { screen = .brushing })
                    .transition(.asymmetric(insertion: .scale(scale: 0.8).combined(with: .opacity),
                                            removal: .scale(scale: 1.3).combined(with: .opacity)))
            case .brushing:
                BrushingView(
                    theme: settings.theme,
                    duration: settings.duration,
                    onFinish: {
                        let sticker = rewards.awardSticker(for: settings.theme)
                        screen = .finale(sticker)
                    },
                    onQuit: { screen = .home }
                )
                .transition(.opacity)
            case .finale(let sticker):
                FinaleView(theme: settings.theme, sticker: sticker, onDone: { screen = .home })
                    .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: screen)
    }
}
