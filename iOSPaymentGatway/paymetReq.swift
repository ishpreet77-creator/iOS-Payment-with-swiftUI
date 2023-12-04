//
//  paymetReq.swift
//  iOSPaymentGatway
//
//  Created by John on 15/11/23.
//

import Foundation




struct PaymentReq : JsonSerilizer {
  
    var currency: String = ""
    var amount : String = ""
    
    func serilize() -> Dictionary<String, Any> {
        return [
            "currency": currency,
            "amount": amount,
         
        ]
    }
}
