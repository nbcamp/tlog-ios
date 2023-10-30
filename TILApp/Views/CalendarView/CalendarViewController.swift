import FSCalendar
import UIKit
import XMLCoder

struct RSS: Codable {
//    let to: String
    let channel: RSSChannel
}

struct RSSChannel: Codable {
    let posts: [RSSPost]

    enum CodingKeys: String, CodingKey {
        case posts = "item"
    }
}

struct RSSPost: Codable {
    let title: String?
    let content: String?
    let pubDate: String?
    let link: String?
    let contentEncoded: String?

    enum CodingKeys: String, CodingKey {
        case title, pubDate, link
        case contentEncoded = "content:encoded"
        case content = "description"
    }
}
struct CreatePostInput2: Codable {
    let title: String
    let content: String
    let url: String

    let publishedAt: Date
}

/**
 rss 는 데이터 잘 나옴
 컴바인으로 뷰모델의 변화를 인식해 핸들링 가능 - 인스턴스 생성 - 상속하면 안됨 - model에 구조체 - 뷰모델이 클래스 생성해서 정리
 클로저 함수 쓸때 self 쓸일 있으면 weak self 사용해서 뭐시깽 해야함 안하면 존나 강한 참조되서 레퍼런스 참조를 하고 있으면 메모리에서 삭제를 안해준다 심각한 문제구나;

 -
     - 블로그 rss 등록 기능 재 확인 후 서버에 post요청 넣기
     - 캘린더 셀 선규님꺼 같이 쓰기
     - 겟 요청으로 계정내 가지고 있는 게시물 정보 긁어서 파싱하기
     - xml 파서 등록된 블로그 별 rss 데이터 서버로 post요청 넣기 - 서버와 rss 받아온 데이터와 비교해서 차이나는 부분 서버로 전달 로직짜기
     - 태그는 뭐 현재 잘 작동해서 걸러주니까 그 로직 보기 좋게 정리하고
     - 펍데이터 좀 여러가지 케이스 두고 데이터 뽑힐때까지 돌아가는 로직 작성
 */
/**
 extension UIImageView {
     func setImage(_ image: UIImage?, duration: Double = 0.3) {
         UIView.transition(with: self, duration: duration, options: .transitionCrossDissolve, animations: {
             self.image = image
         }, completion: nil)
     }

     func load(url: URL, completion: ((UIImage?) -> Void)? = nil) {
         DispatchQueue.global().async { [weak self] in
             guard let data = try? Data(contentsOf: url) else { completion?(nil); return }
             guard let image = UIImage(data: data) else { completion?(nil); return }
             DispatchQueue.main.async {
                 self?.image = image
                 completion?(image)
             }
         }
     }
 }
  */

// UInt64
// 매번 업데이트는 애바니까 til의 마지막 날짜를 저장해 놓고
// iso8601

// 시간 date타입과 string타입 전환간의 익스텐션 만듥
// 저는 서버에서 왜 timestamp로 저장해야 하는지를 이해를 못하는중 - 그냥 문자열로 저장하면 안되나?
// 마지막 발행일 저장
// - 키워드가 바뀌면 rss내용 자체가 싹다 바뀌니까 이럴땐 처음부터 다 보낸다?
// 블로그 별로 rss를 보내되 키워드
var tag: [String] = ["테스트", "마작"]
var blogUrl: String = "https://noobd.tistory.com"
var blogRssUrl: [String] = ["https://skypine.tistory.com/rss"]
var datesWithCatData: [CreatePostInput2] = []
var monthDateFormat: String = ""
var monthDatanum = ""
var descriptionStr: [CreatePostInput2] = []
var descriptionStr2: String?
var serverBlogContent : [CreatePostInput2] = []
// 앱 이름 "나 오늘 이거 배웠다" 510 오늘의 일과 공유
// Rss 구현중
// 디크립션 content
// 시간
// 더미데이터 비슷하게해서 적용해보기

var tempRssModel: CreatePostInput2?

class CalendarViewController: UIViewController {
    private var rssList: RSS?
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
    fileprivate var datesWithCat: [String] = []
    private let calendarResultContent = UILabel().then {
        $0.text = "5"
        $0.textColor = .black
        $0.font = .boldSystemFont(ofSize: 30)
        $0.numberOfLines = 1
        $0.textAlignment = .center
    }

