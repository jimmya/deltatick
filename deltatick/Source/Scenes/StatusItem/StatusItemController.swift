import Cocoa
import Foundation
import KeychainSwift

protocol StatusItemDisplayLogic: class {
    
    func displayData(_ viewModel: StatusItem.Fetch.ViewModel)
    func displaySync(_ viewModel: StatusItem.Sync.ViewModel)
}

final class StatusItemController: StatusItemDisplayLogic {
    
    var interactor: StatusItemBusinessLogic!
    var router: (StatusItemRoutingLogic & StatusItemDataPassing)!
    
    // MARK: Object lifecycle
    
    private let statusItem: NSStatusItem
    private let keychain: KeychainSwift
    private let startupHelper: AutoStartupHelperLogic
    private let delayHelper: DelayHelperLogic
    
    init(statusItem: NSStatusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength),
         keychain: KeychainSwift = KeychainSwift(),
         startupHelper: AutoStartupHelperLogic = AutoStartupHelper(),
         delayHelper: DelayHelperLogic = DelayHelper()) {
        self.statusItem = statusItem
        self.keychain = keychain
        self.startupHelper = startupHelper
        self.delayHelper = delayHelper
        setup()
        setupStatusItem()
    }
    
    func fetchData() {
        interactor.fetchData(request: StatusItem.Fetch.Request())
    }
    
    func displaySync(_ viewModel: StatusItem.Sync.ViewModel) {
        guard let button = statusItem.button else { return }
        delayHelper.delay(0.5) { [weak self] in
            self?.router.routeToSyncViewController(sourceButton: button)
        }
    }
    
    func displayData(_ viewModel: StatusItem.Fetch.ViewModel) {
        statusItem.button?.title = viewModel.buttonTitle
    }
}

// MARK: Setup
private extension StatusItemController {
    
    func setup() {
        let presenter = StatusItemPresenter(controller: self)
        let interactor = StatusItemInteractor(presenter: presenter)
        let router = StatusItemRouter(controller: self, dataStore: interactor)
        
        self.interactor = interactor
        self.router = router
    }
    
    func setupStatusItem() {
        let menu = NSMenu()
        
        menu.addItem(displayMetricTypeMenuItem())
        menu.addItem(refreshIntervalMenuItem())
        menu.addItem(NSMenuItem.separator())
        
        let syncMenuItem = NSMenuItem(title: "Sync", action: #selector(syncItemSelected), keyEquivalent: "")
        syncMenuItem.target = self
        menu.addItem(syncMenuItem)
        
        let autoStartupMenuItem = NSMenuItem(title: "auto_startup_menu_option".ls, action: #selector(autoStartupItemSelected(_:)), keyEquivalent: "")
        autoStartupMenuItem.state = startupHelper.autoStartupEnabled ? .on : .off
        autoStartupMenuItem.target = self
        menu.addItem(autoStartupMenuItem)
        
        let quitMenuItem = NSMenuItem(title: "quit_menu_option".ls, action: #selector(quit), keyEquivalent: "quit_menu_shortcut".ls)
        quitMenuItem.target = self
        menu.addItem(quitMenuItem)
        statusItem.menu = menu
    }
}

private extension StatusItemController {
    
    func refreshIntervalMenuItem() -> NSMenuItem {
        let item = NSMenuItem(title: "refresh_interval_menu_option".ls, action: nil, keyEquivalent: "")
        let submenu = NSMenu()
        
        let currentInterval = UserDefaults.standard.refreshInterval
        RefreshInterval.allValues.forEach { option in
            let item = NSMenuItem(title: option.title, action: #selector(intervalItemSelected(_ :)), keyEquivalent: "")
            item.tag = option.rawValue
            item.target = self
            if currentInterval == option {
                item.state = .on
            }
            submenu.addItem(item)
        }
        item.submenu = submenu
        return item
    }
    
    func displayMetricTypeMenuItem() -> NSMenuItem {
        let item = NSMenuItem(title: "display_value_menu_option".ls, action: nil, keyEquivalent: "")
        let submenu = NSMenu()
        
        let currentDisplayMetricType = UserDefaults.standard.displayMetricType
        MetricType.allValues.forEach { (metricType) in
            let item = NSMenuItem(title: metricType.title, action: #selector(metricTypeItemSelected(_ :)), keyEquivalent: "")
            item.tag = metricType.rawValue
            item.target = self
            if currentDisplayMetricType == metricType {
                item.state = .on
            }
            submenu.addItem(item)
        }
        item.submenu = submenu
        return item
    }
    
    @objc
    func quit() {
        NSApplication.shared.terminate(self)
    }
    
    @objc
    func syncItemSelected() {
        interactor.requestSync(request: StatusItem.Sync.Request())
    }
    
    @objc
    func intervalItemSelected(_ sender: NSMenuItem) {
        guard let interval = RefreshInterval(rawValue: sender.tag) else {
            return
        }
        sender.menu?.items.forEach({ $0.state = .off })
        sender.state = .on
        let request = StatusItem.UpdateRefreshInterval.Request(interval: interval)
        interactor.updateRefreshInterval(request: request)
    }
    
    @objc
    func metricTypeItemSelected(_ sender: NSMenuItem) {
        guard let metricType = MetricType(rawValue: sender.tag) else {
            return
        }
        sender.menu?.items.forEach({ $0.state = .off })
        sender.state = .on
        let request = StatusItem.UpdateDisplayMetricType.Request(displayMetricType: metricType)
        interactor.updateDisplayMetricType(request: request)
    }
    
    @objc
    func autoStartupItemSelected(_ sender: NSMenuItem) {
        sender.state = sender.state == .on ? .off : .on
        let request = StatusItem.UpdateAutoStartup.Request(autoStartup: sender.state == .on)
        interactor.updateAutoStartup(request: request)
    }
}
