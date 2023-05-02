//
//  HomeViewController.swift
//  USIM
//
//  Created by Asher Azeem on 2/18/23.
//

import UIKit
import AVKit
import GSPlayer

class HomeViewController: UIViewController {

    // MARK: -  IBOutlets -
    @IBOutlet weak var playerView: DesignableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewViews: UICollectionView!
    @IBOutlet weak var modeButton: UIButton!
    @IBOutlet weak var viewsButton: UIButton!
    @IBOutlet weak var backScrollImage: UIImageView! {
        didSet {
            backScrollImage.isUserInteractionEnabled = true
            let gesture = UITapGestureRecognizer(target: self, action: #selector(backScrollTapped))
            backScrollImage.addGestureRecognizer(gesture)
        }
    }
    @IBOutlet weak var nextScrollImage: UIImageView! {
        didSet {
            nextScrollImage.isUserInteractionEnabled = true
            let gesture = UITapGestureRecognizer(target: self, action: #selector(nextScrollTapped))
            nextScrollImage.addGestureRecognizer(gesture)
        }
    }
    
    @IBOutlet weak var backViewsImage: UIImageView! {
        didSet {
            backViewsImage.isUserInteractionEnabled = true
            let gesture = UITapGestureRecognizer(target: self, action: #selector(backViewsScrollTapped))
            backViewsImage.addGestureRecognizer(gesture)
        }
    }
    @IBOutlet weak var nextViewsImage: UIImageView! {
        didSet {
            nextViewsImage.isUserInteractionEnabled = true
            let gesture = UITapGestureRecognizer(target: self, action: #selector(nextViewsScrollTapped))
            nextViewsImage.addGestureRecognizer(gesture)
        }
    }
    
    // MARK: -  Properties -
    var homeLayoutHelper = HomeLayoutHelper()
    var videoPlayer: AVPlayer?
    var videoPlayerController: AVPlayerViewController?
    var currentCode: String?
    var currentTimer: Timer?
    var lastInstanceKey: String?
    
    // MARK: -  Life Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        if let collectionView {
            setupCollectionView(collectionView)
            setupCollectionView(collectionViewViews)
        }
        visibilityAddButton(USIM.application.config.getTotalModeCount() > 0)
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.requestNotificationAuthorization()
        }
        scheduleNotifications()
    }
    
    func visibilityAddButton(_ value: Bool) {
        modeButton.isEnabled = value
        viewsButton.isEnabled = value
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupVideoPlay()
        self.collectionView.reloadData()
        self.collectionViewViews.reloadData()
        visibilityAddButton(USIM.application.config.getTotalModeCount() > 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        resetConfiguration()
        if(!USIM.application.isLicenseValid()) {
            // go to licnese view screen
            return
        }
    }
    
    func resetConfiguration() {
        USIM.inputManager.resetInput()
        USIM.inputManager.setCallback(self)
        USIM.RemoteLog("Set Input Handler to \(self)")
    }
    
    // MARK: -  IBActions -
    
    @IBAction func onClickAddMode(_ sender: UIButton) {
        requireConfirm(title: "Add Mode", text: "Are you sure you want to create a new mode?") {
            [self] in
            if($0) {
                let modeKey = "mode_custom_\(UUID().uuidString)"
                USIM.application.config.addCustomMode(modeKey: modeKey, name: "New Mode")
                let viewKey = "view_custom_\(UUID().uuidString)"
                USIM.application.config.addCustomView(modeKey: modeKey, viewKey: viewKey, name: "New View")
                USIM.application.setCurrentMode(modeKey: modeKey)
                editMode(modeKey: modeKey)
            }
        }
    }
    
    @IBAction func onClickAddView(_ sender: UIButton) {
        requireConfirm(title: "Add View", text: "Are you sure you want to create a new view?") {
            [self] in
            if($0) {
                let viewKey = "view_custom_\(UUID().uuidString)"
                USIM.application.config.addCustomView(modeKey: USIM.application.currentMode!, viewKey: viewKey, name: "New View")
                if let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "CustomVideoViewController") as? CustomVideoViewController {
                    secondViewController.targetModeKey = USIM.application.currentMode!
                    secondViewController.targetViewKey = viewKey
                    secondViewController.modalTransitionStyle = .crossDissolve
                    secondViewController.modalPresentationStyle = .fullScreen
                    self.present(secondViewController, animated: true, completion: nil)
                }
            }
        }
    }
    
    // MARK: -  Methods -
    func setupVideoPlay() {
        let videoPlayer = AVPlayer()
        let videoPlayerController = AVPlayerViewController()
        videoPlayerController.player = videoPlayer
        videoPlayerController.showsPlaybackControls = false
                videoPlayerController.view.translatesAutoresizingMaskIntoConstraints = false
                addChild(videoPlayerController)
        playerView.addSubview(videoPlayerController.view)
        NSLayoutConstraint.activate([
            videoPlayerController.view.leadingAnchor.constraint(equalTo: playerView.leadingAnchor, constant: 0),
            videoPlayerController.view.trailingAnchor.constraint(equalTo: playerView.trailingAnchor, constant: 0),
            videoPlayerController.view.topAnchor.constraint(equalTo: playerView.topAnchor, constant: 0),
            videoPlayerController.view.bottomAnchor.constraint(equalTo: playerView.bottomAnchor, constant: 0),
        ])
        videoPlayerController.didMove(toParent: self)
        playerView.sendSubviewToBack(videoPlayerController.view)
        self.videoPlayer = videoPlayer
        self.videoPlayerController = videoPlayerController
    }
    
    
    func lastInputTimer() {
        currentTimer?.invalidate()
        currentTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(HomeViewController.onTimeOut), userInfo: nil, repeats: false)
    }
    
