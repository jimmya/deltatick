import Cocoa

protocol SyncDisplayLogic: class {
    
    func displayMigrationToken(viewModel: Sync.MigrationToken.ViewModel)
    func displayLoadingStatus(viewModel: Sync.Loading.ViewModel)
    func displayMigrationResult(viewModel: Sync.Migration.ViewModel)
}

protocol SyncViewControllerDelegate: class {
    
    func viewControllerRequestsPoverClose(_ viewController: SyncViewController)
}

final class SyncViewController: NSViewController, SyncDisplayLogic {
    
    @IBOutlet weak var codeImageView: NSImageView!
    @IBOutlet weak var loadingLabel: NSTextField!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    weak var delegate: SyncViewControllerDelegate?
    
    var interactor: SyncBusinessLogic!
    var router: (SyncRoutingLogic & SyncDataPassing)!
    
    // MARK: Object lifecycle
    
    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
    
    // MARK: Setup
    
    private func setup() {
        let presenter = SyncPresenter(viewController: self)
        let interactor = SyncInteractor(presenter: presenter)
        let router = SyncRouter(viewController: self, dataStore: interactor)
        
        self.interactor = interactor
        self.router = router
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        codeImageView.wantsLayer = true
        codeImageView.layer?.backgroundColor = NSColor.lightGray.cgColor
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        interactor.requestMigrationToken(Sync.MigrationToken.Request())
    }
    
    // MARK: - Actions
    
    @IBAction func cancelButtonPressed(sender: NSButton) {
        delegate?.viewControllerRequestsPoverClose(self)
    }
    
    func displayMigrationToken(viewModel: Sync.MigrationToken.ViewModel) {
        let size = codeImageView.bounds.size
        if let codeImage = NSImage.createSyncImageForCode(viewModel.code, size: size) {
            codeImageView.image = codeImage
        }
    }
    
    func displayLoadingStatus(viewModel: Sync.Loading.ViewModel) {
        loadingLabel.stringValue = viewModel.message
        progressIndicator.startAnimation(self)
    }
    
    func displayMigrationResult(viewModel: Sync.Migration.ViewModel) {
        if viewModel.shouldClose {
            delegate?.viewControllerRequestsPoverClose(self)
        } else if let message = viewModel.message {
            loadingLabel.stringValue = message
            progressIndicator.stopAnimation(self)
        }
    }
}
