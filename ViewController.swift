//
//  ViewController.swift
//  FirstMany
//
//  Created by Aleksey Alyonin on 11.10.2021.
//

import UIKit
import RealmSwift
//import SwiftUI

class ViewController: UIViewController {

    let realm = try! Realm()
    var spendingArray: Results<Spending>!
    
    var displayValue:Int = 1
    var categoryName = ""
    
    var stillTyping = false
    
    @IBOutlet weak var spendByCheck: UILabel!
    
    @IBOutlet weak var allExpenses: UILabel!
    
    @IBOutlet weak var huwManyCanSend: UILabel!
    @IBOutlet weak var limitLabel: UILabel!
    
    
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet var numberCollection: [UIButton]!{
        didSet{
            for button in numberCollection {
                button.layer.cornerRadius =  11
            }
        }
    }
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spendingArray = realm.objects(Spending.self)
        leftLabels()
        allExpensesAction()

        
    }


    @IBAction func numberPressed(_ sender: UIButton) {
        let number = sender.currentTitle!
        
        if number == "0" && displayLabel.text == "0" {
            stillTyping = false
        }
        
        if stillTyping {
            if displayLabel.text!.count < 15 {
                displayLabel.text = displayLabel.text! + number
            }
        } else {
            displayLabel.text = number
            stillTyping = true
        }
        
    }
    @IBAction func resetButton(_ sender: UIButton) {
        displayLabel.text = "0"
        stillTyping = false

    }
    @IBAction func catetgorePressed(_ sender: UIButton) {
        categoryName = sender.currentTitle!
        displayValue = Int(displayLabel.text!)!
        displayLabel.text = "0"
        stillTyping = false
        
        let value = Spending(value: ["\(categoryName)", displayValue])
        
        try! realm.write {
            realm.add(value)
        }
        leftLabels()
        allExpensesAction()
        tableView.reloadData()
    }
    
    
    @IBAction func limitPresed(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: "Установить лимит", message: "Введите сумму и колличество дней", preferredStyle: .alert)
        let aletrInstal = UIAlertAction(title: "Установить", style: .default) { action in
            
            let tfsum = alertController.textFields?[0].text
            let tfday = alertController.textFields?[1].text

            guard tfday != "" && tfsum != "" else { return }
            
            self.limitLabel.text = tfsum

            if let day = tfday{
                let dateNow = Date()
                let lastDay: Date = dateNow.addingTimeInterval(60*60*24*Double(day)!)
                
                let limit = self.realm.objects(Limit.self)
                if limit.isEmpty == true {
                    let value = Limit(value: [self.limitLabel.text!, dateNow, lastDay])
                    
                    try! self.realm.write {
                        self.realm.add(value)
                    }
                }else {
                    try! self.realm.write{
                        limit[0].limitSum = self.limitLabel.text!
                        limit[0].limitDate = dateNow as NSDate
                        limit[0].lastDay = lastDay as NSDate
                    }
                    
                }
               
            }
            
            self.leftLabels()
        }
        alertController.addTextField {(money) in
            money.placeholder = "Summa"
            money.keyboardType = .asciiCapableNumberPad
        }
        alertController.addTextField {(day) in
            day.placeholder = "Count"
            day.keyboardType = .asciiCapableNumberPad
        }
        
        let alertCancel = UIAlertAction(title: "Cancel", style: .default) { _ in }
        
        alertController.addAction(aletrInstal)
        alertController.addAction(alertCancel)
        present(alertController, animated: true, completion: nil)
    }
    
    func leftLabels(){
        
        let limit = realm.objects(Limit.self)
        guard limit.isEmpty == false else { return }
        limitLabel.text = limit[0].limitSum
        
        
        let calendar = Calendar.current
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        
        let firstDay = limit[0].limitDate as Date
        let lastDay = limit[0].lastDay as Date
        print(firstDay)
        print(lastDay)
        
        let firstComponents = calendar.dateComponents([.year, .month, .day], from: firstDay)
        let lastComponents = calendar.dateComponents([.year, .month, .day], from: lastDay)

        let startDate = formatter.date(from:"\(firstComponents.year!)/ \(firstComponents.month!)/ \(firstComponents.day!) 00:00") as Any
        let endDate = formatter.date(from: "\(lastComponents.year!)/\(lastComponents.month!)/\(lastComponents.day!) 23:59") as Any

        let filtredLimit: Int = realm.objects(Spending.self).sum(ofProperty:"cost")
        
        spendByCheck.text = "\(filtredLimit)"
    
        let a = Int("\(limitLabel.text!)")!
        let b = Int("\(spendByCheck.text!)")!
        let c = a - b
        huwManyCanSend.text = "\(c)"
    }
    
    func allExpensesAction(){
        let expenes: Int = realm.objects(Spending.self).sum(ofProperty:"cost")
        allExpenses.text? = "\(expenes)"
    }
}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spendingArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomViewSellTableViewCell
        
        let spending = spendingArray.reversed()[indexPath.row]
        
        cell.recordCategory.text = spending.category
        cell.recordCost.text = "\(spending.cost)"
        
        switch spending.category {
        case "Еда": cell.recordImage.image = #imageLiteral(resourceName: "Foods")
        case "Одежда": cell.recordImage.image = #imageLiteral(resourceName: "Clothing")
        case "Досуг": cell.recordImage.image = #imageLiteral(resourceName: "Ggfgf")
        case "Связь": cell.recordImage.image = #imageLiteral(resourceName: "Hhh")
        case "Красота": cell.recordImage.image = #imageLiteral(resourceName: "Some")
        case "Авто": cell.recordImage.image = #imageLiteral(resourceName: "Car")

        default: cell.recordImage.image = #imageLiteral(resourceName: "Charcoal")
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editionRow = spendingArray[indexPath.row]
        let editionAction = UIContextualAction(style: .destructive, title: "Delete") { _,_, complitionHandler in
            try! self.realm.write{
                self.realm.delete(editionRow)
                self.leftLabels()
                self.allExpensesAction()
                tableView.reloadData()
            }
        }
        return UISwipeActionsConfiguration(actions: [editionAction])
    }

}
