//
//  SettingsView.swift
//  TextGenius
//
//  Created by Dev Asheesh Chopra on 30/06/24.
//

import SwiftUI

struct SettingsView: View {
    @State private var textInput: String = ""
    @State private var showInfoView = false
    
    
    @AppStorage("isAutocorrectEnabled", store: UserDefaults(suiteName: "group.dev-d-gr8.TextGenius"))
    var isAutocorrectEnabled: Bool = false
    
    @AppStorage("isDoubleSpaceForPeriodEnabled", store: UserDefaults(suiteName: "group.dev-d-gr8.TextGenius"))
    var isDoubleSpaceForPeriodEnabled: Bool = false
    
    @AppStorage("isAutoCapsEnabled", store: UserDefaults(suiteName: "group.dev-d-gr8.TextGenius"))
    var isAutoCapsEnabled: Bool = false
    
    @AppStorage("promptClearEnabled", store: UserDefaults(suiteName: "group.dev-d-gr8.TextGenius"))
    var promptClearEnabled: Bool = false
    
    @AppStorage("resetSpecialKeyAfterSubmissionEnabled", store: UserDefaults(suiteName: "group.dev-d-gr8.TextGenius"))
    var resetSpecialKeyAfterSubmissionEnabled: Bool = true
    
    @AppStorage("longSpacePressCursorMovementEnabled", store: UserDefaults(suiteName: "group.dev-d-gr8.TextGenius"))
    var longSpacePressCursorMovementEnabled: Bool = false
    
    @AppStorage("keyClickSoundsEnabled", store: UserDefaults(suiteName: "group.dev-d-gr8.TextGenius"))
    var keyClickSoundsEnabled: Bool = true
    
    @AppStorage("hapticFeedbackEnabled", store: UserDefaults(suiteName: "group.dev-d-gr8.TextGenius"))
    var hapticFeedbackEnabled: Bool = true

