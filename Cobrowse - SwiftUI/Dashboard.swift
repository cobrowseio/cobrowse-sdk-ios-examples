//
//  Dashboard.swift
//  Cobrowse - SwiftUI
//

import SwiftUI
import Charts
import CobrowseIO

extension Transaction {
    enum Detent {
        case collapsed, fraction, large
    }
}

extension Transaction.Detent {
    class State: ObservableObject {
        @Published var current: Transaction.Detent
        
        init(_ detent: Transaction.Detent) {
            self.current = detent
        }
        
        func `is`(_ detent: Transaction.Detent) -> Bool {
            current == detent
        }
    }
}

struct Dashboard: View {
    
    @State var shouldPresentAccountSheet = false
    
    @State var shouldPresentTransactionsSheet: Bool
    @State private var tansactionDetent = Transaction.Detent.State(.collapsed)
    
    @EnvironmentObject private var account: Account
    @EnvironmentObject private var session: Session
    
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
                                Transaction.List(transactions: account.transactions)
                                    .presentationDetents([.fraction(0.40), .large])
                                    .presentationBackgroundInteraction(.enabled(upThrough: .fraction(0.40)))
                                    .interactiveDismissDisabled()
                                    .onHeightChange { height in
                                        let fractionHeight = (geometry.size.height - offset) * 0.9
                                        tansactionDetent.current = height > fractionHeight ? .large : .fraction
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
        .environmentObject(tansactionDetent)
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

struct PieChart: View {
    
    let recentTransactions: [Transaction]
    
    private var recentTransactionsByCategory: [Dictionary<Transaction.Category, [Transaction]>.Element] {
        Dictionary(grouping: recentTransactions, by: { $0.category })
            .sorted { $0.key.rawValue < $1.key.rawValue }
    }
    
    @State private var angleSelection: Double?
    @State private var selectedCategory: Transaction.Category?
    
    var body: some View {
        Chart {
            ForEach(recentTransactionsByCategory, id: \.key) { (category, transactions) in
                let total = transactions.reduce(0.0) { $0 + $1.amount }
                
                SectorMark(angle: .value(category.rawValue, total),
                           innerRadius: .ratio(0.5),
                           outerRadius: selectedCategory == category ? .ratio(1.0) : .ratio(0.88),
                           angularInset: 2)
                .foregroundStyle(by: .value(category.rawValue, category.rawValue))
                .annotation(position: .overlay, alignment: .center) {
                    category.icon
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 35, height: 35)
                        .foregroundStyle(Color.white)
                }
            }
        }
        .chartBackground(content: { proxy in
            VStack {
                Text("Spent")
                    .font(.subheadline)
                    .foregroundStyle(Color.Cobrowse.text)
                
                if let totalSpent = recentTransactions.totalSpent.currencyString {
                    Text(totalSpent)
                        .font(.title)
                        .foregroundStyle(Color.Cobrowse.primary)
//                        .redacted()
                }
                
                Text("This month")
                    .font(.subheadline)
                    .foregroundStyle(Color.Cobrowse.text)
            }
        })
        .chartLegend(.hidden)
        .chartForegroundStyleScale(domain: .automatic, range: recentTransactionsByCategory.map { $0.key.color })
        .chartAngleSelection(value: $angleSelection)
        .onChange(of: angleSelection) { _, newValue in
            guard let newValue
                else { return }
            
            selectedCategory = category(for: newValue)
        }
    }
    
    private func category(for value: Double) -> Transaction.Category? {
        var accumulatedCount = 0.0
        
        let category = Array(recentTransactionsByCategory).first { (category, transactions) in
            let total = transactions.reduce(0.0) { $0 + $1.amount }
            accumulatedCount += total
            return value <= accumulatedCount
        }
        
        return category?.key
    }
}

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
            NavigationStack {
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
                .toolbar {
                    if let session = session.current, session.isActive(), transactionDetent.is(.large) {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button { session.end() }
                                label: { Image(systemName: "rectangle.badge.xmark") }
                        }
                    }
                }
            }
        }
        
        init(transactions: [Transaction]) {
            self.transactions = transactions
        }
    }
}

