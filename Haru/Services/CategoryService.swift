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
    
    private init() {}
    
    /**
     * 카테고리 목록 가져오기
     */
    public static func fetchCategoryList(_ completion: @escaping (Result<[Category], Error>) -> Void) {
        struct Response: Codable {
            let success: Bool
            let data: [Category]
        }
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]
        
        AFProxy.request(
            CategoryService.baseURL + (Global.shared.user?.id ?? "unknown") + "/categories",
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
     * 카테고리 추가하기
     */
    public static func addCategory(_ category: Request.Category, _ completion: @escaping (Result<Category, Error>) -> Void) {
        struct Response: Codable {
            let success: Bool
            let data: Category
        }
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]
        
        AFProxy.request(
            CategoryService.baseURL + (Global.shared.user?.id ?? "unknown"),
            method: .post,
            parameters: category,
            encoder: JSONParameterEncoder(),
            headers: headers
        ).responseDecodable(of: Response.self) { response in
            switch response.result {
            case let .success(response):
                completion(.success(response.data))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    /**
     * 카테고리 수정하기 (전체)
     */
    public static func updateAllCategoyList(categoryIds: [String], isSelected: [Bool], _ completion: @escaping (Result<Bool, Error>) -> Void) {
        struct Response: Codable {
            let success: Bool
        }
        
        struct Request: Codable {
            let categoryIds: [String]
            let isSelected: [Bool]
        }
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]
        
        let requestBody = Request(categoryIds: categoryIds, isSelected: isSelected)
        
        AFProxy.request(
            CategoryService.baseURL + (Global.shared.user?.id ?? "unknown") + "/order/categories",
            method: .patch,
            parameters: requestBody,
            encoder: JSONParameterEncoder(),
            headers: headers
        ).responseDecodable(of: Response.self) { response in
            switch response.result {
            case let .success(response):
                completion(.success(response.success))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    public static func updateCategory(
        categoryId: String,
        category: Request.Category,
        completion: @escaping (Result<Category, Error>) -> Void
    ) {
        struct Response: Codable {
            let success: Bool
            let data: Category
        }
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]
        
        AFProxy.request(
            CategoryService.baseURL + (Global.shared.user?.id ?? "unknown") + "/\(categoryId)",
            method: .patch,
            parameters: category,
            encoder: JSONParameterEncoder(),
            headers: headers
        ).responseDecodable(of: Response.self) { response in
            switch response.result {
            case let .success(response):
                completion(.success(response.data))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    public static func deleteCategory(
        categoryId: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        struct Response: Codable {
            let success: Bool
        }
        
        struct Request: Codable {
            let categoryIds: [String]
        }
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]
        
        let requestBody = Request(categoryIds: [categoryId])
        
        AFProxy.request(
            CategoryService.baseURL + (Global.shared.user?.id ?? "unknown") + "/categories",
            method: .delete,
            parameters: requestBody,
            encoder: JSONParameterEncoder(),
            headers: headers
        ).responseDecodable(of: Response.self) { response in
            switch response.result {
            case let .success(response):
                completion(.success(response.success))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
