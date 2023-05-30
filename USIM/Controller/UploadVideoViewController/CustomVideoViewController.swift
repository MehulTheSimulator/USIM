//
//  CustomVideoViewController.swift
//  USIM
//
//  Created by mehul on 18/04/2023.
//

import UIKit

class CustomVideoViewController: UIViewController {

    // MARK: -  IBOutlets -
    @IBOutlet weak var videoCollectionView: UICollectionView!
    @IBOutlet weak var txtView: UITextField!
    @IBOutlet weak var lblmode: UILabel!
    
    // MARK: -  Properties -
    var defaultVideos: [(String, VideoRemoteData)]?
    var allCustomMedia: [CustomVideoData] = []
    var cache: NSCache<NSString, UIImage>!
    
    public var targetModeKey: Int?
    public var targetViewKey: Int?
    
    // MARK: - Lazy Properties -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cache = NSCache()
        if let videoCollectionView {
            setupCollectionView(videoCollectionView)
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let app = USIM.application
        self.txtView.text = app.config.getViewDefinition(modeid: targetModeKey!, viewid: targetViewKey!)?.viewname ?? ""
//        let isNotCustom = app.config.isModeNotCustom(modeKey: targetModeKey!)
//        txtView?.isUserInteractionEnabled = !isNotCustom
       // btnSetName.isEnabled = !isNotCustom
        self.lblmode.text = app.config.getMode(modeid: targetModeKey!)?.name
        defaultVideos = []
        for ref in app.config.getDefaultVideos() {
            let point = app.config.getAccessPoint(id: ref.point_id)?.name ?? ""
            let mode = app.config.getMode(modeid: ref.mode_id)?.name ?? ""
            let view = app.config.getViewDefinition(modeid: ref.mode_id, viewid: ref.view_id)?.viewname ?? ""
            let ind = app.config.getVideoInstanceIndex(ref)
            defaultVideos?.append(("\(point)/\(mode)/\(view) \(ind + 1)", ref))
        }
        reloadData()
    }
    
    // MARK: -  IBActions -
    @IBAction func onClickBack(_ sender: UIButton) {
        self.dismiss(animated: false)
    }
    
    @IBAction func onClickCustomViewTool(_ sender: UIButton) {
        let tip = Toolkit()
        tip.showTipView(sender: sender, text: "The app allows you to create custom views based on your specific angle requirements for the access points. You can add videos to these views based on the access points, and also choose from pre-existing default videos.")
    }
    
    @IBAction func onClickUploadMedia(_ sender: UIButton) {
        
        guard allCustomMedia.count < 8 else {
            self.showAlert(message: "You Can't add more video because all access points are taken.")
            return
        }
        
        requireConfirm(title: "Add Media", text: "Are you sure you want to add a new custom video?") {
            [self] in
            if($0) {
//                USIM.application.config.addCustomVideoData(videoRef: VideoReference(modeKey: targetModeKey!, viewKey: USIM.application.config.getDefaultView(modeKey: targetModeKey!) ?? "idk", pointKey: USIM.application.config.getAccessPoint(index: 0)?.key ?? "idk", instanceKey: UUID().uuidString), name: "New Video", cachedPathRelative: nil)
                //USIM.application.config.addCustomVideoData(videoRef: VideoReference(modeKey: targetModeKey!, viewKey: targetViewKey ?? "idk", pointKey: USIM.application.config.getAccessPoint(index: 0)?.key ?? "idk", instanceKey: UUID().uuidString), name: "New Video", cachedPathRelative: nil)
                USIM.application.config.addCustomVideoData(videoRef: VideoRemoteData(url: nil, mode_id: targetModeKey!, view_id: targetViewKey ?? 0, point_id: 0, id: USIM.application.config.getUUIDAsInt()), name: "New Video", cachedPathRelative: nil)
                    reloadData()
            }
        }
    }
    
    @IBAction func buttonSetNamePressed(_ sender: Any) {
        if let def = USIM.application.config.getViewDefinition(modeid: targetModeKey!, viewid: targetViewKey!) {
            def.viewname = txtView.text ?? "New View"
            USIM.application.config.trySaveLocalData()
        }
        self.showAlert(message: "View name saved")
    }
    
    // MARK: -  Methods -
    func setupCollectionView(_ name: UICollectionView) {
        name.delegate = self
        name.dataSource = self
        name.registerCollectionCell(name: String(describing: VideoCollectionCell.self))
    }
    
    func reloadData() {
        allCustomMedia = USIM.application.config.getAllCustomMedia(modeid: targetModeKey!, viewid: targetViewKey!)
        videoCollectionView?.reloadData()
    }
    
    func requireConfirm(title: String, text: String, _ callback: @escaping (Bool) -> ()) {
        if let controller = (self.storyboard?.instantiateViewController(withIdentifier: "ViewControllerConfirm") as? ViewControllerConfirm) {
            controller.confirmTitle = title
            controller.confirmText = text
            controller.callback = callback
            self.present(controller, animated: true, completion: nil)
        }
    }

}


// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension CustomVideoViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allCustomMedia.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index = indexPath.row
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: VideoCollectionCell.self), for: indexPath) as! VideoCollectionCell
        cell.target = self
        cell.index = index
        cell.customVideoData = allCustomMedia[index]
        cell.initCell(defaultVideos: defaultVideos ?? [])
        cell.update()
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width / 2.0
        return CGSize(width: width, height: 150)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
    }
}
