enum Dockerfile {
  static func makeMinimalDockerFile(
    image: String,
    directory directoryName: String,
    action: ActionLabel
  ) -> String {
    let directory = directoryName.replacingOccurrences(of: " ", with: "\\ ").lowercased()

    return """
    FROM \(image)
    LABEL \(ActionLabel.label)="\(action.rawValue)"
    LABEL \(FolderLabel.label)="\(directory)"
    COPY . /\(directory)
    WORKDIR /\(directory)
    RUN swift build\n
    """
  }

  static func filter(for action: ActionLabel) -> String {
    "label=\(ActionLabel.label)=\(action.rawValue)"
  }
}
