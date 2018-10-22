//
//  ViewModel.swift
//  HomeRobot
//
//  Created by Dmitry Suvorov on 21/10/2018.
//  Copyright © 2018 homesuvorov. All rights reserved.
//

import Alamofire
import RxSwift
import RxCocoa
import Alamofire
import AlamofireImage

let raspHost = "http://192.168.1.63:5010/"
enum raspUrls: String, URLRequestConvertible {
    case co2 = "http://192.168.1.63:5010/getCO2"
    case humidity = "http://192.168.1.63:5010/getHum"
    case temperature = "http://192.168.1.63:5010/getTemp"
    case forward = "http://192.168.1.63:5010/up_side"
    case back = "http://192.168.1.63:5010/down_side"
    case left = "http://192.168.1.63:5010/left_side"
    case right = "http://192.168.1.63:5010/right_side"
    
    func asURLRequest() throws -> URLRequest {
        return URLRequest(url: URL(string: self.rawValue)!)
    }
}

class ViewModel {
    let streamImage = PublishSubject<UIImage>()
    let left = PublishSubject<Void>()
    let right = PublishSubject<Void>()
    let forward = PublishSubject<Void>()
    let back = PublishSubject<Void>()
    let co2 = PublishSubject<String>()
    let temperature = PublishSubject<String>()
    let humidity = PublishSubject<String>()
    private let disposeBag = DisposeBag()
    
    init() {
        bindInput()
        bindOutput()
    }
}

private extension ViewModel {
    
    func bindInput() {
        left
            .bind {
                Alamofire.request(raspUrls.left).response{ _ in }
            }
            .disposed(by: disposeBag)
        
        right
            .bind {
                Alamofire.request(raspUrls.right).response{ _ in }
            }
            .disposed(by: disposeBag)
        
        forward
            .bind {
                Alamofire.request(raspUrls.forward).response{ _ in }
            }
            .disposed(by: disposeBag)
        
        back
            .bind {
                Alamofire.request(raspUrls.back).response{ _ in }
            }
            .disposed(by: disposeBag)
    }
    
    func bindOutput() {
        Observable<Int>.timer(RxTimeInterval(exactly: 0)!, period: RxTimeInterval(exactly: 10.0), scheduler: MainScheduler.instance)
            .map { _ in
                return 1
            }
            .bind { _ in
                Alamofire.request(raspUrls.co2)
                    .responseString { co2 in
                        let co2Str = "CO₂: \(co2.value ?? "NA") ppm"
                        self.co2.onNext(co2Str)
                }
            }
            .disposed(by: disposeBag)
        
        Observable<Int>.timer(RxTimeInterval(exactly: 0)!, period: RxTimeInterval(exactly: 10.0), scheduler: MainScheduler.instance)
            .map { _ in
                return 1
            }
            .bind { _ in
                Alamofire.request(raspUrls.temperature)
                    .responseString { temp in
                        let tempStr = "Temperature: \(temp.value ?? "NA")⁰C"
                        self.temperature.onNext(tempStr)
                }
            }
            .disposed(by: disposeBag)
        
        Observable<Int>.timer(RxTimeInterval(exactly: 0)!, period: RxTimeInterval(exactly: 10.0), scheduler: MainScheduler.instance)
            .map { _ in
                return 1
            }
            .bind { _ in
                Alamofire.request(raspUrls.humidity)
                    .responseString { hum in
                        let humStr = "Humidity: \(hum.value ?? "NA")%"
                        self.humidity.onNext(humStr)
                }
            }
            .disposed(by: disposeBag)
    }
}
