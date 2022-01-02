//
//  extension.swift
//  MQTT Messaging
//
//  Created by Neil McGrogan on 1/2/22.
//

import SwiftUI

// Color palate
extension Color {
    static var textColor = Color(red: 0/255, green: 59/255, blue: 92/255)
}

struct ColorView: View {
    var body: some View {
        VStack {
            Color.textColor
            
        }
    }
}

struct ColorView_Previews: PreviewProvider {
    static var previews: some View {
        ColorView()
    }
}
