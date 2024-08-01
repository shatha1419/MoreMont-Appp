import SwiftUI
import CloudKit

struct MainView: View {
    @State private var nickname: String = ""
    @State private var isLoading = true  // Initially true to show loading on view appear
    @State private var navigatingToBoardCreation = false
    @State private var showingJoinBoard = false  // Updated state for showing the JoinBoardView
    @State private var errorMessage: String?
    @State private var boards: [(record: CKRecord, image: UIImage?)] = []
    @State private var showingDeleteAlert = false

    var body: some View {
        NavigationStack {
              ZStack {
                  // Check if we are still loading data
                     if isLoading {
                         ProgressView("Loading...").scaleEffect(1.5, anchor: .center)
                     } else if boards.isEmpty {
                         // If not loading and boards are empty, show empty state view
                         emptyStateView
                     } else {
                         // If we have boards, show the boards list
                         boardsList
                     }
                 }
                 .onAppear {
                     fetchBoards()  // Fetching boards on view appear
                 }
              
              .navigationBarItems(
                  leading: AnyView(Text("Welcome, \(nickname)!").bold()),
                  trailing: HStack {
                            Button(action: {
                                showingJoinBoard = true
                            }) {
                                Image(systemName: "person.2")
                                    .foregroundColor(Color("MainColor")) // لون الأيقونة


                            }
                            Button(action: {
                                navigatingToBoardCreation = true
                            }) {
                                Image(systemName: "plus.rectangle")
                                    .foregroundColor(Color("MainColor"))
                            }
                        }
                    
              )
              .navigationBarBackButtonHidden(true)
              .navigationTitle("Boards")
              
              .onAppear {
                fetchUserProfile()
                fetchBoards()
            }
            
            
            
            .fullScreenCover(isPresented: $navigatingToBoardCreation) {
                            BoardCreationView()
                                .transition(.move(edge: .trailing)) 
                        }
            .overlay(
                         Group {
                             if showingJoinBoard {
                                 JoinBoardView(nickname: $nickname, isShowingPopover: $showingJoinBoard)
                                     .background(Color.white)
                                     .cornerRadius(20)
                                     .shadow(radius: 10)
                                     .transition(.scale)
                             }
                         }, alignment: .center
                     )
            .alert(isPresented: $showingDeleteAlert) {
                Alert(
                    title: Text("Confirm Deletion"),
                    message: Text("Are you sure you want to delete your profile?"),
                    primaryButton: .destructive(Text("Delete")) {
                        deleteUserProfile()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
    private var emptyStateView: some View {
        VStack(alignment: .center) {
            Image("Empty")
            Text("Start designing your boards by creating a new board")
                .foregroundColor(Color.gray.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .padding()
    }



    var boardsList: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(boards, id: \.record.recordID) { board in
                    boardCard(for: board)
                        .frame(minWidth: 0, maxWidth: .infinity)
                }
            }
        }
        .refreshable {
            fetchBoards()
        }
    }


    func boardCard(for board: (record: CKRecord, image: UIImage?)) -> some View {
        NavigationLink(destination: BoardView(boardID: board.record["boardID"] as? String ?? "Unknown",
                                               ownerNickname: extractOwnerNickname(from: board.record),
                                               title: board.record["title"] as? String ?? "Unnamed Board")) 
        {
            
            VStack {
                if let image = board.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .clipped()
                        .frame(width: 170, height: 150)
                        .clipShape(RoundedCorner(radius: 10, corners: [.topLeft, .topRight]))
                        .background(Color.white)
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 190, height: 150)
                        .cornerRadius(10)
                        .foregroundColor(.gray)
                        .background(Color.white)
                }
                Text(board.record["title"] as? String ?? "Unnamed Board")
                    .font(.system(size: 19))
                    .foregroundColor(.black)
                Text(dateToString(board.record.creationDate ?? Date()))
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                    .frame(height: 20)
            }
            .background(Color("GrayLight"))
            .cornerRadius(10)
            .frame(width: 170, height: 218)
        }
        .contextMenu {
            Button(action: {
                deleteBoard(boardID: board.record["boardID"] as? String ?? "")
            }) {
                Label("Delete Board", systemImage: "trash")
            }
        }
    }

    var deleteProfileButton: some View {
        Button("Delete Profile") {
            showingDeleteAlert = true
        }
        .padding()
        .background(Color.red)
        .foregroundColor(.white)
        .cornerRadius(10)
        .padding()
    }

    
    func fetchUserProfile() {
        isLoading = true
        UserProfileManager.shared.fetchUserProfile { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let fetchedNickname):
                    if let nickname = fetchedNickname {
                        self.nickname = nickname // Updating the nickname state
                    } else {
                        errorMessage = "No profile exists, please create one."
                    }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func deleteBoard(boardID: String) {
            isLoading = true
            BoardManager.shared.handleBoardDeletion(boardID: boardID) { result in
                DispatchQueue.main.async {
                    isLoading = false
                    switch result {
                    case .success():
                        self.boards.removeAll { $0.record["boardID"] as? String ?? "" == boardID }
                        print("Board deleted successfully.")
                    case .failure(let error):
                        self.errorMessage = "Failed to delete board: \(error.localizedDescription)"
                    }
                }
            }
        }
    
    func deleteUserProfile() {
        UserProfileManager.shared.deleteUserProfile(nickname: nickname) { result in
            switch result {
            case .success():
                print("Profile deleted successfully.")
                nickname = ""
            case .failure(let error):
                errorMessage = error.localizedDescription
                print("Error deleting profile: \(error.localizedDescription)")
            }
        }
    }

    func dateToString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    private func extractOwnerNickname(from record: CKRecord) -> String {
        (record["owner"] as? CKRecord.Reference)?.recordID.recordName ?? "Unknown"
    }

    func fetchBoards() {
        isLoading = true
        var fetchedBoards: [(record: CKRecord, image: UIImage?)] = []
        
        let group = DispatchGroup()
        
        group.enter()
        BoardManager.shared.fetchBoards { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let boardData):
                    fetchedBoards.append(contentsOf: boardData)
                case .failure(let error):
                    errorMessage = "Error fetching owned boards: \(error.localizedDescription)"
                }
                group.leave()
            }
        }
        
        group.enter()
        BoardManager.shared.fetchBoardsForCurrentUser { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let boardData):
                    fetchedBoards.append(contentsOf: boardData)
                case .failure(let error):
                    errorMessage = "Error fetching boards as member: \(error.localizedDescription)"
                }
                group.leave()
            }
        }

        group.notify(queue: DispatchQueue.main) {
            self.boards = fetchedBoards.sorted { $0.record.creationDate ?? Date.distantPast > $1.record.creationDate ?? Date.distantPast }
            self.isLoading = false  // Ensure this is only set after all fetches are complete
        }
    }
}

struct UMainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
