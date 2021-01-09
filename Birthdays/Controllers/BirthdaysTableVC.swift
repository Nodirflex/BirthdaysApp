//
//  BirthdaysTableVC.swift
//  Birthdays
//
//  Created by user on 05.01.2021.
//  Copyright © 2021 user. All rights reserved.
//

import UIKit
import UserNotifications

class BirthdaysTableVC: UIViewController {

    let cellId = "cellId"
    @IBOutlet var tableView: UITableView!
    
    var birthdayArray = [BirthdayModel(name: "Grogu", bithday: Date(), image: UIImage(named: "Grogu")), BirthdayModel(name: "Steve", bithday: Date(), image: UIImage(named: "Steve")), BirthdayModel(name: "Elon", bithday: Date(), image: UIImage(named: "Elon")), BirthdayModel(name: "Henry", bithday: Date(), image: UIImage(named: "Henry")), BirthdayModel(name: "Mando", bithday: Date(), image: UIImage(named: "Mando"))]
    var birthdaySearchResult = [BirthdayModel]()
    
    var searchController = UISearchController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        searchController = UISearchController(searchResultsController: nil)
        //searchController.searchResultsUpdater = self
        self.tableView.tableHeaderView = searchController.searchBar
        self.searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.searchBarStyle = .minimal
        
        prepareNotification()
    }
    
    func prepareNotification(){
        if birthdayArray.isEmpty{
            return
        }
        
        let itemForBirthday = birthdayArray[0]
        
        let categoryIdentifier = "happybirthday.actions"
        let dismissAction = UNNotificationAction(identifier: "happybirthday.cancel", title: "Dismiss", options: [])
        let category = UNNotificationCategory(identifier: categoryIdentifier, actions: [dismissAction], intentIdentifiers: [], options: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        let date = formatDateFor(itemForBirthday.bithday!)
        
        let content = UNMutableNotificationContent()
        content.title = "Birthday"
        content.subtitle = "Do not forget to wish Happy Birthday!"
        content.body = itemForBirthday.name! + " celebrates birthday at " + date
        content.sound = .default
        content.categoryIdentifier = categoryIdentifier
    
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: "happybirthday.usernotification", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem){
        guard let vc = storyboard?.instantiateViewController(identifier: "DetailVC") as? DetailVC else {return}
        
        vc.title = "New Birthday"
        vc.completion = { name, birthday, image in
            self.navigationController?.popToRootViewController(animated: true)
            self.birthdayArray.append(BirthdayModel(name: name, bithday: birthday, image: image))
            self.tableView.reloadData()
            
            let itemForBirthday = self.birthdayArray[0]
            
            let categoryIdentifier = "happybirthday.actions"
            let dismissAction = UNNotificationAction(identifier: "happybirthday.cancel", title: "Dismiss", options: [])
            let category = UNNotificationCategory(identifier: categoryIdentifier, actions: [dismissAction], intentIdentifiers: [], options: [])
            
            UNUserNotificationCenter.current().setNotificationCategories([category])
            
            let date = self.formatDateFor(itemForBirthday.bithday!)
            
            let content = UNMutableNotificationContent()
            content.title = "Birthday"
            content.subtitle = "Do not forget to wish Happy Birthday!"
            content.body = itemForBirthday.name! + " celebrates birthday at " + date
            content.categoryIdentifier = categoryIdentifier
            content.sound = .default
            
            let targetDate = birthday
            let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second],
                                                          from: targetDate),
            repeats: false)
            
            let request = UNNotificationRequest(identifier: "birthdayapp", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
                if error != nil {
                    print("error")
                }
            })
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func formatDateFor(_ date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM, dd, YYYY"
        let formattedString = formatter.string(from: date)
        return formattedString
    }
}

extension BirthdaysTableVC: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive{
            return birthdaySearchResult.count
        }else{
            return birthdayArray.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        let birthdayItem = (searchController.isActive) ? birthdaySearchResult[indexPath.row] : birthdayArray[indexPath.row]

        let date = formatDateFor(birthdayItem.bithday!)

        cell.textLabel?.text = birthdayItem.name
        cell.detailTextLabel?.text = date
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.layer.cornerRadius = (cell.imageView?.layer.frame.height)! / 2
        cell.imageView?.clipsToBounds = true
        cell.imageView?.image = image(birthdayItem.image, withSize: CGSize(width: 90, height: 90))

        return cell
    }
    
    func image( _ image: UIImage?, withSize newSize:CGSize) -> UIImage {
        UIGraphicsBeginImageContext(newSize)
        if let image = image{
            image.draw(in: CGRect(x: 0,y: 0,width: newSize.width, height: newSize.height))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return newImage!.withRenderingMode(.automatic)
        }
        return UIImage()
    }
    
}

extension BirthdaysTableVC: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = storyboard?.instantiateViewController(identifier: "DetailVC") as? DetailVC else {return}
        
        let birthdayItem = (searchController.isActive) ? birthdaySearchResult[indexPath.row] : birthdayArray[indexPath.row]
        
        vc.title = "Birthday"
        vc.exName = birthdayItem.name
        vc.exBirthday = birthdayItem.bithday
        vc.exImage = birthdayItem.image
        vc.completion = { name, birthday, image in
            self.navigationController?.popToRootViewController(animated: true)
            self.birthdayArray[indexPath.row] = BirthdayModel(name: name, bithday: birthday, image: image)
            self.tableView.reloadData()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            birthdayArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

extension BirthdaysTableVC: UISearchResultsUpdating{
    
    func filterContent(for searchText: String){
        birthdaySearchResult = birthdayArray.filter({ (birthday) -> Bool in
            if let name = birthday.name{
                let isMatch = name.localizedCaseInsensitiveContains(searchText)
                return isMatch
            }
            return false
        })
    }
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text{
            filterContent(for: searchText)
            tableView.reloadData()
        }
    }
}
