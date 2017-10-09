

//
//  SimpleFileManager.swift
//  PhotoLibraryImageTrimminger
//
//  Created by Satoshi Yoshio on 2017/10/04.
//  Copyright © 2017年 Yoshio. All rights reserved.
//

import Foundation
import UIKit

//ファイル処理の共通処理のプロトコル（削除処理）
protocol SimpleFileManager{
    func deleteFile(path: String, fileName: String) -> Void
}

extension SimpleFileManager{
    func deleteFile(path: String, fileName: String){
        let fileManager = FileManager.default
        var isDir : ObjCBool = false
        fileManager.fileExists(atPath: path, isDirectory: &isDir)
        
        if !isDir.boolValue{
            try! fileManager.createDirectory(atPath: path ,withIntermediateDirectories: false, attributes: nil)
        }
        
        let fullPath = "\(path)/\(fileName)"
        do{
            print("deletingFile: \(fullPath)")
            try FileManager.default.removeItem(atPath: fullPath)
            print("file delete succeeded")
        }catch{
            print("file delete failed")
        }
    }
}
