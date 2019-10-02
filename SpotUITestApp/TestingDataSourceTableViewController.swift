//
//  TestingDataSourceTableViewController.swift
//  SpotUITestApp
//
//  Created by Shawn Clovie on 2/10/2019.
//  Copyright © 2019 Shawn Clovie. All rights reserved.
//

import Foundation
import UIKit
import SpotUI

final class TestingDataSourceTableViewController: DataSourceTableViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		dataSource.sections = [
			DataSourceSection("Section A", items: [
				DataSourceCell(
					title: .init(string: "Cell A", attributes: [.font: UIFont.systemFont(ofSize: 40)]),
					subtitle: .init(string: "Description A", attributes: [.font: UIFont.systemFont(ofSize: 10)]),
					mark: "cell_a"),
				.init(brimming: UIImageView(image: UIImage(named: "images/Cat-party.gif"))),
				DataSourceCell(title: "Cell B", mark: "cell_b")
				], mark: "section_a"),
			DataSourceSection("", items: [
				DataSourceCell(title: "Cell 2A"),
				]),
		]
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		if let mark = dataSource.cell(at: indexPath)?.mark as? String {
			print(mark)
		}
	}
}
