protocol ViewModel {
    static var shared: Self { get set }
    static func reset()
}
