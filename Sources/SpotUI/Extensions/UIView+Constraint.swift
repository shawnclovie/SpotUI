//
//  View+Constraint.swift
//  SpotUI
//
//  Created by Shawn Clovie on 6/21/16.
//  Copyright © 2016 Shawn Clovie. All rights reserved.
//

#if canImport(UIKit)
import UIKit
import Spot

/// Constraint builder
public struct Constraint {
	let view: UIView
	let item: Any
	let attribute: NSLayoutConstraint.Attribute
	let relation: NSLayoutConstraint.Relation
	
	public init(_ view: UIView,
	            _ attribute: NSLayoutConstraint.Attribute = .notAnAttribute,
	            _ by: NSLayoutConstraint.Relation = .equal) {
		self.init(view, item: view, attribute, by)
	}
	
	public init(_ view: UIView,
	            item: Any,
	            _ attribute: NSLayoutConstraint.Attribute = .notAnAttribute,
	            _ by: NSLayoutConstraint.Relation = .equal) {
		self.view = view
		self.item = item
		self.attribute = attribute
		relation = by
	}
	
	/// Create another constraint builder.
	public func constraint(_ attribute: NSLayoutConstraint.Attribute,
	                       _ by: NSLayoutConstraint.Relation = .equal) -> Constraint {
		Constraint(view, item: item, attribute, by)
	}
	
	@discardableResult
	public func with(_ to: Any? = nil,
	                 _ toAttr: NSLayoutConstraint.Attribute = .notAnAttribute,
	                 multiplier: CGFloat = 1,
	                 constant: CGFloat = 0,
	                 priority: UILayoutPriority = .required) -> NSLayoutConstraint {
		(item as? UIView)?.translatesAutoresizingMaskIntoConstraints = false
		let cons = NSLayoutConstraint(item: item,
		                              attribute: attribute,
		                              relatedBy: relation,
		                              toItem: to,
		                              attribute: toAttr,
		                              multiplier: multiplier,
		                              constant: constant)
		cons.priority = priority
		view.addConstraint(cons)
		return cons
	}
}

extension Suffix where Base: UIView {
	/// Create constraint builder with self.
	/// - parameter attribute: LayoutAttribute
	/// - parameter by:        LayoutRelation, default is equal.
	/// - returns: Constraint builder
	public func constraint(_ attribute: NSLayoutConstraint.Attribute,
	                       _ by: NSLayoutConstraint.Relation = .equal) -> Constraint {
		Constraint(base, item: base, attribute, by)
	}
	
	/// Create constraint builder with the view.
	/// - parameter view:      The view
	/// - parameter attribute: LayoutAttribute
	/// - parameter by:        LayoutRelation, default is equal.
	/// - returns: Constraint builder	*/
	public func constraint(_ view: UIView?,
	                       _ attribute: NSLayoutConstraint.Attribute,
	                       _ by: NSLayoutConstraint.Relation = .equal) -> Constraint {
		Constraint(base, item: view ?? base, attribute, by)
	}
	
	/// Add constraints to the view with some attributes.
	///
	/// - Parameters:
	///   - view: The view
	///   - attributes: LayoutAttributes to constraint, default is [left, top, right, bottom].
	///   - by: Layout relation, default is equal.
	///   - multiplier: Multiplier, default is 1.
	///   - constant: Constant, default is 0.
	///   - priority: LayoutPriority, default is Required.
	/// - Returns: All added constraints.
	@discardableResult
	public func constraints(_ view: UIView,
	                        attributes: [NSLayoutConstraint.Attribute] = [.left, .top, .right, .bottom],
	                        _ by: NSLayoutConstraint.Relation = .equal,
	                        multiplier: CGFloat = 1,
	                        constant: CGFloat = 0,
	                        priority: UILayoutPriority = .required) -> [NSLayoutConstraint] {
		var cons = [NSLayoutConstraint]()
		for attr in attributes {
			let con = Constraint(base, item: view, attr, by)
			cons.append(con.with(base, attr, multiplier: multiplier, constant: constant, priority: priority))
		}
		return cons
	}

	/// Add constraints with VFL
	/// - parameter format:  VirtualFormat
	/// - parameter options: LayoutFormatOptions
	/// - parameter metrics: Metrics
	/// - parameter views:   Views
	/// - returns: All added constraints.
	@discardableResult
	public func constraints(vfl: String,
	                        options: NSLayoutConstraint.FormatOptions = [],
	                        metrics: [String : Any]? = nil,
	                        views: [String : Any]) -> [NSLayoutConstraint] {
		let cs = NSLayoutConstraint.constraints(withVisualFormat: vfl, options: options, metrics: metrics, views: views)
		base.translatesAutoresizingMaskIntoConstraints = false
		base.addConstraints(cs)
		return cs
	}
}

extension Array where Element: NSLayoutConstraint {
	
	/// Activate or deactivate constraints
	///
	/// It would set firstItem.translatesAutoresizingMaskIntoConstraints to false for all constants.
	public func spot_set(active: Bool) {
		for con in self {
			(con.firstItem as? UIView)?.translatesAutoresizingMaskIntoConstraints = false
		}
		if active {
			NSLayoutConstraint.activate(self)
		} else {
			NSLayoutConstraint.deactivate(self)
		}
	}
}

extension Suffix where Base: NSLayoutConstraint {
	@discardableResult
	public func setActived(_ v: Bool = true) -> NSLayoutConstraint {
		base.isActive = v
		return base
	}
}
#endif
