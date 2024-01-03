//
//  Transaction+Detail.swift
//  Cobrowse - SwiftUI
//

import SwiftUI

extension Transaction {
    
    struct Detail: View {
        
        @EnvironmentObject private var session: Session
        
        @EnvironmentObject private var transactionDetent: Transaction.Detent.State
        
        private let transaction: Transaction
        
        private var url: URL {
            var url = URL(string: "https://cobrowseio.github.io/cobrowse-sdk-ios-examples")!
            
            url.append(queryItems: [
                .init(name: "title", value: transaction.title),
                .init(name: "subtitle", value: transaction.subtitle),
                .init(name: "amount", value: transaction.amount.currencyString),
                .init(name: "category", value: transaction.category.rawValue)
            ])
            
            return url
        }
        
        var body: some View {
            WebView(url: url)
                .onNavigation { url in
                    print(url)
                }
                .navigationTitle("Transaction")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    if let session = session.current, session.isActive(), transactionDetent.is(.large) {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button { session.end() }
                                label: { Image(systemName: "rectangle.badge.xmark") }
                        }
                    }
                }
        }
        
        init(for transaction: Transaction) {
            self.transaction = transaction
        }
    }
}
