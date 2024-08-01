import SwiftUI

// StickyNote data structure
class StickyNote: Identifiable, ObservableObject {
    let id = UUID()
    @Published var text: String
    @Published var position: CGPoint
    @Published var scale: CGFloat
    @Published var color: Color
    @Published var isBold: Bool

    init(text: String, position: CGPoint = CGPoint(x: 100, y: 100), scale: CGFloat = 1.0, color: Color = .yellow, isBold: Bool = false) {
        self.text = text
        self.position = position
        self.scale = scale
        self.color = color
        self.isBold = isBold
    }
}

struct StickyNoteView: View {
    @ObservedObject var stickyNote: StickyNote

    var body: some View {
        VStack {
            TextField("Enter note text", text: $stickyNote.text)
                .padding()
                .frame(width: 200, height: 200)  // Set fixed size for the sticky note
                .background(stickyNote.color)
                .cornerRadius(15)  // Add corner radius
                .scaleEffect(stickyNote.scale)
                .position(stickyNote.position)
                .multilineTextAlignment(.center)  // Center text alignment
                .foregroundColor(.black)  // Text color
                .font(stickyNote.isBold ? .system(size: 16, weight: .bold) : .system(size: 16, weight: .regular))
        }
    }
}

struct StickyNoteToolbar: View {
    @ObservedObject var stickyNote: StickyNote
    var onDelete: () -> Void
    var onBold: () -> Void
    @State private var showColors = false

    let availableColors: [Color] = [
        Color.purple, Color.yellow, Color.orange, Color.green, Color.blue
    ]

    var body: some View {
        VStack {
            HStack {
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .padding(.trailing, 20)
                }

                Divider()

                Button(action: onBold) {
                    Image(systemName: "bold")
                        .foregroundColor(.black)
                        .padding(.trailing, 10)
                }
                .padding()

                Divider()
                
                Button(action: {
                    showColors.toggle()
                }) {
                    Image(systemName: "paintpalette")
                        .foregroundColor(.black)
                        .padding(.leading, 20)
                }
            }
            .padding()
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 25))
            .frame(width: 360, height: 90)
            if showColors {
                colorPickerSection
                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut, value: showColors)
            }
        }
    }

    private var colorPickerSection: some View {
        HStack {
            ForEach(availableColors, id: \.self) { color in
                Circle()
                    .fill(color)
                    .frame(width: 30, height: 30)
                    .onTapGesture {
                        stickyNote.color = color
                        showColors = false
                    }
            }
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(10)
        .shadow(radius: 3)
    }
}

// Preview Providers
struct StickyNoteView_Previews: PreviewProvider {
    @StateObject static var sampleNote = StickyNote(text: "Sample Note")
    
    static var previews: some View {
        StickyNoteView(stickyNote: sampleNote)
            .previewLayout(.sizeThatFits)  // Use sizeThatFits to avoid additional background
    }
}

struct StickyNoteToolbar_Previews: PreviewProvider {
    @StateObject static var sampleNote = StickyNote(text: "Sample Note")
    
    static var previews: some View {
        VStack {
            StickyNoteToolbar(
                stickyNote: sampleNote,
                onDelete: {},
                onBold: {}
            )
            .background(Color.gray.opacity(0.1))
            .padding()
        }
        .previewLayout(.sizeThatFits)
    }
}



