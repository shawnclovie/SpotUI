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

open class AnimateImageView: UIImageView, Animatable {

	open var animateImage: AnimateImage? {
		didSet {
			guard animateImage !== oldValue else {
				return
			}
			if animateImage == nil {
				stopAnimating()
			} else {
				super.image = nil
				super.isHighlighted = false
				invalidateIntrinsicContentSize()
			}
			accumulator = 0
			currentFrame = animateImage?.posterImage
			super.image = currentFrame
			currentFrameIndex = 0
			let count = animateImage?.loopCount ?? 0
			loopCountdown = count == 0 ? UInt.max : count
			
			updateShouldAnimate()
			if shouldAnimate {
    			startAnimating()
			}
			layer.setNeedsDisplay()
		}
	}
	
	private var currentFrame: UIImage?
	private var currentFrameIndex: UInt = 0
	private var loopCountdown: UInt = 0
	private var accumulator: TimeInterval = 0
	private var displayLink: CADisplayLink?
	private var shouldAnimate = false
	private var needDisplayWhenImageBecomesAvailable = false
	
	deinit {
		displayLink?.invalidate()
	}
	
	// MARK: UIView functions
	
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
	
	// MARK: Auto Layout
	
	open override var intrinsicContentSize: CGSize {
		animateImage == nil
			? super.intrinsicContentSize : (image?.size ?? .zero)
	}
	
	// MARK: ImageView functions
	
	open override var image: UIImage? {
		get {animateImage == nil ? super.image : currentFrame}
		set {
			if newValue != nil {
    			animateImage = nil
			}
			super.image = newValue
		}
	}
	
	open func setImage(withFile url: URL) {
		if let animateImage = AnimateImage(.url(url)) {
			self.animateImage = animateImage
		} else {
			image = UIImage(contentsOfFile: url.path)
		}
	}
	
	open func clearImage() {
		animateImage = nil
		image = nil
	}
	
	open override var isAnimating: Bool {
		if animateImage == nil {
			return super.isAnimating
		}
		return !(displayLink?.isPaused ?? true)
	}
	
	open override func startAnimating() {
		if animateImage == nil {
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
		if animateImage == nil {
			super.stopAnimating()
		} else {
			displayLink?.isPaused = true
		}
	}
	
	open override var isHighlighted: Bool {
		get {super.isHighlighted}
		set {
			if animateImage == nil {
    			super.isHighlighted = newValue
			}
		}
	}
	
	private func updateShouldAnimate() {
		shouldAnimate = animateImage != nil && window != nil && superview != nil
	}
	
	@objc private func displayRefreshed(_ link: CADisplayLink) {
		guard shouldAnimate,
			let animate = animateImage,
			let image = animate.lazilyCachedImage(at: currentFrameIndex) else {
				return
		}
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

extension Suffix where Base: AnimateImageView {
	public var imageSize: CGSize {
		base.animateImage?.size
			?? base.image?.size
			?? .zero
	}
}
#endif
