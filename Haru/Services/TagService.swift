//
//  TagService.swift
//  Haru
//
//  Created by 최정민 on 2023/03/13.
//

import Alamofire
import Foundation

struct TagService {
    private static let baseURL = Constants.baseURL + "tag/"

    // Tags 가져오기
    func fetchTags(completion: @escaping (Result<[Tag], Error>) -> Void) {
        struct Response: Codable {
            let success: Bool
            let data: [Tag]
        }

        AF.request(
            TagService.baseURL + "\(Global.shared.user?.id ?? "unknown")/tags",
            method: .get
        ).responseDecodable(of: Response.self) { response in
            switch response.result {
            case .success(let response):
                completion(.success(response.data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
