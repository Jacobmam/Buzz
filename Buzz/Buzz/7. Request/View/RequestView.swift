//
//  RequestView.swift
//  Buzz
//
//  Created by Harshil Gajjar on 02/08/25.

import SwiftUI

struct RequestView: View {
    @State private var selectedSegment = 0
    @Environment(\.dismiss) private var dismiss
    @StateObject private var requestViewModel = RequestViewModel()
    
    var body: some View {
        ZStack {
            VStack {
                headerView
                
                // Native Segmented Picker
                Picker("Request Type", selection: $selectedSegment) {
                    
                    Text("Received").tag(0)
                        .font(.headline)
                    Text("Sent").tag(1)
                        .font(.headline)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal,15)
                .padding(.bottom, 10)
                
                requestListView
                
                Spacer()
            }
            .onAppear {
                if let currentId = UserLoginCache.get()?.id {
                    requestViewModel.fetchRequests(for: currentId)
                }
            }
        }
        .alert(isPresented: $requestViewModel.showResponseMessage, content: {
            Alert(title: Text("Sucess"),
                  message: Text(requestViewModel.responseMessage ?? ""),
                  dismissButton: .default(Text("OK")) {
                if requestViewModel.acceptedRequestId.count > 0 {
                    requestViewModel.navigateToGameScoreboardView.toggle()
                }
            })
        })
        .navigate(to: GameScoreboardView(requestId: requestViewModel.acceptedRequestId), when: $requestViewModel.navigateToGameScoreboardView)
    }
    
    // MARK: - List View based on Segment
    private var requestListView: some View {
        ScrollView {
            if requestViewModel.isLoading {
                ProgressView("Loading...")
                    .foregroundColor(.white)
                    .padding(.top)
            } else {
                VStack(spacing: 12) {
                    if selectedSegment == 1 {
                        if requestViewModel.sentRequests.count > 0 {
                            ForEach(requestViewModel.sentRequests) { request in
                                RequestCardView(
                                    title: "Sent to:",
                                    opponentusername: request.opponentUsername,
                                    myUserName: UserLoginCache.get()?.username ?? "Me",
                                    gameType: request.gameType,
                                    
                                    onTapCancelRequest: {
                                        requestViewModel.changeRequestStatus(request, .cancelled)
                                    }
                                )
                            }
                        } else {
                            Text("No request found")
                                .foregroundStyle(.white)
                        }
                    } else {
                        if requestViewModel.receivedRequests.count > 0 {
                            ForEach(requestViewModel.receivedRequests) { request in
                                RecivedRequestCardView(
                                    title: "From:",
                                    opponentusername: request.opponentUsername,
                                    myUserName: UserLoginCache.get()?.username ?? "Me",
                                    gameType: request.gameType,
                                    requestedAt: request.requestedAt,
                                    requestStatus: request.requestStatus,
                                    onTapAcceptRequest: {
                                        requestViewModel.changeRequestStatus(request, .accepted)
                                    },
                                    onTapRejectRequest: {
                                        requestViewModel.changeRequestStatus(request, .rejected)
                                    }
                                )
                            }
                        } else {
                            Text("No request found")
                                .foregroundStyle(.white)
                        }
                    }
                }
                .padding(.vertical)
            }
        }
    }
    var headerView: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .resizable()
                    .tint(.orange)
                    .frame(width: 12, height: 20)
                    .bold()
            }
            .frame(width: 50, height: 50)
            Text("Game Request")
                .fontWeight(.bold)
                .foregroundColor(.orange)
                .font(.system(size: 30))
            Spacer()
        }
        .padding(.leading, 7)
        .padding(.trailing)
        
    }
}

// MARK: - Reusable Request Card View
struct RequestCardView: View {
    let title: String
    let opponentusername: String
    let myUserName: String
    let gameType: String
    var onTapCancelRequest: (() -> Void)
    var body: some View {
        ZStack {
            
            VStack(spacing: 15) {
                Text(gameType)
                    .font(.system(size: 25))
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical,10)
                    .background(.black)
                    .foregroundColor(.orange)
                    .cornerRadius(12)
                    .padding(.horizontal,16)
                HStack(alignment: .center, spacing: 16) {
                    VStack(spacing: 6) {
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28, height: 28)
                        
                        Text(myUserName)
                            .font(.headline)
                            .fontWeight(.bold)
                            .lineLimit(1)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.black.opacity(0.8), .orange]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .foregroundColor(.white)
                    .shadow(color: .orange.opacity(0.4), radius: 4, x: 0, y: 3)
                    
                    // "VS" text
                    Text("VS")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    
                    // "you" card
                    VStack(spacing: 6) {
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28, height: 28)
                        
                        Text(opponentusername)
                            .font(.headline)
                            .fontWeight(.bold)
                            .lineLimit(1)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.black.opacity(0.8), .green]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .foregroundColor(.white)
                    .shadow(color: .green.opacity(0.4), radius: 4, x: 0, y: 3)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                
                // Cancel Button
                Button(action: {
                    // Cancel logic here
                    onTapCancelRequest()
                }) {
                    Text("Cancel")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.red.opacity(0.8), .red]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.4), radius:2, x: 0, y: 4)
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 30)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: .orange.opacity(0.3), radius: 10, x: 0, y: 8)
            )
            .padding()
        }
    }
}

struct RecivedRequestCardView: View {
    let title: String
    let opponentusername: String
    let myUserName: String
    let gameType: String
    let requestedAt: String
    let requestStatus: Int
    var onTapAcceptRequest: (() -> Void)
    var onTapRejectRequest: (() -> Void)
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                VStack(spacing: 15) {
                    HStack {
                        HStack {
                            Image(systemName: "basketball")
                                .resizable()
                                .frame(width: 20, height: 20)
                            Text(gameType)
                                .font(.system(size: 20))
                                .bold()
                        }
                        .padding()
                        .background(.black)
                        .foregroundColor(.white)
                        .cornerRadius(30)
                        Spacer()
                        Text("\(opponentusername) vs You")
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
                    Text("\(HelperClass.shared.timeAgoString(from: requestedAt))")
                        .font(.system(size: 15))
                        .fontWeight(.light)
                        .foregroundColor(.white)
                    Spacer()
                    Button {
                        onTapRejectRequest()
                    } label: {
                        Text("Reject")
                            .padding(10)
                            .bold()
                    }
                    .tint(.white)
                    .background(.red)
                    .cornerRadius(12)
                    Button {
                        onTapAcceptRequest()
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
    RequestView()
}


