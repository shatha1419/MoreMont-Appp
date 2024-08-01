import SwiftUI

struct SplashScreen: View {
    @State private var isActive = false
    @State private var isOnboardingCompleted = false
    @Environment(\.scenePhase) private var scenePhase
    private let splashDelay = 3.0 // Configurable delay duration

    var body: some View {
        VStack {
            Image("logo") // Ensure this image is available in your assets
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
            Text("Welcome to MyApp")
                .font(.headline)
                .foregroundColor(.blue)
        }
        .onAppear {
            isOnboardingCompleted = UserDefaults.standard.bool(forKey: "OnboardingCompleted")
            print("Is Onboarding Completed: \(isOnboardingCompleted)")
            DispatchQueue.main.asyncAfter(deadline: .now() + splashDelay) {
                self.isActive = true
            }
        }

        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active && !isActive {
                // Optionally reset or adjust behavior when app comes to foreground
            }
        }
        .fullScreenCover(isPresented: $isActive) {
            if isOnboardingCompleted {
                MainView()
            } else {
                OnboardingView()
            }
        }
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
    }
}
