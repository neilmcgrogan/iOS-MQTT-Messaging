//
//  MQTTAppState.swift
//  MQTT Messaging
//
//  Created by Neil McGrogan on 1/2/22.
//

import Combine
import Foundation

// States of connection between app and broker
enum MQTTAppConnectionState {
    case connected
    case disconnected
    case connecting
    case connectedSubscribed
    case connectedUnSubscribed

    var description: String {
        switch self {
        case .connected:
            return "CONNECTED"
        case .disconnected:
            return "DISCONNECTED"
        case .connecting:
            return "CONNECTING"
        case .connectedSubscribed:
            return "SUBSCRIBED"
        case .connectedUnSubscribed:
            return "CONNECTED UNSUBSCRIBED"
        }
    }
    
    var isConnected: Bool {
        switch self {
        case .connected, .connectedSubscribed, .connectedUnSubscribed:
            return true
        case .disconnected,.connecting:
            return false
        }
    }
    
    var isSubscribed: Bool {
        switch self {
        case .connectedSubscribed:
            return true
        case .disconnected,.connecting, .connected,.connectedUnSubscribed:
            return false
        }
    }
}

final class MQTTAppState: ObservableObject {
    @Published var appConnectionState: MQTTAppConnectionState = .disconnected
    @Published var historyText: String = ""
    private var receivedMessage: String = ""
    
    @Published var historyArray: [String] = [""]

    func setReceivedMessage(text: String) {
        receivedMessage = text
        historyText = historyText + "\n" + receivedMessage
        historyArray.append(receivedMessage)
    }

    func clearData() {
        receivedMessage = ""
        historyText = ""
    }

    func setAppConnectionState(state: MQTTAppConnectionState) {
        appConnectionState = state
    }
}
