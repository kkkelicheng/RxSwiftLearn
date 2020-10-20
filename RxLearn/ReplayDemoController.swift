//
//  ReplayDemoController.swift
//  RxLearn
//
//  Created by Emma Sun on 2020/10/20.
//  Copyright © 2020 Shushangyun. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class ReplayDemoController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        test()
        // Do any additional setup after loading the view.
    }
    
    func test(){
        let intSequence = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
            .replay(3) //replay 操作符将 Observable 转换为可被连接的 Observable
        //并且这个可被连接的 Observable 将缓存最新的 n 个元素。当有新的观察者对它进行订阅时，它就把这些被缓存的元素发送给观察者

        _ = intSequence
            .subscribe(onNext: { print("Subscription 1:, Event: \($0)") })

        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            print("已经过去6s，开始连接")
            //不过在被订阅后不会发出元素，直到 connect 操作符被应用为止
            _ = intSequence.connect()
            //connect以后才会开始执行信号
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 12) {
          _ = intSequence
              .subscribe(onNext: { print("Subscription 3:, Event: \($0)") })
        }
        
        /*
         已经过去6s，开始连接
         Subscription 1:, Event: 0
         Subscription 1:, Event: 1
         Subscription 1:, Event: 2
         Subscription 1:, Event: 3
         Subscription 1:, Event: 4
         
         Subscription 3:, Event: 2  //这里的因为缓存了3个，就是从2开始回放
         Subscription 3:, Event: 3
         Subscription 3:, Event: 4
         Subscription 1:, Event: 5
         Subscription 3:, Event: 5
         
         */
    }

}
