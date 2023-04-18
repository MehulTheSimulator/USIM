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
    
    // MARK: -  Properties -
    var defaultVideos: [(String, VideoReference)]?
    var allCustomMedia: [CustomVideoData] = []
    
    public var targetModeKey: String?
    public var targetViewKey: String?
    
    // MARK: - Lazy Properties -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let videoCollectionView {
            setupCollectionView(videoCollectionView)
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let app = USIM.application
        self.txtView.text = app.config.getViewDefinition(modeKey: targetModeKey!, viewKey: targetViewKey!)?.name ?? ""
        let isNotCustom = app.config.isModeNotCustom(modeKey: targetModeKey!)
        txtView?.isUserInteractionEnabled = !isNotCustom
       // btnSetName.isEnabled = !isNotCustom
        defaultVideos = []
        for ref in app.config.getDefaultVideos() {
            let point = app.config.getAccessPoint(key: ref.pointKey)?.name ?? ""
            let mode = app.config.getMode(modeKey: ref.modeKey)?.name ?? ""
            let view = app.config.getViewDefinition(modeKey: ref.modeKey, viewKey: ref.viewKey)?.name ?? ""
            let ind = app.config.getVideoInstanceIndex(ref)
            defaultVideos?.append(("\(point)/\(mode)/\(view) \(ind + 1)", ref))
        }
        reloadData()
    }
    
    // MARK: -  IBActions -
    @IBAction func onClickBack(_ sender: UIButton) {
        self.dismiss(animated: false)
    }
    
    @IBAction func onClickUploadMedia(_ sender: UIButton) {
        requireConfirm(title: "Add Media", text: "Are you sure you want to add a new custom video?") {
            [self] in
            if($0) {
                USIM.application.config.addCustomVideoData(videoRef: VideoReference(modeKey: targetModeKey!, viewKey: USIM.application.config.getDefaultView(modeKey: targetModeKey!) ?? "idk", pointKey: USIM.application.config.getAccessPoint(index: 0)?.key ?? "idk", instanceKey: UUID().uuidString), name: "New Video", cachedPathRelative: nil)
                    reloadData()
            }
        }
    }
    
    @IBAction func buttonSetNamePressed(_ sender: Any) {
        if let def = USIM.application.config.getViewDefinition(modeKey: targetModeKey!, viewKey: targetViewKey!) {
            def.name = txtView.text ?? "New View"
            USIM.application.config.trySaveLocalData()
        }
    }
    
    // MARK: -  Methods -
    func setupCollectionView(_ name: UICollectionView) {
        name.delegate = self
        name.dataSource = self
        name.registerCollectionCell(name: String(describing: VideoCollectionCell.self))
    }
    
    func reloadData() {
        allCustomMedia = USIM.application.config.getAllCustomMedia(modeKey: targetModeKey!, viewKey: targetViewKey!)
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
        //cell.target = self
        cell.index = index
        cell.customVideoData = allCustomMedia[index]
        cell.initCell(defaultVideos: defaultVideos ?? [])
        cell.update()
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width / 2.0 - 15
        return CGSize(width: width, height: 150)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
    }
}
