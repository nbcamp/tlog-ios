import Foundation
import XMLCoder

enum RssError: Error {
    case invalidUrl
    case invalidResponse
    case errorOccurred(Error)
    case parseFailed
}

final class RssService {
    static let shared: RssService = .init()
    private init() {}

    private let decoder = XMLDecoder()

    func loadDocument(
        url: String,
        _ completion: @escaping (_ result: Result<[RSSPost], RssError>) -> Void
    ) {
        guard let url = URL(string: url) else { completion(.failure(.invalidUrl)); return }
        URLSession.shared.dataTask(with: url) { [unowned self] data, response, error in
            if let error { completion(.failure(.errorOccurred(error))); return }
            guard let data, let response = response as? HTTPURLResponse,
                  200 ..< 300 ~= response.statusCode
            else { completion(.failure(.invalidResponse)); return }
            do {
                let rss = try decoder.decode(RSS.self, from: data)
                guard let posts = rss.channel?.items else { completion(.success([])); return }
                let sanitizedPosts: [RSSPost] = posts.compactMap { post in
                    guard let title = post.title,
                          let content = post.content ?? post.contentEncoded,
                          let url = post.link,
                          let pubDate = post.pubDate,
                          let publishedAt = toDate(string: pubDate, formats: [
                              "EEE, dd MMM yyyy HH:mm:ss z",
                          ])
                    else { return nil }

                    return .init(
                        title: title,
                        content: .init(sanitize(content: content).prefix(100)),
                        url: url,
                        publishedAt: publishedAt
                    )
                }
                completion(.success(sanitizedPosts))
            } catch {
                debugPrint(#function, error)
                completion(.failure(.parseFailed))
            }
        }.resume()
    }

    func loadDocument(url: String) async throws -> [RSSPost] {
        return try await withCheckedThrowingContinuation { [unowned self] continuation in
            loadDocument(url: url) { result in
                switch result {
                case .success(let res): continuation.resume(returning: res)
                case .failure(let err): continuation.resume(throwing: err)
                }
            }
        }
    }

    private func sanitize(content: String) -> String {
        return content.replacingOccurrences(
            of: "<[^>]+>|\t|\n|;|&[a-z]+;",
            with: "",
            options: .regularExpression,
            range: nil
        )
    }
}
