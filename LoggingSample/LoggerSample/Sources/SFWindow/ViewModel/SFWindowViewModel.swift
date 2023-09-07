import UIKit
import RxSwift
import RxCocoa

final class SFWindowViewModel
{
    private var _rootViewController = BehaviorSubject<UIViewController?>(value: nil)
    
    var rootViewController: Observable<UIViewController?> {
        return _rootViewController.asObservable()
    }
    
    private let windowModel: SFWindowModelProtocol
    
    init(windowModel: SFWindowModelProtocol)
    {
        self.windowModel = windowModel
        self.displayViewController(windowModel.openWindow(.SFSampleWindow))
        
        let loggerModel: SFLoggerModelProtocol = SFLoggerModel(.JP)
        let loggerViewModel: SFLoggerViewModel = SFLoggerViewModel(loggerModel)
        loggerViewModel.loggerStartLogMessage()
        loggerViewModel.outputLogMessages("Start Application.", logType: .Infomation)
    }
    
    private func displayViewController(_ viewController: UIViewController?) {
        self._rootViewController.onNext(viewController)
    }
}
