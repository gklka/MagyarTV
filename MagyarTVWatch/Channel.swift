//
//  Channel.swift
//  MagyarTVWatch
//
//  Copyright © 2026. GKSoftware. All rights reserved.
//

import Foundation

struct Channel: Identifiable, Hashable {
    let id: String
    let title: String
    let logoName: String

    static let all: [Channel] = [
        Channel(id: "mtv1", title: "M1", logoName: "m1logo"),
        Channel(id: "mtv2", title: "M2", logoName: "m2logo"),
        Channel(id: "mtv4", title: "M4 Sport", logoName: "m4logo"),
        Channel(id: "mtv5", title: "M5", logoName: "m5logo"),
        Channel(id: "duna", title: "Duna", logoName: "dunalogo"),
        Channel(id: "dunaworld", title: "Duna World", logoName: "dunaworldlogo"),
    ]
}
