//
//  ProductModel.swift
//  ThirdwayvTask
//
//  Created by Ibrahim Mo Gedami on 30/01/2022.
//

import Foundation

struct Product: Codable {
    let data: [ProductData]
}

// MARK: - Datum
struct ProductData: Codable {
    let id: Int
    let productDescription: String
    let image: Image
    let price: Int
}

// MARK: - Image
struct Image: Codable {
    let width, height: Int
    let url: String
}
