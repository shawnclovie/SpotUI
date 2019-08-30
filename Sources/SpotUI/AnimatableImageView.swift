//
//  AnimateImageView.swift
//  SpotUI
//
//  Created by Shawn Clovie on 5/16/16.
//  Copyright © 2016 Shawn Clovie. All rights reserved.
//

#if canImport(UIKit)
import UIKit
import ImageIO
import MobileCoreServices
import Spot

public protocol Animatable: class {
	func startAnimating()
	func stopAnimating()
}

/// A subclass of UIImageView
///
/// It can present simple image (single framed and animated image), or AnimatableImage (low memory cost).
open class AnimatableImageView: UIImageView, Animatable {

	open var animatableImage: AnimatableImage? {
		didSet {
			guard animatableImage !== oldValue else {
				return
			}
			if animatableImage == nil || super.image?.images != nil {
				stopAnimating()
			} else {
				super.image = nil
				super.isHighlighted = false
				invalidateIntrinsicContentSize()
			}
			accumulator = 0
			currentFrame = animatableImage?.createImage()
			super.image = currentFrame
			currentFrameIndex = 0
			let count = animatableImage?.loopCount ?? 0
			loopCountdown = count == 0 ? .max : count
			
			updateShouldAnimate()
			if shouldAnimate {
    			startAnimating()
			}
			layer.setNeedsDisplay()
		}
	}
	
	private var currentFrame: UIImage?
	private var currentFrameIndex: Int = 0
	private var loopCountdown: Int = 0
	private var accumulator: TimeInterval = 0
	private var displayLink: CADisplayLink?
	private var shouldAnimate = false
	private var needDisplayWhenImageBecomesAvailable = false
	
	deinit {
		displayLink?.invalidate()
	}
	
	open override func didMoveToSuperview() {
		super.didMoveToSuperview()
		updateShouldAnimate()
		if shouldAnimate {
			startAnimating()
		} else {
			stopAnimating()
		}
	}
	
	open override func didMoveToWindow() {
		super.didMoveToWindow()
		if shouldAnimate {
			startAnimating()
		} else {
			stopAnimating()
		}
	}
	
	open override var intrinsicContentSize: CGSize {
		animatableImage == nil
			? super.intrinsicContentSize : (currentFrame?.size ?? .zero)
	}
	
	open override var image: UIImage? {
		get {animatableImage == nil ? super.image : currentFrame}
		set {
			animatableImage = nil
			super.image = newValue
		}
	}
	
	public var imageSize: CGSize {
		animatableImage?.size ?? image?.size ?? .zero
	}
	
	open func setImage(path: URL, scaleToFit: CGSize? = nil, scaleQueue: DispatchQueue? = nil) {
		guard let image = AnimatableImage(.path(path)) else {return}
		if image.frameCount > 1 {
			animatableImage = image
			return
		}
		if scaleToFit != nil, let queue = scaleQueue {
			queue.async { [weak self] in
				let scaled = image.createImage(at: 0, scaleToFit: scaleToFit)
				DispatchQueue.main.async {
					self?.image = scaled
				}
			}
		} else {
			self.image = image.createImage(at: 0, scaleToFit: scaleToFit)
		}
	}
	
	open override var isAnimating: Bool {
		animatableImage == nil
			? super.isAnimating : !(displayLink?.isPaused ?? true)
	}
	
	open override func startAnimating() {
		if animatableImage == nil {
			super.startAnimating()
			return
		}
		if displayLink == nil {
			let mode: RunLoop.Mode = ProcessInfo.processInfo.activeProcessorCount > 1
				? .common : .default
			let proxy = WeakProxy(self, #selector(displayRefreshed(_:)))
			let link = CADisplayLink(target: proxy, selector: #selector(proxy.event(_:)))
			link.add(to: .main, forMode: mode)
			displayLink = link
		}
		updateShouldAnimate()
		displayLink?.isPaused = false
	}
	
	open override func stopAnimating() {
		if animatableImage == nil {
			super.stopAnimating()
		} else {
			displayLink?.isPaused = true
		}
	}
	
	open override var isHighlighted: Bool {
		get {super.isHighlighted}
		set {
			if animatableImage == nil {
    			super.isHighlighted = newValue
			}
		}
	}
	
	private func updateShouldAnimate() {
		shouldAnimate = animatableImage != nil && window != nil && superview != nil
	}
	
	@objc private func displayRefreshed(_ link: CADisplayLink) {
		guard shouldAnimate,
			let animate = animatableImage,
			let image = animate.lazilyCachedImage(at: currentFrameIndex)
			else {return}
		currentFrame = image
		if needDisplayWhenImageBecomesAvailable {
			layer.setNeedsDisplay()
			needDisplayWhenImageBecomesAvailable = false
		}
		accumulator += link.duration
		while accumulator >= animate.delayTimes[Int(currentFrameIndex)] {
			accumulator -= animate.delayTimes[Int(currentFrameIndex)]
			currentFrameIndex += 1
			if currentFrameIndex >= animate.frameCount {
				loopCountdown -= 1
				if loopCountdown == 0 {
					stopAnimating()
					return
				}
				currentFrameIndex = 0
			}
			needDisplayWhenImageBecomesAvailable = true
		}
	}
	
	// MARK: Providing layer's content
	
	open override func display(_ layer: CALayer) {
		layer.contents = image?.cgImage
	}
}
#endif
