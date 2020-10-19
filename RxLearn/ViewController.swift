//
//  ViewController.swift
//  RxLearn
//
//  Created by Emma Sun on 2020/10/16.
//  Copyright © 2020 Shushangyun. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let titles : [String] = ["1","2"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }


}

extension ViewController : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "homeCell", for: indexPath)
        cell.textLabel!.text = self.titles[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
}