    @objc func onTimeOut() {
        stopVideo()
    }

    var urlToPlay: URL?
    
    func playVideo(url: URL) {
        if(!USIM.application.isLicenseValid()) {
            return;
        }
        do {
            try USIM.RemoteLog("\(FileManager.default.attributesOfItem(atPath: url.path)[.size] ?? 0)")
        } catch let error {
            USIM.RemoteLog("Error getting file size: \(error)")
        }
        self.videoPlayer?.replaceCurrentItem(with: nil)
        self.videoPlayer?.play()
        
        USIM.RemoteLog("Playing URL \(url)")
        self.videoPlayer?.replaceCurrentItem(with: AVPlayerItem(url: Bundle.main.url(forResource: "preVideo", withExtension: "mp4")!))
        NotificationCenter.default.addObserver(self, selector: #selector(logoVideoEnded), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.videoPlayer?.currentItem)
        urlToPlay = url
        videoPlayer?.play()
        if let vpc = videoPlayerController {
            playerView.bringSubviewToFront(vpc.view)
        }
    }
    
    func stopVideo() {
        self.videoPlayer?.replaceCurrentItem(with: nil)
        self.videoPlayer?.play()
        videoEnded()
    }
    
    @objc func logoVideoEnded() {
        if let url = urlToPlay {
            USIM.RemoteLog("Playing URL \(url)")
            videoPlayer?.replaceCurrentItem(with: AVPlayerItem(url: url))
            NotificationCenter.default.addObserver(self, selector: #selector(videoEnded), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.videoPlayer?.currentItem)
            self.videoPlayer?.play()
        }
        else if let vpc = videoPlayerController {
            playerView.sendSubviewToBack(vpc.view)
        }
    }
    
    @objc func videoEnded() {
        currentCode = nil
        if let vpc = videoPlayerController {
            playerView.sendSubviewToBack(vpc.view)
        }
    }

    // MARK: -  Methods -
    func setupCollectionView(_ name: UICollectionView) {
        if name == self.collectionView {
            name.registerCollectionCell(name: String(describing: TagModeCollectionCell.self))
        } else {
            name.registerCollectionCell(name: String(describing: TagViewsCollectionCell.self))
        }
        guard let section = homeLayoutHelper.tagSection else {
            return
        }
        name.collectionViewLayout = UICollectionViewCompositionalLayout(section: section)
    }
        
    func updateMode() {
        if let vpc = videoPlayerController {
            playerView.sendSubviewToBack(vpc.view)
        }
        self.videoPlayer?.replaceCurrentItem(with: nil)
        self.videoPlayer?.play()
        for i in 0...collectionView.numberOfSections-1 {
            for j in 0...collectionView.numberOfItems(inSection: i) {
                if let cell = collectionView.cellForItem(at: IndexPath(row: j, section: i)) {
                    if let modeCell = cell as? TagModeCollectionCell {
                        modeCell.update()
                    }
                }
            }
        }
        collectionViewViews?.reloadData()
    }
    
    func updateView() {
        if let vpc = videoPlayerController {
            playerView.sendSubviewToBack(vpc.view)
        }
        self.videoPlayer?.replaceCurrentItem(with: nil)
        self.videoPlayer?.play()
        for i in 0...collectionViewViews.numberOfSections-1 {
            for j in 0...collectionViewViews.numberOfItems(inSection: i){
                if let cell = collectionViewViews.cellForItem(at: IndexPath(row: j, section: i)) {
                    if let viewCell = cell as? TagViewsCollectionCell {
                        viewCell.update()
                    }
                }
            }
        }
    }
    
    
    // MARK: - Edit
    
    func editMode(modeKey: String) {
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ModeEditViewController.self)) as? ModeEditViewController {
            controller.targetModeKey = modeKey
            controller.modalTransitionStyle = .crossDissolve
            controller.modalPresentationStyle = .fullScreen
            present(controller, animated: true, completion: nil)
        }
    }
    
