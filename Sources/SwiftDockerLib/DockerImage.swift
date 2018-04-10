/// A docker image represented either as a full image or a swift version.
enum DockerImage {
    case image(String)
    case swiftVersion(String)

    init?(version: String?, image: String?) {
        if let fullImage = image, fullImage.isEmpty == false {
            self = .image(fullImage)
            return
        }

        if let version = version {
            self = .swiftVersion(version)
            return
        }

        return nil
    }

    var imageName: String {
        switch self {
        case let .image(fullImage): return fullImage
        case let .swiftVersion(version): return makeDefaultImage(forVersion: version)
        }
    }
}
