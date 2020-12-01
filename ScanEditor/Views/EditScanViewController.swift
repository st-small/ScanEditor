import UIKit
import AVFoundation

public struct QuadConfigurator {
    public var quadStrokeColor: UIColor
    public var quadStrokeWidth: CGFloat
    public var quadFillColor: UIColor
    
    public init(quadStrokeColor: UIColor = .white,
         quadStrokeWidth: CGFloat = 1,
         quadFillColor: UIColor = .white) {
        self.quadStrokeColor = quadStrokeColor
        self.quadStrokeWidth = quadStrokeWidth
        self.quadFillColor = quadFillColor
    }
}

/// The `EditScanViewController` offers an interface for the user to edit the detected quadrilateral.
final class EditScanViewController: UIViewController {
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.isOpaque = true
        imageView.image = image
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var quadView: QuadrilateralView = {
        let quadView = QuadrilateralView()
        quadView.editable = true
        quadView.strokeColor = quadConfigurator.quadStrokeColor.cgColor
        quadView.strokeWidth = quadConfigurator.quadStrokeWidth
        quadView.fillColor = quadConfigurator.quadFillColor.cgColor
        quadView.translatesAutoresizingMaskIntoConstraints = false
        return quadView
    }()
    
    private var quadConfigurator: QuadConfigurator
    
    /// The image the quadrilateral was detected on.
    private let image: UIImage
    
    /// The initial image to reset all operations and return original one.
    private let initialImage: UIImage?
    
    /// The detected quadrilateral that can be edited by the user. Uses the image's coordinates.
    private var quad: Quadrilateral
    
    private var zoomGestureController: ZoomGestureController!
    
    private var quadViewWidthConstraint = NSLayoutConstraint()
    private var quadViewHeightConstraint = NSLayoutConstraint()
    
    /// The object that acts as the delegate of the `ImageScannerController`.
    public weak var imageScannerDelegate: ImageScannerDelegate?
    
    // MARK: - Life Cycle
    
    init(image: UIImage, rotateImage: Bool = true, initialImage: UIImage? = nil, configurator: QuadConfigurator = QuadConfigurator(), delegate: ImageScannerDelegate? = nil) {
        self.image = rotateImage ? image.applyingPortraitOrientation() : image
        self.initialImage = initialImage
        self.quadConfigurator = configurator
        self.imageScannerDelegate = delegate
        self.quad = EditScanViewController.defaultQuad(forImage: image)
        
        super.init(nibName: nil, bundle: nil)
        
        detect(image: image) { [weak self] detectedQuad in
            guard let self = self else { return }
            self.quad = detectedQuad ?? EditScanViewController.defaultQuad(forImage: image)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
        
        zoomGestureController = ZoomGestureController(image: image, quadView: quadView)
        
        let touchDown = UILongPressGestureRecognizer(target: zoomGestureController, action: #selector(zoomGestureController.handle(pan:)))
        touchDown.minimumPressDuration = 0
        view.addGestureRecognizer(touchDown)
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        adjustQuadViewConstraints()
        displayQuad()
    }
    
    // MARK: - Setups
    
    private func detect(image: UIImage, completion: @escaping (Quadrilateral?) -> Void) {
        // Whether or not we detect a quad, present the edit view controller after attempting to detect a quad.
        // *** Vision *requires* a completion block to detect rectangles, but it's instant.
        // *** When using Vision, we'll present the normal edit view controller first, then present the updated edit view controller later.
        
        guard let ciImage = CIImage(image: image) else { return }
        let orientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue)) ?? .up
        let orientedImage = ciImage.oriented(forExifOrientation: Int32(orientation.rawValue))
        
        VisionRectangleDetector.rectangle(forImage: ciImage, orientation: orientation) { (quad) in
            let detectedQuad = quad?.toCartesian(withHeight: orientedImage.extent.height)
            completion(detectedQuad)
        }
    }
    
    private func setupViews() {
        view.addSubview(imageView)
        view.addSubview(quadView)
    }
    
    private func setupConstraints() {
        let imageViewConstraints = [
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: imageView.leadingAnchor)
        ]
        
