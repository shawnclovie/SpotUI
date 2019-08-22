//
//  Applyers.swift
//  SpotUI
//
//  Created by Shawn Clovie on 21/8/2019.
//  Copyright © 2019 Shawn Clovie. All rights reserved.
//

#if canImport(UIKit)
import UIKit
import SpotCache

extension Style {
	/// UIView.layer.masksToBounds | CALayer.masksToBounds
	@discardableResult
	public func maskToBounds(_ v: Bool) -> Self {
		set(MaskToBoundsApplyer(v))
	}
	
	/// UIView.isUserInteractionEnabled
	@discardableResult
	public func userInteractionEnabled(_ v: Bool) -> Self {
		set(UserInteractionEnabledApplyer(v))
	}
	
	/// UIButton.imageView?.contentMode |
	/// UIView.contentMode
	@discardableResult
	public func contentMode(_ v: UIView.ContentMode) -> Self {
		set(ContentModeApplyer(v))
	}
	
	/// UIStackView.axis |
	/// UICollectionView.UICollectionViewFlowLayout.scrollDirection
	@discardableResult
	public func axis(_ v: NSLayoutConstraint.Axis) -> Self {
		set(LayoutConstraintAxisApplyer(v))
	}
	
	/// UILabel.lineBreakMode |
	/// UITextView.textContainer.lineBreakMode |
	/// UIButton.titleLabel?.lineBreakMode
	@discardableResult
	public func lineBreakMode(_ v: NSLineBreakMode) -> Self {
		set(LineBreakModeApplyer(v))
	}
	
	/// UILabel.textAlignment | UITextView.textAlignment |
	/// UITextField.textAlignment | UIButton.titleLabel?.textAlignment
	@discardableResult
	public func textAlignment(_ v: NSTextAlignment) -> Self {
		set(TextAlignmentApplyer(v))
	}
	
	/// UICollectionView.UICollectionViewFlowLayout.itemSize
	@discardableResult
	public func itemSize(_ fn: @escaping (UITraitCollection)->CGSize) -> Self {
		set(ItemSizeApplyer(fn))
	}
	
	/// UIView.layer.border | CALayer.border
	@discardableResult
	public func border(_ fn: @escaping (UITraitCollection)->(CGColor?, CGFloat)) -> Self {
		set(BorderApplyer(fn))
	}
	
	/// UIView.backgroundColor | CALayer.backgroundColor
	@discardableResult
	public func backgroundColor(_ fn: @escaping (UITraitCollection)->UIColor?) -> Self {
		set(BackgroundColorApplyer(fn))
	}
	
	/// UILabel.textColor | UITextField.textColor | UITextView.textColor
	@discardableResult
	public func textColor(_ fn: @escaping (UITraitCollection)->UIColor?) -> Self {
		set(TextColorApplyer(fn))
	}
	
	/// UIButton.setTitleColor
	@discardableResult
	public func buttonTitleColor(for states: Set<UIControl.State> = [.normal],
								 _ fn: @escaping (UIControl.State, UITraitCollection)->UIColor?) -> Self {
		set(StatefulTitleColorApplyer(for: states, fn))
	}
	
	/// UIView.tintColor | UIBarButtonItem.tintColor
	@discardableResult
	public func tintColor(_ fn: @escaping (UITraitCollection)->UIColor?) -> Self {
		set(TintColorApplyer(fn))
	}
	
	/// UIToolbar.barTintColor |
	/// UITabBar.barTintColor |
	/// UISearchBar.barTintColor |
	/// UINavigationBar.barTintColor
	@discardableResult
	public func barTintColor(_ fn: @escaping (UITraitCollection)->UIColor?) -> Self {
		set(BarTintColorApplyer(fn))
	}
	
	/// CAShapeLayer.fillColor
	@discardableResult
	public func fillColor(_ fn: @escaping (UITraitCollection)->CGColor?) -> Self {
		set(FillColorApplyer(fn))
	}
	
	/// CAShapeLayer.strokeColor
	@discardableResult
	public func strokeColor(_ fn: @escaping (UITraitCollection)->CGColor?) -> Self {
		set(StrokeColorApplyer(fn))
	}
	
	/// CAShapeLayer.lineDashPattern
	@discardableResult
	public func lineDashPattern(_ fn: @escaping (UITraitCollection)->[Double]) -> Self {
		set(LineDashPatternApplyer(fn))
	}
	
	/// UILabel.font | UIButton.titleLabel?.font | UITextView.font
	@discardableResult
	public func font(_ fn: @escaping (UITraitCollection)->UIFont) -> Self {
		set(FontApplyer(fn))
	}
	
	/// UIButton.setBackgroundImage | UISearchBar.backgroundImage
	@discardableResult
	public func backgroundImage(_ fn: @escaping (UITraitCollection)->[UIControl.State: StyleImageSource]) -> Self {
		set(BackgroundImageApplyer(fn))
	}
	
