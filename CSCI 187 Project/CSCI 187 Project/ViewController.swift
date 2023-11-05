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

class ThirdViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
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
