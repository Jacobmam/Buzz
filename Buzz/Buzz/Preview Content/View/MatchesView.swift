import SwiftUI

struct MatchesView: View {
    var body: some View {
        ZStack {
            

            VStack(spacing: 10) {
        
                    Text("1vs1")
                        .font(.system(size: 25))
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical,10)
                        .background(.black)
                        .foregroundColor(.orange)
                        .cornerRadius(12)
                        .padding(.horizontal,16)
              
                    
              
                HStack(alignment: .center, spacing: 16) {

                    // "me" card
                    VStack(spacing: 6) {
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28, height: 28)

                        Text("me")
                            .font(.headline)
                            .fontWeight(.bold)
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

                        Text("you")
                            .font(.headline)
                            .fontWeight(.bold)
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
                }) {
                    Text("Cancel")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.black.opacity(0.8), .red]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: .orange.opacity(0.4), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 20)
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

#Preview {
    MatchesView()
}

//#Preview {
//    MatchesView()
//}
