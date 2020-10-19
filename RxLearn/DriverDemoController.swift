//
//  DriverDemoController.swift
//  RxLearn
//
//  Created by Emma Sun on 2020/10/19.
//  Copyright © 2020 Shushangyun. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class DriverDemoController: UIViewController {

    @IBOutlet weak var countLabel2: UILabel!
    @IBOutlet weak var countLabel1: UILabel!
    @IBOutlet weak var query: UITextField!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let queryResults = query.rx.text.throttle(RxTimeInterval.microseconds(300), scheduler: MainScheduler.instance)
        let result = queryResults.flatMap {
            self.fetchAutoCompleteItems($0)
        }
        
        result.subscribe(onNext: { (element) in
                    print("订阅到 \(element)")
            }).disposed(by: disposeBag)
                
        result.subscribe(onNext: { (element) in
                    print("订阅到 \(element)----\(Thread.current)")
            }).disposed(by: disposeBag)
    }
    
    func fetchAutoCompleteItems(_ inputText:String?) -> Observable<Any>{
        print("开始请求网络 \(Thread.current)")
        return Observable<Any>.create({ (ob) -> Disposable in
            if inputText == "123456" {
                ob.onError(NSError.init(domain: "com.henry", code: 10010, userInfo: nil))
            }
            DispatchQueue.global().async {
                print("发送信号之前: \(Thread.current)")
                ob.onNext("发送的内容:\(inputText)")
                ob.onCompleted()
            }
            return Disposables.create()
        })
    }

}
