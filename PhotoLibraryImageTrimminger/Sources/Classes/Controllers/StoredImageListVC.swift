//
//  StoredImageListVC.swift
//  PhotoLibraryImageTrimminger
//
//  Created by Satoshi Yoshio on 2017/10/04.
//  Copyright © 2017年 Yoshio. All rights reserved.
//

import UIKit

class StoredImageListVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate{

    var imageIndex = 0
    var imageList = [UIImage]()
    var imageFileNameList = [String]()
    var imageView: UIImageView!
    let imageFileManager = ImageFileManager()
    let imageListFileManager = ImageListFileManager()
    var photoLibraryManager : PhotoLibraryManager!
    let imageViewCreator = ImageViewCreator()
    
    @IBAction func loadImageFromPhotoLibraryButton(_ sender: Any) {
        photoLibraryManager.callPhotoLibrary()
    }
    
    @IBAction func nextImageButton(_ sender: Any) {
        showNextImageView()
    }
    
    @IBAction func backImageButton(_ sender: Any) {
        showPreviousImageView()
    }
    
    @IBOutlet weak var deleteImageButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoLibraryManager = PhotoLibraryManager(parentViewController: self)
        loadStoredImageList()
        if imageList.count > 0{
            let image = imageList[imageIndex]
            imageView = imageViewCreator.createFittedImageView(image: image,screenSize: self.view.frame.size)
            centerizeImageView(imageView: imageView)
            self.view.addSubview(imageView)
            deleteImageButton.isEnabled = true
            deleteImageButton.addTarget(self, action: #selector(createAlertViewForDeleteImage), for:.touchUpInside)
        }else{
            deleteImageButton.isEnabled = false
        }
        imageIndex = 0
    }
    
    /*
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        //ImageViewを画面サイズに合わせるためにviewDidLoadではできないため、DidAppearで行う
        if imageList.count > 0 {
            let image = imageList[imageIndex]
            imageView = imageViewCreator.createFittedImageView(image: image,screenSize: self.view.frame.size)
            centerizeImageView(imageView: imageView)
            self.view.addSubview(imageView)
            deleteImageButton.isEnabled = true
        }
    }
 */
    /*
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //ImageViewを画面サイズに合わせるためにviewDidLoadではできないため、WillAppearで行う
        if imageList.count > 0 {
            let image = imageList[imageIndex]
            imageView = imageViewCreator.createFittedImageView(image: image,screenSize: self.view.frame.size)
            centerizeImageView(imageView: imageView)
            self.view.addSubview(imageView)
            deleteImageButton.isEnabled = true
        }
    }
 */
    func showNextImageView(){
        if imageIndex < imageList.count-1 {
            imageIndex += 1
            print(imageIndex)
            updateImageView(newImage: imageList[imageIndex])
        }
    }
    
    func showPreviousImageView(){
        if imageIndex > 0 && imageList.count > 0{
            imageIndex -= 1
            print(imageIndex)
            updateImageView(newImage: imageList[imageIndex])
        }
    }
    
    func loadStoredImageList(){
        imageFileNameList = imageListFileManager.readImageListFileToArray()
        print(imageFileNameList)
        for imageFileName in imageFileNameList{
            if let image = imageFileManager.readImageFile(fileName: imageFileName) {
                imageList.append(image)
            }
        }
    }
    
    @objc func createAlertViewForDeleteImage(){
        let alert = UIAlertController(title: "確認",
                                      message: "本当に削除しますか？",
                                      preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "削除", style: .default) { (_) -> Void in
             self.deleteAndRefreshImageView()
        }
        alert.addAction(confirmAction)
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel) { _ in
            // 何もしない
        })
        self.present(alert, animated: true)
    }
    
    func deleteAndRefreshImageView(){
        print(imageView)
        imageList.remove(at: imageIndex)
        if imageList.count == 0{
            deleteImageButton.isEnabled = false
        }
        imageListFileManager.removeFromImageListFile(deletingFileName: imageFileNameList[imageIndex])
        //再度データのロード
        loadStoredImageList()
        //一つ画像が減ったので、その前もしくは後の画像を表示（保存された画像が消した画像のみの場合は、何も表示しない）
        if imageList.count > 0{
            if imageIndex == 0{
                updateImageView(newImage: imageList[imageIndex])
            }else {
                showPreviousImageView()
            }
        }else{
            imageView.removeFromSuperview()
        }
    }
    
    func centerizeImageView(imageView: UIImageView){
        // 画像の中心をスクリーンの中心位置に設定
        let screenWidth = self.view.frame.width
        let screenHeight = self.view.frame.height
        imageView.center = CGPoint(x:screenWidth/2, y:screenHeight/2)
    }
    
    func updateImageView(newImage: UIImage){
        imageView.removeFromSuperview()
        showImage(image: newImage)
    }
    
    func showImage(image: UIImage){
        imageView = imageViewCreator.createFittedImageView(image: image, screenSize: self.view.frame.size)
        centerizeImageView(imageView: imageView)
        self.view.addSubview(imageView)
    }

    //写真選択完了後に呼ばれる標準メソッド
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.photoLibraryImage = pickedImage
        }
        
        //withIdentifier: "imageEditVC"は遷移先のViewControllerのIdentifier。as! ImageEditVCは遷移先ののViewControllerの型名
        let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "trimImageVC") as! TrimImageVC
        picker.present(nextViewController, animated: true)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
