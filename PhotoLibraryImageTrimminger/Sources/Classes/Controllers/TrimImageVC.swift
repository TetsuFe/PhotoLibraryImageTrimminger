//
//  TrimImageVC.swift
//  PhotoLibraryImageTrimminger
//
//  Created by Satoshi Yoshio on 2017/10/04.
//  Copyright © 2017年 Yoshio. All rights reserved.
//

import UIKit
import Foundation

class TrimImageVC: UIViewController {
        
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var navigationLabel: UILabel!
    @IBOutlet weak var cropImageButton: UIButton!
    @IBOutlet weak var cancelEditButton: UIButton!
    @IBOutlet weak var finishEditingButton: UIButton!
    @IBOutlet weak var editPhotoView: UIView!
    @IBOutlet weak var centerizeButton: UIButton!
   
    @IBOutlet weak var headerView: UIView!
    var image : UIImage!
    var imageView : UIImageView!
    var previousImages = [UIImage]()
    var previousScaleZoomedInOut = [CGFloat]()
    var scaleZoomedInOut : CGFloat = 1.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        cropImageButton.addTarget(self, action: #selector(clipImage), for: .touchUpInside)
        cancelEditButton.addTarget(self, action: #selector(cancelEdit), for: .touchUpInside)
        centerizeButton.addTarget(self, action: #selector(centerizeImage), for: .touchUpInside)
        finishEditingButton.addTarget(self, action: #selector(finishCropping), for: .touchUpInside)
        editPhotoView.layer.borderColor = UIColor.black.cgColor
        editPhotoView.layer.borderWidth = 1
        setUpPinchInOutAndDoubleTap()
        
        //load image and show UIImageView
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        image = appDelegate.photoLibraryImage
        previousScaleZoomedInOut.append(scaleZoomedInOut)
        createImageView(on: editPhotoView)
        mainStackView.bringSubview(toFront: headerView)
    }
    
    func setUpPinchInOutAndDoubleTap(){
        // ピンチイン・アウトの準備
        let pinchGetsture = UIPinchGestureRecognizer(target: self, action: #selector(pinchAction(gesture:)))
        pinchGetsture.delegate = self as? UIGestureRecognizerDelegate
        
        self.editPhotoView.isUserInteractionEnabled = true
        self.editPhotoView.isMultipleTouchEnabled = true
        
        self.editPhotoView.addGestureRecognizer(pinchGetsture)
        // ダブルタップの準備
        let doubleTapGesture = UITapGestureRecognizer(target: self, action:#selector(doubleTapAction(gesture:)))
        doubleTapGesture.numberOfTapsRequired = 2
        self.editPhotoView.addGestureRecognizer(doubleTapGesture)
    }
    
    func createImageView(on parentView: UIView){
        imageView = UIImageView(image: image)
        // 画像の幅・高さの取得
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        
        let rect:CGRect = CGRect(x:0, y:0, width:scaleZoomedInOut*imageWidth, height:scaleZoomedInOut*imageHeight)
        // ImageView frame をCGRectで作った矩形に合わせる
        imageView.frame = rect

        let screenWidth = editPhotoView.frame.width
        let screenHeight = editPhotoView.frame.height
        // 画像の中心をスクリーンの中心位置に設定
        imageView.center = CGPoint(x:screenWidth/2, y:screenHeight/2)

        parentView.addSubview(imageView)
        parentView.sendSubview(toBack: imageView)
    }
    
    func updateImageView(){
        imageView.removeFromSuperview()
        createImageView(on: editPhotoView)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // タッチイベントを取得.
        let aTouch: UITouch = touches.first!
        
        // 移動した先の座標を取得.
        let location = aTouch.location(in: editPhotoView)
        
        // 移動する前の座標を取得.
        let prevLocation = aTouch.previousLocation(in: editPhotoView)
        
        let deltaX = location.x - prevLocation.x
        let deltaY = location.y - prevLocation.y
        
        // 移動した分の距離をmyFrameの座標にプラスする.
        imageView.frame.origin.x += deltaX
        imageView.frame.origin.y += deltaY
    }
    
    func makeCroppingRect() -> CGRect?{
        var width = CGFloat()
        var height = CGFloat()
        var croppingX = CGFloat()
        var croppingY = CGFloat()
        
        let deltaX = imageView.frame.origin.x
        let deltaY = imageView.frame.origin.y
        
        //空の部分ができてしまった場合、その部分を切り取る
        
        var xNotCropFlag = false
        //x方向
        if imageView.frame.width > editPhotoView.frame.width {
            
            //3. 最初の時点で画面のy方向に画像がはみ出している時
            if imageView.frame.origin.x > 0{
                //origin.y > 0の場合、確実にy方向に画面から外れている
                //上方向にはみ出し
                width = editPhotoView.frame.size.width - deltaX
            }else{
                //origin.y < 0の場合、上方向には確実にはみ出している
                //下方向がはみ出していない
                if editPhotoView.frame.size.width > (imageView.frame.size.width + imageView.frame.origin.x) {
                    width = imageView.frame.size.width + imageView.frame.origin.x
                }else{
                    //下方向もはみ出し
                    width = editPhotoView.frame.size.width
                }
            }
        }else{
            //4. 最初の時点で画面のy方向に画像がすっぽり全て収まっている時
            if imageView.frame.origin.x > 0{
                if editPhotoView.frame.size.width < (imageView.frame.size.width + imageView.frame.origin.x) {
                    //下方向にはみ出し
                    width = editPhotoView.frame.size.width - deltaX
                }else{
                    xNotCropFlag = true
                    width = imageView.frame.size.width
                }
            }else{
                //上方向にはみ出し
                width = imageView.frame.size.width + imageView.frame.origin.x
            }
        }
        //y方向
        if imageView.frame.height > editPhotoView.frame.height {
            
            //3. 最初の時点で画面のy方向に画像がはみ出している時
            if imageView.frame.origin.y > 0{
                //origin.y > 0の場合、確実にy方向に画面から外れている
                //下方向にはみ出し
                height = editPhotoView.frame.size.height - deltaY
            }else{
                //origin.y < 0の場合、上方向には確実にはみ出している
                //下方向がはみ出していない
                if editPhotoView.frame.size.height > (imageView.frame.size.height + imageView.frame.origin.y) {
                    height = imageView.frame.size.height + imageView.frame.origin.y
                }else{
                    //下方向もはみ出し
                    height = editPhotoView.frame.size.height
                }
            }
        }else{
            //4. 最初の時点で画面のy方向に画像がすっぽり全て収まっている時
            if imageView.frame.origin.y > 0{
                if editPhotoView.frame.size.height < (imageView.frame.size.height + imageView.frame.origin.y) {
                    //下方向にはみ出し
                    height = editPhotoView.frame.size.height - deltaY
                }else{
                    if xNotCropFlag {
                        return nil
                    }else{
                        height = imageView.frame.size.height
                    }
                }
            }else{
                //上方向にはみ出し
                height = imageView.frame.size.height + imageView.frame.origin.y
            }
        }
        
        //croppingRectの座標を決定
        if imageView.frame.origin.x > editPhotoView.frame.origin.x {
            croppingX = 0
        }else{
            croppingX = -deltaX
        }
        
        if imageView.frame.origin.y > 0 {
            croppingY = 0
        }else{
            croppingY = -deltaY
        }
        
        return CGRect(x: croppingX, y: croppingY, width: width, height: height)
    }
    
    //はみ出したところを切り出す
    @objc func clipImage(){
        if let croppingRect = makeCroppingRect(){
            previousImages.append(image)
            previousScaleZoomedInOut.append(scaleZoomedInOut)
            image = image.cropping(to: croppingRect, zoomedInOutScale: scaleZoomedInOut)
            updateImageView()
        }
    }
    
    @objc func finishCropping(){
        saveImage()
        moveToNextPage()
    }
    
    func saveImage(){
        print(editPhotoView.frame.width)
        print(imageView.frame.size)
        print(image.size)
        let imageListFileManager = ImageListFileManager()
        let imageFileManager = ImageFileManager()
        //if let data = UIImageJPEGRepresentation(image, 1.0) {
        if let data = UIImagePNGRepresentation(image) {
            let autoIncrementedFileName = imageListFileManager.autoIncrementedFileName()
            print(autoIncrementedFileName)
            imageFileManager.writeNewImageFile(data: data, fileName: autoIncrementedFileName)
            imageListFileManager.addNewImageFileName(fileName: autoIncrementedFileName)
        }
    }
    
    func moveToNextPage(){
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "storedImageListVC") as! StoredImageListVC
        self.present(secondViewController, animated: true)
    }
    
    @objc func cancelEdit(){
        if previousScaleZoomedInOut.count > 1{
            _ = previousScaleZoomedInOut.popLast()!
            scaleZoomedInOut = previousScaleZoomedInOut.popLast()!
            previousScaleZoomedInOut.append(scaleZoomedInOut)
        }
        if previousImages.count > 0{
            image = previousImages.popLast()
            updateImageView()
        }
    }
    
    @objc func centerizeImage(){
        // 画像サイズをスクリーン幅に合わせる
        let screenWidth = editPhotoView.frame.width
        let screenHeight = editPhotoView.frame.height
        imageView.center = CGPoint(x:screenWidth/2, y:screenHeight/2)
    }
    
    
    var pichCenter : CGPoint!
    var touchPoint1 : CGPoint!
    var touchPoint2 : CGPoint!
    let maxScale : CGFloat = 1
    var pinchStartImageCenter : CGPoint!
    
    @objc func pinchAction(gesture: UIPinchGestureRecognizer) {
        
        if gesture.state == UIGestureRecognizerState.began {
            // ピンチを開始したときの画像の中心点を保存しておく
            pinchStartImageCenter = imageView.center
            touchPoint1 = gesture.location(ofTouch: 0, in: self.view)
            touchPoint2 = gesture.location(ofTouch: 1, in: self.view)
            
            // 指の中間点を求めて保存しておく
            // UIGestureRecognizerState.Changedで毎回求めた場合、ピンチ状態で片方の指だけ動かしたときに中心点がずれておかしな位置でズームされるため
            pichCenter = CGPoint(x: (touchPoint1.x + touchPoint2.x) / 2, y: (touchPoint1.y + touchPoint2.y) / 2)
            
        } else if gesture.state == UIGestureRecognizerState.changed {
            // ピンチジェスチャー・変更中
            var pinchScale :  CGFloat// ピンチを開始してからの拡大率。差分ではない
            if gesture.scale > 1 {
                pinchScale = 1 + gesture.scale/100
            }else{
                pinchScale = gesture.scale
            }
            if pinchScale*self.imageView.frame.width < editPhotoView.frame.width {
                pinchScale = editPhotoView.frame.width/self.imageView.frame.width
            }
            scaleZoomedInOut *= pinchScale
            
            // ピンチした位置を中心としてズーム（イン/アウト）するように、画像の中心位置をずらす
            let newCenter = CGPoint(x: pinchStartImageCenter.x - ((pichCenter.x - pinchStartImageCenter.x) * pinchScale - (pichCenter.x - pinchStartImageCenter.x)),y: pinchStartImageCenter.y - ((pichCenter.y - pinchStartImageCenter.y) * pinchScale - (pichCenter.y - pinchStartImageCenter.y)))
            self.imageView.frame.size = CGSize(width: pinchScale*self.imageView.frame.width, height: pinchScale*self.imageView.frame.height)
            imageView.center = newCenter
        }
    }
    
    @objc func doubleTapAction(gesture: UITapGestureRecognizer) {
        
        if gesture.state == UIGestureRecognizerState.ended {
            
            let doubleTapStartCenter = imageView.center
            let doubleTapScale: CGFloat = 2.0 // ダブルタップでは現在のスケールの2倍にする
            scaleZoomedInOut *= doubleTapScale
            let tapPoint = gesture.location(in: self.view)
            let newCenter = CGPoint(x:
                doubleTapStartCenter.x - ((tapPoint.x - doubleTapStartCenter.x) * doubleTapScale - (tapPoint.x - doubleTapStartCenter.x)),
                                    y: doubleTapStartCenter.y - ((tapPoint.y - doubleTapStartCenter.y) * doubleTapScale - (tapPoint.y - doubleTapStartCenter.y)))
            
            // 拡大・縮小とタップ位置に合わせた中心点の移動
            UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {() -> Void in
                self.imageView.frame.size = CGSize(width: doubleTapScale*self.imageView.frame.width, height: doubleTapScale*self.imageView.frame.height)
                self.imageView.center = newCenter
            }, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
