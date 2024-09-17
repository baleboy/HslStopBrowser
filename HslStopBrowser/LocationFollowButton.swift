//
//  LocateButton.swift
//  HslStopBrowser
//
//  Created by Francesco Balestrieri on 17.9.2024.
//

import SwiftUI

struct LocationFollowButton: View {
    let isCameraFollowingUser: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: isCameraFollowingUser ? "location.fill" : "location")
                .foregroundColor(isCameraFollowingUser ? .blue : .gray)
                .padding()
                .background(Color.white)
                .clipShape(Circle())
                .shadow(radius: 4)
        }
        .padding()
    }
}

#Preview {
        LocationFollowButton(isCameraFollowingUser: false, action: {})
}

#Preview {
        LocationFollowButton(isCameraFollowingUser: true, action: {})
}
