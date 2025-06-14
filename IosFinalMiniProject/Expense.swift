//
//  Expense.swift
//  IosFinalMiniProject
//
//  Created by Jiseong Ko on 6/14/25.
//

import Foundation

struct Expense: Identifiable, Codable {
    var id = UUID()
    var name: String
    var amount: Int
    var category: String
    var date: Date
}