    func editView(modeKey: String, viewKey: String) {
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "CustomVideoViewController") as? CustomVideoViewController {
            controller.targetModeKey = modeKey
            controller.targetViewKey = viewKey
            controller.modalTransitionStyle = .crossDissolve
            controller.modalPresentationStyle = .fullScreen
            present(controller, animated: true, completion: nil)
        }
    }
    
    // MARK: - Delete (Mode & Views)
    func deleteMode(modeKey: String) {
        requireConfirm(title: "Delete Mode", text: "Are you sure you want to delete this mode?") {
            [self] in
            if($0) {
                USIM.application.config.deleteCustomMode(modeKey: modeKey)
                USIM.application.setCurrentMode(modeKey: USIM.application.config.getDefaultMode()!)
                collectionView.reloadData()
                collectionViewViews.reloadData()
            }
        }
    }
    
    func deleteView(modeKey: String, viewKey: String) {
        requireConfirm(title: "Delete View", text: "Are you sure you want to delete this view?") {
            [self] in
            if($0) {
                USIM.application.config.deleteCustomView(modeKey: modeKey, viewKey: viewKey)
                USIM.application.setCurrentView(modeKey: modeKey, viewKey: USIM.application.config.getDefaultView(modeKey: modeKey) ?? "")
                collectionViewViews.reloadData()
            }
        }
    }
    
    func requireConfirm(title: String, text: String, _ callback: @escaping (Bool) -> ()) {
        if let controller = (self.storyboard?.instantiateViewController(withIdentifier: "ViewControllerConfirm") as? ViewControllerConfirm) {
            controller.confirmTitle = title
            controller.confirmText = text
            controller.callback = callback
            present(controller, animated: true, completion: nil)
        }
    }
    
    @objc func backScrollTapped() {
        // perform action for scroll back
        print("Left")
        setLeftScroll(collectionView)
    }
    
    @objc func nextScrollTapped() {
        // perform action to scroll right
        print("Right")
        setScrollOnCollection(collectionView)
    }
    
    @objc func backViewsScrollTapped() {
        // perform action for scroll back
        print("Left")
        setLeftScroll(collectionViewViews)
    }
    
    @objc func nextViewsScrollTapped() {
        // perform action to scroll right
        print("Right")
        setScrollOnCollection(collectionViewViews)
    }

    func setLeftScroll(_ collection: UICollectionView) {
        let indexPath = IndexPath(item: 0, section: 0)
        collection.scrollToItem(at: indexPath, at: .left, animated: true)
    }
    
    func setScrollOnCollection(_ collection: UICollectionView) {
        let lastItemIndex = collection.numberOfItems(inSection: 0) - 1
        let indexPath = IndexPath(item: lastItemIndex, section: 0)
        collection.scrollToItem(at: indexPath, at: .right, animated: true)
    }
}
