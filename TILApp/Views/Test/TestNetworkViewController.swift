#if DEBUG

import Combine
import CombineMoya
import FlexLayout
import Moya
import PinLayout
import Then
import UIKit

struct Pong: Codable {
    let message: String
    let version: String
    let build: String
    let env: String
    let tz: String
}

final class TestNetworkViewController: UIViewController {
    private lazy var label = UILabel().then { label in
        label.text = "Network Test!"
        label.textAlignment = .center
    }

    private lazy var signButton = UIButton().then { button in
        button.setTitle("Sign In", for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.backgroundColor = .systemTeal
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = .init(top: 6, left: 10, bottom: 6, right: 10)
        button.addTarget(self, action: #selector(signIn), for: .touchUpInside)
    }

    private lazy var requestButton = UIButton().then { button in
        button.setTitle("Request!", for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.backgroundColor = .systemTeal
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = .init(top: 6, left: 10, bottom: 6, right: 10)
        button.addTarget(self, action: #selector(requestButtonTapped), for: .touchUpInside)
    }

    private lazy var statusLabel = UILabel().then { label in
        label.text = "Click Button to Authenticate!"
        label.textAlignment = .center
    }

    // Combine을 사용하려면 필수! 반드시 클래스 속성으로 작성해야 합니다.
    private var cancellables: [AnyCancellable] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
        print(Date().unixtime)

//        moya1()
//        moya2()
//        moya3()
//        moya4()

        // https://github.com/Moya/Moya/issues/2247
        // Swift의 Task와 Moya의 Task가 충돌하면서 발생한 문제인데 아직도 안 고쳐줬네요...
        // Swift의 Task를 사용하시려면 _Concurrency.Task를 대신 사용하시면 됩니다.
//        _Concurrency.Task {
//            await moya5()
//        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.flex.layout()
    }

    private func configureUI() {
        view
            .flex
            .backgroundColor(.systemBackground)
            .direction(.column)
            .justifyContent(.center)
            .padding(40)
            .define { flex in
                flex.addItem(label)
                flex.addItem(requestButton).marginTop(20)
                flex.addItem(signButton).marginTop(40)
                flex.addItem(statusLabel).marginTop(10)
            }

        AuthViewModel.shared.$isAuthenticated.sink { [weak self] authenticated in
            guard let self else { return }
            self.signButton.removeTarget(nil, action: nil, for: .allEvents)
            if authenticated {
                self.signButton.setTitle("Sign Out", for: .normal)
                self.signButton.addTarget(self, action: #selector(signOut), for: .touchUpInside)
                self.statusLabel.text = "Authenticated Successfully!"
            } else {
                self.signButton.setTitle("Sign In", for: .normal)
                self.signButton.addTarget(self, action: #selector(signIn), for: .touchUpInside)
                self.statusLabel.text = "Click Button to Authenticate!"
            }
            self.statusLabel.sizeToFit()
        }.store(in: &cancellables)
    }

    // MARK: - APIService (NetworkLayer) 작성방법

    @objc private func requestButtonTapped() {
        APIService.shared.request(.getProfile) { response in
            _ = response
        }

        APIService.shared.request(.getProfile) { response in
            _ = response
            print(response)
        } onError: { error in
            _ = error
            print(error)
        }

        APIService.shared.request(.getProfile, model: AuthUser.self) { model in
            _ = model
        }

        APIService.shared.request(.getProfile, model: AuthUser.self) { model in
            _ = model
            print(model)
        } onError: { error in
            _ = error
            print(error)
        }
    }

    // MARK: - Using Custom APIService with Moya

    private let provider = MoyaProvider<APIRequest>()

    // MARK: - #1 Moya

    private func moya1() {
        provider.request(.ping) { result in
            switch result {
            case .success(let response):
                print("#1 Start")
                guard let json = try? response.mapJSON() else { return }
                guard let pong = try? response.map(Pong.self) else { return }
                print(json)
                print(pong)
                print("#1 End")
            case .failure(let error):
                print(error)
            }
        }
    }

    // MARK: - #2 Moya + Combine

    private func moya2() {
        provider
            .requestPublisher(.ping)
            .print("[Moya + Combine 기본]") // 디버깅용
            .sink { completion in
                guard case .failure(let error) = completion else { return }
                print(error)
            } receiveValue: { response in
                print("#2 Start")
                guard let json = try? response.mapJSON() else { return }
                guard let pong = try? response.map(Pong.self) else { return }
                print(json)
                print(pong)
                print("#2 End")
            }.store(in: &cancellables) // store를 호출해야 정상적으로 요청 가능
    }

    // MARK: - #3 Moya + Combine (Mapping Model)

    private func moya3() {
        provider
            .requestPublisher(.ping)
            .map(Pong.self) // Codable한 Model 형식으로 변환합니다.
            .print("[Moya + Combine (Mapping Model)]")
            .sink { completion in
                guard case .failure(let error) = completion else { return }
                print(error)
            } receiveValue: { pong in
                print("#3 Start")
                print(pong)
                print("#3 End")
            }.store(in: &cancellables)
    }

    // MARK: - #4 Request with payload

    private func moya4() {
        provider.request(.signIn(.init(
            username: "asdf",
            avatarUrl: "http://url.com",
            provider: "APPLE",
            providerId: "1234"
        ))) { result in
            switch result {
            case .success(let response):
                print("#4 Start")
                guard let output = try? response.map(SignInOutput.self) else { return }
                print(output)
                print("#4 End")
            case .failure(let error):
                print(error)
            }
        }
    }

    // MARK: - #5 Request using async/await

    private func moya5() async {
        let result = await provider.request(.ping)
        switch result {
        case .success(let response):
            print("#1 Start")
            guard let json = try? response.mapJSON() else { return }
            guard let pong = try? response.map(Pong.self) else { return }
            print(json)
            print(pong)
            print("#1 End")
        case .failure(let error):
            print(error)
        }
    }

    // MARK: - Authentication

    @objc private func signIn() {
        AuthViewModel.shared.signIn(.init(
            username: nil,
            avatarUrl: nil,
            provider: "APPLE",
            providerId: "1234"
        )) { user in
            print(user)
        } onError: { error in
            print(error)
        }
    }

    @objc private func signOut() {
        AuthViewModel.shared.signOut()
    }
}

#endif
