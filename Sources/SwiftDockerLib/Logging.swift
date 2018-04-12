import Foundation
import Rainbow
import ShellOut

func runAndLog(_ cmd: ShellOutCommand, prefix: String) throws {
    printTitle("\(prefix): \(cmd.string)")
    try shellOut(to: cmd, outputHandle: bodyHandle, errorHandle: errorHandle)
}

func printTitle(_ string: String) {
    print(string.bold.lightGreen)
}

func printBody(_ string: String) {
    print(string.italic.lightCyan)
}

func printError(_ string: String) {
    print(string.lightRed)
}

// MARK: Handles
class ColorfulHandle: Handle {
    let print: (String) -> Void

    init(print: @escaping (String) -> Void) {
        self.print = print
    }

    func handle(data: Data) {
        let output = String(data: data, encoding: .utf8)!
        print(output)
    }
}

let bodyHandle = ColorfulHandle(print: printBody)
let errorHandle = ColorfulHandle(print: printError)
