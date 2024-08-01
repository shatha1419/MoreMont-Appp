import SwiftUI

struct ToolbarView: View {
    @Binding var showStickers: Bool
    @Binding var showPhotoPicker: Bool
    var addStickyNote: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                HStack {
                    Button(action: {
                        addStickyNote()  // إضافة الملاحظة الجديدة عند النقر
                    }) {
                        Image("StickyNote") // تأكد من وجود هذه الصورة في مشروعك
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .padding(.top, 60)
                            .padding(.trailing, 10)
                    }
                    Divider()

                    Button(action: {
                        self.showPhotoPicker.toggle()
                    }) {
                        Image(systemName: "camera")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.yellow)
                            .frame(width: 30, height: 30)
                            .padding(30)
                    }

                    Divider()
                    Button(action: {
                        self.showStickers.toggle()
                    }) {
                        Image("Sticker") // تأكد من وجود هذه الصورة في مشروعك
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 55, height: 50)
                            .padding()
                    }
                }
                .frame(width: 360, height: 90)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 25))
            }
        }
    }
}

struct ToolbarView_Previews: PreviewProvider {
    static var previews: some View {
        ToolbarView(showStickers: .constant(false), showPhotoPicker: .constant(false), addStickyNote: {})
    }
}
