import Foundation
import SwiftUI

func createGitHubRepository(repositoryName: String, isPrivate: Bool, githubToken: String) -> Int {
    guard let url = URL(string: "https://api.github.com/user/repos") else { return 1 }
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("Bearer \(githubToken)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    let jsonBody: [String: Any] = [
        "name": repositoryName,
        "private": isPrivate
    ]
    guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonBody, options: []) else { return 1 }
    request.httpBody = jsonData
    let semaphore = DispatchSemaphore(value: 0)
    var resultStatus: Int = 1
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        defer { semaphore.signal() }
        if let error = error {
            print("Error creating repository: \(error.localizedDescription)")
            resultStatus = 1
            return
        }
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 201 {
                print("Repository created successfully!")
                resultStatus = 0
            } else {
                print("Failed to create repository. Status code: \(httpResponse.statusCode)")
                if let data = data, let errorResponse = String(data: data, encoding: .utf8) {
                    print("Response from GitHub: \(errorResponse)")
                }
                resultStatus = httpResponse.statusCode
            }
        }
    }
    task.resume()
    semaphore.wait()
    return resultStatus
}

func getGithubUsername(fromToken token: String) -> String? {
    let url = URL(string: "https://api.github.com/user")!
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("token \(token)", forHTTPHeaderField: "Authorization")
    let semaphore = DispatchSemaphore(value: 0)
    var username: String? = nil
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error: \(error.localizedDescription)")
            semaphore.signal()
            return
        }
        guard let data = data else {
            print("No data received")
            semaphore.signal()
            return
        }
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            if let extractedUsername = json["login"] as? String {
                username = extractedUsername
            } else {
                print("Username not found in the response")
            }
        }
        semaphore.signal()
    }
    task.resume()
    semaphore.wait()
    return username
}

struct GitHubRepo {
    let repositoryName: String
    let isPrivate: Bool
    let repoURL: String
    let ownerName: String
    let ownerEmail: String
}

func fetchGitHubRepositoryDetails(repoLink: String, githubToken: String) -> GitHubRepo? {
    guard let url = URL(string: repoLink) else {
        print("Invalid repository link")
        return nil
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("Bearer \(githubToken)", forHTTPHeaderField: "Authorization")
    
    let semaphore = DispatchSemaphore(value: 0)
    var fetchedRepo: GitHubRepo? = nil
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        defer { semaphore.signal() }
        
        if let error = error {
            print("Error fetching repository details: \(error.localizedDescription)")
            return
        }
        
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 200, let data = data {
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let repoName = jsonResponse["name"] as? String,
                       let isPrivate = jsonResponse["private"] as? Bool,
                       let repoURL = jsonResponse["html_url"] as? String,
                       let owner = jsonResponse["owner"] as? [String: Any],
                       let ownerName = owner["login"] as? String {
                        
                        // Fetch user email separately
                        let userInfoURL = URL(string: "https://api.github.com/user")!
                        var userRequest = URLRequest(url: userInfoURL)
                        userRequest.setValue("Bearer \(githubToken)", forHTTPHeaderField: "Authorization")
                        
                        let userEmailSemaphore = DispatchSemaphore(value: 0)
                        var userEmail: String = "N/A"
                        
                        let userInfoTask = URLSession.shared.dataTask(with: userRequest) { userData, userResponse, userError in
                            defer { userEmailSemaphore.signal() }
                            if let userData = userData,
                               let userJson = try? JSONSerialization.jsonObject(with: userData, options: []) as? [String: Any],
                               let email = userJson["email"] as? String {
                                userEmail = email
                            }
                        }
                        userInfoTask.resume()
                        userEmailSemaphore.wait()
                        
                        fetchedRepo = GitHubRepo(
                            repositoryName: repoName,
                            isPrivate: isPrivate,
                            repoURL: repoURL,
                            ownerName: ownerName,
                            ownerEmail: userEmail
                        )
                    }
                } catch {
                    print("Error parsing response JSON: \(error.localizedDescription)")
                }
            } else {
                print("Failed to fetch repository. Status code: \(httpResponse.statusCode)")
                if let data = data, let errorResponse = String(data: data, encoding: .utf8) {
                    print("Response from GitHub: \(errorResponse)")
                }
            }
        }
    }
    task.resume()
    semaphore.wait()
    return fetchedRepo
}
