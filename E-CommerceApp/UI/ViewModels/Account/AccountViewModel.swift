//
//  AccountViewModel.swift
//  E-CommerceApp
//
//  Created by Tural Babayev on 19.10.2024.
//

import Foundation

class AccountViewModel{
    let username = UserDefaults.standard.string(forKey: "savedUsername") ?? "guest"
    
    func getUserName() -> String{
        return username
    }
    
    func getProfileLogo()->String{
        let initials = username.split(separator: " ").map { $0.first?.uppercased() ?? "" }.joined()
        return initials
    }

}
