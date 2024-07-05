//
//  StartView.swift
//  TextGenius
//
//  Created by Dev Asheesh Chopra on 02/07/24.
//


import SwiftUI

struct StartView: View {
    @State private var isAnimating = false
    @State private var sliderValue: CGFloat = 0.0
    @State private var isActive: Bool = false
    @State private var textOpacity: Double = 0.0
    @State private var showInstructionView: Bool = false
    @State private var showingPopup = false
    
    @State private var displayedText: String = ""
        private let fullText: String = "Instant answers, Infinite Efficiency"
        @State private var timer: Timer.TimerPublisher = Timer.publish(every: 0.1, on: .main, in: .common)
    
    var body: some View {
        
            ZStack {
                Color.teal.ignoresSafeArea() // Background color covering
                
                VStack{
                    Spacer(minLength: 30)
                    Text("TextGenius")
                        .font(.largeTitle)
                        .scaleEffect(CGSize(width: 2.0, height: 2.0))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .opacity(textOpacity)
                        .onAppear {
                            withAnimation(.easeIn(duration: 1.5)) {
                                textOpacity = 0.7
                            }
                        }
                    
                    Spacer(minLength: 20)
                    Text(displayedText)
                        .scaleEffect(CGSize(width: 1.1, height: 1.1))
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .onReceive(timer) { _ in
                            if displayedText.count < fullText.count {
                                let nextIndex = fullText.index(fullText.startIndex, offsetBy: displayedText.count)
                                displayedText.append(fullText[nextIndex])
                            } else {
                                timer.connect().cancel()
                            }
                        }
                        .onAppear {
                            timer = Timer.publish(every: 0.12, on: .main, in: .common)
                            timer.connect()
                        }
                    
                    Spacer(minLength: 120)
                                        
                    
                    CircleAnimation(isAnimating: $isAnimating)
                    
                    
                    SliderView(showInstructionView: $showInstructionView)
                }
                
                if showInstructionView {
                    
                    InstructionView(showingPopup: $showingPopup)
                    
                }
        }
    }
        
}

struct CircleAnimation: View {
    @Binding var isAnimating: Bool
    var body: some View {
        ZStack {
            // Innermost circle
            
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: 15)
                .frame(width: 200, height: 200)
            
            // Middle circle
            Circle()
                .stroke(Color.white.opacity(0.4), lineWidth: 22)
                .frame(width: 239, height: 239)
            
            // Outermost circle
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: 15)
                .frame(width: 280, height: 280)
            
            LottieView(name: "keyboard", loopMode: .loop, animationSpeed: 1)
                .scaleEffect(CGSize(width: 0.15, height: 0.15))
            
            
            
        }
        .offset(y: isAnimating ? -10 : 10)
        .animation(
            Animation.easeInOut(duration: 2).repeatForever(autoreverses: true),
            value: isAnimating
        )
        .onAppear {
            isAnimating = true
        }
        .frame(width: 250, height: 250)
    }
}



struct SliderView: View {
    @State private var isAnimating = false
    @State private var sliderValue: CGFloat = 0.0
    @State private var isActive: Bool = false
    @State private var shimmer: Bool = false
    @Binding var showInstructionView: Bool
    @State private var showingPopup = false
    var body: some View {
        
            VStack {
                Spacer()
                ZStack {
                    // Background for 3D effect
                    Capsule()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: UIScreen.main.bounds.width * 0.9-75, height: 82)
                    
                    // Foreground slider
                    Capsule()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: UIScreen.main.bounds.width * 0.83-70, height: 65)
                    
                    ShimmeringTextView(text: "Get Started")
                    
                    // Active slider
                    GeometryReader { geometry in
                        HStack {
                            Capsule()
                                .fill(Color.red.opacity(0.5))
                                .frame(width: (sliderValue) * (geometry.size.width), height: 70)
                            
                            Spacer()
                        }
                        .frame(width: geometry.size.width, height: 76, alignment: .leading)
                        .animation(.easeOut(duration: 0.7), value: sliderValue) // Match the duration with handle animation
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.70, height: 76)
                    
                    
                    // Slider handle
                    HStack {
                        ZStack{
                            Circle()
                                .foregroundColor(Color(red: 180/255.0, green: 110/255.0, blue: 110/255.0))
                                .frame(width: 90, height: 90)
                                .offset(x: sliderValue * (UIScreen.main.bounds.width * 0.9 - 80), y: 0)
                            
                            Circle()
                                .foregroundColor(Color(red: 158/255.0, green: 78/255.0, blue: 78/255.0))
                                .frame(width: 70, height: 70)
                                .overlay (
                                    Image(systemName: "chevron.forward.2")
                                        .foregroundStyle(.white)
                                        .font(.title)
                                )
                                .offset(x: sliderValue * (UIScreen.main.bounds.width * 0.9 - 80), y: 0)
                            
                        }
                        .gesture(
                            DragGesture().onChanged { value in
                                isActive = true
                                
                                let sliderWidth = UIScreen.main.bounds.width * 0.8 - 80
                                sliderValue = min(max(0, (value.location.x) / sliderWidth), 1)
                            }
                                .onEnded { _ in
                                    withAnimation(.easeOut(duration: 0.5)) {
                                        if sliderValue >= 0.95 {  // Close to full, trigger view change
                                            showInstructionView = true
                                        }
                                        sliderValue = 0
                                    }
                                }
                        )
                        
                        
                        Spacer()
                    }
                    
                    
                }
                .padding(.horizontal, 15)
                .padding(.bottom, 50)
                
        }
    }
    
}


struct ShimmeringTextView: View {
    let text: String
    @State private var animationIsActive = false

    var body: some View {
        Text(text)
            .font(.title2)
            .frame(width: 200, height: 50, alignment: .center)
            .foregroundColor(.black.opacity(0.4)) // Text color is clear because the gradient is applied as a mask
            .background(
                // The shimmer effect as a moving gradient
                shimmeringGradient
                    .mask(
                        Text(text)
                            .font(.title2)
                            .scaledToFill()
                    )
                    .animation(Animation.linear(duration: 2.5).repeatForever(autoreverses: false), value: animationIsActive)
            )
            .onAppear {
                animationIsActive = true
            }
    }

    var shimmeringGradient: some View {
        LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.3), Color.black,Color.white.opacity(0.7)]), startPoint: .leading, endPoint: .trailing)
            .frame(width: 300)
            .offset(x: animationIsActive ? 300 : -300)
    }
}



struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
    }
}
