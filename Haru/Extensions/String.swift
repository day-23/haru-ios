//
//  String.swift
//  Haru
//
//  Created by 이준호 on 2023/05/12.
//

import Foundation

extension String
{
    func encodeUrl() -> String?
    {
        self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }

    func decodeUrl() -> String?
    {
        self.removingPercentEncoding
    }
}
