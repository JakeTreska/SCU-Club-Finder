//
//  ViewController.swift
//  CSCI 187 Project
//
//  Created by Jake Treska on 11/3/23.
//

import UIKit

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

class ThirdViewController: UIViewController{

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var clubs:[Club]?

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        fetchClubs()
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
    
    @IBOutlet weak var club_information: UITextView!
    
    @IBAction func addClub(_ sender: Any) {
        let alert  = UIAlertController(title: "Add Person", message: "What Is the club's name?", preferredStyle: .alert)
        
        alert.addTextField{ (club_name) in
            club_name.text = ""
            club_name.placeholder = "name"
        }
        alert.addTextField() {(club_info) in
            club_info.text = ""
            club_info.placeholder = "info"
        }
        alert.addTextField(){(club_meeting_info) in
            club_meeting_info.text = ""
            club_meeting_info.placeholder = "days"
        }
        alert.addTextField(){(club_meeting_times) in
            club_meeting_times.text = ""
            club_meeting_times.placeholder = "times"
        }
        
        let submitButton = UIAlertAction(title: "Add", style:.default) {(action) in
            
            let name_input = alert.textFields![0]
            let club_info_input = alert.textFields![1]
            let meeting_days_input = alert.textFields![2]
            let meeting_time_input = alert.textFields![3]
            let newClub = Club(context: self.context)
            newClub.name = name_input.text
            newClub.club_info = club_info_input.text
            newClub.meeting_days = meeting_days_input.text
            newClub.meeting_times = meeting_time_input.text
            self.club_information.text =  "\(name_input.text ?? "")\n\(club_info_input.text ?? "")\n\(meeting_days_input.text ?? "")\n\(meeting_time_input.text ?? "")"
            
            do{
                try self.context.save()
            }
            catch{
                
            }
            
            self.fetchClubs()
        }
        alert.addAction(submitButton)
        self.present(alert, animated: true, completion: nil)
        
    }
}

extension ThirdViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            // Append the search text to the text view
            textView.text += " " + searchText + ","
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
}
