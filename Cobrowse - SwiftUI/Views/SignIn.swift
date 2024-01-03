//
//  SignIn.swift
//  Cobrowse - SwiftUI
//
//  Created by Ste Prescott on 03/01/2024.
//

import SwiftUI

struct SignIn: View {
    
    @EnvironmentObject private var session: Session
    @EnvironmentObject private var account: Account
    
    @State var username = ""
    @State var password = ""
    
    @FocusState private var focusField: Field?
    
    private var invalidField: Field? {
        switch (username.isEmpty, password.isEmpty) {
            case (true, _): return .username
            case (_, true): return .password
            default: return nil
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                    .frame(height:140)
                
                if let icon = Locale.current.currency?.icon {
                    icon
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(maxWidth: 200)
                        .padding()
                        .foregroundColor(.Cobrowse.primary)
                }
                
                Text("Please enter your details")
                    .foregroundStyle(Color.Cobrowse.text)
                
                VStack(spacing: 4) {
                    TextField("Username", text: $username)
                        .textFieldStyle(.roundedBorder)
                        .multilineTextAlignment(.center)
                        .focused($focusField, equals: .username)
                        .onSubmit { signIn() }
//                        .redacted()
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                        .multilineTextAlignment(.center)
                        .focused($focusField, equals: .password)
                        .onSubmit { signIn() }
//                        .redacted()
                }
                .padding(.horizontal, 16)
                .frame(maxWidth: 500)
                
                Button {
                    signIn()
                } label: {
                    Text("Sign in")
                        .fontWeight(.semibold)
                        .frame(minWidth: 120)
                }
                .buttonStyle(.borderedProminent)
                .disabled(invalidField != nil)
                .padding(.top, 16)
                
                Spacer()
            }
            .background {
                Color.Cobrowse.background
                    .ignoresSafeArea()
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
        }
    }
    
    func signIn() {
        focusField = invalidField
        
        guard invalidField == nil
            else { return }
        
        account.isSignedIn = true
    }
}

extension SignIn {
    
    enum Field {
        case username
        case password
    }
}
