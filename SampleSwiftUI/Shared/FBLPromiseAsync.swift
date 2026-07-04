import FBLPromises

nonisolated(unsafe) private var lastFBLPromiseResult: AnyObject?
nonisolated(unsafe) private var lastFBLPromiseError: Error?

func asyncValue(from promise: FBLPromise<AnyObject>) async throws -> AnyObject {
    try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
        DispatchQueue.global(qos: .userInitiated).async {
            var error: NSError?
            let rawValue = __FBLPromiseAwait(promise, &error)
            if let error {
                lastFBLPromiseError = error
                continuation.resume(throwing: error)
                return
            }
            guard let value = rawValue as AnyObject? else {
                let missingValueError = NSError(
                    domain: "SampleSwiftUI",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Promise resolved without a value."]
                )
                lastFBLPromiseError = missingValueError
                continuation.resume(throwing: missingValueError)
                return
            }
            lastFBLPromiseResult = value
            continuation.resume()
        }
    }

    if let error = lastFBLPromiseError {
        throw error
    }
    guard let result = lastFBLPromiseResult else {
        throw NSError(
            domain: "SampleSwiftUI",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "Promise resolved without a value."]
        )
    }
    return result
}
