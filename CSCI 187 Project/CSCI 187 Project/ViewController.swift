//
//  ViewController.swift
//  CSCI 187 Project
//
//  Created by Jake Treska on 11/3/23.
//

import UIKit
import CoreData

// First Screen

class ViewController: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // Search Button
    @IBAction func SearchClubs(_ sender: Any) {
        if ProfileIsNotEmpty(){
            self.performSegue(withIdentifier: "NavigationSegue", sender: Self.self)
        }
        else{
            self.emptyProfile()
                }
        }
    // Check if user info is empty
    func ProfileIsNotEmpty() -> Bool{
        do{
            let get_data: NSFetchRequest<App_User> = App_User.fetchRequest()
            let data = try context.fetch(get_data)
            
            if let user = data.first{
                if user.user_name == ""{
                    return false
                }
                if user.user_major == ""{
                    return false
                }
                if user.user_year == ""{
                    return false
                }
                if user.user_email == ""{
                    return false
                }
            }
        }catch{
            print("error: \(error)")
        }
        return true
    }
    // display error message if empty
    func emptyProfile() {
        DispatchQueue.main.async {
            let errorMessage = UIAlertController(title: "Empty Profile", message: "Must Fill Out Profile", preferredStyle: .alert)
            let OK = UIAlertAction(title: "OK", style: .default, handler: nil)
            errorMessage.addAction(OK)
            self.present(errorMessage, animated: true, completion: nil)
        }
    }
    
}
// Second Screen
class SecondViewController: UIViewController, UITextViewDelegate {
    
    var user: App_User?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var major: UITextField!
    @IBOutlet weak var status: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var liked_clubs_list: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        name.delegate = self
        major.delegate = self
        status.delegate = self
        email.delegate = self
        liked_clubs_list.delegate = self
        get_user_data()
    }
    // get user data from database
    func get_user_data(){
        
        do{
            let get_data: NSFetchRequest<App_User> = App_User.fetchRequest()
            let data = try context.fetch(get_data)
            print("Fetched \(data.count) user(s)")
            if let person = data.first{
                print("fetched user: \(person.user_name ?? "No Name")")
                DispatchQueue.main.async {
                    self.name.text = person.user_name
                    self.major.text = person.user_major
                    self.status.text = person.user_year
                    self.email.text = person.user_email
                    self.user = person
                    self.liked_clubs_list.text = person.user_list_clubs
            }
            }
        }
        catch{
            print("error")
        }
        
    }
    
    
}
// save user data from profile screen
extension SecondViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Save the text field values in UserDefaults
        if let person = user{
            if textField == name {
                person.user_name = name.text
            } else if textField == major {
                person.user_major = major.text
            } else if textField == status {
                person.user_year = status.text
            } else if textField == email {
                person.user_email = email.text
            }
        }
        do{
            try context.save()
        }catch{
            print("error : \(error)")
        }
    }
}
// Third Screen
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
        
        tableView.dataSource = self
        tableView.delegate = self
        initsearchController()
        fetchClubs()
    }

// *
    // enter pin alert
    @IBAction func Pin(_ sender: Any) {
        let alert = UIAlertController(title: "Enter PIN", message: nil, preferredStyle: .alert)

            alert.addTextField { textField in
                textField.placeholder = "12345"
            }
// checks if input is equal to correct pin
            let submitAction = UIAlertAction(title: "Enter", style: .default) { [weak self] _ in
                if let pin = alert.textFields?.first?.text, let enteredNumber = Int(pin) {
        
                    if enteredNumber == 19548 {
                        
                        self?.performSegue(withIdentifier: "Dev Access Segue", sender: self)
                    } else {
                        self?.FailedAccess()
                    }
                } else {
                    self?.FailedAccess()
                }
            }
        
// *
        
            alert.addAction(submitAction)
            present(alert, animated: true, completion: nil)
        }
// message when entereing incorrect pin
        func FailedAccess() {
            let errorMessage = UIAlertController(title: "Incorrect PIN", message: "Restricted Access", preferredStyle: .alert)
            let OK = UIAlertAction(title: "OK", style: .default, handler: nil)
            errorMessage.addAction(OK)
            present(errorMessage, animated: true, completion: nil)
        }
    
    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           fetchClubs()
       }
    // initiating search bar features
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
    
    // relead clubs
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
    // filter database based on search bar
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
                clubDetailVC.user_picked_club = clubs?[indexPath.row]
            }
        }
    }
}

// Display club data on new screen
class ClubDetailViewController: UIViewController {
    var user_picked_club: Club?
    var ID: App_User?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    @IBOutlet weak var name_text: UITextView!
    @IBOutlet weak var contact_text: UITextView!
    @IBOutlet weak var meeting_text: UITextView!
    @IBOutlet weak var info_text: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        if let club = user_picked_club {
            self.name_text.text =  club.name!
            self.info_text.text = club.club_info!
            self.meeting_text.text = club.requirements!

            self.contact_text.text = club.contact_information!

        }
    }
    
    // ability to like/save clubs
    @IBAction func FavoriteClub(_ sender: Any) {
        if let club_name = user_picked_club!.name{
        do{
            let get_data: NSFetchRequest<App_User> = App_User.fetchRequest()
            let data = try context.fetch(get_data)
            print("Fetched \(data.count) user(s)")
            if let person = data.first{
                print("fetched user: \(person.user_name ?? "No Name")")
                DispatchQueue.main.async {
                    if person.user_list_clubs != nil{
                        person.user_list_clubs! = "Liked Clubs: \(club_name), "
                        do{
                            try self.context.save()
                        }catch{
                            print("error : \(error)")
                        }
                    }
                    else{
                        person.user_list_clubs! = "\(club_name), "
                        do{
                            try self.context.save()
                        }catch{
                            print("error : \(error)")
                        }
}
            }
            }
        }
        catch{
            print("error")
        }
           }
        // provide successful message
        let add_message = UIAlertController(title:"Added", message: "Club has successfully been added", preferredStyle: .alert)
           let OK = UIAlertAction(title: "OK", style: .default, handler: nil)
           add_message.addAction(OK)
           self.present(add_message, animated: true, completion: nil)
       }
            
            
}


// Fourth Screen
class FourthViewController: UIViewController{
    
    @IBOutlet weak var club_information: UITextView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad(){
        super.viewDidLoad()
    }
    // add clubs
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

        alert.addTextField(){(club_contact_information) in
            club_contact_information.text = ""
            club_contact_information.placeholder = "contact information"
        }
        
        let submitButton = UIAlertAction(title: "Add", style:.default) {(action) in
            
            let name_input = alert.textFields![0]
            let club_info_input = alert.textFields![1]
            let club_category = alert.textFields![2]
            let club_meeting_requirements = alert.textFields![3]

            let contact_information = alert.textFields![4]
            let newClub = Club(context: self.context)
            newClub.name = name_input.text
            newClub.club_info = club_info_input.text
            newClub.club_category = club_category.text
            newClub.requirements = club_meeting_requirements.text

            newClub.contact_information = contact_information.text
            self.club_information.text =  "\(name_input.text ?? "")\n\(club_info_input.text ?? "")\n\(club_category.text ?? "")\n\(club_meeting_requirements.text ?? "")\n\(contact_information.text ?? "")"
            
     
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
    // delete database
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

