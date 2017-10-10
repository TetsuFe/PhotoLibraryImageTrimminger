//
//  UIImage+Trimming.swift
//  PhotoLibraryImageTrimminger
//
//  Created by Satoshi Yoshio on 2017/10/04.
//  Copyright © 2017年 Yoshio. All rights reserved.
//

import UIKit

//トリミングを行うメソッド
//トリミング範囲の大きさtrimmingRectと元画像の大きさとの拡大倍率をzoomedInOutScaleを用いる
extension UIImage {
    func trimming(to trimmingRect : CGRect , zoomedInOutScale: CGFloat) -> UIImage? {
        var opaque = false
        if let cgImage = cgImage {
            switch cgImage.alphaInfo {
            case .noneSkipLast, .noneSkipFirst:
                opaque = true
            default:
                break
            }
        }
        UIGraphicsBeginImageContextWithOptions(CGSize(width: trimmingRect.size.width/zoomedInOutScale, height: trimmingRect.size.height/zoomedInOutScale), opaque, scale)
        draw(at: CGPoint(x: -trimmingRect.origin.x/zoomedInOutScale, y: -trimmingRect.origin.y/zoomedInOutScale))
        let trimmedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return trimmedImage
    }
}
