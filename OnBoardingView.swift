import SwiftUI

struct OnboardingView: View {
    var onboardingData: [OnboardingItem] = [
        OnboardingItem(imageName: "OB1", title: "Focus on your moments", description: "With your family and friends, and keep those memories here."),
        OnboardingItem(imageName: "OB2", title: "Save it in one place", description: "Anytime and anywhere, you and those who love to share can look back to it with MoreMent.")
    ]

    let lastOnboardingItem = OnboardingItem(imageName: "OB3", title: "Enter your name", description: "Choose a Good one, you can’t change it!")

    @State private var currentPage = 0
    @State private var isOnboardingComplete = false
    @State private var userName: String = ""
    @State private var userHasProfile = false

    var body: some View {
        NavigationView {
            VStack {
                TabView(selection: $currentPage) {
                    ForEach(onboardingData.indices, id: \.self) { index in
                        OnboardingSlideView(item: onboardingData[index], isLastSlide: false, userName: $userName)
                            .tag(index)
                    }
                    if !userHasProfile {
                        OnboardingSlideView(item: lastOnboardingItem, isLastSlide: true, userName: $userName)
                            .tag(onboardingData.count)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                .padding()
                
                PageControl(numberOfPages: userHasProfile ? onboardingData.count : onboardingData.count + 1, currentPage: $currentPage)
                    .padding()
                
                Button(action: {
                    if currentPage < (userHasProfile ? onboardingData.count - 1 : onboardingData.count) {
                        currentPage += 1
                    } else {
                        if userHasProfile {
                            isOnboardingComplete = true
                        } else {
                            createUserProfileAndCompleteOnboarding()
                        }
                    }
                }) {
                    Text(currentPage == (userHasProfile ? onboardingData.count - 1 : onboardingData.count) ? "Let's Start" : "Next")
                        .frame(width: 358, height: 46)
                        .background(Color("MainColor"))
                        .foregroundColor(.black)
                        .cornerRadius(8)
                }
                .padding()
                
                Spacer()
            }
            .navigationBarItems(trailing: Button("Skip") {
                UserDefaults.standard.set(true, forKey: "OnboardingCompleted")
                isOnboardingComplete = true
            }.foregroundColor(.gray))



            .fullScreenCover(isPresented: $isOnboardingComplete, content: {
                MainView()
            })
            .onAppear {
                checkUserProfileExistence()
            }
       }
    }

    private func checkUserProfileExistence() {
        let onboardingCompleted = UserDefaults.standard.bool(forKey: "OnboardingCompleted")
        if onboardingCompleted {
            self.isOnboardingComplete = true
            return
        }

        UserProfileManager.shared.fetchUserProfile { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedNickname):
                    if let nickname = fetchedNickname, !nickname.isEmpty {
                        self.userName = nickname
                        self.userHasProfile = true
                    } else {
                        self.userHasProfile = false
                    }
                case .failure(_):
                    self.userHasProfile = false
                }
            }
        }
    }


    private func createUserProfileAndCompleteOnboarding() {
        UserProfileManager.shared.createUserProfile(nickname: userName) { result in
            DispatchQueue.main.async {
                switch result {
                case .success():
                    UserDefaults.standard.set(true, forKey: "OnboardingCompleted")
                    self.isOnboardingComplete = true
                case .failure(let error):
                    print("Error creating user profile: \(error.localizedDescription)")
                }
            }
        }
    
    }



}

struct OnboardingSlideView: View {
    let item: OnboardingItem
    let isLastSlide: Bool
    @Binding var userName: String

    var body: some View {
        VStack {
            Image(item.imageName)
                .resizable()
                .scaledToFit()

            Text(item.title)
                .font(.title)
                .padding()

            if isLastSlide {
                TextField("Enter your name", text: $userName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            Text(item.description)
                .multilineTextAlignment(.center)
        }.padding()
    }
}

struct PageControl: View {
    var numberOfPages: Int
    @Binding var currentPage: Int

    var body: some View {
        HStack {
            ForEach(0..<numberOfPages, id: \.self) { index in
                Circle()
                    .frame(width: 8, height: 8)
                    .foregroundColor(currentPage == index ? Color("MainColor") : .gray)
                    .overlay(Circle().stroke(Color.gray, lineWidth: 0.5))
            }
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
