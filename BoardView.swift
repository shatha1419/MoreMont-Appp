import SwiftUI
import Photos
import CloudKit

struct BoardView: View {
    var boardID: String
    var ownerNickname: String
    var title: String
    
    @State private var showingPopover = false
    @State private var showStickers = false
    @State private var showPhotoPicker = false
    @State private var tempImage: UIImage?  // Temporary variable for image selection
    @State private var stickers: [Sticker] = []  // List to hold multiple stickers
    @State private var stickyNotes: [StickyNote] = []  // List to hold multiple sticky notes
    @State private var members: [String] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var JoinBoardView = false
    @State private var showMembersList = false
    @State private var selectedStickerID: UUID? = nil  // For tracking the selected sticker
    @State private var selectedStickyNoteID: UUID? = nil  // For tracking the selected sticky note

    var body: some View {
        NavigationStack {
            ZStack {
                Color("GrayLight")
                    .ignoresSafeArea()
                    .gesture(TapGesture().onEnded {
                        selectedStickyNoteID = nil
                    })
                
                ForEach($stickers) { $sticker in
                    displaySticker(sticker: $sticker)
                }
                
                ForEach(stickyNotes) { stickyNote in
                    StickyNoteView(stickyNote: stickyNote)
                        .gesture(TapGesture().onEnded {
                            selectedStickyNoteID = stickyNote.id  // Select the sticky note on tap
                            selectedStickerID = nil  // Deselect any sticker
                        })
                        .gesture(DragGesture()
                            .onChanged { value in
                                stickyNote.position = value.location
                            }
                        )
                        .gesture(MagnificationGesture()
                            .onChanged { value in
                                let minScale: CGFloat = 0.5  // Minimum scale
                                stickyNote.scale = max(value, minScale)  // Update the scale with a minimum limit
                            }
                        )
                }
                
                displayStickerGridView()
                displayImagePicker()
            }
            .onChange(of: tempImage, perform: handleImageSelection)
            .onAppear(perform: setupView)
            .navigationBarTitle(title, displayMode: .inline)
            .navigationBarItems(leading: backButton(), trailing: trailingButtons())
            .toolbar { toolbarItems() }
            .overlay(popoverOverlay(), alignment: .center)
            .overlay(membersListOverlay())
        }
    }
    
    private func displaySticker(sticker: Binding<Sticker>) -> some View {
        ZStack {
            Image(uiImage: sticker.wrappedValue.image)
                .resizable()
                .scaledToFit()
                .scaleEffect(sticker.wrappedValue.scale)  // Apply scaling
                .frame(width: 150 * sticker.wrappedValue.scale, height: 150 * sticker.wrappedValue.scale)  // Adjust the size as needed
                .cornerRadius(15)  // Apply corner radius
                .position(sticker.wrappedValue.position)
                .gesture(TapGesture().onEnded {
                    selectedStickerID = sticker.wrappedValue.id  // Select the sticker on tap
                    selectedStickyNoteID = nil  // Deselect any sticky note
                })
                .gesture(DragGesture()
                    .onChanged { value in
                        sticker.wrappedValue.position = value.location
                    }
                )
                .gesture(MagnificationGesture()
                    .onChanged { value in
                        let minScale: CGFloat = 0.5  // Minimum scale
                        sticker.wrappedValue.scale = max(value, minScale)  // Update the scale with a minimum limit
                    }
                )
            
            if selectedStickerID == sticker.wrappedValue.id {
                Button(action: {
                    if let index = stickers.firstIndex(where: { $0.id == sticker.wrappedValue.id }) {
                        stickers.remove(at: index)
                    }
                    selectedStickerID = nil
                }) {
                    Image(systemName: "trash.circle.fill")
                        .font(.title)
                        .foregroundColor(.red)
                }
                .position(x: sticker.wrappedValue.position.x + 60, y: sticker.wrappedValue.position.y - 60)
            }
        }
    }
    
    private func displayStickerGridView() -> some View {
        Group {
            if showStickers {
                StickerGridView(selectSticker: { sticker in
                    self.addStickerToBoard(sticker: sticker)
                }, showStickers: $showStickers)
            }
        }
    }
    
