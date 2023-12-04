//
//  AmountBox.swift
//  iOSPaymentGatway
//
//  Created by John on 15/11/23.
//

import Foundation
import SwiftUI

struct AmountSelectionBox: View {
    let amount: Int
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        VStack {
            Text("$\(amount)")
                .font(.headline)
                .padding(10)
                .background(isSelected ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(8)
                .onTapGesture {
                    onTap()
                }
        }
    }
}
