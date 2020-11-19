//
//  CityModel.swift
//  UmbrellaJudgement
//
//  Created by 竹辻篤志 on 2020/10/14.
//

import Foundation

struct cityModel:Decodable{
    
    var list: [List]

    struct List:Decodable {
        var pop:Double
    }
    
}
