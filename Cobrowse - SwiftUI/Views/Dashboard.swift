//
//  Dashboard.swift
//  Cobrowse - SwiftUI
//

import SwiftUI
import Charts
import CobrowseIO

struct Dashboard: View {
    
    @State var shouldPresentAccountSheet = false
    
    @State var shouldPresentTransactionsSheet: Bool
    @State private var transactionDetent = Transaction.Detent.State(.collapsed)
    
    @EnvironmentObject private var account: Account
    @EnvironmentObject private var session: Session
    
    @ObservedObject var navigation = Navigation()
    
    private let offset = 65.0
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    
                    Heading()
                        .padding(.top, shouldPresentTransactionsSheet ? offset : 0)
                    
                    if !shouldPresentTransactionsSheet {
                        Color.clear
                    }
                    
                    PieChart(recentTransactions: account.transactions.recentTransactions)
                        .frame(maxWidth: shouldPresentTransactionsSheet ? nil : geometry.size.width,
                               maxHeight: shouldPresentTransactionsSheet ? nil : max(geometry.size.height - offset, 0))
                        .aspectRatio(1, contentMode: .fill)
                        .padding(.horizontal, 6)
                    
                    Spacer()
                    
                    if shouldPresentTransactionsSheet {
                        Color.Cobrowse.background
                            .sheet(isPresented: $shouldPresentTransactionsSheet) {
                                NavigationStack(path: $navigation.path) {
                                    Transaction.List(transactions: account.transactions)
                                }
                                .presentationDetents([.fraction(0.40), .large])
                                .presentationBackgroundInteraction(.enabled(upThrough: .fraction(0.40)))
                                .interactiveDismissDisabled()
                                .onHeightChange { height in
                                    let fractionHeight = (geometry.size.height - offset) * 0.9
                                    transactionDetent.current = height > fractionHeight ? .large : .fraction
                                }
                                .sheet(isPresented: $shouldPresentAccountSheet) {
                                    AccountView(isPresented: $shouldPresentAccountSheet)
                                }
                            }
                    } else {
                        Color.Cobrowse.background
                            .sheet(isPresented: $shouldPresentAccountSheet) {
                                AccountView(isPresented: $shouldPresentAccountSheet)
                            }
                    }
                }
                .background {
                    Color.Cobrowse.background
                }
            }
            .ignoresSafeArea()
        }
        .toolbar {
            if let session = session.current, session.isActive() {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { session.end() }
                        label: { Image(systemName: "rectangle.badge.xmark") }
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button { shouldPresentAccountSheet = true }
                    label: { Image(systemName: "person.crop.circle") }
            }
        }
        .environmentObject(navigation)
        .environmentObject(transactionDetent)
    }
}

extension Dashboard {
    struct Heading: View {
        
        @EnvironmentObject private var account: Account
        
        var body: some View {
            VStack(spacing: 6) {
                Text("Balance")
                    .font(.title3)
                    .foregroundStyle(Color.Cobrowse.text)
                
                if let accountTotal = account.total.currencyString {
                    Text(accountTotal)
                        .font(.title)
                        .foregroundStyle(Color.Cobrowse.primary)
//                        .redacted()
                }
            }
        }
    }
}