extension Transaction {
    
    struct Item: View {
        private let transaction: Transaction
        
        var body: some View {
            NavigationLink(destination: Detail(for: transaction)) {
                HStack {
                    transaction.category.icon
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(4)
                        .frame(width: 40, height: 40)
                        .foregroundColor(transaction.category.color)
                    
                    VStack(alignment:.leading, spacing: 2) {
                        Text(transaction.title)
                            .font(.body)
                            .foregroundStyle(Color.Cobrowse.text)
//                            .redacted()
                        
                        Text(transaction.subtitle)
                            .font(.caption2)
                            .foregroundStyle(Color.Cobrowse.text)
//                            .redacted()
                    }
                    Spacer()
                    if let amount = transaction.amount.currencyString {
                        Text(amount)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.Cobrowse.primary)
//                            .redacted()
                    }
                }
            }
        }
        
        init(for transaction: Transaction) {
            self.transaction = transaction
        }
    }
}

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

import WebKit

struct WebView: UIViewRepresentable {
    
    let url: URL
    var onNavigation: ((URL) -> Void) = { _ in }
    
    private let webView = WKWebView()
    private let delegate = Delegate()
    
    func makeUIView(context: Context) -> WKWebView {
        webView.navigationDelegate = delegate
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        delegate.onNavigation = onNavigation
        
        webView.load(URLRequest(url: url))
    }
}

extension WebView {
    
    class Delegate: NSObject, WKNavigationDelegate {
        
        var onNavigation: ((URL) -> Void) = { _ in }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
            
            guard let url = navigationAction.request.url,
                  let scheme = url.scheme
            else { return .allow }

            switch scheme {
                case "tel", "sms", "facetime", "mailto":
                    DispatchQueue.main.async {
                        UIApplication.shared.open(url)
                    }
                
                    return .cancel
                
                default: break
            }

            if navigationAction.navigationType != .other {
                DispatchQueue.main.async {
                    self.onNavigation(url)
                }
                
                return .cancel
            }

            return .allow
        }
    }
}

extension WebView {
    
    func onNavigation(perform action: @escaping (URL) -> Void) -> WebView {
        var webView = self
        webView.onNavigation = action
        return webView
    }
}

struct AccountView: View {
    
    @EnvironmentObject private var session: Session
    @EnvironmentObject private var account: Account
    
    @Binding var isPresented: Bool

    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(height: 120)
                    .foregroundColor(Color.Cobrowse.primary)
                
                VStack(spacing: 2) {
                    Text("Frank Spensor")
                        .font(.largeTitle)
                        .foregroundStyle(Color.Cobrowse.text)
//                        .redacted()
                    
                    Text(verbatim: "f.spencer@demo.com")
                        .font(.title2)
                        .foregroundStyle(Color.Cobrowse.text)
//                        .redacted()
                }
                
                Color.Cobrowse.background.ignoresSafeArea()
                
                VStack {
                    
                    if !(session.current?.isActive() ?? false) {
                        if let code = session.current?.code() {
                            let string = "\(code.prefix(3)) - \(code.suffix(3))"
                            Text(string)
                                .font(.largeTitle)
                                .foregroundStyle(Color.Cobrowse.text)
                        }
                        
                        Button { CobrowseIO.instance().createSession() }
                            label: {
                                Text("Get session code")
                                    .frame(minWidth: 200)
                            }
                        .buttonStyle(.borderedProminent)
                        
                        NavigationLink(destination: AgentPresentView(isPresented: $isPresented)) {
                            Text("Agent Present Mode")
                                .frame(minWidth: 200)
                                .foregroundColor(Color.Cobrowse.primary)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color.Cobrowse.secondary)

                        
                        
                    }
                    Button("Logout") {
                        account.isSignedIn = false
                    }
                    .padding(.top, 8)

                }
                .padding(.bottom, 20)
            }
            .background { Color.Cobrowse.background.ignoresSafeArea() }
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if let session = session.current, session.isActive() {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button { session.end() }
                            label: { Image(systemName: "rectangle.badge.xmark") }
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button { isPresented = false }
                        label: { Image(systemName: "xmark") }
                }
            }
        }
        .onDisappear {
            guard let current = session.current, !current.isActive()
            else { return }
            
            session.current = nil
        }
    }
}

