//
//  ContentView.swift
//  AssaAbloy
//
//  Created by Gabriel do Prado Moreira on 07/04/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var container: AppContainer
    @StateObject private var authViewModel = AuthFactory.makeViewModel()
    
    var body: some View {
        if authViewModel.isAuthenticated {
            Text("Logged In")
                .font(.largeTitle)
                .onTapGesture {
                    authViewModel.signOut()
                }
        } else {
            AuthFactory.makeSignInView(viewModel: authViewModel)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppContainer())
}
