//
//  ViewController.swift
//  ScanEditor
//
//  Created by Stanly Shiyanovskiy on 30.11.2020.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        addViewController()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showEditor))
    }
    
    func addViewController() {
        guard let image = UIImage(named: "sample") else { return }
        let controller  = ImageScannerController(image: image, delegate: self)
        controller.view.frame = CGRect(x: 20, y: 20, width: UIScreen.main.bounds.width - 40, height: 500)
        self.view.addSubview(controller.view)
        self.addChild(controller)
        controller.didMove(toParent: self)
    }


    
    // MARK: - Actions
    @objc
    private func showEditor() {
        guard let image = UIImage(named: "sample") else { return }
        let editor = ImageScannerController(image: image, delegate: self)
        navigationController?.present(editor, animated: true)
    }
}

extension ViewController: ImageScannerControllerDelegate {
    func imageScannerController(_ scanner: ImageScannerController, didFinishScanningWithResults results: ImageScannerResults) {
        
    }
    
    func imageScannerControllerDidCancel(_ scanner: ImageScannerController) {
        
    }
    
    func imageScannerController(_ scanner: ImageScannerController, didFailWithError error: Error) {
        
    }
}
