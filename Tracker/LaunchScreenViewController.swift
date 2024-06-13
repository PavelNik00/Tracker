//
//  LaunchScreenViewController.swift
//  Tracker
//
//  Created by Pavel Nikipelov on 03.04.2024.
//

import UIKit

class LaunchScreenViewController: UIViewController {
    
    let mainView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMainView()
    }
    
    private func setupMainView() {
        mainView.backgroundColor = UIColor.blue
        
        let imageView = UIImageView(image: UIImage(named: "AppLogo"))
        imageView.contentMode = .scaleAspectFit
        
        mainView.addSubview(imageView)
        view = mainView
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 91).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 94).isActive = true

        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}
