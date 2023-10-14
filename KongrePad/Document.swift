//
//  Document.swift
//  KongrePad
//
//  Created by Mert Demirbağ on 29.08.2023.
//

struct Document : Codable, Identifiable{
    
    var id: Int?
    var meeting_id: Int?
    var file_name: String?
    var file_extension: String?
    var title: String?
    var allowed_to_review: Int?
    var sharing_via_email: Int?
    var status: Int?
    var is_requested: Bool?
    var session: Session?
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
