import Rainbow

func printTitle(_ string: String) {
    print(string.bold.lightGreen)
}

func printBody(_ string: String) {
    print(string.italic.lightCyan)
}

func printError(_ string: String) {
    print(string.lightRed)
}
