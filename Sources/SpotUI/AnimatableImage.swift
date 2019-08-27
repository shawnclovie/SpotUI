//
//  AnimateImage.swift
//  SpotUI
//
//  Created by Shawn Clovie on 5/16/16.
//  Copyright © 2016 Shawn Clovie. All rights reserved.
//

#if canImport(UIKit)
import UIKit
import MobileCoreServices
import ImageIO
import Spot
import SpotCache

/// An images container, it can present animation with any UIImageView
open class AnimatableImage {
	
	private static let defaultDelayTime: TimeInterval = 0.1
	private static let minimumDelayTime: TimeInterval = 0.02
	
	/// Create image with image source for 1st frame.
	/// - parameter source: Image source
	/// - returns: Created image
	public static func createImage(from source: CGImageSource) -> UIImage? {
		for index in 0..<CGImageSourceGetCount(source) {
			if let frame = CGImageSourceCreateImageAtIndex(source, index, nil) {
				return .init(cgImage: frame)
			}
		}
		return nil
	}
	
	public static func createImage(from source: Data.Source) -> UIImage? {
		guard let src = imageSource(of: source) else {return nil}
		return createImage(from: src)
	}
	
	public static func gifImageSize(with source: CGImageSource) -> CGSize? {
		guard let containerType = CGImageSourceGetType(source),
			UTTypeConformsTo(containerType, kUTTypeGIF) else {
				return nil
		}
		for index in 0..<CGImageSourceGetCount(source) {
			if let frame = CGImageSourceCreateImageAtIndex(source, index, nil) {
				let size = UIImage(cgImage: frame).size
				if size != .zero {
					return size
				}
			}
		}
		return nil
	}
	
	public static func gifImageSize(with source: Data.Source) -> CGSize? {
		if let imageSource = AnimatableImage.imageSource(of: source) {
			return gifImageSize(with: imageSource)
		}
		return nil
	}
	
	public let dataSource: Data.Source
	public let loopCount: Int
	public let size: CGSize
	public let delayTimes: [TimeInterval]
	
	open var maxFrameCacheSize = 0 {
		didSet {
			if maxFrameCacheSize != oldValue {
				purgeFrameCacheIfNeeded()
			}
		}
	}
	
	private var requestedFrameIndex = 0
	private var cachedFrames: [Int: UIImage] = [:]
	private var cachedFrameIndexes: Set<Int> = []
	private var requestedFrameIndexes: Set<Int> = []
	
	private lazy var renderQueue: DispatchQueue = {
		.init(label: "animate_image_render")
	}()
	private let imageSource: CGImageSource
	public private(set) var isRendering = false
	
	/// Create the AnimatableImage with CGImageSource
	/// - Parameter source: Data source, data in memory or path
	public init?(_ source: Data.Source) {
		guard let imageSource = Self.imageSource(of: source) else {return nil}
		let imageCount = CGImageSourceGetCount(imageSource)
		guard imageCount > 0 else {return nil}
		var delayTimes = [TimeInterval]()
		delayTimes.reserveCapacity(imageCount)
		for index in 0..<imageCount {
			var delay: TimeInterval
			if let props = CGImageSourceCopyPropertiesAtIndex(imageSource, index, nil) as? [AnyHashable: Any],
				let gifProps = props[kCGImagePropertyGIFDictionary as String] as? [AnyHashable: Any],
				let number = gifProps[kCGImagePropertyGIFUnclampedDelayTime as String] as? NSNumber
				?? gifProps[kCGImagePropertyGIFDelayTime as String] as? NSNumber {
				delay = TimeInterval(number.doubleValue)
			} else {
				delay = index == 0 ? Self.defaultDelayTime : delayTimes[index - 1]
			}
			delay = max(delay, Self.minimumDelayTime)
			delayTimes.append(delay)
		}
		self.delayTimes = delayTimes
		self.imageSource = imageSource
		dataSource = source
		size = imageSource.spot.size
		
		// Get LoopCount, 0 means repeating the animation indefinitely.
		// {FileSize=?, "{GIF}"={HasGlobalColorMap=1/0, LoopCount=?}}
		if let props = CGImageSourceCopyProperties(imageSource, nil),
			let gifProps = props.spot.unsafeCastValue(forKey: kCGImagePropertyGIFDictionary) as CFDictionary?,
			let number = gifProps.spot.unsafeCastValue(forKey: kCGImagePropertyGIFLoopCount) as NSNumber? {
			loopCount = number.intValue
		} else {
			loopCount = 0
		}
	}
	
	public var duration: TimeInterval {
		delayTimes.reduce(0, +)
	}
	
	@inlinable
	public var frameCount: Int {
		delayTimes.count
	}
	
	/// Try to create image iterate from first
	public func createImage() -> UIImage? {
		Self.createImage(from: imageSource)
	}
	
