import SwiftUI

struct OverlayView: View {
    @State private var isBlinking = false
    @State private var animationProgress: CGFloat = 0
    @State private var timer: Timer?
    @State private var blinkInterval: Double
    
    init(blinkInterval: Double) {
        _blinkInterval = State(initialValue: blinkInterval)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // This transparent color is needed for the animation to be visible
                Color.black.opacity(0.001) // Nearly invisible but gives a surface for the animation
                    .contentShape(Rectangle())
                
                // Blinking animation overlay
                if isBlinking {
                    BlinkView(progress: animationProgress)
                }
            }
            .onAppear {
                print("OverlayView appeared")
                startBlinkTimer()
                setupNotificationObserver()
            }
            .onDisappear {
                // Remove notification observer when view disappears
                NotificationCenter.default.removeObserver(self)
                timer?.invalidate()
            }
        }
        .ignoresSafeArea()
    }
    
    private func setupNotificationObserver() {
        // Create a NotificationCenter observer for blink triggers
        NotificationCenter.default.addObserver(
            forName: .triggerBlink,
            object: nil,
            queue: .main
        ) { _ in
            print("Notification received to trigger blink")
            triggerBlink()
        }
        
        // Create a NotificationCenter observer for interval changes
        NotificationCenter.default.addObserver(
            forName: .blinkIntervalChanged,
            object: nil,
            queue: .main
        ) { notification in
            print("Notification received to change interval")
            if let newInterval = notification.userInfo?["interval"] as? Double {
                blinkInterval = newInterval
                print("Interval updated to \(blinkInterval)")
                restartTimer()
            }
        }
    }
    
    private func startBlinkTimer() {
        // Immediately trigger a blink to test
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            print("Initial test blink triggered")
            triggerBlink()
        }
        
        // Setup timer with configurable interval
        timer = Timer.scheduledTimer(withTimeInterval: blinkInterval, repeats: true) { _ in
            print("Timer triggered blink")
            triggerBlink()
        }
        
        print("Blink timer started with interval: \(blinkInterval) seconds")
    }
    
    private func restartTimer() {
        // Invalidate existing timer
        timer?.invalidate()
        
        // Create new timer with updated interval
        timer = Timer.scheduledTimer(withTimeInterval: blinkInterval, repeats: true) { _ in
            triggerBlink()
        }
        
        print("Blink timer restarted with interval: \(blinkInterval) seconds")
    }
    
    private func triggerBlink() {
        print("Triggering blink animation")
        // Don't trigger again if already blinking
        guard !isBlinking else { 
            print("Already blinking, ignoring trigger")
            return 
        }
        
        isBlinking = true
        
        // Animation sequence: 0 to 1 (top to bottom), then 1 to 2 (bottom to top), then reset
        withAnimation(.easeInOut(duration: 0.15)) {
            animationProgress = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.easeInOut(duration: 0.15)) {
                animationProgress = 2.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                isBlinking = false
                animationProgress = 0
                print("Blink animation complete")
            }
        }
    }
}

struct BlinkView: View {
    let progress: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // For progress 0-1: dark overlay moves from top to bottom
                if progress <= 1.0 {
                    Color.black
                        .opacity(0.8)
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.height * progress
                        )
                        .position(
                            x: geometry.size.width / 2,
                            y: geometry.size.height * progress / 2
                        )
                }
                // For progress 1-2: dark overlay retracts from bottom to top
                else {
                    let reversedProgress = 2.0 - progress // 1.0 to 0.0
                    Color.black
                        .opacity(0.8)
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.height * reversedProgress
                        )
                        .position(
                            x: geometry.size.width / 2,
                            y: geometry.size.height * reversedProgress / 2
                        )
                }
            }
        }
    }
}
