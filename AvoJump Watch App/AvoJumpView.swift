////
////  AvoJumpView.swift
////  AvoJump Watch App
////
////  Created by YEJIN KIM on 2025/04/22.
////
import SwiftUI
import WatchKit

// 아보카도 뷰 - 이미지 사용
struct avoView: View {
    var avoY: CGFloat
    var isCollided: Bool
    
    var body: some View {
        Image("avo")
            .resizable()
            .scaledToFit()
            .frame(width: 45)
            .offset(y: avoY)
            .opacity(isCollided ? 0.5 : 1.0) // 충돌 시 반투명하게
            .scaleEffect(isCollided ? 0.9 : 1.0) // 충돌 시 약간 축소
    }
}

// 장애물 뷰 - 이미지 사용
struct ObstacleView: View {
    var obstacle: Obstacle
    
    var body: some View {
        Image(obstacle.type)
            .resizable()
            .scaledToFit()
            .frame(width: 20, height: obstacle.height)
            .offset(x: obstacle.x, y: 0)
    }
}

// 메인 게임 뷰
struct AvoJumpView: View {
    @StateObject private var gameState = GameState()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 배경 이미지
                Image("background") // Assets에 추가할 배경 이미지 이름
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                
                
                // 바닥선
                Rectangle()
                    .fill(Color.white).opacity(0)
                    .frame(height: 2)
                    .offset(y: 32)
                
                // 아보카도
                avoView(avoY: gameState.avoY, isCollided: gameState.isCollided)
                    .position(x: 50, y: geometry.size.height / 2 + 20)
                
                // 장애물들
                ForEach(gameState.obstacles) { obstacle in
                    ObstacleView(obstacle: obstacle)
                        .position(x: obstacle.x, y: geometry.size.height / 2 + 20)
                }
                
                // 점수
                Text("Record: \(gameState.highScore)")
                    .font(.system(size: 12))
                    .foregroundColor(Color.white)
                    .position(x: geometry.size.width / 2, y: 0)
                
                Text("Score: \(gameState.score)")
                    .font(.system(size: 12))
                    .foregroundColor(Color.gray)
                    .position(x: geometry.size.width / 2, y: 20)
                
                
                // 게임오버 표시
                if gameState.gameOver {
                    ZStack {
                        Color.black
                            .edgesIgnoringSafeArea(.all)
                            .opacity(0.8)
                        
                        
                        VStack(spacing: 5) {
                            
                            Text("GAME OVER!")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color("Color2"))
                            
                            
                            Text("Score: \(gameState.score)")
                                .font(.system(size: 12))
                                .foregroundColor(.white)
                                .padding(10)
                            
                            Button("RETRY") {
                                gameState.startGame()
                            }
                            .padding(8)
                            .font(.headline)
                            .background(Color("Color4"))
                            .foregroundColor(Color.white)
                            .cornerRadius(28)
                        }
                        .padding(10)
                        
                        Button(action: {
                            // 게임 상태 초기화 및 시작 화면으로 돌아가기
                            gameState.gameOver = false
                            gameState.isPlaying = false
                            gameState.obstacles = []
                            gameState.timer?.invalidate()
                            gameState.timer = nil
                        }) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color("Color4").opacity(0.8))
                                .clipShape(Circle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        .position(x: 30, y: geometry.size.height * 0.15)
                        
                    }
                }
                
                // 시작 화면
                if !gameState.isPlaying && !gameState.gameOver {
                    ZStack {
                        // 배경 색상
                        Color.black.opacity(0.8)
                            .edgesIgnoringSafeArea(.all)
                        
                        // 컨텐츠를 정중앙에 배치하고 화면 크기에 맞게 조정
                        GeometryReader { startScreenGeo in
                            VStack(spacing: 15) {
                                
                                // 이미지 크기를 화면 비율에 맞게 조정
                                Image("hi_avo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: startScreenGeo.size.height * 0.7) // 화면 너비의 60%로 제한
                                
                                Button("START") {
                                    gameState.startGame()
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 10)
                                .font(.headline)
                                .background(Color("Color3"))
                                .foregroundColor(Color("Color2"))
                                .cornerRadius(50)
                                
                            }
                            .frame(width: startScreenGeo.size.width, height: startScreenGeo.size.height)
                            .position(x: startScreenGeo.size.width / 2, y: startScreenGeo.size.height / 2)
                        }
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
