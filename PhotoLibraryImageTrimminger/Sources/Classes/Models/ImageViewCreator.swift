//
//  ImageViewCreator.swift
//  PhotoLibraryImageTrimminger
//
//  Created by Satoshi Yoshio on 2017/10/08.
//  Copyright © 2017年 Yoshio. All rights reserved.
//

import UIKit

struct ImageViewCreator{
    //もとの解像度よりも大きくなってしまうような拡大はしない
    //例えば、縮小した後に横を少し削ると、保存時点では横幅が若干小さいものになる。しかし、実際には大きなサイズのまま保存されるので、壁紙に使用する際や一覧表示する際には画像の解像度が画面の横幅よりも大きければ、画面いっぱいに表示されることになる
    func createFittedImageView(image: UIImage, screenSize: CGSize) -> UIImageView{
        let imageView = UIImageView(image: image)
        // 画像の幅・高さの取得
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height*2/3 //本来は違う
        
        print(screenSize.width)
        print(image.size)
        
        // 画像サイズが横方向にスクリーンサイズよりも大きければ、スクリーン幅に合わせる。アスペクト比は同じ
        if imageWidth > screenWidth {
            let autoSizingScale = screenWidth / imageWidth
            let rect:CGRect = CGRect(x:0, y:0, width:imageWidth*autoSizingScale, height:imageHeight*autoSizingScale)
            imageView.frame = rect
        }
        // 画像サイズが横方向にスクリーンサイズよりも大きければ、スクリーン幅に合わせる。アスペクト比は同じ
        if imageView.frame.height > screenHeight {
            let autoSizingScale = screenHeight / imageView.frame.height
            let rect:CGRect = CGRect(x:0, y:0, width:imageView.frame.width*autoSizingScale, height:imageView.frame.height*autoSizingScale)
            imageView.frame = rect
        }
        return imageView
    }
}
