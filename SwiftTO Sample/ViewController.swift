//
//  ViewController.swift
//  SwiftTO Sample
//
//  Created by Marwan Alani on 2019-08-02.
//  Copyright © 2019 Marwan Alani. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var users = [ApiUser]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let url = URL(string: "https://randomuser.me/api/?inc=name,phone&nat=ca&results=20") else { return }
        let networkCall = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let strongSelf = self,
                let httpURLResponse = response as? HTTPURLResponse,
                httpURLResponse.statusCode == 200,
                let unwrappedData = data,
                error == nil
                else {
                    print("Something went wrong fetching users: \(error.debugDescription)")
                    return
            }
            
            let apiResponse = try? JSONDecoder().decode(ApiResponse.self, from: unwrappedData)
            if let unwrappedApiResponse = apiResponse {
                strongSelf.users = unwrappedApiResponse.results
                DispatchQueue.main.async {
                    strongSelf.tableView.reloadData()
                }
            }
        }
        networkCall.resume()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)
        cell.textLabel?.text = "\(users[indexPath.row].name.first.capitalized) \(users[indexPath.row].name.last.capitalized)"
        cell.detailTextLabel?.text = users[indexPath.row].phone
        
        return cell
    }
}

struct ApiName: Codable {
    let first: String
    let last: String
}

struct ApiUser: Codable {
    let name: ApiName
    let phone: String
}

struct ApiResponseInfo: Codable {
    let seed: String
    let results: Int
    let page: Int
    let version: String
}

struct ApiResponse: Codable {
    let results: [ApiUser]
    let info: ApiResponseInfo
}
