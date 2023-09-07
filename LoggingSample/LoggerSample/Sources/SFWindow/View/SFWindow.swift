import UIKit
import RxSwift
import RxCocoa

final class SFWindow: UIWindow
{
    private var windowModel: SFWindowModelProtocol!
    private var viewModel: SFWindowViewModel!
    private let disposeBag: DisposeBag = DisposeBag()
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.setupBindings()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    private func setupBindings() {
        self.windowModel = SFWindowModel() as SFWindowModelProtocol
        self.viewModel = SFWindowViewModel(windowModel: self.windowModel)
        
        self.viewModel.rootViewController
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] viewController in
                self?.rootViewController = viewController
            })
            .disposed(by: disposeBag)
    }
}
