//
//  ToastView.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 2/6/21.
//

import SwiftUI

struct ToastView: View {
    var text: String
    @State private var isPresented: Bool = true
    @State private var offset: CGFloat = 0
    
    private let cornerRadius: CGFloat = 40
    private let backgroundColor: Color = Color(.secondarySystemBackground)
    
    var body: some View {
        guard isPresented else {
            return EmptyView().eraseToAnyView()
        }
        
        return
            Text(text)
            .bold()
            .padding()
            .background(backgroundColor.cornerRadius(cornerRadius))
            .padding(4)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(backgroundColor, lineWidth: 5)
            )
            .offset(x: 0, y: offset)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        self.offset = 8
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.isPresented = false
                        }
                    }
                }
            }
            .animation(.spring(dampingFraction: 0.50))
            .transition(.asymmetric(insertion: .offset(x: 0, y: -80),
                                    removal: .offset(x: 0, y: -150)))
            .eraseToAnyView()
    }
}

struct ToastView_Previews: PreviewProvider {
    
    /// A wrapper for the text State variable. If you just use a State variable in the PreviewProvider,
    /// the view's Binding won't update it for some reason.
    /// See: https://stackoverflow.com/questions/59246859/mutable-binding-in-swiftui-live-preview
    struct BindingHolder: View {
        @State private var toast = "Hello, world!"
        @State private var toasts: [String] = []

        var body: some View {
            VStack {
                ZStack(alignment: .top) {
                    Button {
                        withAnimation {
                            toasts.append(toast)
                            toast += "!"
                        }
                    } label: {
                        Text("Show Toast")
                    }
                    .offset(x: 0, y: 75)

                    ForEach(toasts, id: \.self) { toast in
                        ToastView(text: toast)
                    }
                }

                Spacer()
            }
            .padding()
        }
    }

    static var previews: some View {
        Group {
            ToastView(text: "Hello, world!")
                .padding()
                .previewLayout(.sizeThatFits)

            BindingHolder()
        }
        .preferredColorScheme(.dark)
    }
}
