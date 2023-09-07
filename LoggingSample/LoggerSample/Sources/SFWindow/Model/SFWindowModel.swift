import UIKit

protocol SFWindowModelProtocol: AnyObject
{
    init()
    func openWindow(_ viewType: SFWindowModel.ViewType) -> UIViewController?
}

final class SFWindowModel: SFWindowModelProtocol
{
    enum ViewType
    {
        case None
        case SFSampleWindow
    }
    
    init()
    {
    }
    
    func openWindow(_ viewType: ViewType) -> UIViewController?
    {
        switch viewType {
        case .None:
            fatalError("未定義です。")
        case .SFSampleWindow:
            return SFSampleWindow()
        }
    }
    
    deinit
    {
    }
}
