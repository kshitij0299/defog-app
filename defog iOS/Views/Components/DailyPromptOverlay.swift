import SwiftUI
import SwiftData

struct DailyPromptOverlay: View {
    let staleTasksCount: Int
    let onMove: () -> Void
    let onKeep: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    onDismiss()
                }
            
            VStack(spacing: 24) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.15))
                        .frame(width: 64, height: 64)
                    
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 28))
                        .foregroundColor(.orange)
                }
                
                // Text
                VStack(spacing: 8) {
                    Text("Move yesterday's Today tasks?")
                        .font(.title3.weight(.bold))
                        .multilineTextAlignment(.center)
                    
                    Text("You have \(staleTasksCount) task\(staleTasksCount == 1 ? "" : "s") left over from yesterday. Would you like to move them to This Week?")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                }
                
                // Actions
                VStack(spacing: 12) {
                    Button(action: onMove) {
                        Text("Move to This Week")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    
                    Button(action: onKeep) {
                        Text("Keep in Today")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(12)
                    }
                    
                    Button(action: onDismiss) {
                        Text("Not now")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.secondary)
                            .padding(.vertical, 8)
                    }
                }
            }
            .padding(24)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
            .padding(24)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: true)
    }
}

#Preview {
    DailyPromptOverlay(staleTasksCount: 3, onMove: {}, onKeep: {}, onDismiss: {})
}
