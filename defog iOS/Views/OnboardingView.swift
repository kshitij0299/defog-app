import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    
    var readOnly: Bool = false
    var onCompletion: (() -> Void)? = nil
    
    @State private var currentTab = 0
    
    var body: some View {
        VStack {
            if readOnly {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
            }
            
            TabView(selection: $currentTab) {
                OnboardingSlide(
                    icon: "brain.head.profile",
                    title: "Clear your mind",
                    description: "Jot down everything bouncing around in your head. We'll help you sort it out."
                )
                .tag(0)
                
                OnboardingSlide(
                    icon: "checkmark.circle.fill",
                    title: "Tasks are finite",
                    description: "Things you need to complete once, big or small."
                )
                .tag(1)
                
                OnboardingSlide(
                    icon: "target",
                    title: "Goals are journeys",
                    description: "Ongoing pursuits that take time. Track your progress gently over time.",
                    iconColor: .orange
                )
                .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .animation(.easeInOut, value: currentTab)
            
            if !readOnly {
                HStack {
                    if currentTab < 2 {
                        Button("Skip") {
                            completeOnboarding()
                        }
                        .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button("Next") {
                            withAnimation { currentTab += 1 }
                        }
                        .bold()
                    } else {
                        Button(action: {
                            completeOnboarding()
                        }) {
                            Text("Get Started")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func completeOnboarding() {
        UserPreferences.onboardingCompleted = true
        onCompletion?()
    }
}

struct OnboardingSlide: View {
    let icon: String
    let title: String
    let description: String
    var iconColor: Color = .accentColor
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: icon)
                .font(.system(size: 80))
                .foregroundColor(iconColor)
            
            Text(title)
                .font(.largeTitle)
                .bold()
                .fontDesign(.rounded)
                .multilineTextAlignment(.center)
            
            Text(description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding(.bottom, 60)
    }
}

#Preview("Initial Launch") {
    OnboardingView()
}

#Preview("Read Only (Settings)") {
    OnboardingView(readOnly: true)
}
