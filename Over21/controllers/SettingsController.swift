//
//  SettingsController.swift
//  Over21
//
//  Created by Chrishon Wyllie on 11/13/18.
//  Copyright © 2018 Socket Mobile. All rights reserved.
//

import UIKit

class SettingsController: UIViewController {
    
    // MARK: - Variables
    
    private let reuseIdentifier: String = "SettingsCell"
    
    
    
    
    
    // MARK: - UI Elements
    
    private lazy var tableView: UITableView = {
        let tbv = UITableView()
        tbv.translatesAutoresizingMaskIntoConstraints = false
        tbv.backgroundColor = .clear
        tbv.allowsSelection = false
        tbv.isScrollEnabled = false
        tbv.separatorStyle = .none
        tbv.delegate = self
        tbv.dataSource = self
        return tbv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUIElements()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Reload in the case that the disabled symbologies have changed
        tableView.reloadData()
    }
    
    private func setupUIElements() {
        view.backgroundColor = .white

        view.addSubview(tableView)
        
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        tableView.register(SettingsCell.self, forCellReuseIdentifier: reuseIdentifier)

    }

}


extension SettingsController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SettingsCell?
        
        cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? SettingsCell
        
        cell?.toggleButton.isEnabled = (Settings.shared.disabledSymbologies?.count ?? 0) > 0
        
        cell?.delegate = self
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160.0
    }
    
}

extension SettingsController: SettingsCellDelegate {
    func toggleButtonPressed() {
        print("restore all symbologies")
        Settings.shared.restoreDefaultSettings()
        tableView.reloadData()
        
    }
}
