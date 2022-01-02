//
//  HomeView.swift
//  MQTT Messaging
//
//  Created by Neil McGrogan on 1/2/22.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewRouter: ViewRouter
    
    var body: some View {
        VStack {
            Text("MQTT client")
        }
    }
}

struct ViewController_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .previewDevice("iPhone Xs Max")
    }
}
