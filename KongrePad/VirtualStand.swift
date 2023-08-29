//
//  VirtualStand.swift
//  KongrePad
//
//  Created by Mert Demirbağ on 23.08.2023.
//

class VirtualStand : Codable, Identifiable{
    
    var id: Int?
    var meeting_id: Int?
    var file_name: String?
    var file_extension: String?
    var title: String?
    var status: Int?
}
