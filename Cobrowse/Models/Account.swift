//
//  Account.swift
//  Cobrowse
//

import Combine
import Foundation

class Account: ObservableObject {
    
    let balance = 2495.34
    
    @Published var isSignedIn = true
    @Published var transactions: [Transaction] = []
    
    init() {
        loadData()
    }
    
    private func loadData() {
        
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        
        let currentDate = Date()
        let minDate = currentDate.months(ago: 3)!.startOfMonth
        let maxDate = currentDate.months(ago: 1)!.endOfMonth

        self.transactions = recentTransactions + Transaction.generate(30, between: minDate...maxDate)
    }
    
    private var recentTransactions: [Transaction] {
        
        let currentDate = Date()
        let startOfMonth = currentDate.startOfMonth
        
        return [
            Transaction(
                title: "KinderCare",
                subtitle: "today at 1:07 AM",
                amount: 113.89,
                date: Date.init(timeIntervalSince1970: 1709650867.751),
                category: .childcare),
            Transaction(
                title: "AT&T",
                subtitle: "yeasterday at 4:17 AM",
                amount: 61.91,
                date: Date.init(timeIntervalSince1970: 1709525849.596),
                category: .utilities),
            Transaction(
                title: "Asda",
                subtitle: "last Friday at 8:03 AM",
                amount: 144.83,
                date: Date.init(timeIntervalSince1970: 1709280216.567),
                category: .groceries)
        ]
//        .flatMap { $0 }
        .sorted { $0.date > $1.date }
    }
}
