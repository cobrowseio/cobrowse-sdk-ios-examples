//
//  Transaction+List.swift
//  Cobrowse - SwiftUI
//

import SwiftUI

extension Transaction {
    
    struct List: View {
        
        @EnvironmentObject private var account: Account
        @EnvironmentObject private var session: Session
        
        @EnvironmentObject private var transactionDetent: Transaction.Detent.State
        
        private let transactions: [Transaction]
        
        private var transactionsByMonth: [Dictionary<Date, [Transaction]>.Element] {
            Dictionary(grouping: account.transactions, by: { $0.date.startOfMonth })
                .sorted { $0.key > $1.key }
        }
        
        var body: some View {
            SwiftUI.List {
                ForEach(transactionsByMonth, id: \.key) { (date, transactions) in
                    Section(header: Text(date.string!)) {
                        ForEach(transactions) { transaction in
                            Item(for: transaction)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Transactions")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Transaction.self, destination: { transaction in
                Transaction.Detail(for: transaction)
            })
            .toolbar {
                if let session = session.current, session.isActive(), transactionDetent.is(.large) {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button { session.end() }
                            label: { Image(systemName: "rectangle.badge.xmark") }
                    }
                }
            }
        }
        
        init(transactions: [Transaction]) {
            self.transactions = transactions
        }
    }
}
