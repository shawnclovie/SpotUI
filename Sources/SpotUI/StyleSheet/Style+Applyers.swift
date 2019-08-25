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
	
	/// UIView.isHidden | CALayer.isHidden
	public func hidden(_ v: Bool) -> Self {
		set(BoolApplyer<HiddenApplying>(v))
	}
	
	/// UIView.layer.masksToBounds | CALayer.masksToBounds
	@discardableResult
	public func maskToBounds(_ v: Bool) -> Self {
		set(BoolApplyer<MaskToBoundsApplying>(v))
	}
	
	/// UISegmentedControl.isMomentary
	@discardableResult
	public func momentary(_ v: Bool) -> Self {
		set(BoolApplyer<MomentaryApplying>(v))
	}
	
	/// UIView.isUserInteractionEnabled
	@discardableResult
	public func userInteractionEnabled(_ v: Bool) -> Self {
		set(BoolApplyer<UserInteractionEnabledApplying>(v))
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
		set(ColorApplyer<BackgroundColorApplying>(fn))
	}
	
	/// UILabel.textColor | UITextField.textColor | UITextView.textColor
	@discardableResult
	public func textColor(_ fn: @escaping (UITraitCollection)->UIColor?) -> Self {
		set(ColorApplyer<TextColorApplying>(fn))
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
		set(ColorApplyer<TintColorApplying>(fn))
	}
	
	/// UIToolbar.barTintColor |
	/// UITabBar.barTintColor |
	/// UISearchBar.barTintColor |
	/// UINavigationBar.barTintColor
	@discardableResult
	public func barTintColor(_ fn: @escaping (UITraitCollection)->UIColor?) -> Self {
		set(ColorApplyer<BarTintColorApplying>(fn))
	}
	
	/// CAShapeLayer.fillColor
	@discardableResult
	public func fillColor(_ fn: @escaping (UITraitCollection)->UIColor?) -> Self {
		set(ColorApplyer<FillColorApplying>(fn))
	}
	
	/// CAShapeLayer.strokeColor
	@discardableResult
	public func strokeColor(_ fn: @escaping (UITraitCollection)->UIColor?) -> Self {
		set(ColorApplyer<StrokeColorApplying>(fn))
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
		set(StatefulImageApplyer<BackgroundImageApplying>(fn))
	}
	
	/// CALayer.contents |
	/// UIImageView.image / .highlightedImage |
	/// UIButton.setImage for each state |
	/// UISlider.setThumbImage |
	/// UITabBarItem.selectedImage for highlighed |
	/// UIBarItem.image
	@discardableResult
	public func image(_ fn: @escaping (UITraitCollection)->[UIControl.State: StyleImageSource]) -> Self {
		set(StatefulImageApplyer<ImageApplying>(fn))
	}
	
	/// setMinimumTrackImage and setMaximumTrackImage of UISlider
	@discardableResult
	public func slideTrackImage(min: [UIControl.State: StyleImageSource], max: [UIControl.State: StyleImageSource]) -> Self {
		set(SlideTrackImageApplyer(min: min, max: max))
	}
	
	/// UIView.alpha | CALayer.opacity
	@discardableResult
	public func alpha(_ v: CGFloat) -> Self {
		set(NumberApplyer<AlphaApplying>(v))
	}
	
	/// UIView.layer.cornerRadius | CALayer.cornerRadius
	@discardableResult
	public func cornerRadius(_ fn: @escaping (UITraitCollection)->CGFloat) -> Self {
		set(TraitNumberApplyer<CornerRadiusApplying>(fn))
	}
	
	/// UILabel.numberOfLines |
	/// UITextView.textContainer.maximumNumberOfLines |
	/// UIButton.titleLabel?.numberOfLines
	@discardableResult
	public func numberOfLines(_ v: Int) -> Self {
		set(NumberApplyer<NumberOfLinesApplying>(CGFloat(v)))
	}
	
	/// UITextView.textContainer.lineFragmentPadding |
	/// UICollectionView.UICollectionViewFlowLayout.minimumLineSpacing
	@discardableResult
	public func lineSpacing(_ fn: @escaping (UITraitCollection)->CGFloat) -> Self {
		set(TraitNumberApplyer<LineSpacingApplying>(fn))
	}
	
	/// CAShapeLayer.lineWIdth
	@discardableResult
	public func lineWidth(_ fn: @escaping (UITraitCollection)->CGFloat) -> Self {
		set(TraitNumberApplyer<LineWidthApplying>(fn))
	}
	
	/// UICollectionView.UICollectionViewFlowLayout.minimumInteritemSpacing |
	/// UIStackView.spacing
	@discardableResult
	public func spacing(_ fn: @escaping (UITraitCollection)->CGFloat) -> Self {
		set(TraitNumberApplyer<SpacingApplying>(fn))
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
		"hidden": BoolApplyer<HiddenApplying>.self,
		"mask-to-bounds": BoolApplyer<MaskToBoundsApplying>.self,
		"momentary": BoolApplyer<MomentaryApplying>.self,
		"user-interaction-enabled": BoolApplyer<UserInteractionEnabledApplying>.self,
		
		"content-mode": ContentModeApplyer.self,
		
		"axis": LayoutConstraintAxisApplyer.self,
		
		"line-break-mode": LineBreakModeApplyer.self,
		
		"text-align": TextAlignmentApplyer.self,
		
		"item-size": ItemSizeApplyer.self,
		
		"border": BorderApplyer.self,
		
		"background-color": ColorApplyer<BackgroundColorApplying>.self,
		"color": ColorApplyer<TextColorApplying>.self,
		"tint-color": ColorApplyer<TintColorApplying>.self,
		"bar-tint-color": ColorApplyer<BarTintColorApplying>.self,
		"fill-color": ColorApplyer<FillColorApplying>.self,
		"stroke-color": ColorApplyer<StrokeColorApplying>.self,
		"stateful-title-color": StatefulTitleColorApplyer.self,
		
		"line-dash-pattern": LineDashPatternApplyer.self,
		
		"font": FontApplyer.self,
		
		"background-image": StatefulImageApplyer<BackgroundImageApplying>.self,
		"image": StatefulImageApplyer<ImageApplying>.self,
		"slide-track-image": SlideTrackImageApplyer.self,
		
		"alpha": NumberApplyer<AlphaApplying>.self,
		"number-of-lines": NumberApplyer<NumberOfLinesApplying>.self,
		"corner-radius": TraitNumberApplyer<CornerRadiusApplying>.self,
		"line-spacing": TraitNumberApplyer<LineSpacingApplying>.self,
		"line-width": TraitNumberApplyer<LineWidthApplying>.self,
		"spacing": TraitNumberApplyer<SpacingApplying>.self,
		
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
