import SwiftUI

struct DetailsView: View {
    @Binding var showingPopover: Bool
    @State private var isAcceptingResponses = true
    @State private var showingShareSheet = false
    var boardID: String
    var ownerNickname: String
    var title: String

    var body: some View {
        VStack(alignment: .center) {
            Text(title)
                .padding(.top)
            
            Divider()
                .padding(.horizontal)

            HStack(alignment: .center) {
                Text(boardID)
                    .foregroundColor(Color.gray)
                    .padding()

                Button(action: {
                    UIPasteboard.general.string = boardID
                }) {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 24, weight: .light))
                        .foregroundColor(.black)
                }
            }

            HStack {
                Button(action: {
                    self.showingPopover = false
                }) {
                    Text("Cancel")
                        .foregroundColor(.black)
                        .frame(width: 115, height: 50)
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color("MainColor"), lineWidth: 1)
                        )
                }

                Button(action: {
                    self.showingShareSheet = true
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 20, weight: .light))
                        Text("Share")
                            .font(.body)
                    }
                    .foregroundColor(.black)
                    .frame(width: 115, height: 50)
                    .background(Color("MainColor"))
                    .cornerRadius(10)
                }
            }

            Toggle(isOn: $isAcceptingResponses) {
                Text("Accepting responses")
            }
            .padding()

            Spacer()
        }
        .frame(width: 290, height: 280)
        .background(Color.white)
        .cornerRadius(16)
        // Uncomment the sheet if you want to implement the sharing functionality
        //.sheet(isPresented: $showingShareSheet) {
        //    ActivityView(activityItems: ["Friends Gathering: \(boardID)"])
        //}
    }
}

struct DetailsView_Previews: PreviewProvider {
    static var previews: some View {
        DetailsView(showingPopover: .constant(true), boardID: "12345", ownerNickname: "JaneDoe", title: "My Friends' Gathering")
    }
}
