//
//  SurveyQuestion.swift
//  KongrePad
//
//  Created by Mert Demirbağ on 2.09.2023.
//

struct SurveyQuestion : Codable, Identifiable{
    
    var id: Int?
    var sort_order: Int?
    var survey_id: Int?
    var question: String?
    var options: [SurveyOption]?
    var status: Int?
    var selectedOptionId: Int?
    
    private enum CodingKeys: String, CodingKey {
        case id, sort_order, survey_id, question, options, status
    }
}

class SurveyQuestionsJSON : Codable, Identifiable{
    
    var data: [SurveyQuestion]?
    var errors: [String]?
    var status: Bool?
}

class SurveyQuestionJSON : Codable, Identifiable{
    
    var data: SurveyQuestion?
    var errors: [String]?
    var status: Bool?
}
