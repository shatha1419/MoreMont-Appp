//import SwiftUI
//
//struct UserEntryView: View {
//    @Binding var nickname: String
//    @Binding var isLoading: Bool
//    @Binding var showGreeting: Bool
//    @State private var errorMessage: String?
//
//    var body: some View {
//        VStack(spacing: 10) {
//            Text("Enter Your Name")
//                .padding(.bottom, 20)
//                .font(.headline)
//            
//            TextField("Enter Your Name", text: $nickname)
//                .textFieldStyle(UnderlineTextFieldStyle())
//                .padding(.horizontal)
//            
//            Text("Choose a Good one, you can't change it!")
//                .font(.caption)
//                .foregroundColor(.gray)
//                .padding(.bottom, 40)
//            
//            Button("Save") {
//                isLoading = true
//                UserProfileManager.shared.createUserProfile(nickname: nickname) { result in
//                    DispatchQueue.main.async {
//                        isLoading = false
//                        switch result {
//                        case .success():
//                            showGreeting = true
//                        case .failure(let error):
//                            errorMessage = error.localizedDescription
//                        }
//                    }
//                }
//            }
//            .disabled(nickname.isEmpty || isLoading)
//            .padding()
//            .frame(width: 120, height: 50)
//            .background(isLoading ? Color.gray : Color.blue)
//            .foregroundColor(.white)
//            .cornerRadius(10)
//            
//            if isLoading {
//                ProgressView()
//            }
//        }
//        .frame(width: 320, height: 300)
//        .padding()
//        .background(Color.white)
//        .cornerRadius(12)
//        .shadow(radius: 1)
//        .padding()
//        .alert(isPresented: .constant(errorMessage != nil), content: {
//            Alert(title: Text("Error"), message: Text(errorMessage ?? "Unknown error"), dismissButton: .default(Text("OK"), action: {
//                errorMessage = nil
//            }))
//        })
//    }
//}
//
//struct UnderlineTextFieldStyle: TextFieldStyle {
//    func _body(configuration: TextField<Self._Label>) -> some View {
//        configuration
//            .padding(10)
//            .multilineTextAlignment(.center)
//            .overlay(Rectangle().frame(height: 1).padding(.top, 35), alignment: .bottomLeading)
//            .foregroundColor(Color.black)
//    }
//}
