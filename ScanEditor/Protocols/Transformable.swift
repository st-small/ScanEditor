import UIKit

/// Objects that conform to the Transformable protocol are capable of being transformed with a `CGAffineTransform`.
protocol Transformable {
    
    /// Applies the given `CGAffineTransform`.
    ///
    /// - Parameters:
    ///   - t: The transform to apply
    /// - Returns: The same object transformed by the passed in `CGAffineTransform`.
    func applying(_ transform: CGAffineTransform) -> Self

}

extension Transformable {
    
    /// Applies multiple given transforms in the given order.
    ///
    /// - Parameters:
    ///   - transforms: The transforms to apply.
    /// - Returns: The same object transformed by the passed in `CGAffineTransform`s.
    func applyTransforms(_ transforms: [CGAffineTransform]) -> Self {
        
        var transformableObject = self
        
        transforms.forEach { (transform) in
            transformableObject = transformableObject.applying(transform)
        }
        
        return transformableObject
    }
    
}
