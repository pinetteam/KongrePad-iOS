//
//  Document.swift
//  KongrePad
//
//  Created by Mert Demirbağ on 29.08.2023.
//

class Document : Codable, Identifiable{
    
    var id: Int?
    var meeting_id: Int?
    var file_name: String?
    var file_extension: String?
    var title: String?
    var sharing_via_email: Int?
    var status: Int?
}

class DocumentJSON : Codable, Identifiable{
    
    var data: Document?
    var errors: [String]?
}
