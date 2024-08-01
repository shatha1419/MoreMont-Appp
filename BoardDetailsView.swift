////
////  BoardDetailsView.swift
////  TFainal
////
////  Created by Faizah Almalki on 23/10/1445 AH.
////
//
//import SwiftUI
//import CloudKit
//
//
//struct BoardDetailsView: View {
//    var boardRecord: CKRecord
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 20) {
//            Text("Board Created Successfully!")
//                .font(.headline)
//                .foregroundColor(.green)
//            
//            HStack {
//                Text("Title:")
//                Spacer()
//                Text(boardRecord["title"] as? String ?? "N/A")
//            }
//            
//            HStack {
//                Text("Owner:")
//                Spacer()
//                // افتراض أن المالك محفوظ كمرجع في 'owner'
//                Text(boardRecord["owner"]?.recordID.recordName ?? "Unknown")
//            }
//            
//            HStack {
//                Text("Board ID:")
//                Spacer()
//                Text(boardRecord.recordID.recordName) // معرف فريد للبورد
//            }
//            
//            Spacer()
//        }
//        .padding()
//        .navigationBarTitle("Board Details", displayMode: .inline)
//    }
//}
//
//struct BoardDetailsView_Previews: PreviewProvider {
//    static var previews: some View {
//        // توفير CKRecord مزيف للمعاينة
//        let mockRecord = CKRecord(recordType: "Board")
//        mockRecord["title"] = "Sample Board"
//        mockRecord["owner"] = CKRecord.Reference(recordID: CKRecord.ID(recordName: "User123"), action: .none)
//        return BoardDetailsView(boardRecord: mockRecord)
//    }
//}
//
//
//#Preview {
//    BoardDetailsView()
//}
