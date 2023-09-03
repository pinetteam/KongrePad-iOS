//
//  Document.swift
//  KongrePad
//
//  Created by Mert Demirbağ on 29.08.2023.
//

struct Document : Codable, Identifiable, Hashable{
    
    var id: Int?
    var meeting_id: Int?
    var file_name: String?
    var file_extension: String?
    var title: String?
    var sharing_via_email: Int?
    var status: Int?
    var is_selected = false
    
    private enum CodingKeys: String, CodingKey {
        case id, meeting_id, file_name, file_extension, title, sharing_via_email, status
    }
}

class DocumentJSON : Codable, Identifiable{
    
    var data: Document?
    var errors: [String]?
    var status: Bool?
}
class DocumentsJSON : Codable, Identifiable{
    
    var data: [Document]?
    var errors: [String]?
    var status: Bool?
}
