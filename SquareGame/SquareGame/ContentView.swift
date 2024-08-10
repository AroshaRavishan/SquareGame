import SwiftUI

struct ContentView: View {
    @State private var squares: [Square] = []
    @State private var selectedSquares: [Square] = []
    @State private var score: Int = 0
    @State private var showFailureAlert: Bool = false
    @State private var failureMessage: String? = nil
    
    let colors: [Color] = [.red, .blue, .green]
    let gridSize = 3
    
    var body: some View {
        VStack {
            Text("Score: \(score)")
                .font(.title)
                .padding()
            
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(100)), count: gridSize), spacing: 10) {
                ForEach(squares) { square in
                    Rectangle()
                        .fill(square.color)
                        .frame(width: 100, height: 100)
                        .onTapGesture {
                            handleTap(on: square)
                        }
                        .border(Color.black, width: 2) // Optional: Add border for better visibility
                }
            }
            .padding()
            .alert(isPresented: $showFailureAlert) {
                Alert(
                    title: Text("Game Over"),
                    message: Text(failureMessage ?? "Sorry, you failed."),
                    primaryButton: .destructive(Text("Close")) {
                        // Handle Close action
                    },
                    secondaryButton: .default(Text("Restart")) {
                        // Handle Restart action
                        restartGame()
                    }
                )
            }
        }
        .onAppear(perform: setupGame)
    }
    
    private func setupGame() {
        var colorList = Array(repeating: colors[0], count: gridSize * gridSize / 3) +
                        Array(repeating: colors[1], count: gridSize * gridSize / 3) +
                        Array(repeating: colors[2], count: gridSize * gridSize / 3)
        colorList.shuffle()
        
        squares = (0..<gridSize * gridSize).map { index in
            Square(id: index, color: colorList[index])
        }
    }
    
    private func handleTap(on tappedSquare: Square) {
        if selectedSquares.isEmpty {
            selectedSquares.append(tappedSquare)
        } else if selectedSquares.count == 1 {
            selectedSquares.append(tappedSquare)
            evaluateSelection()
        }
    }
    
    private func evaluateSelection() {
        guard selectedSquares.count == 2 else { return }
        
        let (first, second) = (selectedSquares[0], selectedSquares[1])
        
        if first.color == second.color {
            score += 1
            failureMessage = "Match found! Score: \(score)"
        } else {
            failureMessage = "Sorry, you failed. Score: \(score)"
            showFailureAlert = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            selectedSquares.removeAll()
        }
    }
    
    private func restartGame() {
        score = 0
        setupGame()
    }
}

struct Square: Identifiable {
    let id: Int
    let color: Color
}
