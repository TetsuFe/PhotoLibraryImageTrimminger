//
//  UIImage+Trimming.swift
//  PhotoLibraryImageTrimminger
//
//  Created by Satoshi Yoshio on 2017/10/04.
//  Copyright © 2017年 Yoshio. All rights reserved.
//

import UIKit

//トリミングを行うメソッド
//トリミング範囲の大きさcroppingRectと元画像の大きさとの拡大倍率をzoomedInOutScaleを用いる
extension UIImage {
    func cropping(to croppingRect : CGRect , zoomedInOutScale: CGFloat) -> UIImage? {
        var opaque = false
        if let cgImage = cgImage {
            switch cgImage.alphaInfo {
            case .noneSkipLast, .noneSkipFirst:
                opaque = true
            default:
                break
            }
        }
        UIGraphicsBeginImageContextWithOptions(CGSize(width: croppingRect.size.width/zoomedInOutScale, height: croppingRect.size.height/zoomedInOutScale), opaque, scale)
        draw(at: CGPoint(x: -croppingRect.origin.x/zoomedInOutScale, y: -croppingRect.origin.y/zoomedInOutScale))
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
}
