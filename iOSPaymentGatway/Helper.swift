//
//  Helper.swift
//  iOSPaymentGatway
//
//  Created by John on 15/11/23.
//

import Foundation

protocol JsonSerilizer{
    func serilize() -> Dictionary<String,Any>
}
protocol JsonDeserializer {
    init()
    mutating func deserialize(values: Dictionary<String, Any>?)
}

struct CommonRequest: JsonSerilizer {
    
    func serilize() -> Dictionary<String, Any> {
        return [:]
    }
}
struct AppResponse {

    var createuUser: createuser = createuser()
 
}
