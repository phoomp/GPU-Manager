//
//  GPUTileView.swift
//  Vision GPU Manager
//
//  Created by Phoom Punpeng on 8/7/2565 BE.
//

import SwiftUI
import Foundation

var rastafariGreen: Color = Color(red: 30 / 255, green: 150 / 255, blue: 0 / 255)
var rastafariYellow: Color = Color(red: 255 / 255, green: 242 / 255, blue: 0 / 255)
var rastafariRed: Color = Color(red: 255 / 255, green: 0 / 255, blue: 0 / 255)

var rastafari = LinearGradient(colors: [rastafariGreen, rastafariYellow, rastafariRed], startPoint: .topLeading, endPoint: .bottomTrailing)


var byDesignBlue: Color = Color(red: 0 / 255, green: 159 / 255, blue: 255 / 255, opacity: 1.0)
//var byDesignRed: Color = Color(red: 236 / 255, green: 47 / 255, blue: 75 / 255)
var byDesignRed: Color = Color(red: 239 / 255, green: 59 / 255, blue: 54 / 255, opacity: 0.9)

var byDesign = LinearGradient(colors: [byDesignBlue, byDesignRed], startPoint: .topLeading, endPoint: .bottomTrailing)


var customOrange: Color = Color(red: 242 / 255, green: 113 / 255, blue: 33 / 255, opacity: 0.9)

enum ClusterStatus: Decodable {
    case online
    case offline
    case containsError
    case error
}

struct GPUProcess: Decodable {
    var username: String
    var command: String
    var gpu_memory_usage: Int
    var pid: Int
}

struct GPUStatus: Decodable {
    var index: Int
    var uuid: String
    var name: String
    var temperature_gpu: Int
    var fan_speed: Int
    var utilization_gpu: Int
    var power_draw: Int?
    var enforced_power_limit: Int
    var memory_used: Int
    var memory_total: Int
    var processes: [GPUProcess]
}


struct FirebaseCluster: Decodable {
    var hostname: String
    var query_time: String
    var gpus: [GPUStatus]
}

struct Cluster {
    var cluster: FirebaseCluster
    var status: ClusterStatus
}


struct GPUTileView: View {
    @StateObject var cluster: ClusterModel

    func determineColorFromState() -> Color {
        // Ex. "2022-07-07T19:17:50.322250"
        return .green
//        let timeString: String = cluster.firebaseCluster!.query_time
//        let date: Date = Date(
//
//
//        if cluster.status == .online {
//            return .green
//        }
//        else if cluster.status == .containsError {
//            return .orange
//        }
//        else if cluster.status == .error {
//            return .red
//        }
//        else if cluster.status == .error {
//            return .gray
//        }
//        else {
//            return .black
//        }
    }
    
    func createGradient(freeColor: Color, inUseColor: Color) -> LinearGradient {
        let GPUCount: Int = cluster.firebaseCluster!.gpus.count
        let numGPUAvailable: Int = determineNumGPUAvailable()
        let numGPUInUse: Int = GPUCount - numGPUAvailable
        
        var gradientColors: [Color] = []
        
        for _ in 0 ..< numGPUAvailable {
            gradientColors.append(freeColor)
        }
        
        for _ in 0 ..< numGPUInUse {
            gradientColors.append(inUseColor)
        }
        
        return LinearGradient(colors: gradientColors, startPoint: .leading, endPoint: .bottomTrailing)
    }

    func determineNumGPUAvailable() -> Int {
        var available = 0

        for gpu in cluster.firebaseCluster!.gpus {
            if gpu.utilization_gpu < 10 && gpu.memory_used < 1000 {
                available += 1
            }
        }

        return available
    }

    func determineProcessMemory() -> [Int] {
        var memoryUsages: [Int] = []

        for gpu in cluster.firebaseCluster!.gpus {
            if gpu.utilization_gpu > 10 || gpu.memory_used > 1000 {
                memoryUsages.append(gpu.memory_used)
            }
        }

        return memoryUsages
    }

