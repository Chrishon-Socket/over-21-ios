//
//  ContainerViewController.swift
//  Over21
//
//  Created by Chrishon Wyllie on 11/13/18.
//  Copyright © 2018 Socket Mobile. All rights reserved.
//

import UIKit

class ContainerViewController: UIPageViewController {
    
    private var controllers: [UIViewController] = []
    private var mainController: ViewController!
    private var settingsController: SettingsController!
    private var startIndex = 0
    
    private var pageControl: UIPageControl = {
        let p = UIPageControl()
        p.translatesAutoresizingMaskIntoConstraints = false
        p.numberOfPages = 2
        p.hidesForSinglePage = true
        p.currentPageIndicatorTintColor = entryMAYBEAllowedColor
        p.pageIndicatorTintColor = UIColor.lightGray
        return p
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUIElements()
    }
    
    private func setupUIElements() {
        
        view.backgroundColor = .red
        view.addSubview(pageControl)
        
        pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        pageControl.isUserInteractionEnabled = true
        pageControl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleCurrentViewController)))
        
        mainController = ViewController()
        mainController.delegate = self
        settingsController = SettingsController()
        
        controllers = [mainController, settingsController]
        
        setViewControllers([controllers[startIndex]], direction: .forward, animated: false, completion: nil)
        
        delegate = self
        dataSource = self
    }

    @objc private func toggleCurrentViewController() {
        guard let currentController = viewControllers?.first else { return }
        let destinationController = currentController == mainController ? settingsController : mainController
        let direction: UIPageViewController.NavigationDirection = currentController == mainController ? .forward : .reverse
        
        pageControl.currentPage = destinationController == mainController ? 0 : 1
        
        setViewControllers([destinationController!], direction: direction, animated: true, completion: nil)
    }
    
}

extension ContainerViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        guard let controller = previousViewControllers.first else { return }
        pageControl.currentPage = controller == mainController ? 1 : 0
    }
    
}

extension ContainerViewController: UIPageViewControllerDataSource {
    
    private enum ControllerPage {
        case before
        case after
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return getViewController(from: viewController, page: .before)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return getViewController(from: viewController, page: .after)
    }
    
    private func getViewController(from controller: UIViewController, page: ControllerPage) -> UIViewController? {
        var currentIndex: Int = controllers.index(of: controller)!
        
        if page == .before {
            if currentIndex != 0 {
                currentIndex -= 1
                currentIndex = currentIndex % controllers.count
                return controllers[currentIndex]
            }
            return nil
        } else {
            if currentIndex != controllers.count - 1 {
                currentIndex += 1
                currentIndex = currentIndex % controllers.count
                return controllers[currentIndex]
            }
            return nil
        }
        
    }
}


extension ContainerViewController: ContainerDelegate {
    
    func didScan() {
        // If the user scans a barcode but has the settings controller open,
        // switch back to the main controller
        guard let currentController = viewControllers?.first else { return }
        if currentController == mainController {
            return
        }
        toggleCurrentViewController()
    }
    
}
