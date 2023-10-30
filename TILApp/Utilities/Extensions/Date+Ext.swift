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
        dateFormatter.locale = .init(identifier: Locale.current.identifier)
        dateFormatter.timeZone = .init(identifier: TimeZone.current.identifier)
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: self)
    }

    func relativeFormat() -> String {
        let dateFormatter = RelativeDateTimeFormatter()
        dateFormatter.locale = .init(identifier: "ko_KR")
        dateFormatter.dateTimeStyle = .named
        return dateFormatter.localizedString(for: self, relativeTo: Date.now)
    }
}