	/// CALayer.contents |
	/// UIImageView.image / .highlightedImage |
	/// UIButton.setImage for each state |
	/// UISlider.setThumbImage |
	/// UITabBarItem.selectedImage for highlighed |
	/// UIBarItem.image
	@discardableResult
	public func image(_ fn: @escaping (UITraitCollection)->[UIControl.State: StyleImageSource]) -> Self {
		set(ImageApplyer(fn))
	}
	
	/// setMinimumTrackImage and setMaximumTrackImage of UISlider
	@discardableResult
	public func slideTrackImage(min: [UIControl.State: StyleImageSource], max: [UIControl.State: StyleImageSource]) -> Self {
		set(SlideTrackImageApplyer(min: min, max: max))
	}
	
	/// UIView.alpha | CALayer.opacity
	@discardableResult
	public func alpha(_ v: CGFloat) -> Self {
		set(AlphaApplyer(v))
	}
	
	/// UIView.layer.cornerRadius | CALayer.cornerRadius
	@discardableResult
	public func cornerRadius(_ fn: @escaping (UITraitCollection)->CGFloat) -> Self {
		set(CornerRadiusApplyer(fn))
	}
	
	/// UILabel.numberOfLines |
	/// UITextView.textContainer.maximumNumberOfLines |
	/// UIButton.titleLabel?.numberOfLines
	@discardableResult
	public func numberOfLines(_ v: Int) -> Self {
		set(NumberOfLinesApplyer(v))
	}
	
	/// UITextView.textContainer.lineFragmentPadding |
	/// UICollectionView.UICollectionViewFlowLayout.minimumLineSpacing
	@discardableResult
	public func lineSpacing(_ fn: @escaping (UITraitCollection)->CGFloat) -> Self {
		set(LineSpacingApplyer(fn))
	}
	
	/// CAShapeLayer.lineWIdth
	@discardableResult
	public func lineWidth(_ fn: @escaping (UITraitCollection)->CGFloat) -> Self {
		set(LineWidthApplyer(fn))
	}
	
	/// UICollectionView.UICollectionViewFlowLayout.minimumInteritemSpacing |
	/// UIStackView.spacing
	@discardableResult
	public func spacing(_ fn: @escaping (UITraitCollection)->CGFloat) -> Self {
		set(SpacingApplyer(fn))
	}
	
	/// UIView.layer.shadow | CALayer.shadow
	@discardableResult
	public func shadow(_ fn: @escaping (UITraitCollection)->StyleShadow) -> Self {
		set(ShadowApplyer(fn))
	}
	
	@discardableResult
	public func paragraphSpacing(_ v: UIEdgeInsets) -> Self {
		set(ParagraphSpacing(v))
	}
	
	/// UIButton.contentEdgeInsets |
	/// UITextView.textContainerInset |
	/// UICollectionView.UICollectionViewFlowLayout.sectionInset
	@discardableResult
	public func padding(_ fn: @escaping (UITraitCollection)->UIEdgeInsets) -> Self {
		set(PaddingApplyer(fn))
	}
	
	/// UIButton.titleEdgeInsets
	@discardableResult
	public func titlePadding(_ fn: @escaping (UITraitCollection)->UIEdgeInsets) -> Self {
		set(TitlePaddingApplyer(fn))
	}
}

// MARK: - Dictionary Style Sheet

extension Style {
	static var applyerTypes: [String: StyleApplyer.Type] = [
		"mask-to-bounds": MaskToBoundsApplyer.self,
		"user-interaction-enabled": UserInteractionEnabledApplyer.self,
		
		"content-mode": ContentModeApplyer.self,
		
		"axis": LayoutConstraintAxisApplyer.self,
		
		"line-break-mode": LineBreakModeApplyer.self,
		
		"text-align": TextAlignmentApplyer.self,
		
		"item-size": ItemSizeApplyer.self,
		
		"border": BorderApplyer.self,
		
		"color": TextColorApplyer.self,
		"stateful-title-color": StatefulTitleColorApplyer.self,
		"background-color": BackgroundColorApplyer.self,
		"tint-color": TintColorApplyer.self,
		"bar-tint-color": BarTintColorApplyer.self,
		"fill-color": FillColorApplyer.self,
		"stroke-color": StrokeColorApplyer.self,
		
		"line-dash-pattern": LineDashPatternApplyer.self,
		
		"font": FontApplyer.self,
		
		"background-image": BackgroundImageApplyer.self,
		"image": ImageApplyer.self,
		"slide-track-image": SlideTrackImageApplyer.self,
		
		"alpha": AlphaApplyer.self,
		"corner-radius": CornerRadiusApplyer.self,
		"line-spacing": LineSpacingApplyer.self,
		"line-width": LineWidthApplyer.self,
		"number-of-lines": NumberOfLinesApplyer.self,
		"spacing": SpacingApplyer.self,
		
		"shadow": ShadowApplyer.self,
		
		"paragraph-spacing": ParagraphSpacing.self,
		"padding": PaddingApplyer.self,
		"title-padding": TitlePaddingApplyer.self,
	]
	
	public static func registerApplyer(name: String, _ type: StyleApplyer.Type) {
		applyerTypes[name] = type
	}
}
#endif
