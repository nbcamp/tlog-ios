func toDictionary(from object: Any) -> [String: Any] {
    var result: [String: Any] = [:]
    let mirror = Mirror(reflecting: object)
    for (key, value) in mirror.children {
        guard let key else { continue }
        switch value {
        case Optional<Any>.none:
            continue
        case Optional<Any>.some(let value):
            result[key] = value
        default:
            result[key] = value
        }
    }
    return result
}
