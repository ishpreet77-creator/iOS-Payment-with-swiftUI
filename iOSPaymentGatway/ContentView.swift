////
////  ContentView.swift
////  iOSPaymentGatway
////
////  Created by John on 09/11/23.
////
//
import SwiftUI
import Combine
import StripePaymentSheet
import StoreKit
//
//
struct ContentView: View {
    @ObservedObject var model = MyBackendModel()
    @State private var selectedAmount: Int?
    @State private var showAlert = false
    @State private var isNavigationActive = false

    var body: some View {
        ZStack{
            NavigationStack{
                VStack {
                    HStack {
                        AmountSelectionBox(amount: 39, isSelected: selectedAmount == 39, onTap: { selectAmount(39) })
                        AmountSelectionBox(amount: 49, isSelected: selectedAmount == 49, onTap: { selectAmount(49) })
                        AmountSelectionBox(amount: 59, isSelected: selectedAmount == 59, onTap: { selectAmount(59) })
                    }
                    .padding(.bottom, 100)

                    

                    // Show Buy Button
                    if let paymentSheet = model.paymentSheet {
                        PaymentSheet.PaymentButton(
                            paymentSheet: paymentSheet,
                            onCompletion: model.onPaymentCompletion
                        ) {
                            Text("Buy")
                        }
                        
                    }else{
                        Text("Buy")
                            .onTapGesture {
                            if selectedAmount == nil {
                                // Open payment sheet
                                showAlert = true
                            }
                        }
                    }
                    

                    if let result = model.paymentResult {
                        switch result {
                        case .completed:
                         
                          Spacer()
                                .alert(isPresented: $showAlert) {
                                    Alert(title: Text("Success"), message: Text("payment compleated"), dismissButton: .default(Text("OK")))
                                }
                        case .failed(let error):
                            Text("Payment failed: \(error.localizedDescription)")
                            Spacer()
                                  .alert(isPresented: $showAlert) {
                                      Alert(title: Text("failed"), message: Text("Payment failed: \(error.localizedDescription)"), dismissButton: .default(Text("OK")))
                                  }
                        case .canceled:
                            Text("Payment canceled.")
                            Spacer()
                                  .alert(isPresented: $showAlert) {
                                      Alert(title: Text("canceled"), message: Text("Payment canceled."), dismissButton: .default(Text("OK")))
                                  }
                        }
                    }
                    Button("Subscription Screen"){
                        isNavigationActive = true
                        
                                
                    }.background(
                        NavigationLink("", destination: SubscriptionScreen(), isActive: $isNavigationActive)
                            .opacity(0)
                    )
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"), message: Text("Please select the amount."), dismissButton: .default(Text("OK")))
                }
            }
        }
      
        
       
    }

    private func selectAmount(_ amount: Int) {
        selectedAmount = amount
        print(amount, "dkjbnfjk")
        model.preparePaymentSheet(createuserdata: PaymentReq(currency: "USD", amount: "\(amount)00"))
    }
}




#Preview {
    ContentView()
}





struct SubscriptionScreen: View {
    var body: some View {
        TabView {
            SubscriptionView(productID: "abcd_123", subscriptionTitle: "Three Months")
                .tabItem {
                    Image(systemName: "1.circle")
                    Text("3 Months")
                }
            SubscriptionView(productID: "oneyearsubs", subscriptionTitle: "One Year")
                .tabItem {
                    Image(systemName: "2.circle")
                    Text("1 Year")
                }
        }
    }
}

struct SubscriptionView: View {
    @State private var isSubscribed = false
    @State private var isSubscribing = false
    let productID: String
    let subscriptionTitle: String

    var body: some View {
        VStack {
            if isSubscribed {
                Text("You are subscribed to \(subscriptionTitle)!")
            } else {
                Button(action: {
                    subscribe()
                }) {
                    if isSubscribing {
                        ProgressView("Subscribing...")
                    } else {
                        Text("Subscribe \(subscriptionTitle)")
                    }
                }
            }
        }
        .onAppear(perform: checkSubscription)
    }

    func checkSubscription() {
        // Check if the user is already subscribed
        if let subscription = UserDefaults.standard.value(forKey: "\(productID)_subscription") as? Bool {
            isSubscribed = subscription
        }
    }

    func subscribe() {
        isSubscribing = true

        // Start the in-app purchase process
        IAPManager.shared.purchaseSubscription(productID: productID) { success in
            if success {
                // Update UI and save subscription state
                isSubscribed = true
                UserDefaults.standard.setValue(true, forKey: "\(productID)_subscription")
            } else {
                // Handle subscription failure
                print("Subscription failed")
            }
            
            // Reset the loader state
            isSubscribing = false
        }
    }
}

class IAPManager: NSObject, ObservableObject, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    static let shared = IAPManager()

    private var purchaseCompletion: ((Bool) -> Void)?

    private override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }

    func purchaseSubscription(productID: String, completion: @escaping (Bool) -> Void) {
        // Request product information from the App Store
        let productRequest = SKProductsRequest(productIdentifiers: [productID])
        productRequest.delegate = self
        productRequest.start()

        // Save the completion handler for later use
        purchaseCompletion = completion
    }

    // MARK: - SKProductsRequestDelegate

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if let product = response.products.first {
            // Found the product, initiate the purchase
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        } else {
            // Product not found
            print("Product not available")
            purchaseCompletion?(false)
        }
    }

    // MARK: - SKPaymentTransactionObserver

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                // Handle successful purchase
                purchaseCompletion?(true)
                SKPaymentQueue.default().finishTransaction(transaction)
            case .failed:
                // Handle failed purchase
                purchaseCompletion?(false)
                SKPaymentQueue.default().finishTransaction(transaction)
            case .restored:
                // Handle restored purchase (if applicable)
                purchaseCompletion?(true)
                SKPaymentQueue.default().finishTransaction(transaction)
            default:
                break
            }
        }
    }
}














