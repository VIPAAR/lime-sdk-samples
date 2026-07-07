import Promises

func resolvedPromise(_ value: Bool) -> Promise<AnyObject> {
    Promise<AnyObject>(NSNumber(value: value))
}

func asyncValue(from promise: Promise<AnyObject>) async throws -> AnyObject {
    try await withCheckedThrowingContinuation { continuation in
        promise
            .then { continuation.resume(returning: $0) }
            .catch { continuation.resume(throwing: $0) }
    }
}
