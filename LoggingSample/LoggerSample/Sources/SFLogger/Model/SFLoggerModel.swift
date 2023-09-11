import UIKit

protocol SFLoggerModelProtocol: AnyObject
{
    var FilePath: String? { get }
    var FileFullPath: String? { get }
    init(_ locale: SFLoggerModel.LogLocale)
    func createLogMessage(_ message: String, logType: SFLoggerModel.LogType, error: Error?, file: String, function: String, line: Int) -> String
    func writeLogToFile(_ message: String)
}

final class SFLoggerModel: SFLoggerModelProtocol
{
    
    private let dateFormat: String = "yyyy-MM-dd HH:mm:ss.SSS Z"
    
    private var locale: LogLocale = .None
    
    private var deviceType: DeviceType = .None
    
    private var fileName: String? = nil
    
    private var filePath: String? = nil
    
    public var FileFullPath: String?
    {
        get
        {
            return "\(self.filePath!)/\(self.fileName!)"
        }
    }
    
    public var FilePath: String?
    {
        get
        {
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
        
        self.fileName = self.setLogFileName()
        
        self.filePath = self.setLogFilePath()
    }
    
    private func setLogFilePath() -> String! {
        var documentsUrl: URL? = self.getDocumentsDirectory()
        if documentsUrl == nil
        {
            do {
                try FileManager.default.createDirectory(at: .documentsDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                fatalError("ドキュメントディレクトリを作成できませんでした: \(error.localizedDescription)")
            }
            documentsUrl = self.getDocumentsDirectory()
        }
        // ログディレクトリの存在チェック
        var documentsLogUrl: URL? = self.getDocumentsLogDirectory()
        if documentsLogUrl == nil
        {
            do {
                try FileManager.default.createDirectory(at: .documentsDirectory.appendingPathComponent("Logs"), withIntermediateDirectories: true, attributes: nil)
            } catch {
                fatalError("ログディレクトリを作成できませんでした: \(error.localizedDescription)")
            }
            documentsLogUrl = self.getDocumentsLogDirectory()
        }
        return documentsLogUrl!.path
    }
    
    
    private func setLogFileName() -> String {
        return "\(self.generateDateYmd())_\(self.setBundleName()).log"
    }
    
    private func setBundleName() -> String {
        let bundleName = Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as? String ?? "appLog"
        return "\(bundleName)"
    }
    
    private func generateDateYmd() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let dateString = dateFormatter.string(from: Date())
        return "\(dateString)"
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
    
    private func getDocumentsDirectory() -> URL?
    {
        if let documentsDirectory: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        {
            return documentsDirectory
        }
        return nil
    }
    
    private func getDocumentsLogDirectory() -> URL?
    {
        
        if let documentsLogDirectory: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Logs")
        {
            var isDirectory: ObjCBool = false
            if FileManager.default.fileExists(atPath: documentsLogDirectory.path, isDirectory: &isDirectory) {
                if isDirectory.boolValue {
                    return documentsLogDirectory
                }
            }
        }
        return nil
    }
    
    private func getApplicationSupportDirectory() -> URL?
    {
        if let appSupportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            return appSupportDirectory
        }
        return nil
    }
    
    private func ensureApplicationSupportDirectoryExists() throws -> String
    {
        guard let applicationSupportDirectory: URL = self.getApplicationSupportDirectory() else
        {
            fatalError("Application Supportディレクトリを取得できませんでした。")
        }
        return applicationSupportDirectory.appendingPathComponent(self.fileName!).path
    }
    
    private func ensureDocumentsDirectoryExists() throws -> String
    {
        // ドキュメントディレクトリの存在チェック
        guard let documentsDirectory: URL = self.getDocumentsDirectory() else
        {
            fatalError("ドキュメントディレクトリを取得できませんでした。")
        }
        return documentsDirectory.appendingPathComponent(self.fileName!).path
    }
    
    private func createLogFile() throws
    {
        if !FileManager.default.fileExists(atPath: self.FileFullPath!)
        {
            if !FileManager.default.createFile(atPath: self.FileFullPath!, contents: nil, attributes: nil)
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
            if let fileHandle = FileHandle(forWritingAtPath: self.FileFullPath!)
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
