/// A docker image represented either as a full image or a swift version.
enum DockerTag: Equatable {
  case image(String)
  case officialSwiftVersion(String)

  /// Image has a higher precedance than version
  init?(version: String?, image: String?) {
    if let fullImage = image, fullImage.isEmpty == false {
      self = .image(fullImage)
      return
    }

    if let version = version {
      self = .officialSwiftVersion(version)
      return
    }

    return nil
  }

  var fullName: String {
    switch self {
    case let .image(fullImage): return fullImage
    case let .officialSwiftVersion(version): return "swift:\(version)"
    }
  }
}
