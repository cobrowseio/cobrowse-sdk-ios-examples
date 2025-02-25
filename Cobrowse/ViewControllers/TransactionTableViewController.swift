//
//  TransactionTableViewController.swift
//  Cobrowse
//

import UIKit
import Combine

import CobrowseSDK

class TransactionTableViewController: UITableViewController {

    @IBOutlet weak var sessionButton: UIBarButtonItem!
    
    var selectedTransaction: Transaction?

    /// Displayed cells are stored so parts of them can be redacted when needed.
    var displayedCells = Set<TransactionTableViewCell>()
    
    private var bag = Set<AnyCancellable>()
    
    var transactions: [Date: [Transaction]] = [:] {
        didSet {
            displayedCells.removeAll()
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SheetPresentationDelegate.subscribe(for: sessionButton, store: &bag)
        subscribeToTransactions() 
        
        applyiOS17UISheetPresentationControllerFixIfNeeded()
    }

    @IBAction func sessionButtonWasTapped(_ sender: Any) {
        session.current?.end()
    }
}

// MARK: - CobrowseIORedacted

extension TransactionTableViewController: CobrowseIORedacted {
    
    func redactedViews() -> [UIView] {
        var redacted: [UIView] = []
        for cell in displayedCells {
            redacted += cell.redactedViews()
        }
        return redacted
    }
}

// MARK: - Subscriptions

extension TransactionTableViewController {
    
    private func subscribeToTransactions() {
        account.$transactions.sink { transactions in
            self.transactions = Dictionary(grouping: transactions, by: { $0.date.startOfMonth })
        }
        .store(in: &bag)
    }
}

// MARK: - UITableViewDataSource

extension TransactionTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        transactions.keys.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        transactions.sectionTitle(for: section)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        transactions.for(section).count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TransactionTableViewCell = tableView.dequeueReusableCell(.transaction, for: indexPath)!

        guard let transaction = transactions.transaction(for: indexPath)
            else { return cell }

        cell.titleLabel.text = transaction.title
        cell.subtitleLabel.text = transaction.subtitle
        cell.amountLabel.text = transaction.amount.currencyString
        cell.iconImageView.image = transaction.category.icon
        cell.iconImageView.tintColor = transaction.category.color

        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let transactionCell = cell as? TransactionTableViewCell
            else { return }

        displayedCells.insert(transactionCell)
    }

    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let transactionCell = cell as? TransactionTableViewCell
            else { return }

        displayedCells.remove(transactionCell)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        selectedTransaction = transactions.transaction(for: indexPath)
        performSegue(to: .transaction)
    }
}

// MARK: - Segue

extension TransactionTableViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard segue.identifier == Segue.transaction,
              let webViewController = segue.destination as? WebViewController,
              let transaction = selectedTransaction
        else { return }
        
        var url = URL(string: "https://cobrowseio.github.io/cobrowse-sdk-ios-examples")!
        url.append(queryItems: [
            .init(name: "title", value: transaction.title),
            .init(name: "subtitle", value: transaction.subtitle),
            .init(name: "amount", value: transaction.amount.currencyString),
            .init(name: "category", value: transaction.category.rawValue),
            .init(name: "theme", value: CobrowseIO.theme)
        ])
        
        webViewController.url = url
    }
}

fileprivate extension CobrowseIO {
    
    static var theme: String {
        switch UIScreen.main.traitCollection.userInterfaceStyle {
            case .dark : return "dark"
            default: return "light"
        }
    }
}

// MARK: - iOS 17 fix
extension TransactionTableViewController {
    
    /// In iOS 17 the UISheetPresentationController stops panning gestures triggering.
    /// Removing the _handleExteriorPan gesture allows for the chart to be interacted with.
    private func applyiOS17UISheetPresentationControllerFixIfNeeded() {
        
        if ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 17 {
            if let keyWindow = UIWindow.keyWindow {
                keyWindow.gestureRecognizers = keyWindow.gestureRecognizers?.filter { gesture in
                    !(gesture is UIPanGestureRecognizer) || gesture.view != keyWindow
                }
            }
        }
    }
}
