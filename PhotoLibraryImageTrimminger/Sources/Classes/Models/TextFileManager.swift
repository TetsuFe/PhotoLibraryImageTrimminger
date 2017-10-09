//
//  TextFileManager.swift
//  PhotoLibraryImageTrimminger
//
//  Created by Satoshi Yoshio on 2017/10/09.
//  Copyright © 2017年 Yoshio. All rights reserved.
//

import Foundation

//テキストファイルを扱うための構造体
struct TextFileManager : SimpleFileManager{
    var defaultTextFileDirectoryPath:String
    
    init(defaultTextFileDirectoryPath: String){
        self.defaultTextFileDirectoryPath = defaultTextFileDirectoryPath
    }
    
    //すでにファイルが存在すれば追記
    func writeTextFile(imageFileName: String, toFileName fileName: String){
        //従来のテキストを新規or追記保存するメソッド
        let path = defaultTextFileDirectoryPath
        
        let fileManager = FileManager.default
        var isDir : ObjCBool = false
        fileManager.fileExists(atPath: path, isDirectory: &isDir)
        
        if !isDir.boolValue{
            try! fileManager.createDirectory(atPath: path ,withIntermediateDirectories: false, attributes: nil)
        }
        
        let fullPath = "\(path)/\(fileName)"
        print("writeFile \(fullPath)")
        
        // 保存処理 初回のみfilew == nilなので、初回のみ新規につくられる
        if let filew = FileHandle(forWritingAtPath: fullPath){
            writeTextFileAdditinally(filew:filew,filepath:fullPath,text:imageFileName)
        }else{
            let imageFileFullPathWithNewLine = imageFileName
            try! imageFileFullPathWithNewLine.write(toFile: fullPath, atomically: true, encoding: String.Encoding.utf8)
        }
    }
    
    func writeTextFileAdditinally(filew:FileHandle,filepath:String,text:String){
        print(text)
        let data = (text as NSString).data(using: String.Encoding.utf8.rawValue)
        filew.seekToEndOfFile()
        filew.write(data!)
        filew.closeFile()
    }
    
    func deleteTextFile(fileName: String){
        deleteFile(path: defaultTextFileDirectoryPath, fileName: fileName)
    }
}
