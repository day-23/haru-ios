//
//  AFProxy.swift
//  Haru
//
//  Created by 최정민 on 11/1/23.
//

import Alamofire
import Foundation

final class AFProxyClass {
    private init() {}
    static let `default`: AFProxyClass = .init()

    static let interceptor: ApiRequestInterceptor = .init()

    public func request(_ convertible: URLConvertible,
                        method: HTTPMethod = .get,
                        parameters: Parameters? = nil,
                        encoding: ParameterEncoding = URLEncoding.default,
                        headers: HTTPHeaders? = nil,
                        interceptor: RequestInterceptor? = nil,
                        requestModifier: RequestModifier? = nil) -> DataRequest
    {
        let convertible = RequestConvertible(url: convertible,
                                             method: method,
                                             parameters: parameters,
                                             encoding: encoding,
                                             headers: headers,
                                             requestModifier: requestModifier)

        return AF.request(convertible,
                          interceptor: interceptor == nil
                              ? AFProxyClass.interceptor
                              : interceptor)
    }

    public func request<Parameters: Encodable>(_ convertible: URLConvertible,
                                               method: HTTPMethod = .get,
                                               parameters: Parameters? = nil,
                                               encoder: ParameterEncoder = URLEncodedFormParameterEncoder.default,
                                               headers: HTTPHeaders? = nil,
                                               interceptor: RequestInterceptor? = nil,
                                               requestModifier: RequestModifier? = nil) -> DataRequest
    {
        let convertible = RequestEncodableConvertible(url: convertible,
                                                      method: method,
                                                      parameters: parameters,
                                                      encoder: encoder,
                                                      headers: headers,
                                                      requestModifier: requestModifier)

        return AF.request(convertible,
                          interceptor: interceptor == nil
                              ? AFProxyClass.interceptor
                              : interceptor)
    }

    public func upload(multipartFormData: @escaping (MultipartFormData) -> Void,
                       to url: URLConvertible,
                       usingThreshold encodingMemoryThreshold: UInt64 = MultipartFormData.encodingMemoryThreshold,
                       method: HTTPMethod = .post,
                       headers: HTTPHeaders? = nil,
                       interceptor: RequestInterceptor? = nil,
                       fileManager: FileManager = .default,
                       requestModifier: RequestModifier? = nil) -> UploadRequest
    {
        let convertible = ParameterlessRequestConvertible(url: url,
                                                          method: method,
                                                          headers: headers,
                                                          requestModifier: requestModifier)

        let formData = MultipartFormData(fileManager: fileManager)
        multipartFormData(formData)

        return AF.upload(multipartFormData: formData,
                         with: convertible,
                         usingThreshold: encodingMemoryThreshold,
                         interceptor: interceptor == nil
                             ? AFProxyClass.interceptor
                             : interceptor,
                         fileManager: fileManager)
    }

    public typealias RequestModifier = (inout URLRequest) throws -> Void

    struct RequestConvertible: URLRequestConvertible {
        let url: URLConvertible
        let method: HTTPMethod
        let parameters: Parameters?
        let encoding: ParameterEncoding
        let headers: HTTPHeaders?
        let requestModifier: RequestModifier?

        func asURLRequest() throws -> URLRequest {
            var request = try URLRequest(url: url, method: method, headers: headers)
            try requestModifier?(&request)

            return try encoding.encode(request, with: parameters)
        }
    }

    struct RequestEncodableConvertible<Parameters: Encodable>: URLRequestConvertible {
        let url: URLConvertible
        let method: HTTPMethod
        let parameters: Parameters?
        let encoder: ParameterEncoder
        let headers: HTTPHeaders?
        let requestModifier: RequestModifier?

        func asURLRequest() throws -> URLRequest {
            var request = try URLRequest(url: url, method: method, headers: headers)
            try requestModifier?(&request)

            return try parameters.map { try encoder.encode($0, into: request) } ?? request
        }
    }

    struct ParameterlessRequestConvertible: URLRequestConvertible {
        let url: URLConvertible
        let method: HTTPMethod
        let headers: HTTPHeaders?
        let requestModifier: RequestModifier?

        func asURLRequest() throws -> URLRequest {
            var request = try URLRequest(url: url, method: method, headers: headers)
            try requestModifier?(&request)

            return request
        }
    }
}

let AFProxy: AFProxyClass = .default
