import SwiftUI

struct LogoView: View {
    @State private var isAnimating = false
    @State private var showLogin = false
    @State private var fadeOutLogo = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if showLogin {
                LoginView()
                    .transition(.opacity)
            } else {
                Image("3")
                    .resizable()
                    .scaledToFit()
                    .frame(width: isAnimating ? 350 : 600, height: isAnimating ? 350 : 600)
                    .opacity(fadeOutLogo ? 0 : 1)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1)) {
                            isAnimating = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation(.easeInOut(duration: 1)) {
                                fadeOutLogo = true
                            }
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showLogin = true
                        }
                    }
            }
        }
        .animation(.easeInOut(duration: 1), value: showLogin)
    }
}

#Preview {
    LogoView()
}

