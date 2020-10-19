//
//  SimpleValidationController.swift
//  RxLearn
//
//  Created by Emma Sun on 2020/10/19.
//  Copyright © 2020 Shushangyun. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SimpleValidationController: UIViewController {

    @IBOutlet weak var usernameOutlet: UITextField!
    @IBOutlet weak var usernameValidOutlet: UILabel!
    @IBOutlet weak var passwordOutlet: UITextField!
    @IBOutlet weak var passwordValidOutlet: UILabel!
    @IBOutlet weak var doSomethingOutlet: UIButton!
    
    let disposeBag : DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let minimalUsernameLength = 5
        let minimalPasswordLength = 5

        
        let usernameValid = usernameOutlet.rx.text.orEmpty
            .map { $0.count >= minimalUsernameLength }
            .share(replay: 1)

        let passwordValid = passwordOutlet.rx.text.orEmpty
            .map { $0.count >= minimalPasswordLength }
            .share(replay: 1)

        let everythingValid = Observable.combineLatest(
              usernameValid,
              passwordValid
            ) { $0 && $1 }
            .share(replay: 1)

        usernameValid
            .bind(to: passwordOutlet.rx.isEnabled)
            .disposed(by: disposeBag)

        usernameValid
            .bind(to: usernameValidOutlet.rx.isHidden)
            .disposed(by: disposeBag)

        passwordValid
            .bind(to: passwordValidOutlet.rx.isHidden)
            .disposed(by: disposeBag)

        everythingValid
            .bind(to: doSomethingOutlet.rx.isEnabled)
            .disposed(by: disposeBag)

        doSomethingOutlet.rx.tap
            .subscribe(onNext: { [weak self] in self?.showAlert() })
            .disposed(by: disposeBag)
    }
    
    func showAlert() {
        let alertView = UIAlertView(
            title: "RxExample",
            message: "This is wonderful",
            delegate: nil,
            cancelButtonTitle: "OK"
        )

        alertView.show()
    }
    
    //一步一步的分析
    
    func oneStepByStep(){
        /*
         * RxCocoa.ControlProperty
         * ControlProperty<PropertyType> : ControlPropertyType
         * protocol ControlPropertyType : ObservableType, ObserverType
         */
        let minimalUsernameLength = 5

        
        
        //简单来说
        //ControlProperty(struct类型) 就是 ObservableType(protocol类型)
        let text = usernameOutlet.rx.text.orEmpty
        // Observable<String>  asObserverable 返回的是ControlProperty存的一些列的值
        let textAsObservable = text.asObservable()
        // Observable<Bool>
        let passwordValid = textAsObservable
        // Operator
        .map { $0.count >= minimalUsernameLength }
        
        
        // Observer<Bool> 这里是一个监听者。。。不容易，找到了一个监听者
        let observer = passwordValidOutlet.rx.isHidden
        
        // Disposable
        let disposable = passwordValid
            // Scheduler 用于控制任务在那个线程队列运行
            .subscribeOn(MainScheduler.instance) //Observable
            .observeOn(MainScheduler.instance)  //Observable
            .bind(to: observer)  //Disposable
        
        // 取消绑定，你可以在退出页面时取消绑定
        disposable.dispose()
        
    }
    


}
