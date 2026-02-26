import SwiftUI

struct StorageChoiceView: View {
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var onChoiceMade: ((StorageMode) -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 40) {
            Image(systemName: "icloud.and.arrow.up")
                .font(.system(size: 80))
                .foregroundColor(.accentColor)
            
            VStack(spacing: 8) {
                Text("Where should we save your data?")
                    .font(.title2)
                    .bold()
                    .multilineTextAlignment(.center)
                
                Text("You can always upgrade to iCloud later in Settings.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            
            VStack(spacing: 16) {
                Button(action: {
                    selectStorage(.iCloud)
                }) {
                    HStack {
                        Image(systemName: "icloud.fill")
                        Text("Use iCloud (Recommended)")
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                
                Button(action: {
                    selectStorage(.local)
                }) {
                    Text("This device only")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 30)
            
            Spacer()
        }
        .padding(.top, 60)
        .alert(isPresented: $showingError) {
            Alert(
                title: Text("iCloud Unavailable"),
                message: Text(errorMessage),
                primaryButton: .default(Text("Try Again")) {
                    selectStorage(.iCloud)
                },
                secondaryButton: .cancel(Text("Use this device only")) {
                    selectStorage(.local)
                }
            )
        }
    }
    
    private func selectStorage(_ mode: StorageMode) {
        if mode == .iCloud {
            // Check if iCloud is actually available
            if FileManager.default.ubiquityIdentityToken == nil {
                errorMessage = "You must be signed into iCloud to sync your data. Sign in from the Settings app."
                showingError = true
                return
            }
        }
        
        UserPreferences.storageMode = mode
        UserPreferences.storageChoiceMade = true
        onChoiceMade?(mode)
    }
}

#Preview {
    StorageChoiceView()
}
