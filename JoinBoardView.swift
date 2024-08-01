import SwiftUI
import CloudKit

struct JoinBoardView: View {
    @Binding var nickname: String
    @State private var boardID: String = ""
    @State private var boardTitle: String = ""
    @State private var isJoining: Bool = false
    @State private var joinError: String?
    @State private var navigateToBoard: Bool = false
    @State private var ownerNickname: String = ""
    @Binding var isShowingPopover: Bool

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
            
            VStack(alignment: .center) {
                Text("Enter the board code")
                    .padding(.bottom)
                
                Divider()
                    .padding(.horizontal)
                    .padding(.bottom)
                
                TextField("Enter Board ID", text: $boardID)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .padding(.top, -20)
                
                if let joinError = joinError {
                    Text(joinError).foregroundColor(.red)
                        .font(.system(size: 12))
                }
                if isJoining {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                        .zIndex(1)
                }
                
                HStack {
                    Button("Cancel") {
                        isShowingPopover = false
                    }
                    .background(Color.white)
                    .foregroundColor(.black)
                    .frame(width: 115, height: 50)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color("MainColor"), lineWidth: 1)
                    )
                    
                    Button("Join Board") {
                        joinBoard()
                    }
                    .frame(width: 115, height: 50)
                    .background(Color("MainColor"))
                    .cornerRadius(8)
                    .disabled(boardID.isEmpty || isJoining)
                    .foregroundColor(.white)
                    .fullScreenCover(isPresented: $navigateToBoard) {
                                 BoardView(boardID: boardID, ownerNickname: ownerNickname, title: boardTitle)
                             }
                    
                }
                .padding(.top, 30)
                
                // Ensures navigation link is properly set to activate
              
            }
            .frame(width: 290, height: 280)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(radius: 20)
        
        
    }
    private func joinBoard() {
        let cleanBoardID = boardID.trimmingCharacters(in: .whitespacesAndNewlines)
        isJoining = true
        BoardManager.shared.fetchBoardByBoardID(cleanBoardID) { [self] result in
            DispatchQueue.main.async {
                isJoining = false
                switch result {
                case .success(let boardRecord):
                    boardTitle = boardRecord["title"] as? String ?? "Unknown"
                    ownerNickname = (boardRecord["owner"] as? CKRecord.Reference)?.recordID.recordName ?? "Unknown"
                    proceedToAddMember(boardRecord: boardRecord)
                case .failure(let error):
                    joinError = "Failed to join the board: \(error.localizedDescription)"
                }
            }
        }
    }

    private func proceedToAddMember(boardRecord: CKRecord) {
        BoardManager.shared.addMemberToBoard(memberNickname: nickname, boardID: boardRecord.recordID.recordName) { [self] addMemberResult in
            DispatchQueue.main.async {
                switch addMemberResult {
                case .success():
                    navigateToBoard = true
                case .failure(let error):
                    joinError = "Failed to add member to the board: \(error.localizedDescription)"
                }
            }
        }
    }
}

