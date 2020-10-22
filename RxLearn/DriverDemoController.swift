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
        
       
    }
    
    
    //问题1：这里订阅了两次，但是也请求了两次网络，很明显如果订阅次数非常多次，网络请求也就会非常多次，这样的话会浪费网络资源，占用带宽。
    //问题2：从第二次订阅的时候打印的线程可以看出来，网络请求完数据，订阅到数据还在子线程，如果在这里面进行UI刷新的话，会出现问题。
    //问题3：在这里没有对error事件进行订阅，如果产生了error,会报错误而崩溃。
    func normalProblem_subscribe() {
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
    
    
    //这样的话就解决了上面的问题
    func normalSolveProblem_subscribe() {
        let queryResults = query.rx.text.throttle(RxTimeInterval.microseconds(300), scheduler: MainScheduler.instance)
        let result = queryResults.flatMap {
            self.fetchAutoCompleteItems($0).observeOn(MainScheduler.instance).catchErrorJustReturn("错误事件")
        }.share(replay: 1, scope: .whileConnected)
        
        result.subscribe(onNext: { (element) in
            print("订阅到 \(element)")
        }).disposed(by: disposeBag)
     
        query.rx.text.orEmpty.map({
            return $0 + "x"
        }).subscribe(countLabel1.rx.text)
        
        result.subscribe(onNext: { (element) in
            print("订阅到 \(element)----\(Thread.current)")
        }).disposed(by: disposeBag)
    }
    
    func solveProblemByUseDriver(){
        let queryResults = query.rx.text.throttle(RxTimeInterval.microseconds(300), scheduler: MainScheduler.instance)
        let result = queryResults.flatMap {
            //  仅仅提供发生错误时的备选返回值
            return self.fetchAutoCompleteItems($0).asDriver(onErrorJustReturn: "检测到了错误事件")
        }
        
        //drive()方法绑定UI
        result.subscribe(onNext: { (element) in
            print("订阅到 \(element)")
        }).disposed(by: disposeBag)
        
        //drive()方法绑定UI
        result.subscribe(onNext: { (element) in
            print("订阅到 \(element)----\(Thread.current)")
        }).disposed(by: disposeBag)
        
        
        let driver = query.rx.text.asDriver().flatMap {
            return self.fetchAutoCompleteItems($0).asDriver(onErrorJustReturn: "123")
        }
        driver.drive(self.countLabel1.rx.text).disposed(by: disposeBag)
        
    }
    
    
    
    
    
    
    
    
    func fetchAutoCompleteItems(_ inputText:String?) -> Observable<String>{
        print("开始请求网络 \(Thread.current)")
        return Observable<String>.create({ (ob) -> Disposable in
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
    
    
    //
    ///
    ///
    ///
    ///
  
    ///
    ///
    ///
    ///
    func normalProblem(){
        normalProblem_subscribe()
    }

}


