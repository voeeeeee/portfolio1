//
//  ViewController.swift
//  UmbrellaJudgement
//
//  Created by 竹辻篤志 on 2020/10/04.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class HomeVC: UIViewController,CLLocationManagerDelegate {
    
    //各変数へ初期値を入れておく
    var latitudeNow: Double = 39.0000
    var longitudeNow: Double = 140.0000
    var locationManager: CLLocationManager!
    var administrativeArea:String = ""
    var locationNow: String = ""
    private var citymodel: cityModel?
    var doubleOfMaximumPop:Double = 100.0
    var maxPop:Int = 30
    var Judge:String = ""
    
    
    @IBOutlet weak var umbrellaImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //image viewのレイアウト設定
        umbrellaImage.image = UIImage(named:"umbrellaImage")
        umbrellaImage.layer.cornerRadius = 10
        
        //位置情報が取得できているか確認
        print(latitudeNow,longitudeNow)
        
        //locationManagerをviewDidload時に呼び出す（位置情報を更新する）
        locationManagerDidChangeAuthorization(CLLocationManager())
        
        //天気取得関数の呼び出し
        getWeatherData()
        
    }
    
    //    ボタンを押した際に位置情報を取得する
    @IBAction func buttonTapped(_ sender: Any) {
        
        //ボタンを押すとlocationManager更新をやめる
        stopLocationManager()
    }
    
    //    ボタンを押すとsegueに移行し、UmbrellaVC内のLabel1に都道府県を記載する
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toUmbrellaVC") {
            let  locationNow: UmbrellaVC = (segue.destination as? UmbrellaVC)!
            locationNow.locationText = administrativeArea
            
            let popNow:UmbrellaVC = (segue.destination as? UmbrellaVC)!
            popNow.popText = Int(maxPop)
            
            let umbJud:UmbrellaVC = (segue.destination as? UmbrellaVC)!
            umbJud.umbrellaJudgement = Judge
            
        }
    }
    
    //----------------------------------------------------------------------
    
    //ロケーションマネージャー＠iOS 14　位置情報の更新
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationManager = CLLocationManager()
        
        let status = manager.authorizationStatus
        
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
            
        case .notDetermined, .denied, .restricted:
            showAlert()
            
        default:print("未処理")
        }
    }
    
    //locationManagerの情報更新をやめる
    func stopLocationManager(){
        locationManager.stopUpdatingLocation()
    }

    //----------------------------------------------------------------------
    
    //アラートを表示する関数
    func showAlert(){
        let alertTitle = "位置情報取得が許可されていません。"
        let alertMessage = "設定アプリの「プライバシー > 位置情報サービス」から変更してください。"
        let alert: UIAlertController = UIAlertController(
            title: alertTitle, message: alertMessage, preferredStyle: UIAlertController.Style.alert
        )
        //OKボタン
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        
        //UIAlertControllerにActionを追加
        alert.addAction(defaultAction)
        present(alert, animated: true, completion: nil)
        
    }
    
    //----------------------------------------------------------------------
    
    //位置情報が更新された際、位置情報を格納する関数
    //位置情報が更新されないとlocation managerは起動しない※重要
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        let location = locations.first
        let latitude = location!.coordinate.latitude
        let longitude = location!.coordinate.longitude
        //位置情報を格納する
        self.latitudeNow = Double(latitude)
        self.longitudeNow = Double(longitude)
        
        //位置情報を取得後逆ジオコーディングし、都道府県を割り出す
        let locationA = CLLocation(latitude: latitudeNow, longitude: longitudeNow)
        
        let geocoder: CLGeocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(locationA) { [self] (placemarks, error) in
            if let placemark = placemarks?.first {
                self.administrativeArea = placemark.administrativeArea!
                
            } else {
                self.administrativeArea = "愛知県"
            }
        }
    }
    
    //----------------------------------------------------------------------
    
    //天気予報APIを用いて18時間後までの最大降水確率を取得する
    private func getWeatherData()  {
        //自分のOpenWeather IDを入力する
        let id = "your ID"
        let baseUrl = "http://api.openweathermap.org/data/2.5/forecast?lat=" + "\(latitudeNow)" + "&lon=" + "\(longitudeNow)" + "&exclude=daily&lang=ja&cnt=6&.pop&appid=" + "\(id)"
        
        AF.request(baseUrl, method: .get).responseJSON { [self] response in
            guard let data = response.data else {
                return
            }
            do {
                let citymodel = try JSONDecoder().decode(cityModel.self, from: data)
                
                //APIのデータをリスト表示する
                let popNumber = citymodel.list.map{ $0.pop }
                
                //APIデータリストを確認する
                print(popNumber)
                
                //リスト内のmaxデータを取得する
                var doubleOfMaximumPop = popNumber.max()
                
                //maxデータのパーセンテージ表示に変換する
                let maxPop = doubleOfMaximumPop! * 100
                
                //データがあるかどうかを判断する
                if doubleOfMaximumPop == nil{
                    print(Error.self)
                }else {
                    //データがあれば、
                    if doubleOfMaximumPop != nil{
                        //maxデータを取得する
                        doubleOfMaximumPop = self.doubleOfMaximumPop
                    }else {
                        //同じ数字であれば、その中のひとつをピックアップする
                        doubleOfMaximumPop = popNumber[0]
                    }
                }
                //maxPopへgetweather関数で取得した数値を代入する(quiita参考)
                self.maxPop = Int(maxPop)
                
                //maxPopによって傘が必要かの判断をし、判断した文をJudgeへ代入する。
                if self.maxPop <= 30 {
                    self.Judge = "⛅️傘は不要です⛅️"
                }else if self.maxPop >= 70 {
                    self.Judge = "☔️傘が必要です☔️"
                }else {
                    self.Judge = "☂️折り畳み傘を持っていれば安心☂️"
                }
                
            }catch let error {
                print("Error:\(error)")
            }
        }
    }
    //----------------------------------------------------------------------
}







