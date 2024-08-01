//
//  OnboadingData.swift
//  Fianal
//
//  Created by Deemh Albaqami on 29/10/1445 AH.
//

import Foundation
struct OnboardingItem: Identifiable {
    var id = UUID()
    var imageName: String
    var title: String
    var description: String
}

let onboardingData: [OnboardingItem] = [
    OnboardingItem(imageName: "OB1", title: "Your Title 1", description: "Your description for slide 1."),
    OnboardingItem(imageName: "OB2", title: "Your Title 2", description: "Your description for slide 2."),
    OnboardingItem(imageName: "OB3", title: "Your Title 3", description: "Your description for slide 3.")
]
