//
//  MainGameView.swift
//  Buzz
//
//  Created by Harshil Gajjar on 02/08/25.
//

import SwiftUI

struct MainGameView: View {
    
    var body: some View {
        ZStack {
            
            
            VStack(spacing: 0) {
                VStack(spacing: 15) {
                    HStack {
                        HStack {
                            Image(systemName: "basketball")
                                .resizable()
                                .frame(width: 20, height: 20)
                            Text("1v1")
                                .font(.system(size: 20))
                                .bold()
                        }
                        .padding()
                        .background(.black)
                        .foregroundColor(.white)
                        .cornerRadius(30)
                        Spacer()
                        Text("Jay vs Mansi")
                            .font(.system(size: 25))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.orange.opacity(0.5))
                        .shadow(color: .orange.opacity(0.3), radius: 10, x: 0, y: 8)
                )
                .padding()
                HStack {
                    Text("Just now")
                        .font(.system(size: 15))
                        .fontWeight(.light)
                        .foregroundColor(.white)
                    Spacer()
                    Button {
                        
                    } label: {
                        Text("Reject")
                            .padding(10)
                            .bold()
                    }
                    .tint(.white)
                    .background(.red)
                    .cornerRadius(12)
                    Button {
                        
                    } label: {
                        Text("Accept")
                            .padding(10)
                            .bold()
                    }
                    .tint(.white)
                    .background(.green)
                    .cornerRadius(12)
                    
                   
                }
                .padding(.horizontal,20)
                Divider()
                    .background(.white)
                    .padding()
            }
        }
    }
}

#Preview {
    MainGameView()
}
