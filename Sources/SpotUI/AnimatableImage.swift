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
	
	private enum State {
		case idle, rendering
	}
	
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
	public let duration: TimeInterval
	
	open var maxFrameCacheSize: Int = 0 {
		didSet {
			if maxFrameCacheSize != oldValue {
				purgeFrameCacheIfNeeded()
			}
		}
	}
	
	private var requestedFrameIndex: Int = 0
	private var cachedFrames: [Int: UIImage]
	private var cachedFrameIndexes: Set<Int>
	private var requestedFrameIndexes: Set<Int>
	
	private lazy var renderQueue: DispatchQueue = {
		.init(label: "animate_image_render")
	}()
	private let imageSource: CGImageSource
	private var state = State.idle
	
	public init?(_ source: Data.Source) {
		guard let imageSource = AnimatableImage.imageSource(of: source) else {return nil}
		guard let containerType = CGImageSourceGetType(imageSource),
			UTTypeConformsTo(containerType, kUTTypeGIF)
			else {return nil}
		self.imageSource = imageSource
		dataSource = source
		let imageCount = CGImageSourceGetCount(imageSource)
		var imageSize = CGSize.zero
		var delayTimes = [TimeInterval]()
		var duration = 0.0
		for index in 0..<imageCount {
			if imageSize == .zero,
				let frame = CGImageSourceCreateImageAtIndex(imageSource, index, nil) {
				imageSize = CGSize(width: frame.width, height: frame.height)
			}
			guard let props = CGImageSourceCopyPropertiesAtIndex(imageSource, index, nil),
				let gifProps = props.spot.unsafeCastValue(forKey: kCGImagePropertyGIFDictionary) as CFDictionary? else {
				continue
			}
			var delay: TimeInterval
			if let number = gifProps.spot.unsafeCastValue(forKey: kCGImagePropertyGIFUnclampedDelayTime) as NSNumber?
				?? gifProps.spot.unsafeCastValue(forKey: kCGImagePropertyGIFDelayTime) as NSNumber? {
				delay = TimeInterval(number.doubleValue)
			} else {
				delay = index == 0 ? Self.defaultDelayTime : delayTimes[index - 1]
			}
			delay = max(delay, Self.minimumDelayTime)
			delayTimes.append(delay)
			duration += delay
		}
		if delayTimes.count == 0 {
			return nil
		}
		size = imageSize
		self.duration = TimeInterval(duration)
		self.delayTimes = delayTimes
		cachedFrames = [:]
		cachedFrameIndexes = []
		requestedFrameIndexes = []
		
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
	
	private var currentFrameCacheSize: Int {
		(1...frameCount).contains(maxFrameCacheSize)
			? maxFrameCacheSize : frameCount
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
		return UIImage.animatedImage(with: images, duration: delayTimes.reduce(0, +))
	}
	
	open func cancelCaching() {
		if state == .rendering {
			state = .idle
		}
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
		state = .rendering
		let ranges = [(requestedFrameIndex..<frameCount), (0..<requestedFrameIndex)]
		requestedFrameIndexes.formUnion(indexes)
		renderQueue.async { [weak self] in
			for range in ranges {
				for index in range {
					if self == nil || self?.state != .rendering {
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
		case .url(let url):
			return CGImageSourceCreateWithURL(url as CFURL, nil)
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
