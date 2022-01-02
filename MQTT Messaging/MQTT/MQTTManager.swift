//
//  MQTTManager.swift
//  MQTT Messaging
//
//  Created by Neil McGrogan on 1/2/22.
//

import Foundation
import CocoaMQTT
import Combine

// handles calls to subscribe to topics
final class MQTTManager: ObservableObject {
    private var mqttClient: CocoaMQTT?
    private var identifier: String!
    private var host: String!
    private var topic: String!
    private var username: String!
    private var password: String!
    
    // rewritten declarations
    let brokerAddress = "192.168.0.144"
    let LOCK_A_STATUS = "topic/status/a"
    let LOCK_B_STATUS = "topic/status/b"
    let LOCK_A_COMMAND = "topic/command/a"
    let LOCK_B_COMMAND = "topic/command/b"
    
    let COMMAND_1 = "command_1"
    let COMMAND_2 = "command_2"
    let COMMAND_3 = "command_3"
    
    
    @Published var currentAppState = MQTTAppState()
    private var anyCancellable: AnyCancellable?
    // Private Init
    private init() {
        // Workaround to support nested Observables, without this code changes to state is not propagated
        anyCancellable = currentAppState.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
    }

    // MARK: Shared Instance

    private static let _shared = MQTTManager()

    // MARK: - Accessors

    class func shared() -> MQTTManager {
        return _shared
    }

    func initializeMQTT(host: String, identifier: String, username: String? = nil, password: String? = nil) {
        // If any previous instance exists then clean it
        if mqttClient != nil {
            mqttClient = nil
        }
        self.identifier = identifier
        self.host = host
        self.username = username
        self.password = password
        let clientID = "CocoaMQTT-\(identifier)-" + String(ProcessInfo().processIdentifier)

        // TODO: Guard
        mqttClient = CocoaMQTT(clientID: clientID, host: host, port: 1883)
        // If a server has username and password, pass it here
        if let finalusername = self.username, let finalpassword = self.password {
            mqttClient?.username = finalusername
            mqttClient?.password = finalpassword
        }
        //mqttClient?.willMessage = CocoaMQTTWill(topic: "/will", message: "dieout")
        mqttClient?.keepAlive = 60
        mqttClient?.delegate = self
    }

    func connect() {
        if let success = mqttClient?.connect(), success {
            currentAppState.setAppConnectionState(state: .connecting)
        } else {
            currentAppState.setAppConnectionState(state: .disconnected)
        }
    }

    func subscribe(topic: String) {
        self.topic = topic
        mqttClient?.subscribe(topic, qos: .qos1)
        
        self.sendInit(message: self.COMMAND_1, localTopic: self.LOCK_A_COMMAND)
        self.sendInit(message: self.COMMAND_1, localTopic: self.LOCK_B_COMMAND)
    }

    func publish(with message: String, localTopic: String) {
        mqttClient?.publish(localTopic, withString: message, qos: .qos1)
    }

    func disconnect() {
        mqttClient?.disconnect()
    }

    /// Unsubscribe from a topic
    func unSubscribe(topic: String) {
        mqttClient?.unsubscribe(topic)
    }

    /// Unsubscribe from a topic
    func unSubscribeFromCurrentTopic() {
        mqttClient?.unsubscribe(topic)
    }
    
    func currentHost() -> String? {
        return host
    }
    
    func isSubscribed() -> Bool {
       return currentAppState.appConnectionState.isSubscribed
    }
    
    func isConnected() -> Bool {
        return currentAppState.appConnectionState.isConnected
    }
    
    func connectionStateMessage() -> String {
        return currentAppState.appConnectionState.description
    }
    
    // rewritten functions
    func configureAndConnect(state: MQTTAppConnectionState) {
        self.initializeMQTT(host: self.brokerAddress, identifier: UUID().uuidString)
        self.connect()
        
        let seconds = 5.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            // Put your code which should be executed with a delay here
            switch state {
            case .connected, .connectedUnSubscribed, .disconnected, .connecting:
                self.subscribe(topic: self.LOCK_B_STATUS)
                self.subscribe(topic: self.LOCK_A_STATUS)
            case .connectedSubscribed:
                self.subscribe(topic: self.LOCK_B_STATUS)
                self.subscribe(topic: self.LOCK_A_STATUS)
            }
        }
    }
    
    func sendInit(message: String, localTopic: String) {
        let finalMessage = message
        self.publish(with: finalMessage, localTopic: localTopic)
    }
    
    func unlock(finalMessage: String, localTopic: String) {
        self.publish(with: finalMessage, localTopic: localTopic)
    }
    
    // For sending actuation & status
    func send(message: String, localTopic: String) {
        let finalMessage = message
        self.publish(with: finalMessage, localTopic: localTopic)
    }
}

extension MQTTManager: CocoaMQTTDelegate {
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {
        //
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {
        //
    }

    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        TRACE("ack: \(ack)")

        if ack == .accept {
            currentAppState.setAppConnectionState(state: .connected)
        }
    }

    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        TRACE("topic: \(message.topic), message: \(message.string.description), id: \(id)")
    }

    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        TRACE("id: \(id)")
    }

    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        TRACE("topic: \(String(topic)) message: \(message.string.description), id: \(id)")
        currentAppState.setReceivedMessage(text: message.string.description)
    }

    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
        TRACE("topic: \(topic)")
        currentAppState.setAppConnectionState(state: .connectedUnSubscribed)
        currentAppState.clearData()
    }

    func mqttDidPing(_ mqtt: CocoaMQTT) {
        TRACE("pinged: \(mqtt)")
    }

    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        TRACE()
    }

    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        TRACE("\(err.description)")
        currentAppState.setAppConnectionState(state: .disconnected)
    }
}

// Final message that is sent
extension MQTTManager {
    func TRACE(_ message: String = "", fun: String = #function) {

        if fun == "mqttDidDisconnect(_:withError:)" {
            print("didDisconect")
        }
        
        print("[SEND] \(message)")
    }
}

extension Optional {
    // Unwrap optional value for printing log only
    var description: String {
        if let wraped = self {
            return "\(wraped)"
        }
        return ""
    }
}
