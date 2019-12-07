//
//  ContentView.swift
//  SpotUITestAppForSwiftUI
//
//  Created by Shawn Clovie on 6/12/2019.
//  Copyright © 2019 Shawn Clovie. All rights reserved.
//

import SwiftUI
import Spot
import SpotUI

struct ContentView: View {
	
	@State var image: AnimatableImage?
	
	var testItems: [TestItem] = [
		.init(name: "image still", action: { view in
			let path = Bundle.main.url(forResource: "images/186_52c0eca125447.jpg", withExtension: nil)!
			print("loading image from \(path)")
			view.image = AnimatableImage(.path(path))!
		}),
		.init(name: "image gif", action: { (view) in
			let path = Bundle.main.url(forResource: "images/Cat-party.gif", withExtension: nil)!
			print("loading image from \(path)")
			view.image = AnimatableImage(.path(path))!
		}),
	]
	
    var body: some View {
		NavigationView {
			VStack{
				Text(deviceTextContent)
					.frame(height: 120)
				HStack{
					List(testItems, id: \.name) { it in
						TestItemRow(item: it)
							.gesture(TapGesture().onEnded { _ in
								it.action(self)
							})
					}
						.frame(width: 150)
					AnimatableImageWrapView(animatableImage: $image)
						.gesture(TapGesture().onEnded { _ in
							self.image = nil
						})
				}
			}
				.navigationBarTitle(Text("Simple Test"))
//				.navigationBarItems(trailing: Text("...")
//					.
//				)
		}
	}
}

private var deviceTextContent: String {
	"device\n" +
	"VendorUDID: \(UIDevice.current.identifierForVendor?.uuidString ?? "")\n" +
	"name: \(UIDevice.current.name)\n" +
	"model: \(UIDevice.current.model) - \(Version.deviceModelName)\n\n" +
	"locale: \(Locale.current.identifier)\n"
}

struct TestItem {
	let name: String
	let action: (ContentView)->Void
}

struct TestItemRow: View {
	var item: TestItem
	
	var body: some View {
		Text(item.name)
	}
}

struct AnimatableImageWrapView: UIViewRepresentable {
	typealias UIViewType = AnimatableImageView
	
	@Binding var animatableImage: AnimatableImage?
	
	func makeUIView(context: UIViewRepresentableContext<AnimatableImageWrapView>) -> AnimatableImageWrapView.UIViewType {
		let view = UIViewType()
		view.contentMode = .scaleAspectFit
		return view
	}
	
	func updateUIView(_ uiView: AnimatableImageWrapView.UIViewType, context: UIViewRepresentableContext<AnimatableImageWrapView>) {
		uiView.animatableImage = animatableImage
	}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
