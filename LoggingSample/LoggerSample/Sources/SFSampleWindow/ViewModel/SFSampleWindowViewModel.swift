import UIKit

final class SFSampleWindowViewModel
{
    var inputPlaceholder: String = "メッセージを入力してください."
    var buttonTitle: String = "ログファイルに追記"
    
    var backgroundColor: UIColor? = nil
    
    init()
    {
        let model = SFSampleWindowModel()
        self.backgroundColor = model.setColor()
    }
    
    func buttonTapped(withText textValue: String)
    {
        let message = textValue.isEmpty ? "<テキスト入力値無し>" : textValue
        let loggerModel: SFLoggerModelProtocol = SFLoggerModel(.JP)
        let loggerViewModel: SFLoggerViewModel = SFLoggerViewModel(loggerModel)
        loggerViewModel.outputLogMessages(message, logType: .Infomation)
    }
}
