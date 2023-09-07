//
//  KeypadOption.swift
//  KongrePad
//
//  Created by Mert Demirbağ on 6.09.2023.
//

struct KeypadOption : Codable, Identifiable, Hashable{
    
    var id: Int?
    var sort_order: Int?
    var keypad_id: Int?
    var option: String?
}
