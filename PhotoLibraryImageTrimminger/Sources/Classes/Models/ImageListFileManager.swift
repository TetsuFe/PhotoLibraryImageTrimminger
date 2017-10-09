//
//  ImageListFileManager.swift
//  PhotoLibraryImageTrimminger
//
//  Created by Satoshi Yoshio on 2017/10/09.
//  Copyright © 2017年 Yoshio. All rights reserved.
//

import Foundation

//画像のファイル名の一覧ファイルを扱う構造体。
struct ImageListFileManager{
    let defaultTextFileDirectoryPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] + "/text"
    let imageFileNameListFileName = "imageFileNameList.txt"
    var textFileManager:TextFileManager!
    
    init(){
        textFileManager = TextFileManager(defaultTextFileDirectoryPath:  defaultTextFileDirectoryPath)
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
    
    func getDeletedNameListString(deletingFileName: String)->String{
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
    
    func removeFromImageListFile(deletingFileName: String){
        print("deleting : \(deletingFileName)")
        let deletedFileListString = getDeletedNameListString(deletingFileName: deletingFileName)
        print("now file contents: \(deletedFileListString)")
        textFileManager.deleteTextFile(fileName: imageFileNameListFileName)
        writeNewImageFileName(imageFileListString: deletedFileListString)
    }
    
    func writeNewImageFileName(imageFileListString: String){
        textFileManager.writeTextFile(imageFileName: imageFileListString, toFileName: imageFileNameListFileName)
    }
    
    func addNewImageFileName(fileName: String){
        textFileManager.writeTextFile(imageFileName: fileName+"\n", toFileName: imageFileNameListFileName)
    }
    
    func autoIncrementedFileName()->String{
        return String(countFileLines())+".png"
    }
    
    func updateImageNameList(newList: Array<String>){
        textFileManager.deleteTextFile(fileName: imageFileNameListFileName)
        writeNewImageFileName(imageFileListString: newList.joined(separator: "\n"))
    }
}
