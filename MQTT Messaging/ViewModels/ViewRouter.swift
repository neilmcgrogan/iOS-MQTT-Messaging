//
//  ViewRouter.swift
//  MQTT Messaging
//
//  Created by Neil McGrogan on 1/2/22.
//

import SwiftUI

// class that holds the status of what the current page is
class ViewRouter: ObservableObject {
    @Published var currentPage: Page = .home
}
