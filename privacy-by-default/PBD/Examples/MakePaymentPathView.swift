//
//  MakePaymentPathView.swift
//  PBD
//
//  Created by Ste on 29/08/2026.
//

import SwiftUI
import CobrowseSDK

struct CardDetailsRoute: Hashable {}

struct ExplainBillRoute: Hashable {}

/// `NavigationStack` driven by a typed path, as a contrast with
/// `MakePaymentView`'s boolean destinations.
///
/// The single `cobrowseRedacted()` below goes the other way: it hides the
/// amount field *because* the screen around it is revealed.
struct MakePaymentPathView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var path = NavigationPath()
    @State private var amount: String = "0.00"

    var body: some View {
        NavigationStack(path: $path) {
            Form {
                Section("Amount") {
                    HStack {
                        Text("£")
                            .foregroundStyle(.secondary)
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                            .cobrowseRedacted()
                    }
                }

                Section {
                    Button {
                        path.append(CardDetailsRoute())
                    } label: {
                        Text("Continue")
                            .frame(maxWidth: .infinity)
                            .bold()
                    }
                    .buttonStyle(.borderedProminent)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)

                    Button {
                        path.append(ExplainBillRoute())
                    } label: {
                        Text("Explain My Bill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
            }
            .cobrowseScreen(Self.self)
            .navigationTitle("Make Payment (path)")
            .navigationBarTitleDisplayMode(.inline)
            .cobrowseDestination(for: CardDetailsRoute.self) { _ in
                PaymentDetailsView(amount: amount) { path.removeLast() }
            }
            .cobrowseDestination(for: ExplainBillRoute.self) { _ in
                ExplainMyBillView()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .frameworkPill()
        }
    }
}
