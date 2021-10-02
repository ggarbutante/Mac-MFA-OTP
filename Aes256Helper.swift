//
//  Aes256Helper.swift
//  MacOSMFA
//
//  Created by garbutante on 3/7/21.
//
import Foundation
import CryptoSwift

extension Data {
    func aesEncrypt(key: String, iv: String) throws -> Data{
        let encypted = try AES(key: key.bytes, blockMode: CBC(iv: iv.bytes), padding: .pkcs7).encrypt(self.bytes)
        return Data(encypted)
    }

    func aesDecrypt(key: String, iv: String) throws -> Data {
        let decrypted = try AES(key: key.bytes, blockMode: CBC(iv: iv.bytes), padding: .pkcs7).decrypt(self.bytes)
        return Data(decrypted)
    }
}

@objc class Aes256Helper: NSObject {
    
    let destinationPath = URL(string: "/tmp/testDec.log")
    let totpKey: String // length == 32
    var iv: String = "" // length == 16
    
    @objc init(totpKey: String, iv: String) {
           self.totpKey = totpKey
           self.iv = iv
           super.init()
    }
    
    @objc func encryptFile(_ path: URL) -> Bool{
        do{
            let data = try Data.init(contentsOf: path)
            let encodedData = try data.aesEncrypt(key: totpKey, iv: iv)
            try encodedData.write(to: destinationPath!)
            return true
        }catch{
            return false
        }
    }

    @objc func decryptFile(_ path: URL) -> Bool{
        do{
            let data = try Data.init(contentsOf: path)
            let decodedData = try data.aesDecrypt(key: totpKey, iv: iv)
           // let dataString = NSString(data: decodedData as Data, encoding: String.Encoding.utf8.rawValue)!
           // let dataString = String(decoding: decodedData, as: UTF8.self)
            try decodedData.write(to: destinationPath!)
            return true
        }catch{
            return false
        }
    }

}
