//
//  GameLogic.swift
//  AvoJump
//
//  Created by Niko on 5/18/25.
//

import SwiftUI
#if os(watchOS)
import WatchKit
#endif

// 장애물 모델
struct Obstacle: Identifiable {
    let id = UUID()
    var x: CGFloat
    let height: CGFloat = 20
    let type: String // 장애물 타입 (cado, tomato, lemon)
}

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
    @Published var isCollided = false // 충돌 감지 여부
    
    var timer: Timer?
    let gravity: CGFloat = 0.6
    var velocity: CGFloat = 0
    var obstacleSpeed: CGFloat = 1.5  // 장애물 속도 변수 추가
      
    func startGame() {
        isPlaying = true
        score = 0
        avoY = 0
        isJumping = false
        canDoubleJump = false
        hasDoubleJumped = false
        obstacles = []
        gameOver = false
        isCollided = false // 충돌 상태 초기화
        obstacleSpeed = 1.5  // 게임 시작시 속도 초기화
        
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
            velocity = -10.0
            playJumpHaptic()
        } else if canDoubleJump && !hasDoubleJumped {
            // 더블 점프
            hasDoubleJumped = true
            canDoubleJump = false
            velocity = -8.0
            playJumpHaptic()
        }
    }
    
    // 플랫폼에 따른 햅틱 피드백 처리
    private func playJumpHaptic() {
        #if os(watchOS)
        WKInterfaceDevice.current().play(.click)
        #elseif os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        #endif
    }
    
    // 충돌 햅틱 피드백
    private func playCollisionHaptic() {
        #if os(watchOS)
        WKInterfaceDevice.current().play(.failure)
        #elseif os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
        #endif
    }
    
    func updateGame() {
        if gameOver {
            timer?.invalidate()
            timer = nil
            return
        }
        
        // 충돌 상태일 때는 점수 증가 안함
        if !isCollided {
            // 점수 증가
            score += 1
            
            // 점수에 따라 속도 증가
            if score % 500 == 0 && score > 0 {
                obstacleSpeed += 0.5
            }
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
        
        // 충돌 상태가 아닐 때만 새 장애물 생성
        if !isCollided {
            // 장애물 생성
            if Int.random(in: 0...100) < 2 {
                // 랜덤하게 장애물 타입 선택
                let obstacleTypes = ["cado", "tomato", "lemon"]
                let randomType = obstacleTypes.randomElement() ?? "cado"
                
                let newObstacle = Obstacle(x: 150, type: randomType)
                obstacles.append(newObstacle)
            }
        }
        
        // 장애물 이동 및 제거
        for i in (0..<obstacles.count).reversed() {
            // 충돌 상태가 아닐 때만 장애물 이동
            if !isCollided {
                obstacles[i].x -= obstacleSpeed  // 변수로 속도 조절
            }
            
            // 충돌 감지
            if abs(obstacles[i].x - 23) < 15 && avoY > -15 {
                if !isCollided { // 아직 충돌 처리가 되지 않았을 때만
                    isCollided = true
                    playCollisionHaptic()
                    
                    // 1초 후에 게임오버 처리
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.gameOver = true
                        if self.score > self.highScore {
                            self.highScore = self.score
                            UserDefaults.standard.set(self.highScore, forKey: "highScore")
                        }
                    }
                }
            }
            
            // 충돌 상태가 아닐 때만 화면 밖으로 나간 장애물 제거
            if !isCollided && obstacles[i].x < -20 {
                obstacles.remove(at: i)
            }
        }
    }
}
