import SwiftUI

struct LaunchGateView: View {
    @State private var isShowingContent = false

    var body: some View {
        ZStack {
            if isShowingContent {
                ContentView()
                    .transition(.opacity)
            } else {
                VaraSplashScreen()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.45), value: isShowingContent)
        .task {
            try? await Task.sleep(for: .seconds(1.8))
            isShowingContent = true
        }
    }
}

struct VaraSplashScreen: View {
    var body: some View {
        Image("Splash")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
            .overlay {
                LinearGradient(
                    colors: [
                        .black.opacity(0.18),
                        .black.opacity(0.34)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }
    }
}

#Preview {
    LaunchGateView()
}
