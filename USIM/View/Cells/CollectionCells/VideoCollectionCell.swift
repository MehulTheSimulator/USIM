//
//  VideoCollectionCell.swift
//  USIM
//
//  Created by Asher Azeem on 2/18/23.
//

import UIKit
import AVKit
import MobileCoreServices

class VideoCollectionCell : UICollectionViewCell {
    
    weak var target: CustomVideoViewController?
    
    var index: Int = 0
    var customVideoData: CustomVideoData?
    
    @IBOutlet weak var viewActivity: DesignableView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtPoint: UITextField!
    @IBOutlet weak var txtVideo: UITextField!
    
    var pickerPoint: UIPickerView?
    var pickerVideo: UIPickerView?
    var documentPickerTargetVideoRef: VideoReference? = nil
    var defaultVideos: [(String, VideoReference)]?
    var selectedVideo: VideoReference?
    var imagePicker : UIImagePickerController!
    
    public func initCell(defaultVideos: [(String, VideoReference)]) {
        self.defaultVideos = defaultVideos
        selectedVideo = nil
        pickerPoint = UIPickerView()
        pickerPoint?.dataSource = self
        pickerPoint?.delegate = self
        txtPoint?.inputView = pickerPoint
        pickerVideo = UIPickerView()
        pickerVideo?.dataSource = self
        pickerVideo?.delegate = self
        txtVideo?.inputView = pickerVideo
        txtVideo?.text = "Custom Video"
        imagePicker = UIImagePickerController()
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.mediaTypes = [kUTTypeMovie as String, kUTTypeVideo as String, kUTTypeMPEG2Video as String, kUTTypeMPEG4 as String]
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        txtPoint?.text = USIM.application.config.getAccessPoint(key: customVideoData!.videoRef.pointKey)?.name ?? ""
    }
    
    @IBAction func onClickSetNameBtn(_ sender: UIButton) {
        customVideoData?.name = txtName.text ?? "New Video"
        update()
        USIM.application.config.trySaveLocalData()
    }
    
    func requireConfirm(title: String, text: String, _ callback: @escaping (Bool) -> ()) {
        if let controller = (target?.storyboard?.instantiateViewController(withIdentifier: "ViewControllerConfirm") as? ViewControllerConfirm) {
            controller.confirmTitle = title
            controller.confirmText = text
            controller.callback = callback
            target?.present(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func onButtonDelete(_ sender: Any) {
        requireConfirm(title: "Delete Custom Video", text: "Are you sure you want to delete this custom video?") {
            [self] in
            if($0) {
                let app = USIM.application
                app.config.removeCustomVideoData(modeKey: customVideoData!.videoRef.modeKey, localIndex: index)
                target?.reloadData()
            }
        }
    }
    
    @IBAction func onButtonChooseVideo(_ sender: LoaderButton) {
        /*let app = RFIDVideoPlayer.application
         if let modeKeyValue = modeKey {
         if let viewKeyValue = viewKey {
         app.setCurrentView(modeKey: modeKeyValue, viewKey: viewKeyValue)
         target?.updateView()
         }
         }*/
        setToCustom()
    }
    
    func setToCustom() {
        if let source = selectedVideo {
            Task {
                if let url = USIM.application.config.getCachedVideoURL(videoRef: source) {
                    USIM.RemoteLog("Copying from: \(url)")
                    await USIM.application.config.cacheCustomVideo(videoRef: customVideoData!.videoRef, url: url, customVideoData: customVideoData!, successCompletion: { value in
                        
                    })
                }
            }
        } else {
            
            documentPickerTargetVideoRef = customVideoData!.videoRef
            self.target?.present(imagePicker, animated: true)
            
//            self.present(imagePicker, animated: true, completion: nil)
            
//            let supportedTypes: [UTType] = [.livePhoto, .video, .movie, .audiovisualContent, .mpeg4Movie, .quickTimeMovie, .avi, .mpeg, .mpeg2TransportStream]
//            let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes, asCopy: true)
//            documentPicker.delegate = self
//            documentPicker.shouldShowFileExtensions = true
//            documentPicker.modalPresentationStyle = .overFullScreen
//            self.target?.present(documentPicker, animated: true)
        }
    }

    public func update() {
        /*
         button?.setTitle((modeKey != nil && viewKey != nil ? app.config.getViewDefinition(modeKey: modeKey!, viewKey: viewKey!)?.name : nil) ?? "", for: .normal)
         contentView.backgroundColor = (app.currentMode ?? "") == modeKey ? UIColor.lightGray : .clear
         */
        txtName?.text = customVideoData!.name
        let app = USIM.application
//        pickerView?.selectRow(app.config.getViewIndex(modeKey: customVideoData!.videoRef.modeKey, viewKey: customVideoData!.videoRef.viewKey) ?? 0, inComponent: 0, animated: false)
        pickerPoint?.selectRow(app.config.getAccessPointIndex(pointKey: customVideoData!.videoRef.pointKey) ?? 0, inComponent: 0, animated: false)
    }
}


extension VideoCollectionCell : UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let mediaType = info[UIImagePickerController.InfoKey.mediaType]
                                       as! NSString
        if mediaType.isEqual(to: kUTTypeMovie as String) {
            let url = info[UIImagePickerController.InfoKey.mediaURL]
            if documentPickerTargetVideoRef != nil {
                Task {
                    await USIM.application.config.cacheCustomVideo(videoRef: customVideoData!.videoRef, url: url as! URL, customVideoData: customVideoData!, successCompletion: { value in
                        self.target?.showAlert(message: "Cache video uploaded successfully")
                    })
                }
            }
        }
        picker.dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

//extension VideoCollectionCell : UIDocumentPickerDelegate {
//    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
//        if let videoRef = documentPickerTargetVideoRef {
//            Task {
//                await USIM.application.config.cacheCustomVideo(videoRef: customVideoData!.videoRef, url: url, customVideoData: customVideoData!)
//            }
//        }
//        documentPickerTargetVideoRef = nil
//        controller.dismiss(animated: true)
//    }
//
//    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
//        documentPickerTargetVideoRef = nil
//    }
//}

extension VideoCollectionCell : UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let app = USIM.application
        if(pickerView == pickerPoint) {
            return app.getAccessPointCount()
        }
        return (defaultVideos?.count ?? 0) + 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let app = USIM.application
        if(pickerView == pickerPoint) {
            return app.getAccessPoint(row)?.name
        }
        if(row == 0) {
            return "Custom Video"
        }
        return defaultVideos![row - 1].0
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let app = USIM.application
        if(pickerView == pickerPoint) {
            customVideoData?.videoRef = VideoReference(modeKey: customVideoData!.videoRef.modeKey, viewKey: customVideoData!.videoRef.viewKey, pointKey: app.getAccessPoint(row)!.key, instanceKey: customVideoData!.videoRef.instanceKey)
            txtPoint?.text = app.getAccessPoint(row)?.name
            txtPoint?.resignFirstResponder()
        } else {
            txtVideo?.text = row == 0 ? "Custom Video" : defaultVideos![row - 1].0
            selectedVideo = row == 0 ? nil : defaultVideos![row - 1].1
            txtVideo?.resignFirstResponder()
        }
        app.config.trySaveLocalData()
    }
    
}

