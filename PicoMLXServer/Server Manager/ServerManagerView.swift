//
//  ServerManagerView.swift
//  PicoMLXServer
//
//  Created by Ronald Mannak on 3/18/24.
//

import SwiftUI

struct ServerManagerView: View {
    
    @Environment(\.openURL) var openURL
    @Environment(ServerController.self) private var serverController
    
    @State private var model: String = "mlx-community/starcoder2-7b-4bit"
    @State private var port: Int = 8080
    @State private var showCustomModelTextField = false
    @State private var showError = false
    @State private var error: Error? = nil
    
    // TODO: https://x.com/ronaldmannak/status/1770123553666711778?s=20
    let models = [
        "mlx-community/starcoder2-7b-4bit",
    ]
    
    var body: some View {
        VStack {
            
            ServerListView(showError: $showError, error: $error)
                .padding([.leading, .top, .trailing])
                .frame(maxWidth: .infinity)
            
            HStack {
                Button("Open model cache in Finder") {
                    let url = FileManager.default.homeDirectoryForCurrentUser.appending(path: ".cache/huggingface/hub/")
                    NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: url.path)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .padding(.leading)
                Spacer()
            }

            GroupBox {
                HStack {
                    GroupBox {
                        HStack {
                            Text("Model:")
                            TextField("Model: ", text: $model)
                            Menu {
                                ForEach(models, id: \.self) { model in
                                    Button(model) { self.model = model }
                                }
                            } label: {
                                EmptyView()
                            }
                            .frame(width: 15)
                            .menuStyle(.borderlessButton)
                        }
                    }
                    
                    Text("Port:")
                    TextField("Port", value: $port, format: .number.grouping(.never)) // { Text("Port:") }
                        .frame(width: 100)
                    
                    Button("Create") {
                        do {
                            try serverController.addServer(model: model, port: port)
                        } catch {
                            self.error = error
                        }
                    }
                    .keyboardShortcut(.defaultAction)                    
                    //                    .alert(isPresented: $showError, error: error, actions: {
                    .alert(error?.localizedDescription ?? "Unknown error occurred", isPresented: $showError) {
                        Button("OK", role: .cancel) { }
                    }
                    
                    Button {
                        openURL(URL(string: "https://huggingface.co/mlx-community")!)
                    } label: {
                        Image(systemName: "info.circle")
                    }
                    .padding(.trailing)
                    .buttonStyle(.plain)
                    .controlSize(.small)
                }
                .padding(4)
                
            } label: {
                Label("Create New Server", systemImage: "server.rack")
            }
            .padding()

        }
    }
}

#Preview {
    ServerManagerView()
}
