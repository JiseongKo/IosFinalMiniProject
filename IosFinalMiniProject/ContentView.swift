//
//  ContentView.swift
//  IosFinalMiniProject
//
//  Created by Jiseong Ko on 6/14/25.
//

import SwiftUI
import Charts

struct ExpenseItem: Identifiable, Codable, Equatable {
    let id: UUID
    var amount: Int
    var category: String
    var date: Date

    init(id: UUID = UUID(), amount: Int, category: String, date: Date) {
        self.id = id
        self.amount = amount
        self.category = category
        self.date = date
    }
}

struct ContentView: View {
    @State private var budget: Int = 0
    @State private var expenses: [ExpenseItem] = []
    @State private var showingBudgetInput = false
    @State private var showingExpenseInput = false
    @State private var editingExpense: ExpenseItem?

    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())

    var filteredExpenses: [ExpenseItem] {
        expenses.filter {
            let components = Calendar.current.dateComponents([.year, .month], from: $0.date)
            return components.year == selectedYear && components.month == selectedMonth
        }
    }

    var totalExpense: Int {
        filteredExpenses.reduce(0) { $0 + $1.amount }
    }

    var remainingBudget: Int {
        budget - totalExpense
    }

    var budgetExceeded: Bool {
        remainingBudget < 0
    }
    
    var categoryTotals: [String: Int] {
        var totals = [String: Int]()
        for expense in filteredExpenses {
            totals[expense.category, default: 0] += expense.amount
        }
        return totals
    }

    var body: some View {
        NavigationView {
            VStack {
                Text("개인 예산 관리 앱")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)

                if budget > 0 {
                    Text("예산: \(budget)원")
                        .font(.title3)
                }

                Text("총 지출: \(totalExpense)원")
                    .font(.headline)
                    .foregroundColor(budgetExceeded ? .red : .primary)

                Text("남은 예산: \(remainingBudget)원")
                    .font(.subheadline)
                    .foregroundColor(remainingBudget >= 0 ? .primary : .red)

                if budgetExceeded {
                    Text("⚠️ 예산을 초과했습니다!")
                        .foregroundColor(.red)
                }

                HStack {
                    Picker("연도", selection: $selectedYear) {
                        ForEach(2023...2030, id: \.self) { year in
                            Text("\(year)년").tag(year)
                        }
                    }
                    Picker("월", selection: $selectedMonth) {
                        ForEach(1...12, id: \.self) { month in
                            Text("\(month)월").tag(month)
                        }
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()

                List {
                    ForEach(filteredExpenses) { expense in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(expense.category)
                                Text("\(expense.date, formatter: itemFormatter)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Text("\(expense.amount)원")
                        }
                        .onTapGesture {
                            editingExpense = expense
                            showingExpenseInput = true
                        }
                    }
                    .onDelete(perform: deleteExpense)
                }
                .listStyle(.insetGrouped)
                if !categoryTotals.isEmpty {
                    Chart {
                        ForEach(categoryTotals.sorted(by: { $0.key < $1.key }), id: \.key) { category, total in
                            BarMark(
                                x: .value("카테고리", category),
                                y: .value("총 지출", total)
                            )
                            .foregroundStyle(by: .value("카테고리", category))
                        }
                    }
                    .frame(height: 250)
                    .padding()
                }

            }
            .padding(.horizontal)
            .navigationTitle("")
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button("예산 설정") {
                        showingBudgetInput = true
                    }

                    Spacer()

                    Button("초기화") {
                        resetAll()
                    }
                    .foregroundColor(.red)

                    Spacer()

                    Button("지출 추가") {
                        editingExpense = nil
                        showingExpenseInput = true
                    }
                }
            }
            .onAppear(perform: loadExpenses)
            .sheet(isPresented: $showingBudgetInput) {
                BudgetInputView(budget: $budget)
            }
            .sheet(isPresented: $showingExpenseInput) {
                ExpenseInputView(expenseToEdit: editingExpense, onSave: addOrUpdateExpense)
            }
        }
    }

    // MARK: - 기능 함수들

    func addOrUpdateExpense(_ expense: ExpenseItem) {
        if let index = expenses.firstIndex(where: { $0.id == expense.id }) {
            expenses[index] = expense
        } else {
            expenses.append(expense)
        }
        saveExpenses()
    }

    func deleteExpense(at offsets: IndexSet) {
        let filtered = filteredExpenses
        for offset in offsets {
            if let index = expenses.firstIndex(of: filtered[offset]) {
                expenses.remove(at: index)
            }
        }
        saveExpenses()
    }

    func resetAll() {
        budget = 0
        expenses.removeAll()
        saveExpenses()
    }

    func saveExpenses() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(expenses) {
            UserDefaults.standard.set(encoded, forKey: "expenses")
        }
        UserDefaults.standard.set(budget, forKey: "budget")
    }

    func loadExpenses() {
        if let savedExpenses = UserDefaults.standard.data(forKey: "expenses"),
           let decoded = try? JSONDecoder().decode([ExpenseItem].self, from: savedExpenses) {
            expenses = decoded
        }
        budget = UserDefaults.standard.integer(forKey: "budget")
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter
}()
