//
//  ViewController.swift
//  ObrioMobileTest
//
//  Created by sergemi on 06.11.2020.
//

import UIKit
import Alamofire

class ViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource {
    
    @IBOutlet weak var searchTField: UITextField!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var repositories: [String] = []//["first", "second", "third"]
    
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
//            print("search: \"\(searchText)\"")
            let semaphore = DispatchSemaphore(value: 1)
            
            doSearchRequest(searchString: searchText, page: 1, semaphore: semaphore)
            doSearchRequest(searchString: searchText, page: 2, semaphore: semaphore)
            print("all done")
        }
    }
    
    func doSearchRequest(searchString: String, page: Int, semaphore:DispatchSemaphore) {
        
        guard let url = URL(string:"https://api.github.com/search/repositories") else {
            return
        }
        
        let params = [
            "q": searchString,
            "sort": "stars",
            "order": "desc",
            "per_page": 15,
            "page": page
        ] as [String : Any]
        
        Alamofire.request(
            url,
            method: .get,
            parameters: params
        )
        .validate()
        .responseJSON { [weak self] response in
            guard response.result.isSuccess else {
                return
            }
            
            guard let value = response.result.value as? [String: Any],
                  let items = value["items"] as? [[String: Any]] else {
                return
            }
            var names: [String] = []
            for item in items {
                if let name = item["name"] as? String {
                    names.append(name)
                }
            }
            print(names.count)
            
            print(value)
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

