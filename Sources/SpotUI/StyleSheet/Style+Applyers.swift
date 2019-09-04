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
	
	func applyer<T>() -> T? where T: StyleApplyer {
		applyers["\(T.self)"] as? T
	}
	
	/// UIView.isHidden | CALayer.isHidden
	@discardableResult
	public func hidden(_ v: Bool) -> Self {
		set(BoolApplyer<HiddenApplying>(v))
	}
	
	public func isHidden(default: Bool = false) -> Bool {
		(applyer() as BoolApplyer<HiddenApplying>?)?.value ?? `default`
	}
	
	/// UIView.layer.masksToBounds | CALayer.masksToBounds
	@discardableResult
	public func maskToBounds(_ v: Bool) -> Self {
		set(BoolApplyer<MaskToBoundsApplying>(v))
	}
	
	public func isMaskToBound(default: Bool = false) -> Bool {
		(applyer() as BoolApplyer<MaskToBoundsApplying>?)?.value ?? `default`
	}
	
	/// UISegmentedControl.isMomentary
	@discardableResult
	public func momentary(_ v: Bool) -> Self {
		set(BoolApplyer<MomentaryApplying>(v))
	}
	
	public func isMomentary(default: Bool = false) -> Bool {
		(applyer() as BoolApplyer<MomentaryApplying>?)?.value ?? `default`
	}
	
	/// UIView.isUserInteractionEnabled
	@discardableResult
	public func userInteractionEnabled(_ v: Bool) -> Self {
		set(BoolApplyer<UserInteractionEnabledApplying>(v))
	}
	
	public func isUserInteractionEnabled(default: Bool = false) -> Bool {
		(applyer() as BoolApplyer<UserInteractionEnabledApplying>?)?.value ?? `default`
	}
	
	/// UIButton.imageView?.contentMode |
	/// UIView.contentMode
	@discardableResult
	public func contentMode(_ v: UIView.ContentMode) -> Self {
		set(ContentModeApplyer(v))
	}
	
	public func getContentMode(default: UIView.ContentMode = .scaleToFill) -> UIView.ContentMode {
		(applyer() as ContentModeApplyer?)?.value ?? `default`
	}
	
	/// UIStackView.axis |
	/// UICollectionView.UICollectionViewFlowLayout.scrollDirection
	@discardableResult
	public func axis(_ v: NSLayoutConstraint.Axis) -> Self {
		set(LayoutConstraintAxisApplyer(v))
	}
	
	public func getAxis(default: NSLayoutConstraint.Axis) -> NSLayoutConstraint.Axis {
		(applyer() as LayoutConstraintAxisApplyer?)?.value ?? `default`
	}
	
	/// UILabel.lineBreakMode |
	/// UITextView.textContainer.lineBreakMode |
	/// UIButton.titleLabel?.lineBreakMode
	@discardableResult
	public func lineBreakMode(_ v: NSLineBreakMode) -> Self {
		set(LineBreakModeApplyer(v))
	}
	
	public func getLineBreakMode(default: NSLineBreakMode) -> NSLineBreakMode {
		(applyer() as LineBreakModeApplyer?)?.value ?? `default`
	}
	
	/// UILabel.textAlignment | UITextView.textAlignment |
	/// UITextField.textAlignment | UIButton.titleLabel?.textAlignment
	@discardableResult
	public func textAlignment(_ v: NSTextAlignment) -> Self {
		set(TextAlignmentApplyer(v))
	}
	
	public func getTextAlignment(default: NSTextAlignment) -> NSTextAlignment {
		(applyer() as TextAlignmentApplyer?)?.value ?? `default`
	}
	
	/// UIControl.contentVerticalAlignment
	@discardableResult
	public func verticalAlignment(_ v: UIControl.ContentVerticalAlignment) -> Self {
		set(VerticalAlignmentApplyer(v))
	}
	
	public func getVerticalAlignment(default: UIControl.ContentVerticalAlignment) -> UIControl.ContentVerticalAlignment {
		(applyer() as VerticalAlignmentApplyer?)?.value ?? `default`
	}
	
	/// UICollectionView.UICollectionViewFlowLayout.itemSize
	@discardableResult
	public func itemSize(_ fn: @escaping (UITraitCollection)->CGSize) -> Self {
		set(ItemSizeApplyer(fn))
	}
	
	public func getItemSize(with trait: UITraitCollection, default: CGSize = .zero) -> CGSize {
		(applyer() as ItemSizeApplyer?)?.producer(trait) ?? `default`
	}
	
	/// UIView.layer.border | CALayer.border
	@discardableResult
	public func border(_ fn: @escaping (UITraitCollection)->StyleBorder) -> Self {
		set(BorderApplyer(fn))
	}
	
	public func getBorder(with trait: UITraitCollection, default: StyleBorder = .clear) -> StyleBorder {
		(applyer() as BorderApplyer?)?.producer(trait) ?? `default`
	}
	
	/// UIView.backgroundColor | CALayer.backgroundColor
	@discardableResult
	public func backgroundColor(_ fn: @escaping (UITraitCollection)->UIColor?) -> Self {
		set(ColorApplyer<BackgroundColorApplying>(fn))
	}
	
	public func getBackgroundColor(with trait: UITraitCollection, default: UIColor? = nil) -> UIColor? {
		(applyer() as ColorApplyer<BackgroundColorApplying>?)?.producer(trait) ?? `default`
	}
	
	/// UILabel.textColor | UITextField.textColor | UITextView.textColor
	@discardableResult
	public func textColor(_ fn: @escaping (UITraitCollection)->UIColor?) -> Self {
		set(ColorApplyer<TextColorApplying>(fn))
	}
	
	public func getTextColor(with trait: UITraitCollection, default: UIColor? = nil) -> UIColor? {
		(applyer() as ColorApplyer<TextColorApplying>?)?.producer(trait) ?? `default`
	}
	
	/// UIButton.setTitleColor
	@discardableResult
	public func buttonTitleColor(for states: Set<UIControl.State> = [.normal],
								 _ fn: @escaping (UIControl.State, UITraitCollection)->UIColor?) -> Self {
		set(StatefulTitleColorApplyer(for: states, fn))
	}
	
	public func getButtonTitleColor(state: UIControl.State, with trait: UITraitCollection, default: UIColor? = nil) -> UIColor? {
		(applyer() as StatefulTitleColorApplyer?)?.producer(state, trait) ?? `default`
	}
	
	/// UIView.tintColor | UIBarButtonItem.tintColor
	@discardableResult
	public func tintColor(_ fn: @escaping (UITraitCollection)->UIColor?) -> Self {
		set(ColorApplyer<TintColorApplying>(fn))
	}
	
	public func getTintColor(with trait: UITraitCollection, default: UIColor? = nil) -> UIColor? {
		(applyer() as ColorApplyer<TintColorApplying>?)?.producer(trait) ?? `default`
	}
	
	/// UIToolbar.barTintColor |
	/// UITabBar.barTintColor |
	/// UISearchBar.barTintColor |
	/// UINavigationBar.barTintColor
	@discardableResult
	public func barTintColor(_ fn: @escaping (UITraitCollection)->UIColor?) -> Self {
		set(ColorApplyer<BarTintColorApplying>(fn))
	}
	
	public func getBarTintColor(with trait: UITraitCollection, default: UIColor? = nil) -> UIColor? {
		(applyer() as ColorApplyer<BarTintColorApplying>?)?.producer(trait) ?? `default`
	}
	
	/// CAShapeLayer.fillColor
	@discardableResult
	public func fillColor(_ fn: @escaping (UITraitCollection)->UIColor?) -> Self {
		set(ColorApplyer<FillColorApplying>(fn))
	}
	
	public func getFillColor(with trait: UITraitCollection, default: UIColor? = nil) -> UIColor? {
		(applyer() as ColorApplyer<FillColorApplying>?)?.producer(trait) ?? `default`
	}
	
	/// CAShapeLayer.strokeColor
	@discardableResult
	public func strokeColor(_ fn: @escaping (UITraitCollection)->UIColor?) -> Self {
		set(ColorApplyer<StrokeColorApplying>(fn))
	}
	
	public func getStrokeColor(with trait: UITraitCollection, default: UIColor? = nil) -> UIColor? {
		(applyer() as ColorApplyer<StrokeColorApplying>?)?.producer(trait) ?? `default`
	}
	
	/// CAShapeLayer.lineDashPattern
	@discardableResult
	public func lineDashPattern(_ fn: @escaping (UITraitCollection)->[Double]) -> Self {
		set(LineDashPatternApplyer(fn))
	}
	
	public func getLineDashPattern(with trait: UITraitCollection, default: [Double] = []) -> [Double] {
		(applyer() as LineDashPatternApplyer?)?.producer(trait) ?? `default`
	}
	
	/// UILabel.font | UIButton.titleLabel?.font | UITextView.font
	@discardableResult
	public func font(_ fn: @escaping (UITraitCollection)->UIFont) -> Self {
		set(FontApplyer(fn))
	}
	
	public func getFont(with trait: UITraitCollection, default: UIFont = .systemFont(ofSize: 17)) -> UIFont {
		(applyer() as FontApplyer?)?.producer(trait) ?? `default`
	}
	
	/// UIButton.setBackgroundImage | UISearchBar.backgroundImage
	@discardableResult
	public func backgroundImage(_ fn: @escaping (UITraitCollection)->[UIControl.State: StyleImageSource]) -> Self {
		set(StatefulImageApplyer<BackgroundImageApplying>(fn))
	}
	
	public func getBackgroundImage(with trait: UITraitCollection, default: [UIControl.State: StyleImageSource] = [:]) -> [UIControl.State: StyleImageSource] {
		(applyer() as StatefulImageApplyer<BackgroundImageApplying>?)?.producer(trait) ?? `default`
	}
	
	@discardableResult
	public func image(_ fn: @escaping (UITraitCollection)->StyleImageSource) -> Self {
		set(StillImageApplyer(fn))
	}
	
	public func getImage(with trait: UITraitCollection, default: StyleImageSource = .empty) -> StyleImageSource {
		(applyer() as StillImageApplyer?)?.producer(trait) ?? `default`
	}
	
	/// CALayer.contents |
	/// UIImageView.image / .highlightedImage |
	/// UIButton.setImage for each state |
	/// UISlider.setThumbImage |
	/// UITabBarItem.selectedImage for highlighed |
	/// UIBarItem.image
	@discardableResult
	public func statefulImage(_ fn: @escaping (UITraitCollection)->[UIControl.State: StyleImageSource]) -> Self {
		set(StatefulImageApplyer<ImageApplying>(fn))
	}
	
	public func getStatefulImage(with trait: UITraitCollection, default: [UIControl.State: StyleImageSource] = [:]) -> [UIControl.State: StyleImageSource] {
		(applyer() as StatefulImageApplyer<ImageApplying>?)?.producer(trait) ?? `default`
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
	
	public func getAlpha(default: CGFloat = 1) -> CGFloat {
		(applyer() as NumberApplyer<AlphaApplying>?)?.value ?? `default`
	}
	
	/// UIView.layer.cornerRadius | CALayer.cornerRadius
	@discardableResult
	public func cornerRadius(_ fn: @escaping (UITraitCollection)->CGFloat) -> Self {
		set(TraitNumberApplyer<CornerRadiusApplying>(fn))
	}
	
	public func getCornerRadius(with trait: UITraitCollection, default: CGFloat = 0) -> CGFloat {
		(applyer() as TraitNumberApplyer<CornerRadiusApplying>?)?.producer(trait) ?? `default`
	}
	
	/// UILabel.numberOfLines |
	/// UITextView.textContainer.maximumNumberOfLines |
	/// UIButton.titleLabel?.numberOfLines
	@discardableResult
	public func numberOfLines(_ v: Int) -> Self {
		set(NumberApplyer<NumberOfLinesApplying>(CGFloat(v)))
	}
	
	public func getNumberOfLines(default: Int = 1) -> Int {
		((applyer() as NumberApplyer<NumberOfLinesApplying>?)?.value).map(Int.init) ?? `default`
	}
	
	/// UITextView.textContainer.lineFragmentPadding |
	/// UICollectionView.UICollectionViewFlowLayout.minimumLineSpacing
	@discardableResult
	public func lineSpacing(_ fn: @escaping (UITraitCollection)->CGFloat) -> Self {
		set(TraitNumberApplyer<LineSpacingApplying>(fn))
	}
	
	public func getLineSpacing(with trait: UITraitCollection, default: CGFloat = 0) -> CGFloat {
		(applyer() as TraitNumberApplyer<LineSpacingApplying>?)?.producer(trait) ?? `default`
	}
	
	/// CAShapeLayer.lineWIdth
	@discardableResult
	public func lineWidth(_ fn: @escaping (UITraitCollection)->CGFloat) -> Self {
		set(TraitNumberApplyer<LineWidthApplying>(fn))
	}
	
	public func getLineWidth(with trait: UITraitCollection, default: CGFloat = 0) -> CGFloat {
		(applyer() as TraitNumberApplyer<LineWidthApplying>?)?.producer(trait) ?? `default`
	}
	
	/// UICollectionView.UICollectionViewFlowLayout.minimumInteritemSpacing |
	/// UIStackView.spacing
	@discardableResult
	public func spacing(_ fn: @escaping (UITraitCollection)->CGFloat) -> Self {
		set(TraitNumberApplyer<SpacingApplying>(fn))
	}
	
	public func getSpacing(with trait: UITraitCollection, default: CGFloat = 0) -> CGFloat {
		(applyer() as TraitNumberApplyer<SpacingApplying>?)?.producer(trait) ?? `default`
	}
	
	/// UIView.layer.shadow | CALayer.shadow
	@discardableResult
	public func shadow(_ fn: @escaping (UITraitCollection)->StyleShadow) -> Self {
		set(ShadowApplyer(fn))
	}
	
	public func getShadow(with trait: UITraitCollection, default: StyleShadow = .init()) -> StyleShadow {
		(applyer() as ShadowApplyer?)?.producer(trait) ?? `default`
	}
	
	@discardableResult
	public func paragraphSpacing(_ v: UIEdgeInsets) -> Self {
		set(ParagraphSpacingApplyer(v))
	}
	
	public func getParagraphSpacing(default: UIEdgeInsets = .zero) -> UIEdgeInsets {
		(applyer() as ParagraphSpacingApplyer?)?.value ?? `default`
	}
	
	/// UIButton.contentEdgeInsets |
	/// UITextView.textContainerInset |
	/// UICollectionView.UICollectionViewFlowLayout.sectionInset
	@discardableResult
	public func padding(_ fn: @escaping (UITraitCollection)->UIEdgeInsets) -> Self {
		set(PaddingApplyer(fn))
	}
	
	public func getPadding(with trait: UITraitCollection, default: UIEdgeInsets = .zero) -> UIEdgeInsets {
		(applyer() as PaddingApplyer?)?.producer(trait) ?? `default`
	}
	
	/// UIButton.titleEdgeInsets
	@discardableResult
	public func titlePadding(_ fn: @escaping (UITraitCollection)->UIEdgeInsets) -> Self {
		set(TitlePaddingApplyer(fn))
	}
	
	public func getTitlePadding(with trait: UITraitCollection, default: UIEdgeInsets = .zero) -> UIEdgeInsets {
		(applyer() as TitlePaddingApplyer?)?.producer(trait) ?? `default`
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
		"vertical-align": VerticalAlignmentApplyer.self,
		
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
		
		"paragraph-spacing": ParagraphSpacingApplyer.self,
		"padding": PaddingApplyer.self,
		"title-padding": TitlePaddingApplyer.self,
	]
	
	public static func registerApplyer(name: String, _ type: StyleApplyer.Type) {
		applyerTypes[name] = type
	}
}
#endif
