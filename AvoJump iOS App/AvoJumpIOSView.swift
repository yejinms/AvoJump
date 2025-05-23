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
            .frame(width: 70) // iOS에서는 더 크게 표시
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

// 배경 뷰를 별도로 분리
struct BackgroundView: View {
    var body: some View {
        GeometryReader { geo in
            Image("background")
                .resizable()
                .scaledToFill()
                .frame(width: geo.size.width, height: geo.size.height + 100) // 하단에 여분 높이 추가
                .offset(y: -50) // 이미지를 위로 올려서 하단이 더 많이 보이게 함
                .edgesIgnoringSafeArea(.all)
        }
    }
}

// iOS용 메인 게임 뷰
struct AvoJumpIOSView: View {
    @StateObject private var gameState = GameState()
    
    var body: some View {
        ZStack {
            // 배경 뷰
            BackgroundView()
            
            GeometryReader { geometry in
                ZStack {
                    // 바닥선
                    Rectangle()
                        .fill(Color.white).opacity(0.5)
                        .frame(height:3)
                        .offset(y: 65)
                    
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
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color.white)
                            .padding(5)
                        
                        Text("Score: \(gameState.score)")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color.gray)
                    }
                    .position(x: geometry.size.width / 2, y: 150)
                    
                    // 게임오버 표시
                    if gameState.gameOver {
                        ZStack {
                            Color.black.opacity(0.8)
                                .edgesIgnoringSafeArea(.all)
                            
                            // 뒤로 가기 버튼
                            Button(action: {
                                // 게임 상태 초기화 및 시작 화면으로 돌아가기
                                gameState.gameOver = false
                                gameState.isPlaying = false
                                gameState.obstacles = []
                                gameState.timer?.invalidate()
                                gameState.timer = nil
                            }) {
                                Image(systemName: "arrow.left")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(15)
                                    .background(Color("Color4").opacity(0.8))
                                    .clipShape(Circle())
                            }
                            .position(x: 60, y: 100) // 좌측 상단에 위치
                            
                            VStack(spacing: 15) {
                                Text("GAME OVER!")
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundColor(Color("Color2"))
                                
                                Text("Score: \(gameState.score)")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(15)
                                
                                Button("RETRY") {
                                    gameState.startGame()
                                }
                                .padding(.horizontal, 60)
                                .padding(.vertical, 20)
                                .font(.system(size: 24, weight:.bold))
                                .background(Color("Color4"))
                                .foregroundColor(Color.white)
                                .cornerRadius(50)
                            }
                            .padding(20)
                        }
                    }
                    
                    // 시작 화면
                    if !gameState.isPlaying && !gameState.gameOver {
                        ZStack {
                            Color.black.opacity(0.8)
                                .edgesIgnoringSafeArea(.all)
                            
                            VStack {
                                Text("Avo Jump")
                                    .font(.largeTitle)
                                    .bold()
                                    .padding(.bottom, 30)
                                    .foregroundColor(Color.white)
                                
                                Image("hi_avo")
                                    .padding(.bottom, 30)
                                Button("START") {
                                    gameState.startGame()
                                }
                                .padding(.horizontal, 60)
                                .padding(.vertical, 20)
                                .font(.system(size: 24, weight:.bold))
                                .background(Color("Color3"))
                                .foregroundColor(Color("Color2"))
                                .cornerRadius(50)
                            }
                            .padding(20)
                        }
                    }
                }
            }
        }
        .ignoresSafeArea() // 전체 뷰에서 SafeArea 무시
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

// 프리뷰
struct AvoJumpIOSView_Previews: PreviewProvider {
    static var previews: some View {
        AvoJumpIOSView()
    }
}
