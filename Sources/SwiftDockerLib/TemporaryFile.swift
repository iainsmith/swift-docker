import struct TSCBasic.AbsolutePath

typealias TemporaryFileFunction = (AbsolutePath?, String, String, Bool, (AbsolutePath) throws -> Void) throws -> Void
