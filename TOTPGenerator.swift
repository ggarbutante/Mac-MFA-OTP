//
//  TOTPGenerator.swift
//  MFAPlugin
//
//  Created by garbutante on 2/25/21.
//

import CryptoKit
import CommonCrypto
import Foundation
import Base32
import SwiftOTP
//import KeychainSwift


//let keychain = KeychainSwift()
//let totpKeychainSecret = keychain.get("TOTPsecret")

@objc class TOTPGenerator: NSObject {
    
    let period = TimeInterval(30)
    let digits = 6
    //var keychainItemValue: String
    //let secret = base32DecodeToData(totpKeychainSecret!)!
    //let secret = Data(base64Encoded: "6UAOpz+x3dsNrQ==")!
    //let secret = Base32.decode("HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ")
    //working code below:
    //let secret = base32DecodeToData("HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ")!
    //var secret: Data?
    //let secret = base32DecodeToData()
    var keychainItemValue: String
    var key: String
    //var keySym: SymmetricKey
    //var keySym = keyFromEncKey(key)
    //let decoded = Base32.decode(string: "MZXW6YTBOI======")
    var counter: UInt64
    //let secret: String
    //let data: String
    
    
    @objc init(keychainItemValue: String, fromKey: String) {
        //self.counter = UInt64(Date().timeIntervalSince1970 / period).bigEndian
        self.keychainItemValue = keychainItemValue
        self.key = fromKey
        self.counter = UInt64(Date().timeIntervalSince1970 / period).bigEndian
        //self.secret = try? decryptStringToCodableOject(encData: keychainItemValue)
        super.init()
        //self.key = keyFromEncKey(key)
    }
    
 /*
    @objc func cryptoKitOTPFixed() {
        let counterData = withUnsafeBytes(of: &counter) { Array($0) }
        let hash = HMAC<Insecure.SHA1>.authenticationCode(for: counterData, using: SymmetricKey(data: secret!))
     
        var truncatedHash = hash.withUnsafeBytes { ptr -> UInt32 in
            let offset = ptr[hash.byteCount - 1] & 0x0f
     
            let truncatedHashPtr = ptr.baseAddress! + Int(offset)
            return truncatedHashPtr.bindMemory(to: UInt32.self, capacity: 1).pointee
        }
     
        truncatedHash = UInt32(bigEndian: truncatedHash)
        truncatedHash = truncatedHash & 0x7FFF_FFFF
        truncatedHash = truncatedHash % UInt32(pow(10, Float(digits)))
     
        print("CryptoKitFixed OTP value: \(String(format: "%0*u", digits, truncatedHash))")
    }
    
    @objc func commonCryptoOTP() {
        let counterData = withUnsafeBytes(of: &counter) { Array($0) }
        let key = Data(bytes: &counter, count: MemoryLayout.size(ofValue: counter))
        let (hashAlgorithm, hashLength) = (CCHmacAlgorithm(kCCHmacAlgSHA1), Int(CC_SHA1_DIGEST_LENGTH))

        let hashPtr = UnsafeMutablePointer<Any>.allocate(capacity: Int(hashLength))
        defer {
            hashPtr.deallocate()
        }

        secret!.withUnsafeBytes { secretBytes in
            // Generate the key from the counter value.
            counterData.withUnsafeBytes { counterBytes in
                CCHmac(hashAlgorithm, secretBytes.baseAddress, secret!.count, counterBytes.baseAddress, key.count, hashPtr)
            }
        }

        let hash = Data(bytes: hashPtr, count: Int(hashLength))
        var truncatedHash = hash.withUnsafeBytes { ptr -> UInt32 in
            let offset = ptr[hash.count - 1] & 0x0F
            let truncatedHashPtr = ptr.baseAddress! + Int(offset)
            return truncatedHashPtr.bindMemory(to: UInt32.self, capacity: 1).pointee
        }
        
        truncatedHash = UInt32(bigEndian: truncatedHash)
        truncatedHash = truncatedHash & 0x7FFF_FFFF
        truncatedHash = truncatedHash % UInt32(pow(10, Float(digits)))

        print("CommonCrypto OTP value: \(String(format: "%0*u", digits, truncatedHash))")
    }
 */
    @objc func googleTOTP() -> String {
        let otpDataString = try! decryptStringToCodableOject(encData: keychainItemValue, key: key)
        let otpData = base32DecodeToData(otpDataString)!
        //let otpData = Data(otpDataString.utf8)
        let totp = TOTP(secret: otpData)
        let otpString = totp!.generate(time: Date())
        //print("Google Access Code = " + otpString!)
        //print(otpString!)
        return (otpString!)
    }
        
//############################### ----- ######################################//
    func keyFromEncKey(_ key: String) -> SymmetricKey {
     // Create a SHA256 hash from the provided password
     let hash = SHA256.hash(data: key.data(using: .utf8)!)
     // Convert the SHA256 to a string. This will be a 64 byte string
     let hashString = hash.map { String(format: "%02hhx", $0) }.joined()
     // Convert to 32 bytes
     let subString = String(hashString.prefix(32))
     // Convert the substring to data
     let keyData = subString.data(using: .utf8)!

     // Create the key use keyData as the seed
     return SymmetricKey(data: keyData)
   }
    
    func decryptStringToCodableOject(encData: String, key: String) throws -> String {
          // Convert the base64 string into a Data object
          //let encKey = key
          let keySymmetric = keyFromEncKey(key)
          let data = Data(base64Encoded: encData)!
          // Put the data in a sealed box
          let box = try ChaChaPoly.SealedBox(combined: data)
          // Extract the data from the sealedbox using the decryption key
          let decryptedData = try ChaChaPoly.open(box, using: keySymmetric)
          // The decrypted block needed to be json decoded
          let retstr = String(decoding: decryptedData, as: UTF8.self)
          return retstr
           //return decryptedData
    }
    
    
    /*
       @objc func decryptStringToCodableOject(encData: String) throws -> Data {
         // Convert the base64 string into a Data object
         let encKey = "S3kritS3krit1290"
         let keySymmetric = keyFromEncKey(encKey)
         let data = Data(base64Encoded: encData)!
         // Put the data in a sealed box
         let box = try ChaChaPoly.SealedBox(combined: data)
         // Extract the data from the sealedbox using the decryption key
         let decryptedData = try ChaChaPoly.open(box, using: keySymmetric)
         // The decrypted block needed to be json decoded
         //let retstr = String(decoding: decryptedData, as: UTF8.self)
         //return retstr
          return decryptedData
       }
    */
    
}

