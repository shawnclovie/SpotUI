//
//  UIImagePickerController+.swift
//  SpotUI
//
//  Created by Shawn Clovie on 19/04/2017.
//  Copyright © 2017 Shawn Clovie. All rights reserved.
//

import AVFoundation
import MobileCoreServices
import UIKit
import Spot

public enum MediaPickType {
	case image, movie
	
	var utType: CFString {
		switch self {
		case .image:	return kUTTypeImage
		case .movie:	return kUTTypeMovie
		}
	}
}

public enum MediaPickResult {
	case noFoundMedia
	case image(UIImage)
	case video(AVURLAsset)
}

extension Dictionary where Key == UIImagePickerController.InfoKey {
	public func spot_parseResult() -> MediaPickResult {
		if let mediaType = self[.mediaType] as? String {
			if mediaType == kUTTypeMovie as String,
				let url = self[.mediaURL] as? URL {
				let asset = AVURLAsset(url: url)
				return .video(asset)
			}
			if mediaType == kUTTypeImage as String,
				var image = self[.editedImage] as? UIImage
					?? self[.originalImage] as? UIImage {
				// ReferenceURL cannot access directly since has prefix assets-library://, should save image to tmp.
				if image.imageOrientation != .up {
					UIGraphicsBeginImageContext(image.size)
					image.draw(in: CGRect(origin: .zero, size: image.size))
					if let newImage = UIGraphicsGetImageFromCurrentImageContext() {
						image = newImage
					}
					UIGraphicsEndImageContext()
				}
				return .image(image)
			}
		}
		return .noFoundMedia
	}
}

extension UIImagePickerController {
	public static func spot(source: UIImagePickerController.SourceType, mediaTypes: [MediaPickType]) -> UIImagePickerController? {
		guard UIImagePickerController.isSourceTypeAvailable(source) else {
			return nil
		}
		let it = UIImagePickerController()
		it.sourceType = source
		it.mediaTypes = mediaTypes.map{$0.utType as String}
		return it
	}
}
