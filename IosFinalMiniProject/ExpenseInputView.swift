//
//  ExpenseInputView.swift
//  IosFinalMiniProject
//
//  Created by Jiseong Ko on 6/14/25.
//

import Foundation
import SwiftUICore
import SwiftUI

struct ExpenseInputView: View {
    @Environment(\.dismiss) var dismiss

    var expenseToEdit: ExpenseItem?
    var onSave: (ExpenseItem) -> Void

    @State private var amountText = ""
    @State private var category = ""
    @State private var date = Date()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("지출 정보")) {
                    TextField("금액", text: $amountText)
                        .keyboardType(.numberPad)

                    TextField("카테고리", text: $category)

                    DatePicker("날짜", selection: $date, displayedComponents: .date)
                }
            }
            .navigationBarTitle(expenseToEdit == nil ? "지출 추가" : "지출 편집", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        if let amount = Int(amountText) {
                            let newExpense = ExpenseItem(
                                id: expenseToEdit?.id ?? UUID(),
                                amount: amount,
                                category: category,
                                date: date
                            )
                            onSave(newExpense)
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
            if let expense = expenseToEdit {
                amountText = "\(expense.amount)"
                category = expense.category
                date = expense.date
            }
        }
    }
}
