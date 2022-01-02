//
//  ConnectionStatusBar.swift
//  MQTT Messaging
//
//  Created by Neil McGrogan on 1/2/22.
//

import SwiftUI

// Shows status of connection to the broker
struct ConnectionStatusBar: View {
    var message: String
    var isConnected: Bool
    
    var body: some View {
        HStack {
            Text(message)
                .font(.footnote)
        }.foregroundColor(isConnected ? Color.green : Color.red)
        
    }
}

struct ConnectionStatusBar_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionStatusBar(message: "Hello", isConnected: true)
    }
}
