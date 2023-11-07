import FSCalendar
import UIKit
import XMLCoder

class CalendarViewController: UIViewController {
    private var rssViewModel = RssViewModel.shared
    private lazy var rssPostData = rssViewModel.rssPostData
    private lazy var rssPostAllData = rssViewModel.rssPostAllData
    private lazy var continueFirstDate = rssViewModel.continueFirstDate
    // 캘린더 표시해주는 달을 저장하는 변수
    private lazy var monthDatanum = ""

    let dateFormatter = DateFormatter()
    private lazy var calendarFlexView = UIView().then {
        view.addSubview($0)
        $0.backgroundColor = .white
    }

    private lazy var customTILView = CustomTILView().then {
        view.addSubview($0)
        $0.setup(withTitle: "제목", content: "내용\n내용", date: "2023-10-17")
    }

    private var calendarResultContent = UILabel().then {
        $0.text = "5"
        $0.textColor = .black
        $0.font = .boldSystemFont(ofSize: 25)
        $0.numberOfLines = 1
        $0.textAlignment = .center
    }

    private let tableView = UITableView().then {
        $0.register(UserTableViewCell.self, forCellReuseIdentifier: "UserCell")
    }

    private lazy var calendarView = FSCalendar().then {
        $0.dataSource = self
        $0.delegate = self
        // 첫 열을 월요일로 설정
        $0.firstWeekday = 2
        // week 또는 month 가능
        $0.scope = .month
        $0.appearance.titleWeekendColor = .red
        // 셀 선택시 원형으로 만들어주는 radius 변경
        //        calendar.appearance.borderRadius = 0
        $0.scrollEnabled = false
        $0.locale = Locale(identifier: "ko_KR")
        // 현재 달의 날짜들만 표기하도록 설정
        //        calendar.placeholderType = .none
        $0.appearance.titleFont = .boldSystemFont(ofSize: 14.5)
        // 헤더뷰 높이 설정
        $0.headerHeight = 45
        // 달력 월 형식 설정
        $0.appearance.headerDateFormat = "YYYY년 M월"
        $0.appearance.headerTitleColor = .darkGray
        $0.appearance.headerTitleFont = .boldSystemFont(ofSize: 25)
        // 헤더 다음달 전달 표시
        $0.appearance.headerMinimumDissolvedAlpha = 0
        // 요일 UI 설정
        //        $0.appearance.weekdayTextColor = .black
        // 날짜 UI 설정
        //        $0.appearance.titleTodayColor = .black
        // 오늘 둘러싸는 컬러
        $0.appearance.todayColor = .clear
        // 선택했을때 컬러
        $0.appearance.selectionColor = .init(named: "AccentColor")
        // 선택했을때 테두리 컬러
        $0.appearance.borderSelectionColor = .white
        // week설정
        $0.weekdayHeight = 50
        $0.scrollEnabled = true
        $0.scrollDirection = .horizontal
        // dot 컬러 설정
        $0.appearance.eventDefaultColor = .init(named: "AccentColor")
        $0.appearance.eventSelectionColor = .systemRed
        // 요일 라벨의 textColor를 darkGray로 설정 , dot 색 설정 위치에 따라 적용됨 버그있음
        $0.calendarWeekdayView.weekdayLabels[1].textColor = .darkGray
        $0.calendarWeekdayView.weekdayLabels[1].font = .boldSystemFont(ofSize: 20)
        $0.calendarWeekdayView.weekdayLabels[2].textColor = .darkGray
        $0.calendarWeekdayView.weekdayLabels[2].font = .boldSystemFont(ofSize: 20)
        $0.calendarWeekdayView.weekdayLabels[3].textColor = .darkGray
        $0.calendarWeekdayView.weekdayLabels[3].font = .boldSystemFont(ofSize: 20)
        $0.calendarWeekdayView.weekdayLabels[4].textColor = .darkGray
        $0.calendarWeekdayView.weekdayLabels[4].font = .boldSystemFont(ofSize: 20)
        $0.calendarWeekdayView.weekdayLabels[0].textColor = .darkGray
        $0.calendarWeekdayView.weekdayLabels[0].font = .boldSystemFont(ofSize: 20)
        // 토요일 라벨
        $0.calendarWeekdayView.weekdayLabels[5].textColor = .darkGray
        $0.calendarWeekdayView.weekdayLabels[5].font = .boldSystemFont(ofSize: 20)
        // 일요일 라벨
        $0.calendarWeekdayView.weekdayLabels[6].textColor = .darkGray
        $0.calendarWeekdayView.weekdayLabels[6].font = .boldSystemFont(ofSize: 20)
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        calendarFlexView.flex.direction(.column).define {
            $0.addItem(calendarResultContent).alignItems(.center)
            $0.addItem(calendarView).marginLeft(20).marginRight(20).aspectRatio(1)
            $0.addItem(tableView).grow(1)
        }
        calendarFlexView.pin.all(view.pin.safeArea)
        calendarFlexView.flex.layout()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        tableView.delegate = self
        tableView.dataSource = self
        fightingMessage()
    }
}

