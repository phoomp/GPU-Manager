//
//  GPUView.swift
//  Vision GPU Manager
//
//  Created by Phoom Punpeng on 8/7/2565 BE.
//

import SwiftUI
import Firebase
import FirebaseCore
import FirebaseDatabase
import FirebaseAuth

import Foundation

class ClusterModel: ObservableObject {
    @Published var firebaseCluster: FirebaseCluster?
    @Published var hostname: String
    @Published var status: ClusterStatus
    
    init(hostname: String) {
        self.hostname = hostname
        self.firebaseCluster = FirebaseCluster(hostname: "---", query_time: "---", gpus: [GPUStatus(index: -1, uuid: "-", name: "-", temperature_gpu: -1, fan_speed: -1, utilization_gpu: -1, enforced_power_limit: -1, memory_used: -1, memory_total: -1, processes: [GPUProcess(username: "-", command: "-", gpu_memory_usage: 0, pid: 0)])])
        self.status = .offline
    }
    
    func listen() {
        let ref: DatabaseReference! = Database.database().reference().child("/\(hostname)/gpu_status/")
        
        ref.observe(DataEventType.value, with: { snapshot in
            let value = snapshot.value as! String
            let decodedData = Data(base64Encoded: value)!
            let decodedString = String(data: decodedData, encoding: .utf8)
            let fixedString = decodedString?.replacingOccurrences(of: ".", with: "_")
            
            let jsonData = fixedString?.data(using: .utf8)
            
            self.firebaseCluster = try! JSONDecoder().decode(FirebaseCluster.self, from: jsonData!)
        })
        
        print(self.firebaseCluster!.hostname)
    }
    
    
}

struct GPUView: View {
    var user: FirebaseUser
    
    @State var string: String = ""
    @State var added: [String] = []
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    func initialize() {
        var baseRef: DatabaseReference! = Database.database().reference().child("/")
        var childCount: [String] = []
        
        baseRef.child("/").getData(completion: { error, snapshot in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            let value = snapshot!.value as! [String: AnyObject]
            childCount = Array(value.keys)
            print(childCount)
            
            for key in childCount {
                added.append(key)
                print("Generating reference for " + key)
            }
        });
    }
    
    func listenToDatabase(hostname: String) -> any View {
        var cluster: ClusterModel = ClusterModel(hostname: hostname)
        return GPUTileView(cluster: cluster)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack(alignment: .center, spacing: 0) {
                        ForEach(0 ..< added.count, id: \.self) {
                            AnyView(listenToDatabase(hostname: added[$0]))
                        }.padding(.top, 20)

                        Text(user.email!)
                            .padding(.top, 40)
                        Button {
                            UserDefaults.standard.removeObject(forKey: "username")
                            UserDefaults.standard.removeObject(forKey: "password")
                            do {
                                try Auth.auth().signOut()
                                self.presentationMode.wrappedValue.dismiss()
                            } catch let error as NSError {
                                print("Error: " + (error as! String))
                            }
                        } label: {
                            Text("Sign out")
                        }
                        .padding(.top, 20)
                    }
                }
            }
        }
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.large)
            .navigationTitle("Clusters")
            .onAppear {
                initialize()
            }
    }
}

//struct GPUView_Previews: PreviewProvider {
//    static var previews: some View {
//        GPUView()
//    }
//}
