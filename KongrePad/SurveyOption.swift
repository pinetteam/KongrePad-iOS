//
//  SurveyOption.swift
//  KongrePad
//
//  Created by Mert Demirbağ on 2.09.2023.
//

struct SurveyOption : Codable, Identifiable, Hashable{
    
    var sort_order: Int?
    var id: Int?
    var survey_id: Int?
    var question_id: Int?
    var option: String?
    var status: Int?
    var is_selected: Bool? = false
    
    private enum CodingKeys: String, CodingKey {
        case id, sort_order, survey_id, question_id, option, status
    }
}