extension CalendarViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    // 날짜 선택시 콜백 메소드
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let rssFindKey = rssPostData[rssViewModel.utcTimeConvert(date: date)]
        if rssFindKey != nil {
            rssPostAllData = rssFindKey!
        } else {
            rssPostAllData = []
        }
        tableView.reloadData()
    }

    // 오늘 날짜 자체 텍스트를 바꾸기
    func calendar(_ calendar: FSCalendar, titleFor date: Date) -> String? {
        switch rssViewModel.utcTimeConvert(date: date) {
        case rssViewModel.utcTimeConvert(date: Date()):
            return "오늘"
        default:
            return nil
        }
    }

    // 일요일에 해당되는 모든 날짜의 색상 red로 변경
    func calendar(_ calendar: FSCalendar,
                  appearance: FSCalendarAppearance,
                  titleDefaultColorFor date: Date) -> UIColor?
    {
        let inputDateStr = dateFormatter.string(from: date)
        let monthDataStr = dateFormatter.string(from: calendar.currentPage)
        let dateUtc = rssViewModel.utcTimeConvert(date: date)

        if monthDatanum != monthDataStr {
            monthDatanum = monthDataStr
            // 여기다 서버에 지금 달력이 보여주는 월 보내서 데이터 다다음달 데이터 불러와야함
            calendar.reloadData()
        }
        // 저번달 다음달 일 표시 회색으로
        if monthDataStr.prefix(6) != inputDateStr.prefix(6) {
            return .lightGray
        } else if continueFirstDate != nil {
            if rssPostData[rssViewModel.utcTimeConvert(date: date)] != nil
                && dateDifferenceDay(from: continueFirstDate!, to: dateUtc) >= 0
            {
                return .white
            }
        }

        // ios 업데이트 후 한글 표기에서 영어로 변화됨
        let day = Calendar.current.component(.weekday, from: date) - 1
        let dayLabel = Calendar.current.shortWeekdaySymbols[day]
        if dayLabel == "Sun" || dayLabel == "일" {
            return .systemRed
        } else if dayLabel == "Sat" || dayLabel == "토" {
            return .systemBlue
        } else {
            return .label
        }
    }

    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at monthPosition: FSCalendarMonthPosition) {
        let customView = UIView()
        dateFormatter.dateFormat = "yyyyMMdd"
        let dateUtc = rssViewModel.utcTimeConvert(date: date)
        let todayUtc = rssViewModel.utcTimeConvert(date: Date())
        // dot 크기 설정
        cell.eventIndicator.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        // cell 재사용된 속성 삭제 prepareForReuse를 사용하는 것보다 메모리 관점으로 이득
        if cell.subviews[0].frame.origin.y >= 5 {
            cell.subviews[0].removeFromSuperview()
        }
        if continueFirstDate != nil {
            if dateDifferenceDay(from: continueFirstDate!, to: dateUtc) >= 0
                && dateDifferenceDay(from: todayUtc, to: dateUtc) <= 0
            {
                cell.addSubview(customView)
                customView.translatesAutoresizingMaskIntoConstraints = false
                customView.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -13).isActive = true
                customView.leftAnchor.constraint(equalTo: cell.leftAnchor, constant: 0).isActive = true
                customView.topAnchor.constraint(equalTo: cell.topAnchor, constant: 5).isActive = true
                customView.rightAnchor.constraint(equalTo: cell.rightAnchor, constant: 0).isActive = true
                customView.backgroundColor = .init(named: "AccentColor")
                cell.sendSubviewToBack(customView)
                if continueFirstDate == rssViewModel.utcTimeConvert(date: Date()) {
                    customView.layer.cornerRadius = (calendarView.bounds.height / 10) / 2 - 6
                } else if dateUtc == continueFirstDate {
                    customView.layer.cornerRadius = (calendarView.bounds.height / 10) / 2 - 6
                    customView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
                } else if dateUtc == rssViewModel.utcTimeConvert(date: Date()) {
                    customView.layer.cornerRadius = (calendarView.bounds.height / 10) / 2 - 6
                    customView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
                }
            }
        }
    }

    // dot 키기
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let dateUtc = rssViewModel.utcTimeConvert(date: date)
        if rssPostData[dateUtc] != nil {
            return 1
        } else {
            return 0
        }
    }

    // dot 위치 조정
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventOffsetFor date: Date) -> CGPoint {
        return CGPoint(x: 0, y: 1)
    }

    // 1일 더해서 날짜 바뀌는걸 확인하는 함수
    func timePlusDate(date: Date, dayPlus: Int) -> Date {
        return Calendar.current.date(
            byAdding: .day,
            value: dayPlus,
            to: date)!
    }

    func dateDifferenceDay(from: Date, to: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: from, to: to).day!
    }
}

extension CalendarViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rssPostAllData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        let rssData = rssPostAllData[index]
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "UserCell",
            for: indexPath) as? UserTableViewCell
        else {
            return UITableViewCell()
        }
        dateFormatter.dateFormat = "yyyy-MM-dd"
        cell.userTILView.setup(
            withTitle: rssData.title,
            content: rssData.content,
            date: dateFormatter.string(from: rssPostAllData[index].publishedAt
            ))

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(
            title: "",
            message: rssPostAllData[indexPath.row].title,
            preferredStyle: UIAlertController.Style.alert)
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

extension CalendarViewController {
    func fightingMessage() {
        if continueFirstDate != nil {
            let today = rssViewModel.utcTimeConvert(date: Date())
            if dateDifferenceDay(from: continueFirstDate!, to: today) == 0 {
                calendarResultContent.text = "오늘처럼 내일도 TIl 화이팅"
            }

            calendarResultContent.text = "화이팅 \(dateDifferenceDay(from: continueFirstDate!, to: today) + 1)일 연속 TIL 작성중이에요!"
        } else {
            calendarResultContent.text = "오늘의 TIL을 기록해 봐요!"
        }
    }
}
