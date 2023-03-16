//
//  CategoryService.swift
//  Haru
//
//  Created by 이준호 on 2023/03/16.
//

import Alamofire
import Foundation

final class CategoryService {
    private static let baseURL = Constants.baseURL + "category/"
    
    /**
     * 카테고리 목록 가져오기
     */
    func fetchCategoryList(_ completion: @escaping (Result<[Category], Error>) -> Void) {
        struct Response: Codable {
            let success: Bool
            let data: [Category]
        }
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]
        
        AF.request(
            CategoryService.baseURL + Global.shared.user!.id + "/categories",
            method: .get,
            headers: headers
        )
        .responseDecodable(of: Response.self) { response in
            switch response.result {
            case let .success(response):
                completion(.success(response.data))

            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    /**
     * TODO: 카테고리 목록 추가하기
     */
//    func addCategory(_ completion: @escaping (Result<[]>))
    
}