struct AgentPresentView: View {
    
    @EnvironmentObject private var session: Session
    
    @Binding var isPresented: Bool
    
    @State var code: String?
    @State var shouldShake = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                if let session = session.current, session.isActive() {
                    Text("You are now presenting")
                        .font(.title2)
                        .foregroundStyle(Color.Cobrowse.text)
                    
                    Image(systemName: "rectangle.inset.filled.and.person.filled")
                        .font(.system(size: 120, weight: .thin))
                        .foregroundColor(.Cobrowse.primary)
                        
                    
                    Color.Cobrowse.background
                } else {
                    VStack(spacing: 16) {
                        Text("Please enter your present code")
                            .font(.title2)
                            .foregroundStyle(Color.Cobrowse.text)
                        
                        CodeInput(code: $code)
                            .shake($shouldShake) {
                                shouldShake = false
                                code = nil
                            }
                            .onChange(of: code, { _, _ in
                                guard let code = code
                                else { return }
                                
                                // Commented out as this needs changes made in the unrelased, local Cobrowse iOS SDK
//                                Task {
//                                    do {
//                                        let agentSession = try await CobrowseIO.instance().getSessions(code)
//                                        agentSession.setCapabilities([])
//                                    } catch(let error) {
//                                        print(error)
//                                        shouldShake = true
//                                    }
//                                }
                            })
                        
                        Color.Cobrowse.background
                    }
                }
            }
            .padding(.top, 30)
            .background { Color.Cobrowse.background.ignoresSafeArea() }
            .navigationTitle("Agent Present")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if let session = session.current, session.isActive() {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button { session.end() }
                    label: { Image(systemName: "rectangle.badge.xmark") }
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button { isPresented = false }
                label: { Image(systemName: "xmark") }
                }
            }
        }
    }
}

struct CodeInput: View {
    
    @Binding var code: String?
    @State private var codeValues = Array(repeating: "", count: 6)
    @State private var isDisabled = false
    @FocusState private var focusedInput: Int?
    
    var body: some View {
        HStack(spacing: 20) {
            ForEach(0..<6, id: \.self) { index in
                Input(index: index, value: $codeValues[index]) { textField in
                    codeValues[index] = textField.text ?? ""
                    focusedInput = index + 1
                }
                onFocus: { textField in
                    let codeIndex = codeValues.count - 1
                    let nextIndex = min(index + 1, codeIndex)

                    guard !codeValues[index].isEmpty, codeValues[nextIndex].isEmpty
                        else { return }
                    
                    textField.text = nil
                    codeValues[index] = ""
                }
                onBackspace: { textField in
                    let nextIndex = min(index + 1, codeValues.count - 1)

                    guard !codeValues[index].isEmpty else {
                        focusedInput = index - 1
                        return
                    }

                    let isNextIndexNotEmpty = !codeValues[nextIndex].isEmpty
                    let isLastCodeNotEmpty = (codeValues.last != nil && !codeValues.last!.isEmpty)

                    if isNextIndexNotEmpty || isLastCodeNotEmpty {
                        textField.text = nil
                        codeValues[index] = ""
                    } else {
                        codeValues[index] = ""
                        focusedInput = index - 1
                    }
                }
                .disabled(isDisabled)
                .focused($focusedInput, equals: index)
                .aspectRatio(1, contentMode: .fit)
            }
        }
        .onAppear {
            focusedInput = 0
        }
        .onChange(of: code, { _, _ in
            if code == nil {
                codeValues = Array(repeating: "", count: 6)
                isDisabled = false
                focusedInput = 0
            }
        })
        .onChange(of: codeValues, { _, _ in
            if codeValues.allSatisfy({ !$0.isEmpty }) {
                isDisabled = true
                code = codeValues.joined()
            }
        })
    }
}