    func determineUsers() -> [String] {
        var users: [String] = []

        for gpu in cluster.firebaseCluster!.gpus {
            if gpu.utilization_gpu > 10 || gpu.memory_used > 1000 {
                var max: Int = -1
                var maxUser: String = ""

                for process in gpu.processes {
                    if process.gpu_memory_usage > max {
                        maxUser = process.username
                        max = process.gpu_memory_usage
                    }
                }

                users.append(maxUser)
            }
        }

        return users
    }
    
    func randomizeImages(imageNames: [String]) -> String {
        return imageNames.randomElement()!
    }

    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Image(systemName: randomizeImages(imageNames: ["xserve", "server.rack", "macpro.gen3.server", "cpu", "memorychip"]))
                        .font(.system(size: 140))
                        .opacity(0.04)
                        .padding(.leading, 20)
                    Spacer()
                }
                .padding(.top, 10)
                Spacer()
            }

            VStack() {
                VStack() {
                    HStack {
                        VStack {
                            Text(cluster.firebaseCluster!.hostname)
                                .font(.system(size: 30, weight: .heavy))
                                .padding(.leading, 10)
                                .foregroundColor(.white)
//                            Text(cluster.firebaseCluster!.query_time)
////                                .font(.system(size: 30, weight: .heavy))
//                                .padding(.leading, 10)
//                                .foregroundColor(.white)
                        }
                        Spacer()
                        Circle()
                            .fill(determineColorFromState())
                            .frame(width: 15, height: 15)
                        Image(systemName: "server.rack")
                            .foregroundColor(.white)
                            .font(.system(size: 35, weight: .medium))
                            .padding(.trailing, 10)
                    }.padding(.top, 5)
                    Spacer()

                    HStack {
                        VStack {
                            Spacer()
                            HStack {
                                if cluster.firebaseCluster!.gpus.count - determineNumGPUAvailable() > 0 {
                                    VStack(alignment: .leading) {
                                        ForEach(0 ..< (cluster.firebaseCluster!.gpus.count - determineNumGPUAvailable()), id: \.self) {
                                            Text(determineUsers()[$0])
                                                .font(.system(size: 15, weight: .semibold))
                                                .foregroundColor(.white)
                                                .padding(.leading, 10)
                                        }
                                    }
                                    VStack(alignment: .trailing) {
                                        ForEach(0 ..< (cluster.firebaseCluster!.gpus.count - determineNumGPUAvailable()), id: \.self) {
                                            Text(String(determineProcessMemory()[$0]) + "  MB")
                                                .font(.system(size: 15, weight: .semibold))
                                                .foregroundColor(.white)
                                                .padding(.leading, 10)
                                        }
                                    }
                                } else {
                                    Text("Idle")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(.leading, 10)

                                }
                            }.padding(.bottom, 10)

                        }
                        Spacer()
                        VStack {
                            Spacer()
                            HStack {
                                Image(systemName: "cpu.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 30))
                                Text(String(determineNumGPUAvailable()) + "/" + String(cluster.firebaseCluster!.gpus.count))
                                    .foregroundColor(.white)
                                    .font(.system(size: 30)).bold()
                                    .padding(.trailing, 10)
                            }.padding(.bottom, 10)
                        }
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: 200)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(createGradient(freeColor: byDesignBlue, inUseColor: customOrange))
        )
        .padding(.horizontal, 10)
        .onAppear {
            print(cluster.firebaseCluster!.gpus.count - determineNumGPUAvailable())
            cluster.listen()
            print(cluster.hostname)
        }
    }
}

struct GPUTileView_Previews: PreviewProvider {
    
    static var cluster: ClusterModel = ClusterModel(hostname: "vision03")

    static var previews: some View {
        GPUTileView(cluster: cluster)
    }
}