	public func createImage(at index: Int, scaleToFit fitSize: CGSize? = nil) -> UIImage? {
		guard index >= 0 && index < frameCount else {return nil}
		if let fitSize = fitSize, fitSize.width > 0 && fitSize.height > 0 {
			let opt = [
				kCGImageSourceThumbnailMaxPixelSize: max(fitSize.width, fitSize.height),
				kCGImageSourceCreateThumbnailFromImageAlways: true,
			] as CFDictionary
			guard let cg = CGImageSourceCreateThumbnailAtIndex(imageSource, index, opt) else {return nil}
			return .init(cgImage: cg)
		}
		guard let image = CGImageSourceCreateImageAtIndex(imageSource, index, nil) else {return nil}
		return .init(cgImage: image)
	}
	
	/// Create image with UIImage.animatedImage for simple usage
	/// - Parameter fitSize: Created image would scaled to fit the size if given and each width and height > 0
	public func createAnimatedImages(scaleToFit fitSize: CGSize? = nil) -> UIImage? {
		var images: [UIImage] = []
		images.reserveCapacity(delayTimes.count)
		for i in 0..<delayTimes.count {
			guard let image = createImage(at: i, scaleToFit: fitSize) else {continue}
			images.append(image)
		}
		return UIImage.animatedImage(with: images, duration: duration)
	}
	
	open func cancelCaching() {
		isRendering = false
	}
	
	public func lazilyCachedImage(at index: Int) -> UIImage? {
		guard index < frameCount else {
			return nil
		}
		requestedFrameIndex = index
		if cachedFrameIndexes.count < frameCount {
			let addingIndexes = frameIndexesForCache
				.subtracting(cachedFrameIndexes)
				.subtracting(requestedFrameIndexes)
			if !addingIndexes.isEmpty {
				cacheFrames(withIndexes: addingIndexes)
			}
		}
		let image = cachedFrames[index]
		purgeFrameCacheIfNeeded()
		return image
	}
	
	private func cacheFrames(withIndexes indexes: Set<Int>) {
		isRendering = true
		let ranges = [(requestedFrameIndex..<frameCount), (0..<requestedFrameIndex)]
		requestedFrameIndexes.formUnion(indexes)
		renderQueue.async { [weak self] in
			for range in ranges {
				for index in range {
					if self == nil || self?.isRendering != true {
						break
					}
					guard let image = self?.createImage(at: index) else {
						continue
					}
					DispatchQueue.main.async {
						self?.frameDidCache(image, at: index)
					}
				}
			}
		}
	}
	
	private func frameDidCache(_ image: UIImage, at index: Int) {
		cachedFrames[index] = image
		cachedFrameIndexes.insert(index)
		requestedFrameIndexes.remove(index)
	}
	
	private var currentFrameCacheSize: Int {
		(1...frameCount).contains(maxFrameCacheSize)
			? maxFrameCacheSize : frameCount
	}
	
	private var frameIndexesForCache: Set<Int> {
		let curCacheSize = currentFrameCacheSize
		if curCacheSize == frameCount {
			return .init(0..<delayTimes.count)
		}
		// Add indexes in two blocks -
		// 1st, starting from the requested frame index, up to limit or the end.
		// 2nd if needed, the remaining number of frames beginning at index 0.
		let firstLen = min(curCacheSize, frameCount - requestedFrameIndex)
		var indexes = Set<Int>((requestedFrameIndex...(requestedFrameIndex + firstLen)))
		if curCacheSize > firstLen {
			for index in 0...(curCacheSize - firstLen) {
				indexes.insert(index)
			}
		}
		return indexes
	}
	
	private func purgeFrameCacheIfNeeded() {
		if cachedFrameIndexes.count > currentFrameCacheSize {
			let purgingIndexes = cachedFrameIndexes.subtracting(frameIndexesForCache)
			purgeFrameCache(forIndexes: purgingIndexes)
		}
	}
	
	open func purgeFrameCache() {
		cancelCaching()
		purgeFrameCache(forIndexes: cachedFrameIndexes)
	}
	
	private func purgeFrameCache(forIndexes indexes: Set<Int>) {
		guard !indexes.isEmpty else {
			return
		}
		for index in indexes {
			cachedFrames.removeValue(forKey: index)
		}
		cachedFrameIndexes.subtract(indexes)
	}
	
	private static func imageSource(of source: Data.Source) -> CGImageSource? {
		switch source {
		case .path(let it):
			return CGImageSourceCreateWithURL(it as CFURL, nil)
		case .data(let data):
			return CGImageSourceCreateWithData(data as CFData, nil)
		}
	}
}

extension AnimatableImage: DataConvertable {
	public typealias ItemType = AnimatableImage
	
	public static func convert(from source: Data.Source) -> ItemType? {
		AnimatableImage(source)
	}
	
	public func convertToData() -> Data? {
		dataSource.data
	}
}
#endif
