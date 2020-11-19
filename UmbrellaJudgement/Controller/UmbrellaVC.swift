//
//  UmbrellaVC.swift
//  UmbrellaJudgement
//
//  Created by 竹辻篤志 on 2020/10/04.
//

import UIKit
import CoreLocation

class UmbrellaVC: UIViewController {
    
    @IBOutlet weak var label1: UILabel!
    var locationText:String = "大阪府"
    
    @IBOutlet weak var label2: UILabel!
    var popText:Int = 0
    
    @IBOutlet weak var label3: UILabel!
    var umbrellaJudgement:String = "傘が必要"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label1.text = locationText
        label2.text = "\(popText)" + "%"
        label3.text = umbrellaJudgement
        
        self.label3.layer.borderWidth = 2.0
        self.label3.layer.borderColor = UIColor.black.cgColor
        self.label3.layer.cornerRadius = 20

        //降水確率によって出てくる文字の色を変えて一目でわかるようにする
        if popText >= 30 && popText < 70{
            label3.textColor = .orange
            
        }else if popText >= 70{
            label3.textColor = .red
        }
    }
}
