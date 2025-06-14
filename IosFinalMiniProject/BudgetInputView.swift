//
//  BudgetInputView.swift
//  IosFinalMiniProject
//
//  Created by Jiseong Ko on 6/14/25.
//

import Foundation
import SwiftUICore
import SwiftUI

struct BudgetInputView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var budget: Int
    @State private var inputText = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("예산 입력")) {
                    TextField("예산을 입력하세요", text: $inputText)
                        .keyboardType(.numberPad)
                }
            }
            .navigationBarTitle("예산 설정", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        if let value = Int(inputText) {
                            budget = value
                        }
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            inputText = "\(budget)"
        }
    }
}
