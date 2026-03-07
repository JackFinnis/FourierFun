//
//  UIFont.swift
//  Fourier
//
//  Created by Jack Finnis on 07/03/2026.
//

import UIKit

extension UIFont {
    static let headline: UIFont = {
        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .headline)
            .addingAttributes([.featureSettings : [[UIFontDescriptor.FeatureKey.type : kNumberSpacingType, .selector : kMonospacedNumbersSelector]]])
        return UIFont(descriptor: descriptor, size: descriptor.pointSize)
    }()
}
