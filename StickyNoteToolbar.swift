//import SwiftUI
//
//struct StickyNoteToolbar: View {
//    @Binding var stickyNote: StickyNote
//    var onDelete: () -> Void
//    var onBold: () -> Void
//    @State private var showColors = false
//
//    var body: some View {
//        ZStack {
//            VStack {
//                HStack {
//                    Button(action: onDelete) {
//                        Image(systemName: "trash")
//                            .foregroundColor(.red)
//                            .padding(.trailing, 20)
//                    }
//
//                    Divider()
//
//                    Button(action: onBold) {
//                        Image(systemName: "bold")
//                            .foregroundColor(.black)
//                            .padding(.trailing, 10)
//                    }
//                    .padding()
//
//                    Divider()
//                    
//                    Button(action: {
//                        showColors.toggle()
//                    }) {
//                        Image(systemName: "paintpalette")
//                            .foregroundColor(.black)
//                            .padding(.leading, 20)
//                    }
//                }
//                .padding()
//                .background(Color.white)
//                .clipShape(RoundedRectangle(cornerRadius: 25))
//                .frame(width: 360, height: 30)
//            }
//            
//            if showColors {
//                VStack {
//                    HStack(spacing: 20) {
//                        ForEach([Color.purple, Color.yellow, Color.orange, Color.green, Color.blue], id: \.self) { color in
//                            Button(action: {
//                                stickyNote.color = color
//                                showColors = false  // Hide colors after selection
//                            }) {
//                                Circle()
//                                    .fill(color)
//                                    .frame(width: 25, height: 25)
//                            }
//                        }
//                    }
//                    .padding()
//                    .offset(y: -65)  // Adjust this offset to position the color picker above the toolbar
//                }
//                .transition(.move(edge: .bottom))
//                .animation(.easeInOut, value: showColors)
//            }
//        }
//        .onChange(of: stickyNote.color) { newColor in
//            // Any additional code can be added here if needed when the color changes
//            print("Color changed to \(newColor)")
//        }
//    }
//}
//
//struct StickyNoteToolbar_Previews: PreviewProvider {
//    @State static var stickyNote = StickyNote(
//        text: "Sample Note",
//        position: CGPoint(x: 100, y: 100),
//        scale: 1.0,
//        color: .yellow
//    )
//
//    static var previews: some View {
//        StickyNoteToolbar(stickyNote: $stickyNote, onDelete: {
//            // Handle delete
//        }, onBold: {
//            // Handle bold text
//        })
//            .padding()
//            .previewLayout(.sizeThatFits)
//    }
//}
