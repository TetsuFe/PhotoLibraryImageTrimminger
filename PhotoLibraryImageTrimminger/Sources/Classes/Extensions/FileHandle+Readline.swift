//
//  FileHandle+Readline.swift
//  PhotoLibraryImageTrimminger
//
//  Created by Satoshi Yoshio on 2017/10/06.
//  Copyright © 2017年 Yoshio. All rights reserved.
//

import Foundation

//ファイルを一行ずつ読み込むメソッド。２回目以降は、進んだ次のところから始まる
extension FileHandle{
    func readline() -> String?{
        let seekStep = 1
        let encoding : String.Encoding = .utf8
        let delimData = "\n".data(using: encoding) // delimiterに\nを設定している
        var buffer = Data(capacity: 1)
        var atEof = false
        while !atEof {
            let tmpData = self.readData(ofLength: seekStep)
            if tmpData.count > 0 {
                buffer.append(tmpData)
            } else {
                // EOF or read error.
                atEof = true
                if buffer.count > 0 {
                    // Bufferはファイルの最終行
                    let line = String(data: buffer as Data, encoding: encoding)
                    buffer.count = 0
                    if line == ""{
                        return nil
                    }else{
                        return line
                    }
                }
            }
            if let range = buffer.range(of: delimData!) {
                // delimiterがくるまでの文字列がlineになる。ただし、delimiterを含まない。今回はdelimiterは\nなので、line=一行となる。
                let line = String(data: buffer.subdata(in: 0..<range.lowerBound), encoding: encoding)
                // バッファから文字列とdelimiterを削除（次からはその続きになる）
                buffer.removeSubrange(0..<range.upperBound)
                return line
            }
        }
        
        return nil
    }
}
