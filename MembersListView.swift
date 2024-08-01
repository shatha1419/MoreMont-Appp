import SwiftUI

struct MembersListView: View {
    @State var members: [String]
    var adminNickname: String

    func firstCharacter(of string: String) -> String {
        let index = string.index(string.startIndex, offsetBy: 1, limitedBy: string.endIndex) ?? string.endIndex
        return String(string[..<index])
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(["Admin: \(adminNickname)"] + members, id: \.self) { member in
                    HStack {
                        Circle()
                            .stroke(Color.black, lineWidth: 0.2)
                            .frame(width: 40, height: 40)
                            .overlay(
                                Text(firstCharacter(of: member))
                                    .font(.system(size: 24))
                                    .foregroundColor(.black),
                                alignment: .center
                            )

                        VStack(alignment: .leading) {
                            Text(member.contains("Admin:") ? member.replacingOccurrences(of: "Admin: ", with: "") : member)
                                .font(.body)
                            Text(member.contains("Admin:") ? "admin" : "")
                                .font(.body)
                                .foregroundColor(.gray)
                        }
                    }
                    Divider()

                    .padding(.horizontal)
                }
            }
.frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .cornerRadius(8.0)
            
        }
        .frame(width: 200, height: 200)
        .border(Color.gray.opacity(0.2))
        .cornerRadius(8)
        
    }
}

struct MembersListView_Previews: PreviewProvider {
    static var previews: some View {
        MembersListView(members: ["Nora", "Yasmin", "Faiza","Fouz"], adminNickname: "Demah")
    }
}
