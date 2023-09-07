import UIKit
//import RxSwift
//import RxCocoa

final class SFLoggerViewModel
{
    private let loggerModel: SFLoggerModelProtocol
    
    init(_ loggerModel: SFLoggerModelProtocol)
    {
        self.loggerModel = loggerModel
    }
    
    func loggerStartLogMessage()
    {
        let logMessage: String = self.loggerModel.createLogMessage("以下のファイルにログの記録を開始します。\n ____________________ \n\(self.loggerModel.FilePath!)\n ____________________ \n", logType: .Infomation, error: nil, file: #file, function: #function, line: #line)
        print(logMessage)
    }
    
    func outputLogMessages(_ message: String = "", logType: SFLoggerModel.LogType = .None, error: Error? = nil, file: String = #file, function: String = #function, line: Int = #line)
    {
        let logMessage: String = self.loggerModel.createLogMessage(message, logType: logType, error: error, file: file, function: function, line: line)
        self.loggerModel.writeLogToFile(logMessage)
        print(logMessage)
    }
    
    func createLogMessage(_ message: String = "", logType: SFLoggerModel.LogType = .None, error: Error? = nil, file: String = #file, function: String = #function, line: Int = #line) -> String
    {
        let logMessage: String = self.loggerModel.createLogMessage(message, logType: logType, error: error, file: file, function: function, line: line)
        return logMessage
    }
}
