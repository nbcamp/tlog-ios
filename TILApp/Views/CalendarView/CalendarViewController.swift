import Combine
import FSCalendar
import UIKit
import XMLCoder

final class CalendarViewController: UIViewController, UIGestureRecognizerDelegate {
    private let rssViewModel = RssViewModel.shared

    private let cal = Calendar.current
    private var cancellable: Set<AnyCancellable> = []

    private var posts: [RssViewModel.Post] = []
    private var lastSelectedDate: Date? {
        didSet {
            if let lastSelectedDate {
                posts = rssViewModel.postsMap[lastSelectedDate] ?? []
                placeholderLabel.text = "이 날에 작성한 TIL이 없어요."
            } else {
                posts = rssViewModel.postsByMonthMap[calendarView.currentPage] ?? []
                placeholderLabel.text = "이 달에 작성한 TIL이 없어요."
            }
            tableView.reloadData()
        }
    }

    private lazy var rootView = UIView().then {
        view.addSubview($0)
        $0.backgroundColor = .systemBackground
    }

    private lazy var tableView = UITableView().then {
        $0.register(UserTableViewCell.self, forCellReuseIdentifier: UserTableViewCell.identifier)
        $0.delegate = self
        $0.dataSource = self
        $0.applyCustomSeparator()
    }

    private lazy var placeholderLabel = UILabel().then {
        $0.text = "이 달에 작성한 TIL이 없어요."
        $0.textColor = .systemGray3
        $0.font = .systemFont(ofSize: 20, weight: .bold)
    }

    private lazy var placeholderView = UIView().then {
        $0.backgroundColor = .systemBackground
        $0.flex.alignItems(.center).define { flex in
            flex.addItem(placeholderLabel).marginTop(30)
        }
    }

    private lazy var calendarView = FSCalendar().then {
        $0.scrollEnabled = false

        let swipeRightView = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction))
        swipeRightView.direction = .right
        swipeRightView.delegate = self
        $0.addGestureRecognizer(swipeRightView)

        let swipeLeftView = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction))
        swipeLeftView.direction = .left
        swipeLeftView.delegate = self
        $0.addGestureRecognizer(swipeLeftView)

        $0.dataSource = self
        $0.delegate = self

        $0.firstWeekday = 2
        $0.scope = .month
        $0.locale = Locale(identifier: "ko_KR")

        $0.headerHeight = 45
        $0.weekdayHeight = 50

        $0.allowsMultipleSelection = false

        $0.appearance.titleFont = .boldSystemFont(ofSize: 14.5)
        $0.appearance.headerDateFormat = "yyyy년 M월"
        $0.appearance.headerTitleFont = .boldSystemFont(ofSize: 25)
        $0.appearance.headerTitleColor = .darkGray
        $0.appearance.headerMinimumDissolvedAlpha = 0

        $0.appearance.todayColor = .clear
        $0.appearance.selectionColor = .accent
        $0.appearance.titleWeekendColor = .red
        $0.appearance.borderSelectionColor = .white
        $0.appearance.eventDefaultColor = .accent
        $0.appearance.eventSelectionColor = .systemRed

        for index in 0 ... 6 {
            $0.calendarWeekdayView.weekdayLabels[index].textColor = .darkGray
            $0.calendarWeekdayView.weekdayLabels[index].font = .boldSystemFont(ofSize: 20)
        }
    }

    private lazy var loadingView = UIActivityIndicatorView().then {
        $0.startAnimating()
        $0.transform = .init(scaleX: 1.5, y: 1.5)
        $0.backgroundColor = .systemBackground
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        rssViewModel.$loading
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loading in
                guard let self, !loading else { return }
                loadingView.removeFromSuperview()
                tableView.reloadData()
            }.store(in: &cancellable)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        rootView.pin.all(view.pin.safeArea)
        rootView.flex.direction(.column).define {
            $0.addItem(calendarView).marginLeft(20).marginRight(20).aspectRatio(1)
            $0.addItem(tableView).grow(1)
        }.layout()
        if rssViewModel.loading {
            view.addSubview(loadingView)
            loadingView.pin.all(view.pin.safeArea)
        }
    }

    @objc private func swipeAction(_ sender: UISwipeGestureRecognizer) {
        let increment = sender.direction == .left ? 1 : -1
        guard let date = cal.date(
            byAdding: .init(month: increment),
            to: calendarView.currentPage
        ) else { return }
        if date > .now { return }
        calendarView.setCurrentPage(date, animated: false)
    }
}

