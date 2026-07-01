import FBLPromises

extension FBLPromise {
    func asyncValue() async throws -> Any {
        try await withCheckedThrowingContinuation { continuation in
            then { value in
                continuation.resume(returning: value)
                return value
            }.catch { error in
                continuation.resume(throwing: error)
            }
        }
    }
}
