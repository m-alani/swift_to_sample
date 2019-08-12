//
//  ViewController.swift
//  SwiftTO Sample
//
//  Created by Marwan Alani on 2019-08-02.
//  Copyright © 2019 Marwan Alani. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var users = [User]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUsers(from: "https://randomuser.me/api/?inc=name,phone&nat=ca&results=20") { [weak self] users in
            self?.users = users
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)
        cell.textLabel?.text = users[indexPath.row].name
        cell.detailTextLabel?.text = users[indexPath.row].phone
        
        return cell
    }
}

// MARK: Models

struct ApiName: Codable {
    let first: String
    let last: String
}

struct ApiUser: Codable {
    let name: ApiName
    let phone: String
}

struct ApiResponse: Codable {
    let results: [ApiUser]
}

struct User: Equatable{
    let name: String
    let phone: String
    
    init(name: String, phone: String) {
        self.name = name
        self.phone = phone
    }
    
    /// Initialize a `User` object from an `ApiUser` object, parsing the first & last name together with a space in between
    init(fromNetworkUser user: ApiUser) {
        self.name = "\(user.name.first.capitalized) \(user.name.last.capitalized)"
        self.phone = user.phone
    }
}

// MARK: Network

typealias FetchUsersCompletionHandler = ([User]) -> Void

func fetchUsers(from apiUrlString: String,
                using session: URLSession = URLSession.shared,
                completionHandler: @escaping FetchUsersCompletionHandler) {
    guard let url = URL(string: apiUrlString) else { return }
    
    let networkCall = session.dataTask(with: url) { (data, _ , error) in
        // Make sure everything went well with the network fetch
        guard let unwrappedData = data,
            error == nil else {
                completionHandler([User]()) // something went wrong! return an empty array
                return
        }
        
        // Decode retrived data
        let apiResponse = try? JSONDecoder().decode(ApiResponse.self, from: unwrappedData)
        if let unwrappedApiResponse = apiResponse {
            completionHandler(unwrappedApiResponse.results.map({ User(fromNetworkUser: $0) })) // Map an array of `User`s out of the array of `ApiUser`s we received
        }
    }
    networkCall.resume()
}
