//
//  PhotoLibraryManager.swift
//  PhotoLibraryImageTrimminger
//
//  Created by Satoshi Yoshio on 2017/10/08.
//  Copyright © 2017年 Yoshio. All rights reserved.
//
import Photos

struct PhotoLibraryManager{
    
    var parentViewController : UIViewController!
    
    init(parentViewController: UIViewController){
        self.parentViewController = parentViewController
    }
    
    // 写真へのアクセスがOFFのときに使うメソッド
    func requestAuthorizationOn(){
        // authorization
        let status = PHPhotoLibrary.authorizationStatus()
        if (status == PHAuthorizationStatus.denied) {
            //アクセス不能の場合。アクセス許可をしてもらう。snowなどはこれを利用して、写真へのアクセスを禁止している場合は先に進めないようにしている。
            //アラートビューで設定変更するかしないかを聞く
            let alert = UIAlertController(title: "写真へのアクセスを許可",
                                          message: "写真へのアクセスを許可する必要があります。設定を変更してください。",
                                          preferredStyle: .alert)
            let settingsAction = UIAlertAction(title: "設定変更", style: .default) { (_) -> Void in
                guard let _ = URL(string: UIApplicationOpenSettingsURLString ) else {
                    return
                }
            }
            alert.addAction(settingsAction)
            alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel) { _ in
                // ダイアログがキャンセルされた。つまりアクセス許可は得られない。
            })
            self.parentViewController.present(alert, animated: true)
        }
    }
    
    func callPhotoLibrary(){
        //権限の確認
        requestAuthorizationOn()
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            
            let picker = UIImagePickerController()
            picker.modalPresentationStyle = UIModalPresentationStyle.popover
            picker.delegate = self.parentViewController as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            //以下を設定することで、写真選択後にiOSデフォルトのトリミングViewが開くようになる
            //picker.allowsEditing = true
            if let popover = picker.popoverPresentationController {
                popover.sourceView = self.parentViewController.view
                popover.sourceRect = self.parentViewController.view.frame // ポップオーバーの表示元となるエリア
                popover.permittedArrowDirections = UIPopoverArrowDirection.any
            }
            self.parentViewController.present(picker, animated: true, completion: nil)
        }
    }
}
