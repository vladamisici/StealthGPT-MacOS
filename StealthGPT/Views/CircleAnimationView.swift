import SwiftUI

struct CircleAnimationView: View {
    @State private var circles: [CircleData] = []
    private let circleCount = 20

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<circleCount, id: \.self) { index in
                    if circles.indices.contains(index) {
                        Circle()
                            .fill(Color.black.opacity(0.1))
                            .frame(width: 40, height: 40)
                            .position(circles[index].position)
                            .animation(
                                Animation.linear(duration: circles[index].duration)
                                    .repeatForever(autoreverses: false)
                            )
                            .onAppear {
                                circles[index].position = randomPosition(in: geometry.size)
                            }
                    }
                }
            }
            .onAppear {
                initializeCircles(size: geometry.size)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }

    private func initializeCircles(size: CGSize) {
        circles = (0..<circleCount).map { _ in
            CircleData(position: randomPosition(in: size), duration: Double.random(in: 8.0...20.0))
        }
    }

    private func randomPosition(in size: CGSize) -> CGPoint {
        CGPoint(
            x: CGFloat.random(in: -40...size.width + 40), // Allow positions slightly outside the view
            y: CGFloat.random(in: 0...size.height)
        )
    }
}

struct CircleData {
    var position: CGPoint
    var duration: Double
}

struct CircleAnimationView_Previews: PreviewProvider {
    static var previews: some View {
        CircleAnimationView()
            .frame(width: 600, height: 400)
    }
}