        quadViewWidthConstraint = quadView.widthAnchor.constraint(equalToConstant: 0.0)
        quadViewHeightConstraint = quadView.heightAnchor.constraint(equalToConstant: 0.0)
        
        let quadViewConstraints = [
            quadView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            quadView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            quadViewWidthConstraint,
            quadViewHeightConstraint
        ]
        
        NSLayoutConstraint.activate(quadViewConstraints + imageViewConstraints)
    }
    
    // MARK: - Actions
    public func cancelScanner() {
        guard let image = initialImage else {
            let error = ImageScannerControllerError.noInitialImage
            imageScannerDelegate?.imageScannerController(error)
            return
        }
        imageScannerDelegate?.imageScannerControllerDidCancel(image)
    }
    
    public func applyCrop() {
        guard let quad = quadView.quad,
              let ciImage = CIImage(image: image) else {
            let error = ImageScannerControllerError.ciImageCreation
            imageScannerDelegate?.imageScannerController(error)
            return
        }
        let cgOrientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue)) ?? .up
        let orientedImage = ciImage.oriented(forExifOrientation: Int32(cgOrientation.rawValue))
        let scaledQuad = quad.scale(quadView.bounds.size, image.size)
        self.quad = scaledQuad
        
        // Cropped Image
        var cartesianScaledQuad = scaledQuad.toCartesian(withHeight: image.size.height)
        cartesianScaledQuad.reorganize()
        
        let filteredImage = orientedImage.applyingFilter("CIPerspectiveCorrection", parameters: [
            "inputTopLeft": CIVector(cgPoint: cartesianScaledQuad.bottomLeft),
            "inputTopRight": CIVector(cgPoint: cartesianScaledQuad.bottomRight),
            "inputBottomLeft": CIVector(cgPoint: cartesianScaledQuad.topLeft),
            "inputBottomRight": CIVector(cgPoint: cartesianScaledQuad.topRight)
        ])
        
        let croppedImage = UIImage.from(ciImage: filteredImage)
        // Enhanced Image
        let enhancedImage = filteredImage.applyingAdaptiveThreshold()?.withFixedOrientation()
        let enhancedScan = enhancedImage.flatMap { ImageScannerScan(image: $0) }
        
        let results = ImageScannerResults(detectedRectangle: scaledQuad, originalScan: ImageScannerScan(image: image), croppedScan: ImageScannerScan(image: croppedImage), enhancedScan: enhancedScan)
        
        imageScannerDelegate?.imageScannerController(results)
    }
    
    private func displayQuad() {
        let imageSize = image.size
        let imageFrame = CGRect(origin: quadView.frame.origin, size: CGSize(width: quadViewWidthConstraint.constant, height: quadViewHeightConstraint.constant))
        
        let scaleTransform = CGAffineTransform.scaleTransform(forSize: imageSize, aspectFillInSize: imageFrame.size)
        let transforms = [scaleTransform]
        let transformedQuad = quad.applyTransforms(transforms)
        
        quadView.drawQuadrilateral(quad: transformedQuad, animated: false)
    }
    
    /// The quadView should be lined up on top of the actual image displayed by the imageView.
    /// Since there is no way to know the size of that image before run time, we adjust the constraints to make sure that the quadView is on top of the displayed image.
    private func adjustQuadViewConstraints() {
        let frame = AVMakeRect(aspectRatio: image.size, insideRect: imageView.bounds)
        quadViewWidthConstraint.constant = frame.size.width
        quadViewHeightConstraint.constant = frame.size.height
    }
    
    /// Generates a `Quadrilateral` object that's centered and 90% of the size of the passed in image.
    private static func defaultQuad(forImage image: UIImage) -> Quadrilateral {
        let topLeft = CGPoint(x: image.size.width * 0.05, y: image.size.height * 0.05)
        let topRight = CGPoint(x: image.size.width * 0.95, y: image.size.height * 0.05)
        let bottomRight = CGPoint(x: image.size.width * 0.95, y: image.size.height * 0.95)
        let bottomLeft = CGPoint(x: image.size.width * 0.05, y: image.size.height * 0.95)
        
        let quad = Quadrilateral(topLeft: topLeft, topRight: topRight, bottomRight: bottomRight, bottomLeft: bottomLeft)
        
        return quad
    }
    
}