extension CalendarViewController: FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, titleFor date: Date) -> String? {
        return cal.isDateInToday(date) ? "오늘" : nil
    }

    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return rssViewModel.postsMap[date] != nil ? 1 : 0
    }
}

extension CalendarViewController: FSCalendarDelegate {
    func calendar(
        _ calendar: FSCalendar,
        didSelect date: Date,
        at monthPosition: FSCalendarMonthPosition
    ) {
        if date == lastSelectedDate {
            calendar.deselect(date)
            lastSelectedDate = nil
        } else {
            lastSelectedDate = date
        }
    }

    func calendar(
        _ calendar: FSCalendar,
        shouldSelect date: Date,
        at monthPosition: FSCalendarMonthPosition
    ) -> Bool {
        return cal.isDate(date, equalTo: calendar.currentPage, toGranularity: .month)
    }

    func calendar(
        _ calendar: FSCalendar,
        willDisplay cell: FSCalendarCell,
        for date: Date,
        at monthPosition: FSCalendarMonthPosition
    ) {
        cell.backgroundView = nil
        guard let startOfStreakDays = rssViewModel.startOfStreakDays,
              rssViewModel.isDateInStreakDays(date: date)
        else { return }
        let view = UIView()
        cell.backgroundView = view
        view.backgroundColor = .accent
        view.transform = .init(translationX: 0, y: -5)
            .concatenating(.init(scaleX: 1, y: 0.7))
        view.layer.masksToBounds = true
        if cal.isDate(date, inSameDayAs: startOfStreakDays) {
            view.layer.cornerRadius = view.bounds.height / 2.2
            view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        } else if cal.isDateInToday(date) {
            view.layer.cornerRadius = view.bounds.height / 2.2
            view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        }
    }

    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        if let selectedDate = calendar.selectedDate,
           cal.isDate(selectedDate, equalTo: calendar.currentPage, toGranularity: .month)
        {
            calendar.deselect(selectedDate)
        }
        lastSelectedDate = nil
        tableView.reloadData()
        calendarView.reloadData()
    }
}

extension CalendarViewController: FSCalendarDelegateAppearance {
    func calendar(
        _ calendar: FSCalendar,
        appearance: FSCalendarAppearance,
        titleDefaultColorFor date: Date
    ) -> UIColor? {
        if rssViewModel.isDateInStreakDays(date: date) {
            return .white
        }

        if !cal.isDate(date, equalTo: calendar.currentPage, toGranularity: .month) {
            return .systemGray4
        }

        switch cal.component(.weekday, from: date) {
        case 1: return .systemRed
        case 7: return .systemBlue
        default: return .label
        }
    }

    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventOffsetFor date: Date) -> CGPoint {
        return .init(x: 0, y: 1)
    }
}

extension CalendarViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.backgroundView = posts.count == 0 ? placeholderView : nil
        return posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: UserTableViewCell.identifier,
            for: indexPath
        ) as? UserTableViewCell
        else { return UITableViewCell() }

        let post = posts[indexPath.row]
        cell.userTILView.setup(
            withTitle: post.title,
            content: post.content,
            date: post.publishedAt.format()
        )
        return cell
    }
}

extension CalendarViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(
            title: nil,
            message: posts[indexPath.row].title,
            preferredStyle: UIAlertController.Style.alert
        )
        let deleteAction = UIAlertAction(title: "리로드", style: UIAlertAction.Style.destructive) { _ in
            tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "취소", style: UIAlertAction.Style.cancel, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        present(alert, animated: true)
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 80
    }
}
