import Dispatch
import Foundation
import TSCBasic

extension FileSystem {
  func exists(_ url: URL) -> Bool {
    exists(try! AbsolutePath(validating: url.path))
  }
}

extension ProcessResult {
  func utf8OutputLines() throws -> [String] {
    try utf8Output().split { $0.isWhitespace }.map(String.init)
  }
}

/// Variant of https://github.com/vapor/vapor/blob/master/Sources/Vapor/Commands/ServeCommand.swift
extension TSCBasic.Process {
  func waitUntilExitOrInterupt(didInterupt: @escaping (Int32) -> Void) throws -> ProcessResult {
    var signalSources = [DispatchSourceSignal]()
    let signalQueue = DispatchQueue(label: "com.swiftdockercli.interupt")

    func makeSignalSource(_ code: Int32) {
      let source = DispatchSource.makeSignalSource(signal: code, queue: signalQueue)
      source.setEventHandler {
        didInterupt(code)
        self.signal(code)
      }
      source.resume()
      signalSources.append(source)
      Foundation.signal(code, SIG_IGN)
    }

    makeSignalSource(SIGTERM)
    makeSignalSource(SIGINT)

    let result = try waitUntilExit()
    signalSources.forEach { $0.cancel() }
    return result
  }
}
