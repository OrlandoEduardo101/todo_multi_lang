//
//  ContentView.swift
//  TodoNative
//
//  Created by Orlando Eduardo Pereira on 17/03/26.
//
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Todo Native")
                .font(.largeTitle)
                .bold()

            Text("Dia 1: app shell pronto")
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
