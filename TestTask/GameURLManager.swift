//
//  GameURLManager.swift
//  TestTask
//
//  Created by Serhii Anp on 25.08.2024.
//

import Foundation
class GameURLManager {
    static let shared = GameURLManager()
    
    var winnerURL: String?
    var loserURL: String?
    
    private init() {}
    
    func fetchURLs(completion: @escaping () -> Void) {
        guard let url = URL(string: "https://2llctw8ia5.execute-api.us-west-1.amazonaws.com/prod") else {
            completion()
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion()
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    self.winnerURL = json["winner"] as? String
                    self.loserURL = json["loser"] as? String
                }
                completion()
            } catch {
                completion()
            }
        }
        
        task.resume()
    }
}
