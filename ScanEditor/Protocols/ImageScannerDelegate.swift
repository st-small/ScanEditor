//
//  ImageScannerDelegate.swift
//  ScanEditor
//
//  Created by Stanly Shiyanovskiy on 01.12.2020.
//

import UIKit

/// A set of methods that your delegate object must implement to interact with the image scanner interface.
public protocol ImageScannerDelegate: NSObjectProtocol {
    
    /// Tells the delegate that the user scanned a document.
    ///
    /// - Parameters:
    ///   - results: The results of the user scanning with the camera.
    /// - Discussion: Your delegate's implementation of this method should dismiss the image scanner controller.
    func imageScannerController(_ results: ImageScannerResults)
    
    /// Tells the delegate that the user cancelled the scan operation.
    ///
    /// - Parameters:
    /// - Discussion: Your delegate's implementation of this method should dismiss the image scanner controller.
    func imageScannerControllerDidCancel(_ originImage: UIImage)
    
    /// Tells the delegate that an error occured during the user's scanning experience.
    ///
    /// - Parameters:
    ///   - error: The error that occured.
    func imageScannerController(_ error: Error)
}