    var body: some View {
        ZStack{
            Color.teal.opacity(0.5).ignoresSafeArea()
            VStack {
                
                
                HStack {
                    Text("Customisation Panel")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                    
                    Button(action: {
                        showInfoView.toggle()  // Trigger to show the InfoView
                    }) {
                        Image(systemName: "info.circle")
                            .imageScale(.large)
                            .foregroundColor(.blue)
                    }
                    
                }
                    
                    
                    VStack {
                        
                        Toggle("Enable Autocorrect", isOn: $isAutocorrectEnabled)
                        Toggle("Hold and Drag Spacebar to Move Cursor", isOn: $longSpacePressCursorMovementEnabled)
                        Toggle("Double Space for Period", isOn: $isDoubleSpaceForPeriodEnabled)
                        Toggle("Enable Automatic Caps After Period", isOn: $isAutoCapsEnabled)
                        Toggle("Clear Prompt After Submission", isOn: $promptClearEnabled)
                        Toggle("Reset Special Content Key After Submission", isOn: $resetSpecialKeyAfterSubmissionEnabled)
                        Toggle("Enable Key Click Sounds", isOn: $keyClickSoundsEnabled)
                        Toggle("Enable Haptic Feedback", isOn: $hapticFeedbackEnabled)
                        
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(12.0)
                    
                    
                    
                    Spacer() // Pushes all content to the top
                    
                
            }
            .padding()
            
        }
        .fullScreenCover(isPresented: $showInfoView) {
            InfoView(showInfoView: $showInfoView)
            .background(Color.teal.opacity(0.5))}
        .navigationBarHidden(true)
    }
}



struct InfoView: View {
    @Binding var showInfoView: Bool
    @State private var showingPopup: Bool = false
    var body: some View {
        NavigationView {
            
                
                List {
                    
                    NavigationLink(destination: SetupInstructionsView(showingPopup: $showingPopup)) {
                        Text("Setup Instructions")
                            .foregroundColor(.black)
                            .padding()
                    }
                    
                    NavigationLink(destination: PrivacyPolicyView()) {
                        Text("Privacy Policy")
                            .foregroundColor(.black)
                            .padding()
                    }
                    
                    NavigationLink(destination: AboutDeveloperView()) {
                        Text("About Developer")
                            .foregroundColor(.black)
                            .padding()
                    }
                }
                .navigationTitle("Information")
                .navigationBarItems(leading: Button(action: {
                                showInfoView = false  // Action to dismiss the view
                            }) {
                                Image(systemName: "chevron.left")  // Using system chevron left icon
                                    .foregroundColor(.blue)  // Optionally set the color
                                    .imageScale(.large)
                            })
                            .background(Color.teal.opacity(0.5))
                
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct SetupInstructionsView: View {
    @Binding var showingPopup: Bool
    @State private var navigateToNextPage = false
    @State private var textOpacity: Double = 0.0

    var body: some View {
        NavigationView {
            ZStack{
                Color.teal.opacity(0.5).ignoresSafeArea()
                VStack {
                    Text("Enable SmartText")
                        .font(.title)
                        .fontWeight(.semibold)
                        .padding(.top, 20)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    VStack(spacing: 20) {
                        InstructionStep(number: "1", text: "Go to Settings", showingPopup: $showingPopup, animate: .constant(false))
                        InstructionStep(number: "2", text: "TextGenius", showSettingsButton: true, showingPopup: $showingPopup, animate: .constant(false))
                        InstructionStep(number: "3", text: "Keyboards", showingPopup: $showingPopup, animate: .constant(false))
                        InstructionStep(number: "4", text: "Enable TextGenius-SmartText", showingPopup: $showingPopup, animate: .constant(false))
                        InstructionStep(number: "5", text: "Allow Full Access", showInfoIcon: true, showingPopup: $showingPopup, animate: .constant(false))
                        InstructionStep(number: "6", text: "Customise keyboard settings", showingPopup: $showingPopup, animate: .constant(false))
                    }
                    .padding()
                    
                    Spacer()
                    
                    Text("By installing, you are agreeing to TextGenius' Terms of Service and Privacy Policy")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)                 .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding()
                .blur(radius: showingPopup ? 3 : 0)
                .safeAreaInset(edge: .top) {
                                Color.clear
                                    .frame(height: 0)
                            }
                            .safeAreaInset(edge: .bottom) {
                                Color.clear
                                    .frame(height: 30)
                            }
                .overlay(
                    // Popup Overlay
                    Group {
                        if showingPopup {
                            InfoPopup(showingPopup: $showingPopup)
                        }
                    }
                )
                

            }
                    
        }
        .navigationBarTitle("")
        .navigationBarHidden(false)
        .navigationBarTitleDisplayMode(.inline)
                
    }
    
    
}



struct PrivacyPolicyView: View {
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background dimming
                Color.teal.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                // Scrollable Privacy Policy Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        privacyPolicyText
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 10)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)  // More generous padding at top
                    .padding(.bottom, 40)  // More generous padding at bottom
                }
                .padding(.top, 5)  // Padding on top to respect top safe area
                .padding(.bottom, 40)  // Padding on bottom to respect bottom safe area
            }
        }
        .navigationBarTitle("")
        .navigationBarHidden(false)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var privacyPolicyText: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Privacy Policy")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.vertical)
                .frame(maxWidth: .infinity)  // Stretches the text to the full width of the parent
                .multilineTextAlignment(.center)

            Text("Effective Date: July 5, 2024")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text("Your privacy is critically important to us. At TextGenius, we have a few fundamental principles:")
                .padding(.top)

            ForEach(privacyPrinciples, id: \.self) { principle in
                Text("• \(principle)")
            }

            Text("Information We Collect")
                .font(.headline)
                .padding(.vertical)

            Text("We only collect information about you if we have a reason to do so—for example, to provide our services, to communicate with you, or to make our services better.")

            ForEach(informationTypes, id: \.self) { info in
                Text("• \(info)")
            }

            Text("How We Use Information")
                .font(.headline)
                .padding(.vertical)

            Text("We use the information we collect to provide our services to you, to make them better, maintain our services, and protect TextGenius and our users.")
        }
    }

    private var privacyPrinciples: [String] {
        [
            "We don’t ask for your personal information unless we truly need it.",
            "We don’t share your personal information except to comply with the law, develop our products, or protect our rights.",
            "We don’t store personal information on our servers unless required for the on-going operation of one of our services."
        ]
    }

    private var informationTypes: [String] {
        [
            "Information you provide to us directly.",
            "Information we collect automatically through operating our services.",
            "Information we get from third parties."
        ]
    }
}


struct AboutDeveloperView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 20) {
                
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .padding()
                    .background(Color.gray.opacity(0.3))
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.teal, lineWidth: 4))

                                
                Text("Dev Asheesh Chopra")
                    .font(.title)
                    .fontWeight(.bold)
                    
                Text("Software Developer")
                    .font(.title3)
                    .foregroundColor(.secondary)

                Text("Dev is a passionate software developer with a keen interest in building accessible and user-friendly applications. With a background in mobile and web development, Dev is dedicated to leveraging technology to solve real-world problems.")
                    .padding()
                    .multilineTextAlignment(.center)

                VStack(spacing: 16) {
                    ContactInfoView(iconName: "envelope.fill", info: "chopradevasheesh@gmail.com")
                    
                }
                .padding()
                
            }
            .padding()
        }
        .navigationBarTitle("About Developer", displayMode: .inline)
    }
}

struct ContactInfoView: View {
    var iconName: String
    var info: String

    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(.teal)
                .imageScale(.large)
            Text(info)
                .foregroundColor(.black)
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 3)
    }
}

#Preview {
    SettingsView()
}