struct Input: UIViewRepresentable {
    
    let index: Int
    
    @Binding var value: String

    var onDigitInput: ((CodeTextField) -> Void)?
    var onFocus: ((CodeTextField) -> Void)?
    var onBackspace: ((CodeTextField) -> Void)?
    
    func makeUIView(context: Context) -> CodeTextField {
        let textField = CodeTextField()
        
        textField.text = value
        textField.tag = index
        textField.placeholder = "\(index + 1)"
        textField.onDigitInput = { _ in self.onDigitInput?(textField) }
        textField.onFocus = { _ in self.onFocus?(textField) }
        textField.onBackspace = { _ in self.onBackspace?(textField) }
            
        return textField
    }
    
    func updateUIView(_ textField: CodeTextField, context: Context) {
        textField.text = value
    }
}

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

struct OnHeightChange: ViewModifier {
    
    var didChange: (_ height: Double) -> Void
    
    init(_ didChange: @escaping (_: Double) -> Void) {
        self.didChange = didChange
    }
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onChange(of: geometry.size.height) { _, height in
                            didChange(height)
                        }
                }
            )
    }
}

extension View {
    
    func onHeightChange(_ didChange: @escaping (_ height: Double) -> Void) -> some View {
        self.modifier(OnHeightChange(didChange))
    }
}

struct Shake<Content: View>: View {
    /// Set to true in order to animate
    @Binding var shake: Bool
    /// How many times the content will animate back and forth
    var repeatCount = 3
    /// Duration in seconds
    var duration = 0.8
    /// Range in pixels to go back and forth
    var offsetRange = 10.0

    @ViewBuilder let content: Content
    var onCompletion: (() -> Void)?

    @State private var xOffset = 0.0

    var body: some View {
        content
            .offset(x: xOffset)
            .onChange(of: shake) { shouldShake in
                guard shouldShake else { return }
                Task {
                    await animate()
                    shake = false
                    onCompletion?()
                }
            }
    }

    // Obs: some of factors must be 1.0.
    private func animate() async {
        let factor1 = 0.9
        let eachDuration = duration * factor1 / CGFloat(repeatCount)
        for _ in 0..<repeatCount {
            await backAndForthAnimation(duration: eachDuration, offset: offsetRange)
        }

        let factor2 = 0.1
        await animate(duration: duration * factor2) {
            xOffset = 0.0
        }
    }

    private func backAndForthAnimation(duration: CGFloat, offset: CGFloat) async {
        let halfDuration = duration / 2
        await animate(duration: halfDuration) {
            self.xOffset = offset
        }

        await animate(duration: halfDuration) {
            self.xOffset = -offset
        }
    }
}

extension View {
    func shake(_ shake: Binding<Bool>,
               repeatCount: Int = 3,
               duration: CGFloat = 0.8,
               offsetRange: CGFloat = 10,
               onCompletion: (() -> Void)? = nil) -> some View {
        Shake(shake: shake,
              repeatCount: repeatCount,
              duration: duration,
              offsetRange: offsetRange) {
            self
        } onCompletion: {
            onCompletion?()
        }
    }

    func animate(duration: CGFloat, _ execute: @escaping () -> Void) async {
        await withCheckedContinuation { continuation in
            withAnimation(.linear(duration: duration)) {
                execute()
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                continuation.resume()
            }
        }
    }
}

extension Color {
    
    enum Cobrowse {
        static var primary: Color {
            Color(red: 88 / 255, green: 13 / 255, blue: 245 / 255)
        }
        
        static var secondary: Color {
            Color(red: 224 / 255, green: 245 / 255, blue: 127 / 255, opacity: 1)
        }
        
        static var background: Color {
            Color(red: 248 / 255, green: 247 / 255, blue: 254 / 255)
        }
        
        static var text: Color {
            Color(red: 85 / 255, green: 85 / 255, blue: 85 / 255)
        }
    }
}
