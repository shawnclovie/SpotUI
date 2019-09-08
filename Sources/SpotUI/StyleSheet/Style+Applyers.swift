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
	
	// MARK: - Bool
	
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
	
	// MARK: - ContentMode & Axis & LineBreakMode
	
	/// UIButton.imageView?.contentMode |
	/// UIView.contentMode
	@discardableResult
	public func contentMode(_ v: UIView.ContentMode) -> Self {
		set(ContentModeApplyer(v))
	}
	
	/// Default: scaleToFill
	public func getContentMode(default: UIView.ContentMode = .scaleToFill) -> UIView.ContentMode {
		optContentMode ?? `default`
	}
	
	public var optContentMode: UIView.ContentMode? {
		(applyer() as ContentModeApplyer?)?.value
	}
	
	/// UIStackView.axis |
	/// UICollectionView.UICollectionViewFlowLayout.scrollDirection
	@discardableResult
	public func axis(_ v: NSLayoutConstraint.Axis) -> Self {
		set(LayoutConstraintAxisApplyer(v))
	}
	
	public var optAxis: NSLayoutConstraint.Axis? {
		(applyer() as LayoutConstraintAxisApplyer?)?.value
	}
	
	/// UILabel.lineBreakMode |
	/// UITextView.textContainer.lineBreakMode |
	/// UIButton.titleLabel?.lineBreakMode
	@discardableResult
	public func lineBreakMode(_ v: NSLineBreakMode) -> Self {
		set(LineBreakModeApplyer(v))
	}
	
	public var optLineBreakMode: NSLineBreakMode? {
		(applyer() as LineBreakModeApplyer?)?.value
	}
	
	// MARK: - Alignment
	
	/// UILabel.textAlignment | UITextView.textAlignment |
	/// UITextField.textAlignment | UIButton.titleLabel?.textAlignment
	@discardableResult
	public func textAlignment(_ v: NSTextAlignment) -> Self {
		set(TextAlignmentApplyer(v))
	}
	
	public var optTextAlignment: NSTextAlignment? {
		(applyer() as TextAlignmentApplyer?)?.value
	}
	
	/// UIControl.contentVerticalAlignment
	@discardableResult
	public func verticalAlignment(_ v: UIControl.ContentVerticalAlignment) -> Self {
		set(VerticalAlignmentApplyer(v))
	}
	
	public var optVerticalAlignment: UIControl.ContentVerticalAlignment? {
		(applyer() as VerticalAlignmentApplyer?)?.value
	}
	
	@discardableResult
	public func stackAlignment(_ v: UIStackView.Alignment) -> Self {
		set(StackAlignmentApplyer(v))
	}
	
	public var optStackAlignment: UIStackView.Alignment? {
		(applyer() as StackAlignmentApplyer?)?.value
	}
	
	@discardableResult
	public func stackDistribution(_ v: UIStackView.Distribution) -> Self {
		set(StackDistributionApplyer(v))
	}
	
	public var optStackDistribution: UIStackView.Distribution? {
		(applyer() as StackDistributionApplyer?)?.value
	}
	
	// MARK: - Size
	
	/// UICollectionView.UICollectionViewFlowLayout.itemSize
	@discardableResult
	public func itemSize(_ fn: @escaping (UITraitCollection)->CGSize) -> Self {
		set(ItemSizeApplyer(fn))
	}
	
	/// Default: zero
	public func getItemSize(with trait: UITraitCollection, default: CGSize = .zero) -> CGSize {
		optItemSize(with: trait) ?? `default`
	}
	
	public func optItemSize(with trait: UITraitCollection) -> CGSize? {
		(applyer() as ItemSizeApplyer?)?.producer(trait)
	}
	
	// MARK: - Border
	
	/// UIView.layer.border | CALayer.border
	@discardableResult
	public func border(_ fn: @escaping (UITraitCollection)->StyleBorder) -> Self {
		set(BorderApplyer(fn))
	}
	
	/// Default: clear
	public func getBorder(with trait: UITraitCollection, default: StyleBorder = .clear) -> StyleBorder {
		optBorder(with: trait) ?? `default`
	}
	
	public func optBorder(with trait: UITraitCollection) -> StyleBorder? {
		(applyer() as BorderApplyer?)?.producer(trait)
	}
	
	// MARK: - Color
	
	/// UIView.backgroundColor | CALayer.backgroundColor
	@discardableResult
	public func backgroundColor(_ fn: @escaping (UITraitCollection)->UIColor?) -> Self {
		set(ColorApplyer<BackgroundColorApplying>(fn))
	}
	
	/// Default: clear
	public func getBackgroundColor(with trait: UITraitCollection, default: UIColor = .clear) -> UIColor {
		optBackgroundColor(with: trait) ?? `default`
	}
	
	public func optBackgroundColor(with trait: UITraitCollection) -> UIColor? {
		(applyer() as ColorApplyer<BackgroundColorApplying>?)?.producer(trait)
	}
	
	/// UILabel.textColor | UITextField.textColor | UITextView.textColor
	@discardableResult
	public func textColor(_ fn: @escaping (UITraitCollection)->UIColor?) -> Self {
		set(ColorApplyer<TextColorApplying>(fn))
	}
	
	/// Default: clear
	public func getTextColor(with trait: UITraitCollection, default: UIColor = .clear) -> UIColor {
		optTextColor(with: trait) ?? `default`
	}
	
	public func optTextColor(with trait: UITraitCollection) -> UIColor? {
		(applyer() as ColorApplyer<TextColorApplying>?)?.producer(trait)
	}
	
	/// UIButton.setTitleColor
	@discardableResult
	public func buttonTitleColor(for states: Set<UIControl.State> = [.normal],
								 _ fn: @escaping (UIControl.State, UITraitCollection)->UIColor?) -> Self {
		set(StatefulTitleColorApplyer(for: states, fn))
	}
	
	/// Default: clear
	public func getButtonTitleColor(state: UIControl.State, with trait: UITraitCollection, default: UIColor = .clear) -> UIColor {
		optButtonTitleColor(state: state, with: trait) ?? `default`
	}
	
	public func optButtonTitleColor(state: UIControl.State, with trait: UITraitCollection) -> UIColor? {
		(applyer() as StatefulTitleColorApplyer?)?.producer(state, trait)
	}
	
	/// UIView.tintColor | UIBarButtonItem.tintColor
	@discardableResult
	public func tintColor(_ fn: @escaping (UITraitCollection)->UIColor?) -> Self {
		set(ColorApplyer<TintColorApplying>(fn))
	}
	
	/// Default: clear
	public func getTintColor(with trait: UITraitCollection, default: UIColor = .clear) -> UIColor {
		optTintColor(with: trait) ?? `default`
	}
	
	public func optTintColor(with trait: UITraitCollection) -> UIColor? {
		(applyer() as ColorApplyer<TintColorApplying>?)?.producer(trait)
	}
	
	/// UIToolbar.barTintColor |
	/// UITabBar.barTintColor |
	/// UISearchBar.barTintColor |
	/// UINavigationBar.barTintColor
	@discardableResult
	public func barTintColor(_ fn: @escaping (UITraitCollection)->UIColor?) -> Self {
		set(ColorApplyer<BarTintColorApplying>(fn))
	}
	
	/// Default: clear
	public func getBarTintColor(with trait: UITraitCollection, default: UIColor = .clear) -> UIColor {
		optBarTintColor(with: trait) ?? `default`
	}
	
	public func optBarTintColor(with trait: UITraitCollection) -> UIColor? {
		(applyer() as ColorApplyer<BarTintColorApplying>?)?.producer(trait)
	}
	
	/// CAShapeLayer.fillColor
	@discardableResult
	public func fillColor(_ fn: @escaping (UITraitCollection)->UIColor?) -> Self {
		set(ColorApplyer<FillColorApplying>(fn))
	}
	
	/// Default: clear
	public func getFillColor(with trait: UITraitCollection, default: UIColor = .clear) -> UIColor {
		optFillColor(with: trait) ?? `default`
	}
	
	public func optFillColor(with trait: UITraitCollection) -> UIColor? {
		(applyer() as ColorApplyer<FillColorApplying>?)?.producer(trait)
	}
	
	/// CAShapeLayer.strokeColor
	@discardableResult
	public func strokeColor(_ fn: @escaping (UITraitCollection)->UIColor?) -> Self {
		set(ColorApplyer<StrokeColorApplying>(fn))
	}
	
	/// Default: clear
	public func getStrokeColor(with trait: UITraitCollection, default: UIColor = .clear) -> UIColor {
		optStrokeColor(with: trait) ?? `default`
	}
	
	public func optStrokeColor(with trait: UITraitCollection) -> UIColor? {
		(applyer() as ColorApplyer<StrokeColorApplying>?)?.producer(trait)
	}
	
	// MARK: - [Double]
	
	/// CAShapeLayer.lineDashPattern
	@discardableResult
	public func lineDashPattern(_ fn: @escaping (UITraitCollection)->[Double]) -> Self {
		set(LineDashPatternApplyer(fn))
	}
	
	/// Default: []
	public func getLineDashPattern(with trait: UITraitCollection, default: [Double] = []) -> [Double] {
		optLineDashPattern(with: trait) ?? `default`
	}
	
	public func optLineDashPattern(with trait: UITraitCollection) -> [Double]? {
		(applyer() as LineDashPatternApplyer?)?.producer(trait)
	}
	
	// MARK: - Font
	
	/// UILabel.font | UIButton.titleLabel?.font | UITextView.font
	@discardableResult
	public func font(_ fn: @escaping (UITraitCollection)->UIFont) -> Self {
		set(FontApplyer(fn))
	}
	
	/// Default: systemFont(ofSize: 17)
	public func getFont(with trait: UITraitCollection, default: UIFont = .systemFont(ofSize: 17)) -> UIFont {
		optFont(with: trait) ?? `default`
	}
	
	public func optFont(with trait: UITraitCollection) -> UIFont? {
		(applyer() as FontApplyer?)?.producer(trait)
	}
	
	// MARK: - Image
	
	/// UIButton.setBackgroundImage | UISearchBar.backgroundImage
	@discardableResult
	public func backgroundImage(_ fn: @escaping (UITraitCollection)->[UIControl.State: StyleImageSource]) -> Self {
		set(StatefulImageApplyer<BackgroundImageApplying>(fn))
	}
	
	/// Default: [:]
	public func getBackgroundImage(with trait: UITraitCollection, default: [UIControl.State: StyleImageSource] = [:]) -> [UIControl.State: StyleImageSource] {
		optBackgroundImage(with: trait) ?? `default`
	}
	
	public func optBackgroundImage(with trait: UITraitCollection) -> [UIControl.State: StyleImageSource]? {
		(applyer() as StatefulImageApplyer<BackgroundImageApplying>?)?.producer(trait)
	}
	
	@discardableResult
	public func image(_ fn: @escaping (UITraitCollection)->StyleImageSource) -> Self {
		set(StillImageApplyer(fn))
	}
	
	/// Default: empty
	public func getImage(with trait: UITraitCollection, default: StyleImageSource = .empty) -> StyleImageSource {
		optImage(with: trait) ?? `default`
	}
	
	public func optImage(with trait: UITraitCollection) -> StyleImageSource? {
		(applyer() as StillImageApplyer?)?.producer(trait)
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
	
	/// Default: [:]
	public func getStatefulImage(with trait: UITraitCollection, default: [UIControl.State: StyleImageSource] = [:]) -> [UIControl.State: StyleImageSource] {
		optStatefulImage(with: trait) ?? `default`
	}
	
	public func optStatefulImage(with trait: UITraitCollection) -> [UIControl.State: StyleImageSource]? {
		(applyer() as StatefulImageApplyer<ImageApplying>?)?.producer(trait)
	}
	
	/// setMinimumTrackImage and setMaximumTrackImage of UISlider
	@discardableResult
	public func slideTrackImage(min: [UIControl.State: StyleImageSource], max: [UIControl.State: StyleImageSource]) -> Self {
		set(SlideTrackImageApplyer(min: min, max: max))
	}
	
	// MARK: - Number
	
	/// UIView.alpha | CALayer.opacity
	@discardableResult
	public func alpha(_ v: CGFloat) -> Self {
		set(NumberApplyer<AlphaApplying>(v))
	}
	
	/// Default: 1
	public func getAlpha(default: CGFloat = 1) -> CGFloat {
		optAlpha ?? `default`
	}
	
	public var optAlpha: CGFloat? {
		(applyer() as NumberApplyer<AlphaApplying>?)?.value
	}
	
	/// UIView.layer.cornerRadius | CALayer.cornerRadius
	@discardableResult
	public func cornerRadius(_ fn: @escaping (UITraitCollection)->CGFloat) -> Self {
		set(TraitNumberApplyer<CornerRadiusApplying>(fn))
	}
	
	/// Default: 0
	public func getCornerRadius(with trait: UITraitCollection, default: CGFloat = 0) -> CGFloat {
		optCornerRadius(with: trait) ?? `default`
	}
	
	public func optCornerRadius(with trait: UITraitCollection) -> CGFloat? {
		(applyer() as TraitNumberApplyer<CornerRadiusApplying>?)?.producer(trait)
	}
	
	/// UILabel.numberOfLines |
	/// UITextView.textContainer.maximumNumberOfLines |
	/// UIButton.titleLabel?.numberOfLines
	@discardableResult
	public func numberOfLines(_ v: Int) -> Self {
		set(NumberApplyer<NumberOfLinesApplying>(CGFloat(v)))
	}
	
	/// Default: 1
	public func getNumberOfLines(default: Int = 1) -> Int {
		optNumberOfLines ?? `default`
	}
	
	public var optNumberOfLines: Int? {
		((applyer() as NumberApplyer<NumberOfLinesApplying>?)?.value).map(Int.init)
	}
	
	/// UITextView.textContainer.lineFragmentPadding |
	/// UICollectionView.UICollectionViewFlowLayout.minimumLineSpacing
	@discardableResult
	public func lineSpacing(_ fn: @escaping (UITraitCollection)->CGFloat) -> Self {
		set(TraitNumberApplyer<LineSpacingApplying>(fn))
	}
	
	/// Default: 0
	public func getLineSpacing(with trait: UITraitCollection, default: CGFloat = 0) -> CGFloat {
		optLineSpacing(with: trait) ?? `default`
	}
	
	public func optLineSpacing(with trait: UITraitCollection) -> CGFloat? {
		(applyer() as TraitNumberApplyer<LineSpacingApplying>?)?.producer(trait)
	}
	
	/// CAShapeLayer.lineWIdth
	@discardableResult
	public func lineWidth(_ fn: @escaping (UITraitCollection)->CGFloat) -> Self {
		set(TraitNumberApplyer<LineWidthApplying>(fn))
	}
	
	/// Default: 0
	public func getLineWidth(with trait: UITraitCollection, default: CGFloat = 0) -> CGFloat {
		optLineWidth(with: trait) ?? `default`
	}
	
	public func optLineWidth(with trait: UITraitCollection) -> CGFloat? {
		(applyer() as TraitNumberApplyer<LineWidthApplying>?)?.producer(trait)
	}
	
	/// UICollectionView.UICollectionViewFlowLayout.minimumInteritemSpacing |
	/// UIStackView.spacing
	@discardableResult
	public func spacing(_ fn: @escaping (UITraitCollection)->CGFloat) -> Self {
		set(TraitNumberApplyer<SpacingApplying>(fn))
	}
	
	/// Default: 0
	public func getSpacing(with trait: UITraitCollection, default: CGFloat = 0) -> CGFloat {
		optSpacing(with: trait) ?? `default`
	}
	
	public func optSpacing(with trait: UITraitCollection) -> CGFloat? {
		(applyer() as TraitNumberApplyer<SpacingApplying>?)?.producer(trait)
	}
	
	// MARK: - Shadow
	
	/// UIView.layer.shadow | CALayer.shadow
	@discardableResult
	public func shadow(_ fn: @escaping (UITraitCollection)->StyleShadow) -> Self {
		set(ShadowApplyer(fn))
	}
	
	/// Default: no border - .init()
	public func getShadow(with trait: UITraitCollection, default: StyleShadow = .init()) -> StyleShadow {
		optShadow(with: trait) ?? `default`
	}
	
	public func optShadow(with trait: UITraitCollection) -> StyleShadow? {
		(applyer() as ShadowApplyer?)?.producer(trait)
	}
	
	// MARK: - EdgeInsets
	
	@discardableResult
	public func paragraphSpacing(_ v: UIEdgeInsets) -> Self {
		set(ParagraphSpacingApplyer(v))
	}
	
	/// Default: zero
	public func getParagraphSpacing(default: UIEdgeInsets = .zero) -> UIEdgeInsets {
		optParagraphSpacing ?? `default`
	}
	
	public var optParagraphSpacing: UIEdgeInsets? {
		(applyer() as ParagraphSpacingApplyer?)?.value
	}
	
	/// UIButton.contentEdgeInsets |
	/// UITextView.textContainerInset |
	/// UICollectionView.UICollectionViewFlowLayout.sectionInset
	@discardableResult
	public func padding(_ fn: @escaping (UITraitCollection)->UIEdgeInsets) -> Self {
		set(PaddingApplyer(fn))
	}
	
	/// Default: zero
	public func getPadding(with trait: UITraitCollection, default: UIEdgeInsets = .zero) -> UIEdgeInsets {
		optPadding(with: trait) ?? `default`
	}
	
	public func optPadding(with trait: UITraitCollection) -> UIEdgeInsets? {
		(applyer() as PaddingApplyer?)?.producer(trait)
	}
	
	/// UIButton.titleEdgeInsets
	@discardableResult
	public func titlePadding(_ fn: @escaping (UITraitCollection)->UIEdgeInsets) -> Self {
		set(TitlePaddingApplyer(fn))
	}
	
	/// Default: zero
	public func getTitlePadding(with trait: UITraitCollection, default: UIEdgeInsets = .zero) -> UIEdgeInsets {
		optTitlePadding(with: trait) ?? `default`
	}
	
	public func optTitlePadding(with trait: UITraitCollection) -> UIEdgeInsets? {
		(applyer() as TitlePaddingApplyer?)?.producer(trait)
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
