//
//  CardPresentationController.swift
//  RGB Controller
//
//  Found this from: https://stackoverflow.com/questions/43530231/is-there-a-public-api-for-card-view-ui-that-can-be-seen-across-ios-10
//
//  Created by Erik Nordlund on 6/11/18.
//  Copyright © 2018 Erik Nordlund. All rights reserved.
//
//

import UIKit

let newVehicleViewY: CGFloat = 40
let statusBarHeight: CGFloat = 40

class CardPresentationController: UIPresentationController {
	lazy var dimmingView :UIView = {
		let view = UIView(frame: self.containerView!.bounds)
		view.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4)
		view.layer.cornerRadius = 0//14
		view.clipsToBounds = true
		return view
	}()
	
	override func presentationTransitionWillBegin() {
		
		guard
			let containerView = containerView,
			let presentedView = presentedView
			else {
				return
		}
		
		// Add the dimming view and the presented view to the heirarchy
		dimmingView.frame = containerView.bounds
		containerView.addSubview(dimmingView)
		containerView.addSubview(presentedView)
		
		// Fade in the dimming view alongside the transition
		if let transitionCoordinator = self.presentingViewController.transitionCoordinator {
			transitionCoordinator.animate(alongsideTransition: {(context: UIViewControllerTransitionCoordinatorContext!) -> Void in
				self.dimmingView.alpha = 1.0
			}, completion:nil)
		}
	}
	
	override func presentationTransitionDidEnd(_ completed: Bool)  {
		// If the presentation didn't complete, remove the dimming view
		if !completed {
			self.dimmingView.removeFromSuperview()
		}
	}
	
	override func dismissalTransitionWillBegin()  {
		// Fade out the dimming view alongside the transition
		if let transitionCoordinator = self.presentingViewController.transitionCoordinator {
			transitionCoordinator.animate(alongsideTransition: {(context: UIViewControllerTransitionCoordinatorContext!) -> Void in
				self.dimmingView.alpha  = 0.0
			}, completion:nil)
		}
	}
	
	override func dismissalTransitionDidEnd(_ completed: Bool) {
		// If the dismissal completed, remove the dimming view
		if completed {
			self.dimmingView.removeFromSuperview()
		}
	}
	
	override var frameOfPresentedViewInContainerView : CGRect {
		
		// We don't want the presented view to fill the whole container view, so inset it's frame
		let frame = self.containerView!.bounds;
		var presentedViewFrame = CGRect.zero
		presentedViewFrame.size = CGSize(width: frame.size.width, height: frame.size.height - statusBarHeight)
		presentedViewFrame.origin = CGPoint(x: 0, y: statusBarHeight)
		
		return presentedViewFrame
	}
	
	override func viewWillTransition(to size: CGSize, with transitionCoordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: transitionCoordinator)
		
		guard
			let containerView = containerView
			else {
				return
		}
		
		transitionCoordinator.animate(alongsideTransition: {(context: UIViewControllerTransitionCoordinatorContext!) -> Void in
			self.dimmingView.frame = containerView.bounds
		}, completion:nil)
	}
}
