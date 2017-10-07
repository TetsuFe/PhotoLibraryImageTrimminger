//
//  SimpleFileManager.swift
//  PhotoLibraryImageTrimminger
//
//  Created by Satoshi Yoshio on 2017/10/04.
//  Copyright © 2017年 Yoshio. All rights reserved.
//

import Foundation
import UIKit

struct SimpleFileManager{
    let defaultImageFileDirectoryPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] + "/image"
    
    let defaultTextFileDirectoryPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] + "/text"
    
    let imageFileNameListFileName = "imageFileNameList.txt"
    
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
    
    //readTextFileToArray().countでも代用可能
    func countFileLines()->Int{
        var count = 0
        if let f = FileHandle(forReadingAtPath: "\(defaultTextFileDirectoryPath)/\(imageFileNameListFileName)"){
            while(true){
                if let text = f.readline(){
                    print(text)
                    count += 1
                }else{
                    break;
                }
            }
        }
        return count
    }
    
    func readImageFile(fileName: String) -> UIImage?{
        let d = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("/image/\(fileName)")
        let data = try! Data(contentsOf: d)
        return UIImage(data: data)
    }
    
    func deleteImageFile(fileName: String){
        deleteFile(path: defaultImageFileDirectoryPath, fileName: fileName)
    }
    
    func deleteTextFile(fileName: String){
        deleteFile(path: defaultTextFileDirectoryPath, fileName: fileName)
    }
    
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
    
    func readImageListFileToArray()->Array<String>{
        var imageFileList = [String]()
        if let f = FileHandle(forReadingAtPath: "\(defaultTextFileDirectoryPath)/\(imageFileNameListFileName)"){
            while(true){
                if let imageFileName = f.readline(){
                    if imageFileName != ""{
                        imageFileList.append(imageFileName)
                    }
                }else{
                    break;
                }
            }
        }
        return imageFileList
    }
    
    func getDeletedImageListString(deletingFileName: String)->String{
        var imageFileListString = ""
        if let f = FileHandle(forReadingAtPath: "\(defaultTextFileDirectoryPath)/\(imageFileNameListFileName)"){
            while(true){
                if let imageFileName = f.readline(){
                    print(imageFileName)
                    if imageFileName == deletingFileName{
                        imageFileListString += "\n"
                    }else{
                        imageFileListString += imageFileName+"\n"
                    }
                }else{
                    break;
                }
            }
        }
        print("return:\n \(imageFileListString)")
        return imageFileListString
    }
    
    func removeFromImageListFile(deletingFileName: String){
        print("deleting : \(deletingFileName)")
        let deletedFileListString = getDeletedImageListString(deletingFileName: deletingFileName)
        print("now file contents: \(deletedFileListString)")
        deleteTextFile(fileName: imageFileNameListFileName)
        writeNewImageFileName(imageFileListString: deletedFileListString)
    }
    
    func writeNewImageFileName(imageFileListString: String){
        writeTextFile(imageFileName: imageFileListString, toFileName: imageFileNameListFileName)
    }
    
    func addNewImageFileName(fileName: String){
        writeTextFile(imageFileName: fileName+"\n", toFileName: imageFileNameListFileName)
    }
    
    func writeNewImageFile(data: Data, fileName: String){
        createImageFile(data: data, fileName: fileName)
    }
    
    func autoIncrementedFileName()->String{
        return String(countFileLines())+".png"
    }
    
    func updateImageNameList(newList: Array<String>){
        deleteTextFile(fileName: imageFileNameListFileName)
        writeNewImageFileName(imageFileListString: newList.joined(separator: "\n"))
    }
    
    func updateImageFile(data: Data, fileName: String){
        deleteFile(path: defaultImageFileDirectoryPath, fileName: fileName)
        createImageFile(data: data, fileName: fileName)
    }
}
