import SwiftUI
import CloudKit

struct BoardCreationView: View {
    @State private var boardTitle: String = ""
    @State private var isLoading = false
    @State private var boardDetails: (boardID: String, ownerNickname: String, title: String)?
    @State private var navigateToBoardView = false
    @Environment(\.dismiss) var dismiss
    @State private var boardImage: UIImage? = nil
    @State private var showingImagePicker = false // To show the image picker

    var body: some View {
        let predefinedImages = ["upload", "thumbnail1", "thumbnail2", "thumbnail3" ] // Names of the images in the asset catalog

        NavigationStack {
            VStack {
                if let image = boardImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                       

                        .frame(width: 190, height: 190) // حجم الصورة الظاهري داخل الإطار
                        .clipShape(RoundedRectangle(cornerRadius: 15))  // تطبيق الزوايا المدورة

                        .frame(width: 190, height: 190) // حجم الإطار الخارجي
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color("GrayLight"), lineWidth: 1)
                            
                        )
                
                } else {
                    Image(systemName: "photo.on.rectangle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .padding()
                        .frame(width: 190, height: 190)
                        .clipShape(RoundedRectangle(cornerRadius: 15))  
                

                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color("GrayLight"), lineWidth: 1)
                        )
                        .foregroundColor(Color("MainColor"))
                      


                }

                TextField("Name of the board", text: $boardTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Text("Select thumbnail")
                    .padding(.trailing, 200)
                       .padding(.top)
                

                LazyHGrid(rows: Array(repeating: GridItem(.flexible(minimum: 140, maximum: 250)), count: 2), spacing: 16) {
                        ForEach(predefinedImages, id: \.self) { imageName in
                            if imageName == "upload" {
                                Image(systemName: "square.and.arrow.up")
                                    
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 100, height: 100)
                                    .padding()
                                    .frame(width: 171, height: 130)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color("GrayLight"), lineWidth: 1)
                                    )                                    .foregroundColor(Color("MainColor"))
                                    .onTapGesture {
                                        print("Upload tapped")
                                        showingImagePicker = true
                                    }
                                    .padding(.horizontal, 10)
                            } else {
                                Image(imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 171, height: 130)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color("GrayLight"), lineWidth: 1)
                                    )

                                    .onTapGesture {
                                        
                                        self.boardImage = UIImage(named: imageName)
                                    }
                            }
                        }
                    }                     .padding(.bottom)

                         
                    
                Text("When you create a board, you can share it with others to express your feelings and share special moments.")
                    .padding()
                    .padding(.bottom , 20)
                    .font(.system(size: 12))
            


 

                if isLoading {
                    ProgressView()
                }
                
                
            }
            .navigationBarTitleDisplayMode(.inline)

            .navigationTitle("Create New Board")

            .navigationBarItems(
                
                leading: Button(action: {
                    dismiss()
                }) {
                    Text("Close")
                }
                    .foregroundColor(Color("MainColor")),
                
                trailing: Button("Done") {
                    isLoading = true
                    BoardManager.shared.createBoard(title: boardTitle, image: boardImage) { result in
                        isLoading = false
                        switch result {
                        case .success(let record):
                            let ownerReference = record["owner"] as? CKRecord.Reference
                            let ownerRecordID = ownerReference?.recordID.recordName ?? "Unknown"
                            let createdBoardID = record["boardID"] as? String ?? "Unknown"
                            boardDetails = (boardID: createdBoardID,
                                            ownerNickname: ownerRecordID,
                                            title: boardTitle)
                            navigateToBoardView = true
                        case .failure(let error):
                            print("Error creating board: \(error.localizedDescription)")
                        }
                    }
                }
                    .disabled(boardTitle.isEmpty || boardImage == nil)
            .foregroundColor(boardTitle.isEmpty || boardImage == nil ? .gray : Color("MainColor"))
            )
            .sheet(isPresented: $showingImagePicker) {
                         ImagePicker(selectedImage: $boardImage, sourceType: .photoLibrary)
                     }
 
            .fullScreenCover(isPresented: $navigateToBoardView) {
                if let details = boardDetails {
                    BoardView(boardID: details.boardID, ownerNickname: details.ownerNickname, title: details.title)
                }
            }
            }
        }
    private func loadBoardImage() {
        // Logic to handle the image after selection from library
    }
    }


struct BoardCreationView_Previews: PreviewProvider {
    static var previews: some View {
        BoardCreationView()
    }
}
