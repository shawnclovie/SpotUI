//
//  ImageView+ImageScaledSize.swift
//  SpotUI
//
//  Created by Shawn Clovie on 7/5/16.
//  Copyright © 2016 Shawn Clovie. All rights reserved.
//

#if canImport(UIKit)
import UIKit
import Spot

extension Suffix where Base: UIImageView {
	
	/// Get scale raito on width and height.
	public var imageScales: CGSize {
		base.image?.spot.scaledSize(toFit: base.bounds.size, by: base.contentMode)
			?? .zero
	}
	
	/// Get image scaled size.
	public var imageScaledSize: CGSize {
		let imgSize = base.image?.size ?? .zero
		let scales = imageScales
		return CGSize(width: scales.width * imgSize.width, height: scales.height * imgSize.height)
	}
}
#endif
