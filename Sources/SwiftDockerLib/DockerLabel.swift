protocol DockerLabel {
  static var label: String { get }
  static func label(with value: String) -> String
}

enum ActionLabel: String, DockerLabel {
  case buildForTesting = "test"
  case build

  static let label = "com.\(DockerHub.reservedDockerID).action"

  static func label(with value: ActionLabel) -> String {
    label(with: value.rawValue)
  }
}

enum FolderLabel: DockerLabel {
  static let label = "com.\(DockerHub.reservedDockerID).folder"
}

extension DockerLabel {
  static func label(with value: String) -> String {
    "\(label)=\(value)"
  }
}
