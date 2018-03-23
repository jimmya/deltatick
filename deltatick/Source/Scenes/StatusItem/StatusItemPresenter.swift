import Foundation

protocol StatusItemPresentationLogic {
  
    func presentLoadingIndicator()
    func presentSync(_ response: StatusItem.Sync.Response)
    func presentError(_ response: StatusItem.Error.Response)
    func presentData(_ response: StatusItem.Fetch.Response)
}

final class StatusItemPresenter: StatusItemPresentationLogic {
    
    private weak var controller: StatusItemDisplayLogic?
    private let numberFormatter: NumberFormatter
    
    init(controller: StatusItemDisplayLogic,
         numberFormatter: NumberFormatter = NumberFormatter()) {
        self.controller = controller
        self.numberFormatter = numberFormatter
    }
    
    func presentLoadingIndicator() {
        controller?.displayData(StatusItem.Fetch.ViewModel(buttonTitle: "status_item_loading".ls))
    }
    
    func presentSync(_ response: StatusItem.Sync.Response) {
        controller?.displaySync(StatusItem.Sync.ViewModel())
    }
    
    func presentError(_ response: StatusItem.Error.Response) {
        
    }
    
    func presentData(_ response: StatusItem.Fetch.Response) {
        let value = response.portfolio.balance.valueForMetricType(response.displayMetricType)
        numberFormatter.locale = Locale.current
        numberFormatter.numberStyle = .currency
        if response.displayMetricType.isBTCValue {
            numberFormatter.currencySymbol = "₿"
        } else {
            numberFormatter.currencySymbol = nil
        }
        let title: String
        if response.displayMetricType.isPercentage {
            title = String(format: "%.2f%@", value, "%")
        } else if let numberTitle = numberFormatter.string(from: value as NSNumber) {
            title = numberTitle
        } else {
            title = "status_item_unknown".ls
        }
        controller?.displayData(StatusItem.Fetch.ViewModel(buttonTitle: title))
    }
}
