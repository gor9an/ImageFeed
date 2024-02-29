//
//  OAuthTokenResponseBody.swift
//  ImageFeed
//
//  Created by Andrey Gordienko on 25.02.2024.
//

import Foundation

struct OAuthTokenResponseBody: Decodable {
    let access_token: String
    let token_type: String
    let scope: String
    let created_at: Int
}
