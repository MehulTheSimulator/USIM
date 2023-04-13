//
//  UplaodVideoViewController.swift
//  USIM
//
//  Created by Asher Azeem on 2/18/23.
//

import UIKit
import MobileCoreServices


struct UploadVideoModel {
    var fileName: String
    var view: String
    var position: String
}

class UploadVideoViewController: UIViewController {
    
    // MARK: -  IBOutlets -
    @IBOutlet weak var collectionView: UICollectionView?
    @IBOutlet weak var modeTextField: UITextField?
    @IBOutlet var btnSetName: UIButton!
    
    // MARK: -  Properties -
    var targetModeKey: String?
    var defaultVideos: [(String, VideoReference)]?
    var allCustomMedia: [CustomVideoData] = []
    
    // MARK: - Lazy Properties -
    
    // MARK: -  Life Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        if let collectionView {
            setupCollectionView(collectionView)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let app = USIM.application
        modeTextField?.text = app.getMode(modeKey: targetModeKey!)?.name
        let isNotCustom = app.config.isModeNotCustom(modeKey: targetModeKey!)
        modeTextField?.isUserInteractionEnabled = !isNotCustom
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
    @IBAction func onClickRemoveBtn(_ sender: UIButton) {
        //        if let indexPath = collectionView?.indexPathForItem(at: sender.anchorPoint) {
        //            print(indexPath.row)
        //        }
    }
    
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
        if let def = USIM.application.getMode(modeKey: targetModeKey!) {
            def.name = modeTextField?.text ?? "New Mode"
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
        allCustomMedia = USIM.application.config.getAllCustomMedia(modeKey: targetModeKey!)
        collectionView?.reloadData()
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
