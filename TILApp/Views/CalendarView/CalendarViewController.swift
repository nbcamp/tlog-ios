import FSCalendar
import UIKit
import XMLCoder

class CalendarViewController: UIViewController {
    
    private let rssViewModel = RssViewModel.shared
    private lazy var rssList = rssViewModel.rss
    // 뷰모델에서 가져오는 테이블 뷰 표시할 데이터
    private lazy var convertTableData = rssViewModel.rssPostData
    private lazy var rssPostData = rssViewModel.rssPostData
    // 캘린더 날짜에 표시해줄 데이터
    private var monthDatanum = ""
    fileprivate lazy var datesWithCat: [String] = rssViewModel.datesWithCat
    lazy var calendarFlexView = UIView().then {
        view.addSubview($0)
        $0.backgroundColor = .white
    }
    
    lazy var customTILView = CustomTILView().then {
        view.addSubview($0)
        $0.setup(withTitle: "제목", content: "내용\n내용", date: "2023-10-17")
    }
    // 현재 캘린더가 보여주고 있는 Page 트래킹
    lazy var currentPage = calendarView.currentPage
    // 여기 배열은 라이브러리가 달력 보여줄때 해당되는 내용 보고 적용해줌
    
    private let calendarResultContent = UILabel().then {
        $0.text = "5"
        $0.textColor = .black
        $0.font = .boldSystemFont(ofSize: 30)
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
        // 헤더뷰 설정
        $0.headerHeight = 45
        
        // 달력 월 확인하기 위한 변수 할당
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
        // 선택했을때 테두리
        $0.appearance.borderSelectionColor = .white
        // week설정
        $0.weekdayHeight = 50
        $0.scrollEnabled = true
        $0.scrollDirection = .horizontal
        // dot 색 설정
        $0.appearance.eventDefaultColor = .init(named: "AccentColor")
        $0.appearance.eventSelectionColor = .systemRed
        // 요일 라벨의 textColor를 black로 설정 , dot 색 설정 위치에 따라 적용됨 버그있음
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
        // 일요일 라벨의 textColor를 red로 설정
        $0.calendarWeekdayView.weekdayLabels[6].textColor = .darkGray
        $0.calendarWeekdayView.weekdayLabels[6].font = .boldSystemFont(ofSize: 20)
        
        // 토요일 라벨 파란색으로
        $0.calendarWeekdayView.weekdayLabels[5].textColor = .darkGray
        $0.calendarWeekdayView.weekdayLabels[5].font = .boldSystemFont(ofSize: 20)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
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
        self.view.backgroundColor = .systemBackground
        tableView.delegate = self
        tableView.dataSource = self
        
        calendarView.reloadData()
        tableView.reloadData()
        fightingMessage()
        
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "yyyyMMdd"
    }
}

