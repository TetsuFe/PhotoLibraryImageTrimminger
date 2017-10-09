//
//  ImageFileManager.swift
//  PhotoLibraryImageTrimminger
//
//  Created by Satoshi Yoshio on 2017/10/09.
//  Copyright © 2017年 Yoshio. All rights reserved.
//

import Foundation
import UIKit

//画像ファイルを扱うための構造体
struct ImageFileManager : SimpleFileManager{
    let defaultImageFileDirectoryPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] + "/image"
    
    func createImageFile(data: Data, fileName: String){
        
        let path = defaultImageFileDirectoryPath
        
        let fileManager = FileManager.default
        var isDir : ObjCBool = false
        fileManager.fileExists(atPath: path, isDirectory: &isDir)
        
        if !isDir.boolValue{
            try! fileManager.createDirectory(atPath: path ,withIntermediateDirectories: false, attributes: nil)
        }
        
        try! data.write(to: FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("/image/\(fileName)"))
    }
    
    func readImageFile(fileName: String) -> UIImage?{
        let d = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("/image/\(fileName)")
        let data = try! Data(contentsOf: d)
        return UIImage(data: data)
    }
    
    func writeNewImageFile(data: Data, fileName: String){
        createImageFile(data: data, fileName: fileName)
    }
    
    func updateImageFile(data: Data, fileName: String){
        deleteFile(path: defaultImageFileDirectoryPath, fileName: fileName)
        createImageFile(data: data, fileName: fileName)
    }
    
    func deleteImageFile(fileName: String){
        deleteFile(path: defaultImageFileDirectoryPath, fileName: fileName)
    }
}

