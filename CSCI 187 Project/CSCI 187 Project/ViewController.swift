//
//  ViewController.swift
//  CSCI 187 Project
//
//  Created by Jake Treska on 11/3/23.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    @IBAction func SearchClubs(_ sender: UIButton) {
        performSegue(withIdentifier: "ThirdViewController", sender: Self.self)
    }
}

class SecondViewController: UIViewController {
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var major: UITextField!
    @IBOutlet weak var status: UITextField!
    @IBOutlet weak var email: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load text field values from UserDefaults and set them in the text fields
        if let savedName = UserDefaults.standard.string(forKey: "NameKey") {
            name.text = savedName
        }
        if let savedMajor = UserDefaults.standard.string(forKey: "MajorKey") {
            major.text = savedMajor
        }
        if let savedStatus = UserDefaults.standard.string(forKey: "StatusKey") {
            status.text = savedStatus
        }
        if let savedEmail = UserDefaults.standard.string(forKey: "EmailKey") {
            email.text = savedEmail
        }

        name.delegate = self
        major.delegate = self
        status.delegate = self
        email.delegate = self
    }
}

extension SecondViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Save the text field values in UserDefaults
        if textField == name {
            UserDefaults.standard.set(textField.text, forKey: "NameKey")
        } else if textField == major {
            UserDefaults.standard.set(textField.text, forKey: "MajorKey")
        } else if textField == status {
            UserDefaults.standard.set(textField.text, forKey: "StatusKey")
        } else if textField == email {
            UserDefaults.standard.set(textField.text, forKey: "EmailKey")
        }
    }
}

class ThirdViewController: UIViewController, UISearchResultsUpdating{
    
    @IBOutlet weak var searchBar: UISearchBar!
//    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var clubs:[Club]?
    
    var Filters = ["All","Sports","Arts","Business","STEM"]
    
    let searchController = UISearchController(searchResultsController: nil)
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        searchBar.delegate = self
//        searchBar.showsScopeBar = true
//        initsearchController()
        
        
        tableView.dataSource = self
        tableView.delegate = self
        initsearchController()
        fetchClubs()
    }
    
    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           fetchClubs()
       }
    
    func initsearchController(){
        searchController.loadViewIfNeeded()
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchBar.enablesReturnKeyAutomatically = false
        searchController.searchBar.returnKeyType = UIReturnKeyType.done
        definesPresentationContext = true
        searchController.searchBar.showsScopeBar = false
        searchController.searchBar.scopeButtonTitles = Filters
        searchController.searchBar.delegate = self
        

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            searchBar.showsScopeBar = true  // Show the scope bar when editing begins
            searchBar.sizeToFit()  // Adjust the search bar size
        }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scopeButton = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        let searchText = searchBar.text!
        
        ScopeBarFilter(filter: scopeButton, searchText: searchText)
    }
    
    
    func fetchClubs(){
        do{
            self.clubs = try context.fetch(Club.fetchRequest())
            DispatchQueue.main.async {
                self.tableView?.reloadData()
            }
        }
        catch{
            print("error retching clubs")
        }
    }
    
    func ScopeBarFilter(filter: String, searchText: String) {
        let fetchRequest: NSFetchRequest<Club> = Club.fetchRequest()
        
        
        if filter != "All"{
            let filterPredicate = NSPredicate(format: "club_category == %@", filter)
            fetchRequest.predicate = filterPredicate
        }
        
        else if !searchText.isEmpty {
            let searchFilter = NSPredicate(format: "name CONTAINS[c] %@", searchText)
            fetchRequest.predicate = searchFilter
        }
        
        do {
            self.clubs = try context.fetch(fetchRequest)
            DispatchQueue.main.async {
                self.tableView?.reloadData()
            }
        }
        catch {
            
        }
    }
    
}

extension ThirdViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            // Append the search text to the text view
//            textView.text += " " + searchText + ","
            searchBar.text = "" // Clear the search bar
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