extension CalendarViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    // 날짜 선택시 콜백 메소드
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        // 날짜를 원하는 형식으로 저장하기 위한 방법입니다.
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let tableDateData = dateFormatter.string(from: date)
        // 날짜 눌렀을때 해당 날짜의 데이터만 테이블뷰 표시
        rssPostData = convertTableData.filter { calData in
            dateFormatter.dateFormat = "yyyyMMdd"
            if(dateFormatter.string(from: calData.publishedAt) == tableDateData){
                return true
            }
            return false
        }
        tableView.reloadData()
    }
    // 오늘 날짜 자체 텍스트를 바꾸기
    func calendar(_ calendar: FSCalendar, titleFor date: Date) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        switch dateFormatter.string(from: date) {
        case dateFormatter.string(from: Date()):
            return "오늘"
        default:
            return nil
        }
    }
    
    // 일요일에 해당되는 모든 날짜의 색상 red로 변경
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        let day = Calendar.current.component(.weekday, from: date) - 1
        // 현재 다루는 셀의 date 값
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let inputDateStr = dateFormatter.string(from: date)
        // 이번달 정보로 지난달의 요일 색 변화
        let monthDataFormatter = DateFormatter()
        monthDataFormatter.dateFormat = "YYYYMM"
        let monthDataStr = monthDataFormatter.string(from: calendar.currentPage)
        //         무한 리로드 현상 막기
        if monthDatanum != monthDataStr {
            monthDatanum = monthDataStr
            calendar.reloadData()
        }
        // 전 후 달의 일 표시 회색으로
        if monthDataStr != inputDateStr.prefix(6) {
            return .lightGray
        } else if datesWithCat.contains(inputDateStr) {
            let ifPlusDate = Int(dateFormatter.string(from: timePlusDate(date: date, dayPlus: 1))) ?? 0
            if datesWithCat.contains(String(ifPlusDate)) {
                // datesWithCat에 다음날짜가 오늘자인자 확인
                if ifPlusDate == Int(dateFormatter.string(from: Date())) {
                    return .white
                } else {
                    var dayDifferenceNum = Calendar.current.dateComponents([.day], from: date, to: Date()).day!
                    var dayPlusNum = 1
                    while dayDifferenceNum > 0 {
                        if !(datesWithCat.contains(dateFormatter.string(from: timePlusDate(date: date, dayPlus: dayPlusNum)))) {
                            break
                        }
                        dayDifferenceNum -= 1
                        dayPlusNum += 1
                        if dayDifferenceNum == 0 {
                            return .white
                            if !(datesWithCat.contains(dateFormatter.string(from: timePlusDate(date: date, dayPlus: -1)))) {
                                return .white
                            }
                        }
                    }
                }
                // 오늘 날자면 동글 뱅이 표시
            } else if dateFormatter.string(from: Date()) == inputDateStr {
                
                if datesWithCat.contains(dateFormatter.string(from: timePlusDate(date: date, dayPlus: -1)))  {
                    return .white
                }
            }
        }
        // ios 업데이트 후 한글 표기에서 영어로 변화됨
        if Calendar.current.shortWeekdaySymbols[day] == "Sun" || Calendar.current.shortWeekdaySymbols[day] == "일" {
            return .systemRed
        } else if Calendar.current.shortWeekdaySymbols[day] == "Sat" || Calendar.current.shortWeekdaySymbols[day] == "토" {
            return .systemBlue
        } else {
            return .label
        }
    }
    
    // 시스템 아이콘 색상 바꾸기
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at monthPosition: FSCalendarMonthPosition) {
        let customView = UIView()
        // dot 크기 설정
        cell.eventIndicator.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let inputDateStr = dateFormatter.string(from: date)
        cell.imageView.tintColor = UIColor(red: 1.00, green: 0.42, blue: 0.21, alpha: 1.00)
        // cell 재사용때
        if cell.subviews[0].frame.origin.y >= 5 {
            cell.subviews[0].removeFromSuperview()
        }
        cell.titleLabel.backgroundColor = .clear
        customView.backgroundColor = .clear
        // cell에 연속일수 표시하는 뷰 넣어주기
        if datesWithCat.contains(inputDateStr) {
            // datesWithCat에 해당 날짜가 있다면 cell에 적용될 데이터
            // 요청사항, 연속으로 TIL 작성한 날짜에만 적용될 레이아웃
            cell.addSubview(customView)
            customView.translatesAutoresizingMaskIntoConstraints = false
            customView.layer.cornerRadius = (calendarView.bounds.height / 10) / 2 - 6
            
            customView.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -13).isActive = true
            customView.leftAnchor.constraint(equalTo: cell.leftAnchor, constant: 0).isActive = true
            customView.topAnchor.constraint(equalTo: cell.topAnchor, constant: 5).isActive = true
            customView.rightAnchor.constraint(equalTo: cell.rightAnchor, constant: 0).isActive = true
            customView.backgroundColor = .clear
            cell.sendSubviewToBack(customView)
            
            // date를 yyyyMMdd 형식으로 바꿔줘
            guard let ifPlusDate = Int(dateFormatter.string(from: timePlusDate(date: date, dayPlus: 1))) else {return}
            
            // date의 다음날이 datesWithCat에 있음?
            if datesWithCat.contains(String(ifPlusDate)) {
                // date의 다음날이 오늘자인자 확인
                if ifPlusDate == Int(dateFormatter.string(from: Date())) {
                    
                    if(!datesWithCat.contains(dateFormatter.string(from: timePlusDate(date: date, dayPlus: -1)))){
                        customView.backgroundColor = .init(named: "AccentColor")
                        customView.layer.cornerRadius = (calendarView.bounds.height / 10) / 2 - 6
                        customView.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMinXMaxYCorner)
                        return
                    }else{
                        // 이어지는 뷰 넣어주기
                        customView.backgroundColor = .init(named: "AccentColor")
                        customView.layer.cornerRadius = 0
                        return
                    }
                    // date의 다음날이 오늘이 아님? 그럼 radius 적용 안된 뷰 적용해줘
                } else {
                    var dayDifferenceNum = Calendar.current.dateComponents([.day], from: date, to: Date()).day!
                    var dayPlusNum = 1
                    while dayDifferenceNum > 0 {
                        if !(datesWithCat.contains(dateFormatter.string(from: timePlusDate(date: date, dayPlus: dayPlusNum)))) {
                            break
                        }
                        dayPlusNum += 1
                        dayDifferenceNum -= 1
                        if dayDifferenceNum == 0 {
                            // til 연속일자 중간 설정
                            customView.backgroundColor = .init(named: "AccentColor")
                            customView.layer.cornerRadius = 0
                            if !(datesWithCat.contains(dateFormatter.string(from: timePlusDate(date: date, dayPlus: -1)))) {
                                // til 연속일자 시작 설저
                                customView.backgroundColor = .init(named: "AccentColor")
                                customView.layer.cornerRadius = (calendarView.bounds.height / 10) / 2 - 6
                                customView.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMinXMaxYCorner)
                                return
                            }
                        }
                    }
                }
                //                date의 다음날이 datesWithCat에 없음? 그럼 date가 오늘임?
            } else if dateFormatter.string(from: Date()) == inputDateStr {
                
                // 여기도 날짜 1일 빼는걸로 바꿀것
                if !datesWithCat.contains(dateFormatter.string(from: timePlusDate(date: date, dayPlus: -1))) {
                    customView.backgroundColor = .init(named: "AccentColor")
                    customView.layer.cornerRadius = (calendarView.bounds.height / 10) / 2 - 6
                    customView.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner)
                } else {
                    // 오늘이 til 연속일자의 마지막 날이면
                    customView.layer.cornerRadius = (calendarView.bounds.height / 10) / 2 - 6
                    customView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
                    customView.backgroundColor = .init(named: "AccentColor")
                    return
                }
            } else {
                cell.titleLabel.backgroundColor = .clear
            }
            // shapeLayer 애가 선택했을때의 view
            cell.titleLabel.font = .boldSystemFont(ofSize: cell.titleLabel.font.pointSize + 1)
        } else {
            cell.titleLabel.backgroundColor = .clear
        }
    }
    
    // dot 키기
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let inputDateStr = dateFormatter.string(from: date)
        if datesWithCat.contains(inputDateStr) {
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
    func timePlusDate(date : Date, dayPlus : Int) -> Date {
        return Calendar.current.date(
            byAdding: .day,
            value: dayPlus,
            to: date)!
    }
}

