//
//  PaymentIntent.swift
//  iOSPaymentGatway
//
//  Created by John on 15/11/23.
//

import Foundation
import SwiftUI
import Combine
import StripePaymentSheet

class MyBackendModel: ObservableObject {
    
    @Published var paymentSheet :  PaymentSheet?
    
    @Published var paymentResult: PaymentSheetResult?
    @Published var paymentintent: [String: Any] = [:]
    @Published var appResponse: AppResponse = AppResponse()
    private var apiService = APIService()
    @Published var isLoading = false
    var cancellables = Set<AnyCancellable>()
    @Published var error: Error?
    @Published var client_Secret: String?
    @Published var isSelected = false
    @Published var paymentSheetFlowController : PaymentSheet.FlowController?
    
   

    
    func preparePaymentSheet(createuserdata: PaymentReq) {
      
           apiService.apiHandler(endpoint: "payment_intents", parameters: createuserdata, method: .post, objectType: createuser.self)
               .sink(receiveCompletion: { [weak self] completion in
                   switch completion {
                   case .finished:
                       break
                   case .failure(let error):
                    
                       self?.error = error
                   }
               }, receiveValue: { [weak self] res in
               
                   if let clientSecret = res.client_secret {
                       print("Client Secret:", clientSecret)
                       self?.client_Secret = clientSecret
                       self?.isSelected = true
                       self?.makePayment()
                   } else {
                       // Handle the case where client_secret is not received
                       print("Client Secret not received.")
                   }
               })
               .store(in: &cancellables)
        
       }
    
    func makePayment() {
        
        STPAPIClient.shared.publishableKey = "pk_test_51OA8V1JYZCpvm4VGYouV8l4KiQFAs7s5GpdlAOTPHGZyQ4kard7a5l0WZpXjyTef4VQV00spYQm3aRAhBwVyn4hl00Zn0sMlbC"
        
        var configuration = PaymentSheet.Configuration()
        configuration.merchantDisplayName = "Example, Inc."
        configuration.allowsDelayedPaymentMethods = true
        configuration.applePay = .init(merchantId: "merchant.com.iOSPaymentGatway", merchantCountryCode: "US")
        
        DispatchQueue.main.async {
            if let clientttSecret = self.client_Secret {
                self.paymentSheet = PaymentSheet(paymentIntentClientSecret: clientttSecret, configuration: configuration)
                 
              
            }
        }
        
    }
    
    func onPaymentCompletion(result: PaymentSheetResult) {
        self.paymentResult = result
    }
    

}
