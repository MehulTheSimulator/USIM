//
//  SideMenuViewController.swift
//  USIM
//
//  Created by Asher Azeem on 2/18/23.
//

import UIKit

struct SideMenuTitle {
    static var home = "Home"
    static var softwareUpdate = "Update Configuration"
    static var accessPoint = "Access Point Setting"
    static var licenseUpdate = "License Update"
    static var termsCondition = "Terms & Conditions"
    static var help = "Help"
}

class SideMenuViewController: SSSideMenuContainerViewController {
    
    // MARK: -  Propertis -
    
    lazy var menuTable: SSMenuTableView = {
        let menuTable = SSMenuTableView()
        menuTable.backgroundColor = .white
        menuTable.separatorStyle = .none
        menuTable.rowHeight = 50
        menuTable.showsHorizontalScrollIndicator = false
        menuTable.showsVerticalScrollIndicator = false
        return menuTable
    }()
    
    lazy var menuCellConfig: SSMenuCellConfig = {
        let menuCellConfig = SSMenuCellConfig()
        menuCellConfig.cellStyle = .defaultStyle // .customStyle
        menuCellConfig.leftIconPadding = 20
        menuCellConfig.imageToTitlePadding = 8
        menuCellConfig.imageHeight = 22
        menuCellConfig.imageWidth = 22
        menuCellConfig.selectedColor = UIColor(named: "buttonColor") ?? UIColor.red
        menuCellConfig.nonSelectedColor = .black
        menuCellConfig.images = setImages("first",
                                          "first",
                                          "second",
                                          "third",
                                          "logout",
                                          "logout")
        menuCellConfig.titles = [SideMenuTitle.home,
                                 SideMenuTitle.softwareUpdate,
                                 SideMenuTitle.accessPoint,
                                 SideMenuTitle.licenseUpdate,
                                 SideMenuTitle.termsCondition,
                                 SideMenuTitle.help]
        menuCellConfig.numberOfOptions = menuCellConfig.titles.count
        return menuCellConfig
    }()
    
    
    lazy var sideMenuConfig: SSSideMenuConfig = {
        let sideMenuConfig = SSSideMenuConfig()
        // sideMenuConfig.animationType = .slideOut // .slideIn, .compress(0.8, 20)
        // sideMenuConfig.sideMenuPlacement = .left // .right
        sideMenuConfig.animationType = .slideIn
        sideMenuConfig.menuWidth = UIScreen.main.bounds.width * 0.2
        sideMenuConfig.viewControllers = [homeController!,
                                          updateConfigController!,
                                          acessPointController!,
                                          licenseController!,
                                          termController!,
                                          helpController!]
        return sideMenuConfig
    }()
    
    var urlString: String = ""
    var homeController: UIViewController? {
        configureController(HomeViewController.self)
    }
    var acessPointController: UIViewController? {
        configureController(AccessPointViewController.self)
    }
    var termController: UIViewController? {
        configureController(TermViewController.self)
    }
    var helpController: UIViewController? {
        configureController(HelpViewController.self)
    }
    var licenseController: UIViewController? {
        configureController(LicenseUpdateViewController.self)
    }
    var updateConfigController: UIViewController? {
        configureController(UpdateConfiguViewController.self)
    }
    
    // MARK: -  Life Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSideMenu()
    }
    
    // MARK: -  Methods -
    private func configureSideMenu() {
        menuTable.config = menuCellConfig
        sideMenuConfig.menuTable = menuTable
        ssMenuConfig = sideMenuConfig
        sideMenuDelegate = self
    }
    
    // set side Menu icons
    func setImages(_ names: String...) -> [UIImage] {
        var images: [UIImage] = []
        names.forEach { imgName in
            let image = UIImage(named: imgName) ?? UIImage()
            images.append(image)
        }
        return images
    }
}

// MARK: - SSSideMenu Delegate
extension SideMenuViewController: SSSideMenuDelegate {
    
    func shouldOpenViewController(forMenuOption menuOption: Int) -> Bool {
        // Perform action for custom options (i.e logout)
        guard menuCellConfig.titles.count > 0 else {
            return false
        }
        var isShow: Bool = false
        switch menuCellConfig.titles[menuOption] {
        case SideMenuTitle.home:
            isShow = true
        case SideMenuTitle.softwareUpdate :
            isShow = true
        case SideMenuTitle.accessPoint :
            isShow = true
        case SideMenuTitle.licenseUpdate :
            isShow = true
        case SideMenuTitle.termsCondition :
            let controller = sideMenuConfig.viewControllers.filter({$0 is TermViewController}).first as? TermViewController
            controller?.urlString = "https://www.thesimulatorcompany.com/termsandconditions-u-simapp"
            controller?.screenTitle = SideMenuTitle.termsCondition
            isShow = true
        case SideMenuTitle.help :
            let controller = sideMenuConfig.viewControllers.filter({$0 is HelpViewController}).first as? HelpViewController
            controller?.urlString = "https://www.thesimulatorcompany.com/help-u-simapp"
            controller?.screenTitle = SideMenuTitle.help
            isShow = true
        default:
            break
        }
        return isShow
    }
    
    func controllers() ->  UIViewController? {
        sideMenuConfig.viewControllers.filter({$0 is WebViewController}).first
    }
}
