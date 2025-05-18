//
//  AvoJumpView.swift
//  AvoJump
//
//  Created by Niko on 5/18/25.
//

import SwiftUI

// iOS용 아보카도 뷰
struct AvoViewIOS: View {
    var avoY: CGFloat
    var isCollided: Bool
    
    var body: some View {
        Image("avo")
            .resizable()
            .scaledToFit()
            .frame(width: 60) // iOS에서는 더 크게 표시
            .offset(y: avoY)
            .opacity(isCollided ? 0.5 : 1.0)
            .scaleEffect(isCollided ? 0.9 : 1.0)
    }
}

// iOS용 장애물 뷰
struct ObstacleViewIOS: View {
    var obstacle: Obstacle
    
    var body: some View {
        Image(obstacle.type)
            .resizable()
            .scaledToFit()
            .frame(width: 30, height: obstacle.height * 1.5) // iOS에서는 더 크게 표시
            .offset(x: obstacle.x, y: 0)
    }
}

// iOS용 메인 게임 뷰
struct AvoJumpIOSView: View {
    @StateObject private var gameState = GameState()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 배경 이미지
                Image("background")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .edgesIgnoringSafeArea(.all)
                
                // 바닥선
                Rectangle()
                    .fill(Color.white).opacity(0)
                    .frame(height: 2)
                    .offset(y: 50)
                
                // 아보카도
                AvoViewIOS(avoY: gameState.avoY, isCollided: gameState.isCollided)
                    .position(x: geometry.size.width * 0.2, y: geometry.size.height / 2 + 50)
                
                // 장애물들 - iOS에서는 화면 크기에 맞게 위치 조정
                ForEach(gameState.obstacles) { obstacle in
                    ObstacleViewIOS(obstacle: obstacle)
                        .position(
                            x: obstacle.x + geometry.size.width * 0.1,
                            y: geometry.size.height / 2 + 50
                        )
                }
                
                // 점수 - iOS에서는 더 크게 표시
                VStack {
                    Text("Record: \(gameState.highScore)")
                        .font(.system(size: 20))
                        .foregroundColor(Color.white)
                    
                    Text("Score: \(gameState.score)")
                        .font(.system(size: 18))
                        .foregroundColor(Color.gray)
                }
                .position(x: geometry.size.width / 2, y: 50)
                
                // 게임오버 표시
                if gameState.gameOver {
                    ZStack {
                        Color.black.opacity(0.8)
                            .edgesIgnoringSafeArea(.all)
                        
                        VStack(spacing: 15) {
                            Text("GAME OVER!")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(Color("Color2"))
                            
                            Text("Score: \(gameState.score)")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .padding(15)
                            
                            Button("RETRY") {
                                gameState.startGame()
                            }
                            .padding(12)
                            .font(.title3)
                            .background(Color("Color4"))
                            .foregroundColor(Color.white)
                            .cornerRadius(28)
                        }
                        .padding(20)
                    }
                }
                
                // 시작 화면
                if !gameState.isPlaying && !gameState.gameOver {
                    ZStack {
                        Color.black.opacity(0.5)
                            .edgesIgnoringSafeArea(.all)
                        
                        VStack {
                            Text("Avo Jump")
                                .font(.largeTitle)
                                .bold()
                                .padding(.bottom, 30)
                                .foregroundColor(Color.white)
                            
                            Button("START") {
                                gameState.startGame()
                            }
                            .padding(15)
                            .font(.title2)
                            .background(Color("Color3"))
                            .foregroundColor(Color("Color2"))
                            .cornerRadius(50)
                        }
                        .padding(20)
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
struct AvoJumpIOSView_Previews: PreviewProvider {
    static var previews: some View {
        AvoJumpIOSView()
    }
}