extension ThirdViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.clubs?.count ?? 0
        
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClubCell", for: indexPath)
        
        let club = self.clubs![indexPath.row]
        cell.textLabel?.text = club.name
        return cell

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ClubCell", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ClubCell" {
            if let indexPath = sender as? IndexPath {
                let clubDetailVC = segue.destination as! ClubDetailViewController
                clubDetailVC.selectedClub = clubs?[indexPath.row]
            }
        }
    }
}


class ClubDetailViewController: UIViewController {
    var selectedClub: Club?


    @IBOutlet weak var name_text: UITextView!
    @IBOutlet weak var contact_text: UITextView!
    @IBOutlet weak var meeting_text: UITextView!
    @IBOutlet weak var info_text: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Use the selectedClub property to display club details on this view controller
        if let club = selectedClub {
            self.name_text.text =  club.name!
            self.info_text.text = club.club_info!
            self.meeting_text.text = club.requirements!
//            self.meeting_text.text += club.location! + ": "
//            self.meeting_text.text += club.meeting_days!
//            self.meeting_text.text +=  ", " + club.meeting_times!
            self.contact_text.text = club.contact_information!
            // Update UI elements with club information
            // Example: nameLabel.text = club.name
        }
    }
}

class FourthViewController: UIViewController{
    
    @IBOutlet weak var club_information: UITextView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad(){
        super.viewDidLoad()
    }
    @IBAction func AddClub(_ sender: Any) {
        
        let alert  = UIAlertController(title: "Add Person", message: "What Is the club's name?", preferredStyle: .alert)
        
        alert.addTextField{ (club_name) in
            club_name.text = ""
            club_name.placeholder = "name"
        }
        alert.addTextField() {(club_info) in
            club_info.text = ""
            club_info.placeholder = "info"
        }
        alert.addTextField(){(club_category) in
            club_category.text = ""
            club_category.placeholder = "category"
        }
        alert.addTextField(){(club_requirements) in
            club_requirements.text = ""
            club_requirements.placeholder = "requirements"
        }
//        alert.addTextField(){(club_meeting_info) in
//            club_meeting_info.text = ""
//            club_meeting_info.placeholder = "days"
//        }
//        alert.addTextField(){(club_meeting_times) in
//            club_meeting_times.text = ""
//            club_meeting_times.placeholder = "times"
//        }
//        alert.addTextField(){(club_location) in
//            club_location.text = ""
//            club_location.placeholder = "location"
//        }
        alert.addTextField(){(club_contact_information) in
            club_contact_information.text = ""
            club_contact_information.placeholder = "contact information"
        }
        
        let submitButton = UIAlertAction(title: "Add", style:.default) {(action) in
            
            let name_input = alert.textFields![0]
            let club_info_input = alert.textFields![1]
            let club_category = alert.textFields![2]
            let club_meeting_requirements = alert.textFields![3]
//            let meeting_time_input = alert.textFields![4]
//            let meeting_location = alert.textFields![5]
            let contact_information = alert.textFields![4]
            let newClub = Club(context: self.context)
            newClub.name = name_input.text
            newClub.club_info = club_info_input.text
            newClub.club_category = club_category.text
            newClub.requirements = club_meeting_requirements.text
//            newClub.meeting_days = meeting_days_input.text
//            newClub.meeting_times = meeting_time_input.text
//            newClub.location = meeting_location.text
            newClub.contact_information = contact_information.text
            self.club_information.text =  "\(name_input.text ?? "")\n\(club_info_input.text ?? "")\n\(club_category.text ?? "")\n\(club_meeting_requirements.text ?? "")\n\(contact_information.text ?? "")"
            
            
//            self.club_information.text =  "\(name_input.text ?? "")\n\(club_info_input.text ?? "")\n\(club_category.text ?? "")\n\(meeting_days_input.text ?? "")\n\(meeting_time_input.text ?? "")\n\(meeting_location.text ?? "")\n\(contact_information.text ?? "")"
            
            do{
                try self.context.save()
            }
            catch{
                
            }
        }
        alert.addAction(submitButton)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func DeleteButton(_ sender: Any) {
       // DeleteDatabase()
    }
    
    func DeleteDatabase() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        do {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Club")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

            try context.execute(deleteRequest)
            try context.save()
        } catch {

        }
    }
    
}
