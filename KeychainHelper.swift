//
//  KeychainHelper.swift
//  MacOSMFA
//
//  Created by garbutante on 3/6/21.
//

import Foundation
//import LocalAuthentication

//let keychainKey = "garbutante"
//let keychainService = "TOTPsecret"


//let keychainKey = String(decoding: username, as: UTF8.self)

@objc class KeychainHelper: NSObject {
    
        var username: String
        var service: String
    
    
     @objc init(username: String, service: String) {
            self.username = "yubitest1"
            self.service = "TOTPsecret"
            super.init()
     }
    
/*    convenience override init(username: String, service: String) {
        //self.init(username: String, service: String)
        self.init(username: username, service: service)
        //self.username = username
        //self.service = service
    }*/
    
    
    
    
    @objc static func load(key: String, service: String/*, context: LAContext*/) -> Data? {
        let query = [
            kSecClass                       : kSecClassGenericPassword,
            kSecAttrAccount                 : key,
            kSecAttrService                 : service,
            kSecReturnData                  : true,
            kSecMatchLimit                  : kSecMatchLimitOne
            //kSecUseAuthenticationContext    : context,
            //kSecUseAuthenticationUI         : kSecUseAuthenticationUISkip
        ] as CFDictionary
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query, &dataTypeRef)
        
        if status == noErr {
            return dataTypeRef as? Data
        } else {
            return nil
        }
    }
    
    @objc static var secAccessControl: SecAccessControl {
        return SecAccessControlCreateWithFlags(nil, kSecAttrAccessibleWhenUnlockedThisDeviceOnly, .userPresence, nil)!
    }
    
    
    @objc func readEntry() -> String {
/*        let context = LAContext()
        var error: NSError?
        var keychainOTPValue: String?
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let accessControl = KeychainHelper.secAccessControl
            context.evaluateAccessControl(accessControl, operation: .useItem, localizedReason: "Access app keychain") { [self] (success, error) in
                //let result: String
                if success, let data = KeychainHelper.load(key: username, service: service, context: context) {
                    let dataStr = String(decoding: data, as: UTF8.self)
                    //result = "Result: \(dataStr)"
                    keychainOTPValue = dataStr
                    //return dataStr
                } else {
                    //result = "Can't read entry, error: \(error?.localizedDescription ?? "-")"
                    keychainOTPValue = "error!"
                    //return "error"
                }
                //DispatchQueue.main.async { [weak self] in
                    //self?.updateStatus(result)
                    //print(result)
                    //return result
                }
        }
        else {
           // print("Can't read entry: \(error?.localizedDescription ?? "")")
            keychainOTPValue = "error!"
        }*/
        let data = KeychainHelper.load(key: username, service: service/*, context: context*/)
        let dataStr = String(decoding: data!, as: UTF8.self)
        //let dataStr = "MZSTMOBYGY2DIYLD"
        return dataStr
        //return keychainOTPValue!
    } //func
    
}//class
