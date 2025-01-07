//
//  FindmeWidgetBundle.swift
//  FindmeWidget
//
//  Created by Евгений Полтавец on 12/12/2024.
//

import WidgetKit
import SwiftUI

@main
struct FindmeWidgetBundle: WidgetBundle {
    var body: some Widget {
        FindmeWidget()
        FindmeWidgetLiveActivity()
    }
}
