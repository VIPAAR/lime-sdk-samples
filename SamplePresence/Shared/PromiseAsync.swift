import Promises

func resolvedPromise(_ value: Bool) -> Promise<AnyObject> {
    Promise<AnyObject>(NSNumber(value: value))
}
