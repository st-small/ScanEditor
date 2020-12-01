//
//  ViewController.swift
//  ScanEditor
//
//  Created by Stanly Shiyanovskiy on 30.11.2020.
//

import UIKit

class ViewController: UIViewController {
    
    private var editViewController: EditScanViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let image = UIImage(named: "sample") else { return }
        addScannerView(image: image)
        
        let cropButton = UIButton(type: .system)
        cropButton.setTitle("Crop", for: .normal)
        cropButton.addTarget(self, action: #selector(cropScanner), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: cropButton)
        
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelScanner), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
    }

    private func addScannerView(image: UIImage, initial: UIImage? = nil) {
        removeUnusedScannerViews()
        let configurator = QuadConfigurator(quadFillColor: UIColor.clear)
        editViewController = EditScanViewController(image: image, rotateImage: false, initialImage: initial, configurator: configurator, delegate: self)
        view.addSubview(editViewController.view)
        editViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            editViewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            editViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            editViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            editViewController.view.heightAnchor.constraint(equalToConstant: 500)
        ])
        addChild(editViewController)
        editViewController.didMove(toParent: self)
    }
    
    private func removeUnusedScannerViews() {
        for subview in view.subviews {
            subview.removeFromSuperview()
        }
    }

    
    // MARK: - Actions
    @objc
    private func cropScanner() {
        editViewController?.applyCrop()
    }
    
    @objc
    private func cancelScanner() {
        editViewController?.cancelScanner()
    }
}

extension ViewController: ImageScannerDelegate {
    func imageScannerController(_ results: ImageScannerResults) {
        addScannerView(image: results.croppedScan.image, initial: results.originalScan.image)
    }
    
    func imageScannerControllerDidCancel(_ originImage: UIImage) {
        addScannerView(image: originImage, initial: originImage)
    }
    
    func imageScannerController(_ error: Error) {
        #warning("Add messages alert support!")
    }
}
