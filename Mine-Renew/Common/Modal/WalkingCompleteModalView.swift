//
//  WalkingCompleteModalView.swift
//  Mine-Renew
//
//  Created by 고병학 on 2022/09/11.
//
import Foundation
import UIKit

protocol WalkingCompleteModalViewDelegate {
    func didTapCancel()
    func didTapSave()
}

@IBDesignable
final class WalkingCompleteModalView: UIView {
    
    @IBOutlet weak var modalView: UIView!
    @IBInspectable
    @IBOutlet weak var cancleButton: UIButton!
    @IBInspectable
    @IBOutlet weak var saveButton: UIButton!
    @IBInspectable
    @IBOutlet weak var imageView: UIImageView!
    
    private let nibName = "WalkingCompleteModalView"
    
    var delegate: WalkingCompleteModalViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }
    
    func setup() {
        guard let view = loadViewFromNib() else { return }
        view.frame = self.bounds
        self.addSubview(view)
        modalView.layer.cornerRadius = 17
        modalView.clipsToBounds = true
    }
    
    func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }

    @IBAction func didTapCancle(_ sender: Any) {
        delegate?.didTapCancel()
    }

    @IBAction func didTapSave(_ sender: Any) {
        delegate?.didTapSave()
    }
}
