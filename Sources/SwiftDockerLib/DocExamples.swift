enum DocExamples {
  static let testCommand = """
  swift docker test # Using swift:latest run swift build && swift test
  swift docker test --swift 5.0 # Run tests in the swift:5.0 image
  swift docker test --path ~/my-package # Specify the package directory
  """
}