    private func displayImagePicker() -> some View {
        Group {
            if showPhotoPicker {
                ImagePicker(selectedImage: $tempImage, sourceType: .photoLibrary)
            }
        }
    }
    
    private func handleImageSelection(newImage: UIImage?) {
        if let image = newImage {
            print("New image selected")
            let newSticker = Sticker(image: image)
            self.addStickerToBoard(sticker: newSticker)
            tempImage = nil  // Reset the temporary image after use
            self.showPhotoPicker = false // Close the photo picker
        } else {
            print("No image selected")
        }
    }
    
    private func setupView() {
        loadMembers()
        requestPhotoLibraryAccess()  // Request access to the photo library when the view appears
    }
    
    private func backButton() -> some View {
        NavigationLink(destination: MainView()) {
            Image(systemName: "chevron.left")
                .foregroundColor(Color("MainColor"))
        }
    }
    
    private func trailingButtons() -> some View {
        HStack {
            Button(action: {
                showMembersList.toggle()
            }) {
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(Color("MainColor"))
            }
            
            Button(action: {
                showingPopover.toggle()
            }) {
                Image(systemName: "square.and.arrow.up")
                    .foregroundColor(Color("MainColor"))
            }
        }
    }
    
    private func toolbarItems() -> some ToolbarContent {
        ToolbarItem(placement: .bottomBar) {
            if let selectedStickyNoteID = selectedStickyNoteID,
               let index = stickyNotes.firstIndex(where: { $0.id == selectedStickyNoteID }) {
                StickyNoteToolbar(
                    stickyNote: stickyNotes[index],
                    onDelete: {
                        stickyNotes.remove(at: index)
                        self.selectedStickyNoteID = nil
                    },
                    onBold: {
                        stickyNotes[index].isBold.toggle()  // Toggle bold state
                    }
                )
            } else {
                ToolbarView(showStickers: $showStickers, showPhotoPicker: $showPhotoPicker, addStickyNote: addStickyNoteToBoard)
            }
        }
    }
    
    private func popoverOverlay() -> some View {
        Group {
            if showingPopover {
                DetailsView(showingPopover: $showingPopover, boardID: boardID, ownerNickname: ownerNickname, title: title)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(radius: 8)
                    .transition(.move(edge: .top))
            }
        }
    }
    
    private func membersListOverlay() -> some View {
        Group {
            if showMembersList {
                MembersListView(members: members, adminNickname: ownerNickname)
                    .background(Color.white)
                    .cornerRadius(15)
                    .transition(.move(edge: .top))
                    .padding(.top, -345)
                    .padding(.trailing, -120)
            }
        }
    }
    
    private func addStickerToBoard(sticker: Sticker) {
        var newSticker = sticker
        newSticker.scale = 1.0  // Adjust the initial scale as needed
        
        // Randomly position the sticker within the bounds of the view
        let randomX = CGFloat.random(in: 50...300) // Adjust the range as needed
        let randomY = CGFloat.random(in: 100...600) // Adjust the range as needed
        newSticker.position = CGPoint(x: randomX, y: randomY)
        
        self.stickers.append(newSticker)
        self.showStickers = false
    }
    
    private func addStickyNoteToBoard() {
        let newStickyNote = StickyNote(
            text: "",
            position: CGPoint(x: 150, y: 150),
            scale: 1.0,
            color: .yellow
        )
        self.stickyNotes.append(newStickyNote)
    }
    
    private func loadMembers() {
        isLoading = true
        BoardManager.shared.fetchBoardByBoardID(boardID) { [self] result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let boardRecord):
                    if let membersReferences = boardRecord["members"] as? [CKRecord.Reference] {
                        self.members = membersReferences.map { $0.recordID.recordName }
                    }
                case .failure(let error):
                    self.errorMessage = "Failed to load members: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func requestPhotoLibraryAccess() {
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                print("Access granted to photo library")
            case .denied, .restricted, .notDetermined:
                print("Access denied or not determined")
            default:
                break
            }
        }
    }
}

struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        BoardView(boardID: "12345", ownerNickname: "Alice", title: "Weekly Planning")
    }
}