    private let tableView = UITableView().then {
        $0.register(UserTableViewCell.self, forCellReuseIdentifier: "UserCell")
//        $0.backgroundColor = .blue
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

//    Could not build Objective-C module 'FlexLayoutYogaKit'
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        tableView.delegate = self
        tableView.dataSource = self
        let date = Date() // 2021-10-13 17:16:15 +0000
        var unixTime = date.timeIntervalSince1970 // 1634145375.8035932
        let unixTimeStr = String(unixTime) // "1634145375.8035932"

        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "yyyyMMdd"
        // String to Date
        let unixTime2 = Double(unixTimeStr) ?? 0.0 // 1634145375.8035932
        let date2 = Date(timeIntervalSince1970: unixTime2) // 2021-10-13 17:16:15 +0000
        unixTime = date2.timeIntervalSince1970

        var separateUrl = blogUrl.components(separatedBy: "https://").joined()
        separateUrl = separateUrl.components(separatedBy: "/rss").joined()
        separateUrl = separateUrl.components(separatedBy: "/feed").joined()
        let splitUrl = separateUrl.split(separator: "/")
        // 명확? 사용자 네임이랑
        if splitUrl[0].contains("tistory.com") {
            blogRssUrl.append("https://" + splitUrl[0] + "/rss")
        } else if splitUrl[0].contains("naver.com") {
            blogRssUrl.append("https://" + "rss." + "blog.naver.com/" + splitUrl[1])
        } else if splitUrl[0].contains("velog.io") {
            blogRssUrl.append("https://" + "v2." + "velog.io/rss/" + splitUrl[1])
        } else if splitUrl[0].contains("medium.com") {
            blogRssUrl.append("https://" + "medium.com/feed/" + splitUrl[1])
        }
        blogRssUrl.map {
            respondData(urlString: $0)
        }
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
                datesWithCatData = descriptionStr.filter { calData in
                    var convertStr = ""
                    dateFormatter.dateFormat = "yyyyMMdd"

                    if(dateFormatter.string(from: calData.publishedAt) == tableDateData){
                        return true
                    }
                    return false
                }
                print(datesWithCatData)
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
        var dateComponents = DateComponents()
        // 현재 다루는 셀의 date 값
        let imageDateFormatter = DateFormatter()
        imageDateFormatter.dateFormat = "yyyyMMdd"
        let dateStr = imageDateFormatter.string(from: date)
        let start = dateStr.index(dateStr.startIndex, offsetBy: 0)
        let end = dateStr.index(dateStr.startIndex, offsetBy: 6)
        let result = dateStr.substring(with: start ..< end)
        // 이번달 정보로 지난달의 요일 색 변화
        let monthDataFormatter = DateFormatter()
        monthDataFormatter.dateFormat = "YYYYMM"
        var monthDataStr = monthDataFormatter.string(from: calendar.currentPage)
        //         무한 리로드 현상 막기
        if monthDatanum != monthDataStr {
            monthDatanum = monthDataStr
            calendar.reloadData()
        }
        // 전 후 달의 일 표시 회색으로
        if monthDataStr != result {
            return .lightGray
        } else if datesWithCat.contains(dateStr) {
            // datesWithCat에 해당 날짜가 있다면 cell에 적용될 데이터
            // 요청사항, 연속으로 TIL 작성한 날짜에만 적용될 레이아웃
            if datesWithCat.contains(String(Int(imageDateFormatter.string(from: date))! + 1)) {
                // datesWithCat에 다음날짜가 오늘자인자 확인
                if Int(imageDateFormatter.string(from: date))! + 1 == Int(imageDateFormatter.string(from: Date())) {
                    return .white
                } else {
                    var dateSum = Int(imageDateFormatter.string(from: Date()))! - Int(dateStr)!
                    var notTilSum = 1
                    while dateSum > 0 {
                        if !(datesWithCat.contains(String(Int(dateStr)! + notTilSum))) {
                            break
                        }
                        notTilSum += 1
                        dateSum -= 1
                        if dateSum == 0 {
                            return .white
                            if !(datesWithCat.contains(String(Int(dateStr)! - 1))) {
                                return .white
                            }
                        }
                    }
                }
                // 오늘 날자면 동글 뱅이 표시
            } else if imageDateFormatter.string(from: Date()) == dateStr {
                if !(datesWithCat.contains(String(Int(dateStr)! - 1))) {
                } else {
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
        let eventScaleFactor: CGFloat = 1.2
        cell.eventIndicator.transform = CGAffineTransform(scaleX: eventScaleFactor, y: eventScaleFactor)
        let imageDateFormatter = DateFormatter()
        imageDateFormatter.dateFormat = "yyyyMMdd"
        let dateStr = imageDateFormatter.string(from: date)
        cell.imageView.tintColor = UIColor(red: 1.00, green: 0.42, blue: 0.21, alpha: 1.00)
        // cell 재사용때
        if cell.subviews[0].frame.origin.y >= 5 {
            cell.subviews[0].removeFromSuperview()
        }
        cell.titleLabel.backgroundColor = .clear
        customView.backgroundColor = .clear
        // cell에 연속일수 표시하는 뷰 넣어주기
        if datesWithCat.contains(dateStr) {
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
            cell.sendSubviewToBack(customView)
            if datesWithCat.contains(String(Int(imageDateFormatter.string(from: date))! + 1)) {
                // datesWithCat에 다음날짜가 오늘자인자 확인
                if Int(imageDateFormatter.string(from: date))! + 1 == Int(imageDateFormatter.string(from: Date())) {
                    // 이어지는 뷰 넣어주기
                    customView.backgroundColor = .init(named: "AccentColor")
                    customView.layer.cornerRadius = 0
                    return
                } else {
                    var dateSum = Int(imageDateFormatter.string(from: Date()))! - Int(dateStr)!
                    var notTilSum = 1
                    while dateSum > 0 {
                        if !(datesWithCat.contains(String(Int(dateStr)! + notTilSum))) {
                            break
                        }
                        notTilSum += 1
                        dateSum -= 1
                        if dateSum == 0 {
                            // til 연속일자 중간 설정
                            customView.backgroundColor = .init(named: "AccentColor")
                            customView.layer.cornerRadius = 0
                            if !(datesWithCat.contains(String(Int(dateStr)! - 1))) {
                                // til 연속일자 시작 설저
                                customView.backgroundColor = .init(named: "AccentColor")
                                customView.layer.cornerRadius = (calendarView.bounds.height / 10) / 2 - 6
                                customView.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMinXMaxYCorner)
                                return
                            }
                        }
                    }
                }
                // 오늘 날자면 동글 뱅이 표시
            } else if imageDateFormatter.string(from: Date()) == dateStr {
                if !(datesWithCat.contains(String(Int(dateStr)! - 1))) {
                    customView.backgroundColor = .init(named: "AccentColor")
                    customView.layer.cornerRadius = (calendarView.bounds.height / 10) / 2 - 6
                    customView.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner)
//                    cell.titleLabel.backgroundColor = .white
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
        let imageDateFormatter = DateFormatter()
        imageDateFormatter.dateFormat = "yyyyMMdd"
        let dateStr = imageDateFormatter.string(from: date)
        if datesWithCat.contains(dateStr) {
            return 1
        } else {
            return 0
        }
    }

    // dot 위치 조정
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventOffsetFor date: Date) -> CGPoint {
        return CGPoint(x: 0, y: 1)
    }
}

extension CalendarViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datesWithCatData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as? UserTableViewCell else {
            return UITableViewCell()
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateStr = dateFormatter.string(from: datesWithCatData[index].publishedAt)
      
        cell.userTILView.setup(withTitle: datesWithCatData[index].title, content: datesWithCatData[index].content, date: dateStr)
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "", message: datesWithCatData[indexPath.row].title, preferredStyle: UIAlertController.Style.alert)
        let deleteAction = UIAlertAction(title: "리로드", style: UIAlertAction.Style.destructive) { _ in
            tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "취소", style: UIAlertAction.Style.cancel, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        present(alert, animated: true)
    }
    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 99
    }
}

extension CalendarViewController {
    func respondData(urlString : String) {

        guard let url = URL(string: urlString) else { return }
        let task = URLSession.shared.dataTask(with: url){ data, response, error in
            if let error = error {
                print("Error: \(error)")
            } else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                do {

                    self.rssList = try XMLDecoder().decode(RSS.self, from: data)


                    DispatchQueue.main.async { [self] in
                        var createPostData : [CreatePostInput2]
                        // rss 데이터 맵돌리기
                        createPostData = rssList!.channel.posts.enumerated().map{ (index,indexData) in
                            // pubDate 관련 변수

                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss z"
                            dateFormatter.locale = Locale(identifier:"en_US")

                            var postTitle = indexData.title ?? ""
                            var postUrl = indexData.link ?? ""
                            var postPublishedAt : Date = dateFormatter.date(from: "2023-10-28 08:21:01 +0000")!

                            dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"

                            // title 데이터 가공
                            if let convertTitle = indexData.title{
                                postTitle = convertTitle
                            }

                            // pubDate 데이터 가공
                            if let convertDate = dateFormatter.date(from: indexData.pubDate!) {
                                postPublishedAt = convertDate
                            }

                            // link 데이터 가공
                            if let convertLink = rssList!.channel.posts[index].link {
                                let convertUrlString = convertLink.replacingOccurrences(of: "<[^>]+>|\t|\n", with: "", options: .regularExpression, range: nil)
                                postUrl = convertUrlString
                            }

                            var content = indexData.content ?? indexData.contentEncoded

                            if let unwrapContent = content {

                                content = unwrapContent.replacingOccurrences(of: "<[^>]+>|\t|\n|;|&nbsp", with: "", options: .regularExpression, range: nil)
                            }


                            return .init(
                                title: postTitle,
                                content: content ?? "",
                                url: postUrl,
                                publishedAt: postPublishedAt
                            )
                        }
                        createPostData = createPostData.filter{ filterIndex in
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyyMMdd"
                            var dateStr = ""
                            var tagBool = false

                            let convertStr = dateFormatter.string(from: filterIndex.publishedAt)

                            dateStr = convertStr

                            tag.map {

                                if filterIndex.title.contains($0) {

                                    datesWithCat.map { catDate in
                                        if dateStr == catDate {
                                            datesWithCat = datesWithCat.filter { $0 != catDate }
                                        }
                                    }
                                    datesWithCat.append(dateStr)
                                    datesWithCat.sort()

                                    descriptionStr.append(filterIndex)
                                    tagBool = true
                                }
                            }
                            return tagBool
                        }
                        // 블로그 별로 나눠서 2개의 배열이 됨
//                        print("-------------------------",descriptionStr,"-------------------------")
                        calendarView.reloadData()
                        datesWithCatData = descriptionStr
                        //
            
                        tableView.reloadData()
                        fightingMessage()
                    }
                } catch {
                    print("Error parsing JSON response")
                }
            } else {
                print("에러에러에러에러")
            }
        }
        task.resume()
    }
    func fightingMessage () {
        let imageDateFormatter = DateFormatter()
        imageDateFormatter.dateFormat = "yyyyMMdd"
        if imageDateFormatter.string(from: Date()) == datesWithCat.last! {

            if datesWithCat.count == 1 {

                calendarResultContent.text = "오늘의 TIL을 작성하셨군요? 앞으로도 쭉 달려봐요!"
            } else if (Int(datesWithCat[datesWithCat.count - 1])! - Int(datesWithCat[datesWithCat.count - 2])!) == 1 {
                var i = datesWithCat.count - 2
                var compleDateCount = 1
                var arrayComparison = Int(datesWithCat[datesWithCat.count - 1])!
                while i >= 0 {
                    if (arrayComparison - Int(datesWithCat[i])!) == 1 {
                        arrayComparison = Int(datesWithCat[i])!
                        compleDateCount += 1
                    } else {
                        calendarResultContent.text = "\(compleDateCount)일 연속 TIL 작성!"
                        break
                    }
                    if i == 0 {
                        calendarResultContent.text = "\(compleDateCount)일 연속 TIL 작성!"
                        break
                    }
                    i -= 1
                }
            } else {
                calendarResultContent.text = "조금만 더 힘내봐요!"
            }
        } else {
            calendarResultContent.text = "조금만 더 힘내봐요!"
        }
    }

}
