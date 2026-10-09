// The allowlist.
//
// Every screen the Cobrowse agent is permitted to see is named here, and
// nowhere else. Deleting a line hides that screen; there is no line to add that
// hides one, because hidden is what a screen already is.
//
// No view names itself approved. A screen marks itself a screen, and a pushed
// destination or a sheet is declared through `cobrowseDestination` /
// `cobrowseSheet`; either way this file is what decides.

// MARK: - SwiftUI screens

extension JourneyBView: ApprovedForCobrowse {}

extension MakePaymentView: ApprovedForCobrowse {}
extension MakePaymentPathView: ApprovedForCobrowse {}
extension ExplainMyBillView: ApprovedForCobrowse {}
extension ContactUsView: ApprovedForCobrowse {}

extension SheetsDemoView: ApprovedForCobrowse {}
extension ApprovedSheetView: ApprovedForCobrowse {}
extension RepresentableDemoView: ApprovedForCobrowse {}
//
// Deliberately absent, and worth reading as the point of the demo:
//
//   PaymentDetailsView   — card number, expiry, CVV, cardholder name
//   JourneyAView         — never classified by anyone
//   UnapprovedSheetView  — same shape as the approved sheet, at every depth
//   ContainersDemoView   — a TabView; its tabs decide, not the container
//   UnapprovedTabView    — the tab that stays black beside an approved one

// MARK: - UIKit screens

//extension ViewController: ApprovedForCobrowse {}
