import Foundation
import HLSDK

func demoLogSetup() {
    HLLogEnable(true)
    HLLogSetLogLevel(HLLogLevel.verbose)

    _ = HLLogEnableFileLogger()
    demoLogDebug("Logging setup complete")
}

/// Call after the SDK initializes `HLSDKManager` (which runs `HLLogSetup()`).
/// That attaches both OS and TTY loggers to the SDK's internal `DDLog` instance;
/// in Xcode both write to the debug console and produce duplicate lines.
func demoLogTidyAfterSDKInit() {
    HLLogDisableOSLogger()
}

typealias DemoLogMessage = String

@inline(__always) func demoLogVerbose(
    _ message: @autoclosure () -> DemoLogMessage,
    file: String = #fileID,
    function: String = #function,
    line: UInt = #line
) {
    demoLogMessage(HLLogLevel.verbose, message(), file: file, function: function, line: line)
}

@inline(__always) func demoLogDebug(
    _ message: @autoclosure () -> DemoLogMessage,
    file: String = #fileID,
    function: String = #function,
    line: UInt = #line
) {
    demoLogMessage(HLLogLevel.debug, message(), file: file, function: function, line: line)
}

@inline(__always) func demoLogInfo(
    _ message: @autoclosure () -> DemoLogMessage,
    file: String = #fileID,
    function: String = #function,
    line: UInt = #line
) {
    demoLogMessage(HLLogLevel.info, message(), file: file, function: function, line: line)
}

@inline(__always) func demoLogWarning(
    _ message: @autoclosure () -> DemoLogMessage,
    file: String = #fileID,
    function: String = #function,
    line: UInt = #line
) {
    demoLogMessage(HLLogLevel.warning, message(), file: file, function: function, line: line)
}

@inline(__always) func demoLogError(
    _ message: @autoclosure () -> DemoLogMessage,
    file: String = #fileID,
    function: String = #function,
    line: UInt = #line
) {
    demoLogMessage(HLLogLevel.error, message(), file: file, function: function, line: line)
}

private func demoLogMessage(
    _ level: HLLogLevel,
    _ message: String,
    file: String,
    function: String,
    line: UInt
) {
    guard HLLogIsEnabled(), level.rawValue >= HLLogGetLogLevel().rawValue else {
        return
    }

    HLLogMessageWithoutFormat(
        level,
        Int(HLLogContextSwift),
        file,
        function,
        line,
        message
    )
}
