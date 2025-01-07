//
//  AppIntent.swift
//  FindmeWidget
//
//  Created by Евгений Полтавец on 12/12/2024.
//

import WidgetKit
import AppIntents
import SwiftUI

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    
    static var title: LocalizedStringResource = "Configuration"
    static var description = IntentDescription("This is an example widget.")

    var isButtonPressed: Bool = false
    
    func perform() async throws -> some IntentResult {
       
        let sharedDefaults = UserDefaults(suiteName: "group.findme.com")
        
        let currentState = sharedDefaults?.bool(forKey: "isButtonPressed") ?? false
        sharedDefaults?.set(!currentState, forKey: "isButtonPressed")
 
        print("Кнопка нажата: \(!currentState)")
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}
