//
//  PaymentModel.swift
//  iOSPaymentGatway
//
//  Created by John on 15/11/23.
//

import Foundation
struct createuser: JsonDeserializer, Hashable, Decodable {
    
    init() { }
    var id : String?
    var amount: Int?
    var client_secret: String?
    var currency: String?
    
    
    mutating func deserialize(values: Dictionary<String, Any>?) {
        id = values?["id"] as? String
        amount = values?["amount"] as? Int ?? 0
        client_secret = values?["client_secret"] as? String ?? ""
        currency = values?["currency"] as? String
    }
}
