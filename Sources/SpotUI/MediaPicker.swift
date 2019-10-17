//
//  MediaPicker.swift
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

public final class MediaPicker: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	public enum PickedItem {
		case image(UIImage)
		case video(AVURLAsset)
	}
	
	public var onPicked: ((MediaPicker, PickedItem?, [UIImagePickerController.InfoKey: Any])->Void)?
	public var onCancelled: ((MediaPicker)->Void)?
	public let controller: UIImagePickerController
	
	public init?(sourceType: UIImagePickerController.SourceType = .photoLibrary,
	             mediaTypes: [MediaPickType]) {
		guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
			return nil
		}
		controller = UIImagePickerController()
		super.init()
		controller.delegate = self
		controller.sourceType = sourceType
		controller.mediaTypes = mediaTypes.map{$0.utType as String}
	}
	
	public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		guard let fn = onPicked else {
			return
		}
		if let mediaType = info[.mediaType] as? String {
			if mediaType == kUTTypeMovie as String,
				let url = info[.mediaURL] as? URL {
				let asset = AVURLAsset(url: url)
				fn(self, .video(asset), info)
				return
			}
			if mediaType == kUTTypeImage as String,
				var image = info[.editedImage] as? UIImage
					?? info[.originalImage] as? UIImage {
				// ReferenceURL cannot access directly since has prefix assets-library://, should save image to tmp.
				if image.imageOrientation != .up {
					UIGraphicsBeginImageContext(image.size)
					image.draw(in: CGRect(origin: .zero, size: image.size))
					if let newImage = UIGraphicsGetImageFromCurrentImageContext() {
						image = newImage
					}
					UIGraphicsEndImageContext()
				}
				fn(self, .image(image), info)
				return
			}
		}
		fn(self, nil, info)
	}
	
	public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		onCancelled?(self)
	}
}
