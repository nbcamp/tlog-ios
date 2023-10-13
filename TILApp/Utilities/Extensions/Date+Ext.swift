import Foundation

typealias Unixtime = UInt64

extension Date {
    @available(iOS, obsoleted: 15.0)
    static var now: Date { .init() }

    var unixtime: Unixtime { .init(self.timeIntervalSince1970) }

    init(unixtime: Unixtime) {
        self.init(timeIntervalSince1970: TimeInterval(unixtime))
    }

    func format(_ dateFormat: String = "yyyy-MM-dd") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: self)
    }
}
