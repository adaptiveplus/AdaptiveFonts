//
//  Result.swift
//  AdaptiveFonts
//
//  Created by Nurzhigit on 01.03.2021.
//  Copyright © 2021 Sprint Squads. All rights reserved.
//

enum Result<T> {
    case success(T)
    case failure(Error?)
}