extension CalendarViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rssPostData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as? UserTableViewCell else {
            return UITableViewCell()
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let inputDateStr = dateFormatter.string(from: rssPostData[index].publishedAt)
        
        cell.userTILView.setup(withTitle: rssPostData[index].title, content: rssPostData[index].content, date: inputDateStr)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "", message: rssPostData[indexPath.row].title, preferredStyle: UIAlertController.Style.alert)
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
    func fightingMessage () {
        let imageDateFormatter = DateFormatter()
        imageDateFormatter.dateFormat = "yyyyMMdd"
        // 오늘의 날짜와 rss에서 가져온 게시물의 마지막 작성일이랑 같니?
        if imageDateFormatter.string(from: Date()) == datesWithCat.last {
            let daySumData = imageDateFormatter.date(from: datesWithCat[datesWithCat.count - 1])!
            // 게시물을 오늘 작성했는데 이게 끝이구나?
            if datesWithCat.count == 1 {
                calendarResultContent.text = "오늘의 TIL을 작성하셨군요? 앞으로도 쭉 달려봐요!"
                // 배열의 끝에서 부터 0번 인덱스 도착할 때까지 countDateDown값을 낮추는 로직
            } else if Calendar.current.dateComponents([.day], from: imageDateFormatter.date(from: datesWithCat[datesWithCat.count - 2])!, to: daySumData).day! == 1 {
                var countDateDown = datesWithCat.count - 2
                var compleDateCount = 1
                var arrayComparison = imageDateFormatter.date(from: datesWithCat[datesWithCat.count - 1])
                while countDateDown >= 0 {
                    
                    if Calendar.current.dateComponents([.day], from: imageDateFormatter.date(from: datesWithCat[countDateDown])!, to:arrayComparison! ).day! == 1  {
                        
                        arrayComparison = imageDateFormatter.date(from: datesWithCat[countDateDown])
                        compleDateCount += 1
                        
                    } else {
                        calendarResultContent.text = "\(compleDateCount)일 연속 TIL 작성!"
                        break
                    }
                    // 딱 2일 연속으로만 작성하면 여기 들어와짐
                    if countDateDown == 0 {
                        calendarResultContent.text = "\(compleDateCount)일 연속 TIL 작성!"
                        break
                    }
                    countDateDown -= 1
                }
            } else {
                calendarResultContent.text = "조금만 더 힘내봐요!"
            }
        } else {
            calendarResultContent.text = "조금만 더 힘내봐요!"
        }
    }
}
