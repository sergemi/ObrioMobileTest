//
//  ViewController.swift
//  ObrioMobileTest
//
//  Created by sergemi on 06.11.2020.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource {
    
    @IBOutlet weak var searchTField: UITextField!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var repositories = ["first", "second", "third"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTField.delegate = self
        tableView.dataSource = self
    }
    
    @IBAction func onSearchBtn(_ sender: Any) {
        doSearch()
    }
    
    @IBAction func searchChanged(_ sender: Any) {
        searchBtn.isEnabled = searchTField.text!.count > 0
    }
    
    func doSearch() {
        if let searchText = searchTField.text {
            print("search: \"\(searchText)\"")
        }
    }
    
// MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        repositories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = repositories[indexPath.row]
        return cell
    }
    
// MARK: UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        doSearch()
        return true
    }
    
}

