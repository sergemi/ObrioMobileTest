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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
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
            repositories.removeAll()
            tableView.reloadData()
            searchTField.isEnabled = false
            searchBtn.isEnabled = false
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            
            let group = DispatchGroup()
            
            doSearchRequest(searchString: searchText, page: 1, dispatchGroup: group)
            
            DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(10)) { [weak self] in
                self?.doSearchRequest(searchString: searchText, page: 2, dispatchGroup: group)
            }
            
            group.notify(queue: DispatchQueue.main ) { [weak self] in
                self?.tableView.reloadData()
                self?.searchTField.isEnabled = true
                self?.searchBtn.isEnabled = true
                
                self?.activityIndicator.stopAnimating()
                self?.activityIndicator.isHidden = true
                print("all done: \(self?.repositories.count)")
            }
        }
    }
    
    func doSearchRequest(searchString: String, page: Int, dispatchGroup: DispatchGroup) {
        
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
        
        dispatchGroup.enter()
        print("doSearchRequest: \(String(page))")
        
        Alamofire.request(
            url,
            method: .get,
            parameters: params
        )
        .validate()
        .responseJSON { [weak self] response in
            guard response.result.isSuccess else {
                self?.showAlert(header: "Error", text: response.error?.localizedDescription ?? "Unknown error")
                dispatchGroup.leave()
                return
            }
            
            guard let value = response.result.value as? [String: Any],
                  let items = value["items"] as? [[String: Any]] else {
                dispatchGroup.leave()
                return
            }
            var names: [String] = []
            for item in items {
                if let name = item["name"] as? String {
                    names.append(name)
                }
            }
            
            self?.repositories += names
            
            dispatchGroup.leave()
        }
    }
    
    func showAlert(header:String, text: String) {
        let alertController = UIAlertController(title: header, message: text, preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                    print("Ok button tapped");
                }
        alertController.addAction(OKAction)
        
        self.present(alertController, animated: true, completion: nil)
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

