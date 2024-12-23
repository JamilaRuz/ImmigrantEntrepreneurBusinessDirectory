//
//  EmptyBookmarkView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 10/29/24.
//

import SwiftUI

struct EmptyBookmarkedListView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "bookmark.slash")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("No Bookmarks Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Browse the directory and bookmark companies you're interested in to see them here.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    EmptyBookmarkedListView()
}
