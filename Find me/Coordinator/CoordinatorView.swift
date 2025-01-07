//
//  CoordinatorView.swift
//  Find me
//
//  Created by Евгений Полтавец on 13/12/2024.
//

import SwiftUI


struct CoordinatorView: View {
    
    @StateObject private var coordinator = Coordinator()
    @StateObject private var viewModel = FindMeViewModel()
    @StateObject private var viewModelRecords = AudioRecorderViewModel()
   
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            coordinator.Adminbuild(page: .auth)
                .navigationDestination(for: PageView.self) { page in
                    coordinator.Adminbuild(page: page)
                }
        }
        .environmentObject(coordinator)
        .environmentObject(viewModel)
        .environmentObject(viewModelRecords)
    }
}
