import Foundation
import Moya

extension NotificationCenter {
//    static func postError(withMessage message: String) {
//        NotificationCenter.default.post(name: .init("ShowErrorAlert"), object: nil, userInfo: ["message": message])
//    }
    
    static func postError(withError error: MoyaError) {
        let message: String
        
        if case .underlying(APIError.error(let msg), _) = error {
            message = msg
        } else {
            message = "알 수 없는 오류가 발생했습니다."
        }
            
        NotificationCenter.default.post(name: .init("ShowErrorAlert"), object: nil, userInfo: ["message": message])
    }
}
