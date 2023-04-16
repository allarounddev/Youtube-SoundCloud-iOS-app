
extension NSLayoutConstraint {
    
    @IBInspectable var preciseConstant: Int {
        get {
            return Int(constant * UIScreen.main.scale)
        }
        set {
            constant = CGFloat(newValue) / UIScreen.main.scale
        }
    }
}
