import SwiftUI

struct GitHubLoginView: View {
    @AppStorage("GIT_ENABLED") var enabled: Bool = false
    @AppStorage("GIT_TOKEN") var token: String = ""

    var body: some View {
        List {
            Section {
                Toggle("Enabled", isOn: $enabled)
            }
            if enabled {
                Section {
                    TextField("Token", text: $token)
                }
            }
        }
        .navigationTitle("GitHub")
        .navigationBarTitleDisplayMode(.inline)
    }
}

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
