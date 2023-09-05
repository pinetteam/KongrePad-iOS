class ScoreGamePoint : Codable, Identifiable{
    
    var id: Int?
    var qr_code_id: Int?
    var participant_id: Int?
    var point: Int?
    var title: String?
    var created_at: String?
}

class ScoreGamePointsJSON : Codable, Identifiable{
    
    var data: [ScoreGamePoint]?
    var errors: [String]?
    var status: Bool?
}

class ScoreGamePointsResponseJSON: Codable{
    var data: Bool?
    var errors: [String]?
    var status: Bool?
}
