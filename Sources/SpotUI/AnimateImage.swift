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

private let DefaultDelayTime: TimeInterval = 0.1
private let MinimumDelayTime: TimeInterval = 0.02

open class AnimateImage {
	
	private enum State {
		case idle, rendering
	}
	
	/// Create image with image source for 1st frame.
	/// - parameter source: Image source
	/// - returns: Created image
	public static func posterImage(with source: CGImageSource) -> UIImage? {
		for index in 0..<CGImageSourceGetCount(source) {
			if let frame = CGImageSourceCreateImageAtIndex(source, index, nil) {
				return .init(cgImage: frame)
			}
		}
		return nil
	}
	
	public static func posterImage(with source: Data.Source) -> UIImage? {
		if let imageSource = AnimateImage.imageSource(of: source) {
			return posterImage(with: imageSource)
		}
		return nil
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
		if let imageSource = AnimateImage.imageSource(of: source) {
			return gifImageSize(with: imageSource)
		}
		return nil
	}
	
	public let dataSource: Data.Source
	public let loopCount: UInt
	public let size: CGSize
	public let delayTimes: [TimeInterval]
	public let duration: TimeInterval
	
	open var maxFrameCacheSize: UInt = 0 {
		didSet {
			if maxFrameCacheSize != oldValue {
				purgeFrameCacheIfNeeded()
			}
		}
	}
	
	private var requestedFrameIndex: UInt = 0
	private var cachedFrames: [UInt: UIImage]
	private var cachedFrameIndexes: Set<UInt>
	private var requestedFrameIndexes: Set<UInt>
	
	private lazy var renderQueue: DispatchQueue = {
		DispatchQueue(label: "animate_image_fetch_queue")
	}()
	private let imageSource: CGImageSource
	private var state = State.idle
	
	public init?(_ source: Data.Source) {
		guard let imageSource = AnimateImage.imageSource(of: source) else {
			return nil
		}
		self.imageSource = imageSource
		dataSource = source
		guard let containerType = CGImageSourceGetType(imageSource),
			UTTypeConformsTo(containerType, kUTTypeGIF) else {
				return nil
		}
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
				delay = index == 0 ? DefaultDelayTime : delayTimes[index - 1]
			}
			delay = max(delay, MinimumDelayTime)
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
		var loopCount: UInt = 0
		if let props = CGImageSourceCopyProperties(imageSource, nil),
			let gifProps = props.spot.unsafeCastValue(forKey: kCGImagePropertyGIFDictionary) as CFDictionary?,
			let number = gifProps.spot.unsafeCastValue(forKey: kCGImagePropertyGIFLoopCount) as NSNumber? {
			loopCount = number.uintValue
		}
		self.loopCount = loopCount
	}
	
	open var currentFrameCacheSize: UInt {
		(1...frameCount).contains(maxFrameCacheSize)
			? maxFrameCacheSize : frameCount
	}
	
	open var frameCount: UInt {
		UInt(delayTimes.count)
	}
	
	open var allFrameIndexes: Set<UInt> {
		var indexes = Set<UInt>()
		for index in 0..<delayTimes.count {
			indexes.insert(UInt(index))
		}
		return indexes
	}
	
	open var posterImage: UIImage? {
		AnimateImage.posterImage(with: imageSource)
	}
	
	open func image(at index: UInt) -> UIImage? {
		guard index < frameCount,
			let image = CGImageSourceCreateImageAtIndex(imageSource, Int(index), nil) else {
			return nil
		}
		return .init(cgImage: image)
	}
	
	open func cancelCaching() {
		if state == .rendering {
			state = .idle
		}
	}
	
	open func lazilyCachedImage(at index: UInt) -> UIImage? {
		guard index < frameCount else {
			return nil
		}
		requestedFrameIndex = index
		if UInt(cachedFrameIndexes.count) < frameCount {
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
	
	private func cacheFrames(withIndexes indexes: Set<UInt>) {
		state = .rendering
		let ranges = [(requestedFrameIndex..<frameCount), (0..<requestedFrameIndex)]
		requestedFrameIndexes.formUnion(indexes)
		renderQueue.async { [weak self] in
			for range in ranges {
				for index in range {
					if self == nil || self?.state != .rendering {
						break
					}
					guard let image = self?.renderFrame(at: index) else {
						continue
					}
					DispatchQueue.main.async {
						self?.frameDidCache(image, at: index)
					}
				}
			}
		}
	}
	
	private func frameDidCache(_ image: UIImage, at index: UInt) {
		cachedFrames[index] = image
		cachedFrameIndexes.insert(index)
		requestedFrameIndexes.remove(index)
	}
	
	private var frameIndexesForCache: Set<UInt> {
		let curCacheSize = currentFrameCacheSize
		if curCacheSize == frameCount {
			return allFrameIndexes
		}
		// Add indexes in two blocks -
		// 1st, starting from the requested frame index, up to limit or the end.
		// 2nd if needed, the remaining number of frames beginning at index 0.
		let firstLen = min(curCacheSize, frameCount - requestedFrameIndex)
		var indexes = Set<UInt>((requestedFrameIndex...(requestedFrameIndex + firstLen)))
		if curCacheSize > firstLen {
			for index in 0...(curCacheSize - firstLen) {
				indexes.insert(index)
			}
		}
		return indexes
	}
	
	private func renderFrame(at index: UInt) -> UIImage? {
		guard let image = CGImageSourceCreateImageAtIndex(imageSource, Int(index), nil) else {
			return nil
		}
		return AnimateImage.renderImage(.init(cgImage: image))
	}
	
	private func purgeFrameCacheIfNeeded() {
		if UInt(cachedFrameIndexes.count) > currentFrameCacheSize {
			let purgingIndexes = cachedFrameIndexes.subtracting(frameIndexesForCache)
			purgeFrameCache(forIndexes: purgingIndexes)
		}
	}
	
	open func purgeFrameCache() {
		cancelCaching()
		purgeFrameCache(forIndexes: cachedFrameIndexes)
	}
	
	private func purgeFrameCache(forIndexes indexes: Set<UInt>) {
		guard !indexes.isEmpty else {
			return
		}
		for index in indexes {
			cachedFrames.removeValue(forKey: index)
		}
		cachedFrameIndexes.subtract(indexes)
	}
	
	private static func renderImage(_ image: UIImage) -> UIImage {
		guard let cg = image.cgImage else {
			return image
		}
		var alphaInfo = cg.alphaInfo
		switch alphaInfo {
		case .none, .alphaOnly:	alphaInfo = .noneSkipFirst
		case .first:		alphaInfo = .premultipliedFirst
		case .last:			alphaInfo = .premultipliedLast
		default:break
		}
		var newImage = image
		CGContext.spot(width: Int(image.size.width), height: Int(image.size.height), alpha: alphaInfo) { ctx in
			ctx.draw(cg, in: CGRect(origin: .zero, size: image.size))
			if let newCGImage = ctx.makeImage() {
				newImage = .init(cgImage: newCGImage)
			}
		}
		return newImage
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

extension AnimateImage: DataConvertable {
	public typealias ItemType = AnimateImage
	
	public static func convert(from source: Data.Source) -> ItemType? {
		AnimateImage(source)
	}
	
	public func convertToData() -> Data? {
		dataSource.data
	}
}
#endif
