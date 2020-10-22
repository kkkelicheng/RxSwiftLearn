//
//  ConnectableObservableController.swift
//  RxLearn
//
//  Created by Emma Sun on 2020/10/22.
//  Copyright © 2020 Shushangyun. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ConnectableObservableController: UIViewController {
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "可连接的被观察者"
        // Do any additional setup after loading the view.
    }
    
    
   @IBAction @objc func test_publish(){
        print("publish")
        let intSequence = Observable<Int>
            .interval(1, scheduler: MainScheduler.instance)
                          .publish()
        _ = intSequence
            .subscribe(onNext: { print("Subscription 1:, Event: \($0)") }).disposed(by: self.disposeBag)
  
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            print("-----2-----")
            _ = intSequence.connect().disposed(by: self.disposeBag) //connect后立即执行闭包，创建好Observable
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            print("-----4-----")
            _ = intSequence
                .subscribe(onNext: { print("Subscription 2:, Event: \($0)") }).disposed(by: self.disposeBag)
        }
        /*
         -----2-----
         Subscription 1:, Event: 0
         Subscription 1:, Event: 1
         -----4-----
         Subscription 1:, Event: 2
         Subscription 2:, Event: 2
         Subscription 1:, Event: 3
         Subscription 2:, Event: 3
         */
    }
    
    @IBAction @objc func test_replay(){
         print("test_replay size 1")
        let intSequence = Observable<Int>
            .interval(1, scheduler: MainScheduler.instance)
            .replay(1)
        _ = intSequence
            .subscribe(onNext: { print("Subscription 1:, Event: \($0)") }).disposed(by: self.disposeBag)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            print("-----2-----")
            _ = intSequence.connect().disposed(by: self.disposeBag) //connect后立即执行闭包，创建好Observable
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            print("-----6-----")
            _ = intSequence
                .subscribe(onNext: { print("Subscription 2:, Event: \($0)") }).disposed(by: self.disposeBag)
        }
        /*
         test_replay size 1
         -----2-----
         Subscription 1:, Event: 0
         Subscription 1:, Event: 1
         Subscription 1:, Event: 2
         -----6-----
         Subscription 2:, Event: 2
         Subscription 1:, Event: 3
         Subscription 2:, Event: 3
         Subscription 1:, Event: 4
         Subscription 2:, Event: 4
         */
    }
    
    @IBAction @objc func test_replayAll(){
        print("test_replayAll")
        let intSequence = Observable<Int>
            .interval(1, scheduler: MainScheduler.instance)
            .replayAll()
        _ = intSequence
            .subscribe(onNext: { print("Subscription 1:, Event: \($0)") }).disposed(by: self.disposeBag)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            print("-----2-----")
            _ = intSequence.connect().disposed(by: self.disposeBag) //connect后立即执行闭包，创建好Observable
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            print("-----6-----")
            _ = intSequence
                .subscribe(onNext: { print("Subscription 2:, Event: \($0)") }).disposed(by: self.disposeBag)
        }
        
        /*
         test_replayAll
         -----2-----
         Subscription 1:, Event: 0
         Subscription 1:, Event: 1
         Subscription 1:, Event: 2
         -----6-----
         Subscription 2:, Event: 0
         Subscription 2:, Event: 1
         Subscription 2:, Event: 2
         Subscription 1:, Event: 3
         Subscription 2:, Event: 3
         Subscription 1:, Event: 4
         Subscription 2:, Event: 4
         */
    }
    
    @IBAction @objc func test_Multicast(){
        print("test multi cast")
        let subject = PublishSubject<Int>()
        
        _ = subject
            .subscribe(onNext: { print("Subject: \($0)") }).disposed(by: self.disposeBag)
        
        let intSequence = Observable<Int>
            .interval(1, scheduler: MainScheduler.instance)
            .multicast(subject)
        
        //multicast（广播）相当于代理了一层，这个subject相当于广播的中心，intSequence，后面的subscribe就是多个广播的渠道

        _ = intSequence
                   .subscribe(onNext: { print("Subscription 1:, Event: \($0)") }).disposed(by: self.disposeBag)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            print("-----2 connected-----")
            _ = intSequence.connect().disposed(by: self.disposeBag) //connect后立即执行闭包，创建好Observable
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            print("-----4-----")
              _ = intSequence.subscribe(onNext: { print("Subscription 2:, Event: \($0)") }).disposed(by: self.disposeBag)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            print("-----6-----")
            _ = intSequence
                .subscribe(onNext: { print("Subscription 3:, Event: \($0)") }).disposed(by: self.disposeBag)
        }
        
        /*
         -----2 connected-----
         Subject: 0  //中心代理打印的
         Subscription 1:, Event: 0
         -----4-----
         Subject: 1
         Subscription 1:, Event: 1
         Subscription 2:, Event: 1
         Subject: 2
         Subscription 1:, Event: 2
         Subscription 2:, Event: 2
         -----6-----
         Subject: 3 //这里新增了一个渠道observer Subscription 3
         Subscription 1:, Event: 3
         Subscription 2:, Event: 3
         Subscription 3:, Event: 3
         */
    }

    
}
