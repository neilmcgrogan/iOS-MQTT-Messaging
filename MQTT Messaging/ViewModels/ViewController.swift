//
//  ViewController.swift
//  MQTT Messaging
//
//  Created by Neil McGrogan on 1/2/22.
//

import SwiftUI
import UserNotifications

// Takes in environment object and switches views when changed accordingly
struct ViewController: View {
    @EnvironmentObject var viewRouter: ViewRouter
    @StateObject var mqttManager = MQTTManager.shared()
    
    @State private var sendNotification = false
    
    let COMMAND_1 = "command_1"
    let COMMAND_2 = "command_2"
    let COMMAND_3 = "command_3"
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                switch viewRouter.currentPage {
                case .home:
                    HomeView()
                }
            }
            
            HStack(alignment: .bottom) {
                GeometryReader { geometry in
                    ZStack {
                        Color.white
                            .edgesIgnoringSafeArea(.bottom)
                        VStack {
                            Divider()
                                .padding(.top, 0)
                                .padding(.bottom, 0)
                        }.padding(.top, 0)
                        .frame(height: 44)
                    }
                }.frame(height: 44)
            }
            
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                print("backgroundTest")
            }
            
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                print("terminateBackgroundProcess")
                self.mqttManager.configureAndConnect(state: mqttManager.currentAppState.appConnectionState)
            }
            
            .onAppear(perform: {
                UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert]) { (_, _) in
                }
            })
        }.onAppear {
            self.mqttManager.configureAndConnect(state: mqttManager.currentAppState.appConnectionState)
        }.onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            if sendNotification {
                let content = UNMutableNotificationContent()
                content.title = "title"
                content.subtitle = "subtitle"
                content.sound = UNNotificationSound.default
                
                // show this notification ten seconds from now
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                
                // choose a random identifier
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

                // add our notification request
                UNUserNotificationCenter.current().add(request)
            }
        }
    }
}
