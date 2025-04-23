//
//  AvoJumpView.swift
//  AvoJump Watch App
//
//  Created by YEJIN KIM on 2025/04/22.
//

import SwiftUI
import WatchKit

// 게임 상태 관리
class GameState: ObservableObject {
    @Published var isPlaying = false
    @Published var score = 0
    @Published var highScore = UserDefaults.standard.integer(forKey: "highScore")
    @Published var avoY: CGFloat = 0
    @Published var isJumping = false
    @Published var canDoubleJump = false  // 더블 점프 가능 여부
    @Published var hasDoubleJumped = false  // 이미 더블 점프했는지 여부
    @Published var obstacles: [Obstacle] = []
    @Published var gameOver = false
    
    var timer: Timer?
    let gravity: CGFloat = 0.6
    var velocity: CGFloat = 0
    var obstacleSpeed: CGFloat = 2  // 장애물 속도 변수 추가
      
    
    func startGame() {
        isPlaying = true
        score = 0
        avoY = 0
        isJumping = false
        canDoubleJump = false
        hasDoubleJumped = false
        obstacles = []
        gameOver = false
        obstacleSpeed = 2  // 게임 시작시 속도 초기화
        
        // 장애물 생성 타이머
        timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            self.updateGame()
        }
    }
    
    func jump() {
        if !isJumping {
            // 첫 번째 점프
            isJumping = true
            canDoubleJump = true
            hasDoubleJumped = false
            velocity = -10.0 // 점프 힘
        } else if canDoubleJump && !hasDoubleJumped {
            // 더블 점프
            hasDoubleJumped = true
            canDoubleJump = false
            velocity = -8.0 // 두 번째 점프 힘 (약간 약하게)
        }
    }
    
    func updateGame() {
        if gameOver {
            timer?.invalidate()
            timer = nil
            return
        }
        
        // 점수 증가
        score += 1
    
         // 점수에 따라 속도 증가
         if score % 500 == 0 && score > 0 {
             obstacleSpeed += 0.5
         }
        
        // 아보카도 점프 물리
        if isJumping {
            avoY += velocity
            velocity += gravity
            
            if avoY >= 0 {
                avoY = 0
                isJumping = false
                canDoubleJump = false
                hasDoubleJumped = false
                velocity = 0
            }
        }
        
        // 장애물 생성
        if Int.random(in: 0...100) < 2 {
            // 랜덤하게 장애물 타입 선택
            let obstacleTypes = ["cado", "tomato", "lemon"]
            let randomType = obstacleTypes.randomElement() ?? "cado"
            
            let newObstacle = Obstacle(x: 150, type: randomType)
            obstacles.append(newObstacle)
        }
        
        // 장애물 이동 및 제거
        for i in (0..<obstacles.count).reversed() {
               obstacles[i].x -= obstacleSpeed  // 변수로 속도 조절
            
            // 충돌 감지
            if abs(obstacles[i].x - 16) < 16 && avoY > -16 {
                gameOver = true
                if score > highScore {
                    highScore = score
                    UserDefaults.standard.set(highScore, forKey: "highScore")
                }
            }
            
            // 화면 밖으로 나간 장애물 제거
            if obstacles[i].x < -20 {
                obstacles.remove(at: i)
            }
        }
    }
}

// 장애물 모델
struct Obstacle: Identifiable {
    let id = UUID()
    var x: CGFloat
    let height: CGFloat = 20
    let type: String // 장애물 타입 (cado, tomato, lemon)
}

// 아보카도 뷰 - 이미지 사용
struct avoView: View {
    var avoY: CGFloat
    
    var body: some View {
        Image("avo")
            .resizable()
            .scaledToFit()
            .frame(width: 45)
            .offset(y: avoY)
    }
}

// 장애물 뷰 - 이미지 사용
struct ObstacleView: View {
    var obstacle: Obstacle
    
    var body: some View {
        Image(obstacle.type)
            .resizable()
            .scaledToFit()
            .frame(width: 25, height: obstacle.height)
            .offset(x: obstacle.x, y: 0)
    }
}
// 메인 게임 뷰
struct AvoJumpView: View {
    @StateObject private var gameState = GameState()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 배경
                Color("Color5").edgesIgnoringSafeArea(.all)
                
                // 바닥선
                Rectangle()
                    .fill(Color("Color3"))
                    .frame(height: 2)
                    .offset(y: 20)
                
                // 아보카도
                avoView(avoY: gameState.avoY)
                    .position(x: 50, y: geometry.size.height / 2 + 20)
                
                // 장애물들
                ForEach(gameState.obstacles) { obstacle in
                    ObstacleView(obstacle: obstacle)
                        .position(x: obstacle.x, y: geometry.size.height / 2 + 20)
                }
                
                // 점수
                Text("Record: \(gameState.score)")
                    .font(.system(size: 12))
                    .foregroundColor(Color("Color3"))
                    .position(x: geometry.size.width / 2, y: 20)

                
                // 게임오버 표시
                if gameState.gameOver {
                    ZStack {
                        Color("Color3").opacity(0.9)
                            .edgesIgnoringSafeArea(.all)
                        
                        VStack(spacing: 5) {
                            Text("GAME OVER!")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color("Color2"))
                            
                            Text("Record: \(gameState.highScore)")
                                .font(.system(size: 12))
                                .foregroundColor(.white)
                                .padding(10)
                            
                            Button("RETRY") {
                                gameState.startGame()
                            }
                            .padding(8)
                            .font(.headline)
                            .background(Color("Color1"))
                            .foregroundColor(Color("Color3"))
                            .cornerRadius(28)
                        }
                        .padding(10)
                    }
                }
                
                // 시작 화면
                if !gameState.isPlaying && !gameState.gameOver {
                    ZStack{
                        Color("Color5")
                                    .edgesIgnoringSafeArea(.all)
                        VStack {
                            Text("🥓 Avo Jump 🥑")
                                .font(.headline)
                                .padding(.bottom, 20)
                                .foregroundColor(Color("Color4"))
                            Button("START") {
                                gameState.startGame()
                            }
                            .padding(8)
                            .font(.headline)
                            .background(Color("Color3"))
                            .foregroundColor(Color("Color2"))
                            .cornerRadius(50)
                        }
                        .padding(10)
                        
                    }
                }
            }
            .gesture(
                TapGesture()
                    .onEnded { _ in
                        if gameState.isPlaying && !gameState.gameOver {
                            gameState.jump()
                        }
                    }
            )
        }
    }
}

// 프리뷰
struct AvoJumpView_Previews: PreviewProvider {
    static var previews: some View {
        AvoJumpView()
    }
}
