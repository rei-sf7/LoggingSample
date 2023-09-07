import UIKit

protocol SFLoggerModelProtocol: AnyObject
{
    var FilePath: String? { get }
    init(_ locale: SFLoggerModel.LogLocale)
    func createLogMessage(_ message: String, logType: SFLoggerModel.LogType, error: Error?, file: String, function: String, line: Int) -> String
    func writeLogToFile(_ message: String)
}

final class SFLoggerModel: SFLoggerModelProtocol
{
    
    private let dateFormat: String = "yyyy-MM-dd HH:mm:ss.SSS Z"
    
    private var locale: LogLocale = .None
    
    private var deviceType: DeviceType = .None
    
    private var fileName: String = "myLogFile.log"
    
    private var filePath: String? = nil
    
    public var FilePath: String? {
        get {
            return self.filePath
        }
    }
    
    enum LogLocale
    {
        case None
        case JP
        case US
    }
    
    enum LogType
    {
        case None
        case Infomation
        case Warning
        case Error
        case Test
    }
    
    enum DeviceType
    {
        case None
        case Simulator
        case RealDevice
    }
    
    init (_ locale: SFLoggerModel.LogLocale)
    {
        self.locale = locale
#if targetEnvironment(simulator)
        self.deviceType = .Simulator
#else
        self.deviceType = .RealDevice
#endif
        do {
            try self.ensureDocumentsDirectoryExists()
        } catch let error as NSError {
            fatalError("エラーが発生しました: \(error.localizedDescription)")
        }
    }
    
    private func nowDateTime() -> String
    {
        let formatter = DateFormatter()
        switch self.locale
        {
        case .None:
            fatalError("先にinit()で初期化してください。")
        case .JP:
            formatter.locale = Locale(identifier: "ja_JP")
            formatter.timeZone = TimeZone(identifier:  "Asia/Tokyo")
        case .US:
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(identifier: "America/New_York")
        }
        
        formatter.dateFormat = self.dateFormat
        return formatter.string(from: Date())
    }
    
    private func logTypePrintFormat(_ logType: SFLoggerModel.LogType) -> String
    {
        switch logType
        {
        case .None:
            return "None"
        case .Infomation:
            return "Info"
        case .Warning:
            return "Warning"
        case .Error:
            return "Error"
        case .Test:
            return "Test"
        }
    }
    
    public func createLogMessage(_ message: String, logType: SFLoggerModel.LogType = .None, error: Error? = nil, file: String, function: String, line: Int) -> String
    {
        var logMessage: String = nowDateTime()
        
        if let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
        {
            logMessage += " [B:\(bundleName)]"
        }
        
        if let swiftFile = file.split(separator: "/").last?.split(separator: ".").first
        {
            logMessage += " [F:\(String(swiftFile))]"
        }
        
        logMessage += " <\(function)>"
        logMessage += " [L: \(line)] "
        if let logType = logType != .None ? logTypePrintFormat(logType) : nil
        {
            logMessage += " [\(logType)] "
        }
        logMessage += message
        
        if let error = error
        {
            logMessage += "\n\(error)"
        }
        
        return logMessage
    }
    
    private func getDocumentsDirectory() -> URL? {
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            return documentsDirectory
        }
        return nil
    }
    
    private func ensureDocumentsDirectoryExists() throws
    {
        // ドキュメントディレクトリの存在チェック
        guard let documentsDirectory: URL = self.getDocumentsDirectory() else
        {
            fatalError("ドキュメントディレクトリを取得できませんでした。")
        }
        self.filePath = documentsDirectory.appendingPathComponent(self.fileName).path
    }
    
    private func createLogFile() throws
    {
        // ファイル作成
        if !FileManager.default.fileExists(atPath: self.filePath!)
        {
            if !FileManager.default.createFile(atPath: self.filePath!, contents: nil, attributes: nil)
            {
                fatalError("ファイルを作成できませんでした。")
            }
        }
    }
    
    public func writeLogToFile(_ message: String)
    {
        do {
            try self.createLogFile()
        } catch let error as NSError {
            fatalError("エラーが発生しました: \(error.localizedDescription)")
        }
        switch self.deviceType {
        case .None:
            fatalError("先にinit()で初期化してください。")
        case .Simulator:
            if let fileHandle = FileHandle(forWritingAtPath: self.filePath!)
            {
                fileHandle.seekToEndOfFile()
                if let messageData = "\(message)\n".data(using: .utf8) {
                    fileHandle.write(messageData)
                }
                fileHandle.closeFile()
            } else {
                fatalError("ファイルをオープンできませんでした。")
            }
            break
        case .RealDevice:
            break
        }
    }
}
