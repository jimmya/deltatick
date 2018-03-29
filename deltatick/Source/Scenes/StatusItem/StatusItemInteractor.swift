import Foundation
import KeychainSwift
import ServiceManagement

protocol StatusItemBusinessLogic {
    
    func fetchData(request: StatusItem.Fetch.Request)
    func updateRefreshInterval(request: StatusItem.UpdateRefreshInterval.Request)
    func updateDisplayMetricType(request: StatusItem.UpdateDisplayMetricType.Request)
    func updateAutoStartup(request: StatusItem.UpdateAutoStartup.Request)
    func requestSync(request: StatusItem.Sync.Request)
    func requestReset(request: StatusItem.Reset.Request)
}

protocol StatusItemDataStore {
    
    var portfolio: Portfolio? { get }
}

final class StatusItemInteractor: StatusItemBusinessLogic, StatusItemDataStore {
    
    private(set) var portfolio: Portfolio?
    
    private let presenter: StatusItemPresentationLogic
    private let worker: StatusItemWorkerLogic
    private let keychain: KeychainSwift
    private let userDefaults: UserDefaults
    private let startupHelper: AutoStartupHelperLogic
    private let timerType: Timer.Type
    private var timer: Timer?
    
    init(presenter: StatusItemPresentationLogic, 
         worker: StatusItemWorkerLogic = StatusItemWorker(),
         keychain: KeychainSwift = KeychainSwift(),
         userDefaults: UserDefaults = UserDefaults.standard,
         startupHelper: AutoStartupHelperLogic = AutoStartupHelper(),
         timerType: Timer.Type = Timer.self) {
        self.presenter = presenter
        self.worker = worker
        self.keychain = keychain
        self.userDefaults = userDefaults
        self.startupHelper = startupHelper
        self.timerType = timerType
    }
    
    func fetchData(request: StatusItem.Fetch.Request) {
        presenter.presentLoadingIndicator()
        if keychain.authToken == nil {
            register(request: request)
        } else if !userDefaults.hasSynced {
            presenter.presentSync(StatusItem.Sync.Response())
        } else {
            performFetchData()
            scheduleDataTimer()
        }
    }
    
    func updateRefreshInterval(request: StatusItem.UpdateRefreshInterval.Request) {
        userDefaults.refreshInterval = request.interval
        scheduleDataTimer()
    }
    
    func updateDisplayMetricType(request: StatusItem.UpdateDisplayMetricType.Request) {
        userDefaults.displayMetricType = request.displayMetricType
        if let portfolio = portfolio {
            let response = StatusItem.Fetch.Response(portfolio: portfolio, displayMetricType: request.displayMetricType)
            presenter.presentData(response)
        }
    }
    
    func updateAutoStartup(request: StatusItem.UpdateAutoStartup.Request) {
        startupHelper.setAutoStartupEnabled(request.autoStartup)
    }
    
    func requestSync(request: StatusItem.Sync.Request) {
        presenter.presentSync(StatusItem.Sync.Response())
    }
    
    func requestReset(request: StatusItem.Reset.Request) {
        keychain.authToken = nil
        userDefaults.hasSynced = false
        fetchData(request: StatusItem.Fetch.Request())
    }
}

private extension StatusItemInteractor {
    
    func scheduleDataTimer() {
        let refreshInterval = userDefaults.refreshInterval ?? RefreshInterval.oneMinute
        timer = timerType.scheduledTimer(withTimeInterval: refreshInterval.timeInterval, repeats: true, block: { [weak self] (_) in
            self?.performFetchData()
        })
    }
    
    func register(request: StatusItem.Fetch.Request) {
        worker.register(success: { [weak self] (device) in
            self?.keychain.authToken = device.token
            self?.fetchData(request: request)
            }, failure: { [weak self] (error) in
                let errorResponse = StatusItem.Error.Response(error: error)
                self?.presenter.presentError(errorResponse)
        })
    }
    
    func performFetchData() {
        worker.getPortfolio(success: { [weak self] (portfolio) in
            self?.portfolio = portfolio
            let displayValue = self?.userDefaults.displayMetricType ?? MetricType.worth
            let response = StatusItem.Fetch.Response(portfolio: portfolio, displayMetricType: displayValue)
            self?.presenter.presentData(response)
        }) { [weak self] (error) in
            let errorResponse = StatusItem.Error.Response(error: error)
            self?.presenter.presentError(errorResponse)
        }
    }
}
