//
//  RegisterView.swift
//  Buzz
//
//  Created by Jacob Mampuya on 20.02.25.
//


import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = RegisterViewModel()
    
    private var minBirthDate: Date {
        Calendar.current.date(byAdding: .year, value: -6, to: Date()) ?? Date()
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                headerView
                
                VStack(spacing: 15) {
                    TextField("Vorname", text: $viewModel.firstName)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(lineWidth: 0.5)
                        }
                        .cornerRadius(10)
                    
                    TextField("Nachname", text: $viewModel.lastName)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(lineWidth: 0.5)
                        }
                        .cornerRadius(10)
                    
                    TextField("E-Mail", text: $viewModel.email)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(lineWidth: 0.5)
                        }
                        .cornerRadius(10)
                        .keyboardType(.emailAddress)
                    
                    
                    DatePicker("Geburtstag", selection: $viewModel.birthDate, in: ...minBirthDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(lineWidth: 0.5)
                        }
                        .cornerRadius(10)
                    
                    
                    TextField("Benutzername", text: $viewModel.username)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(lineWidth: 0.5)
                        }
                        .cornerRadius(10)
                    
                    
                    SecureField("Passwort", text: $viewModel.password)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(lineWidth: 0.5)
                        }
                        .cornerRadius(10)
                }
                .padding(.horizontal, 30)
                
                Button {
                    viewModel.register { _ in }
                } label: {
                    Text("REGISTRIEREN")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(viewModel.isFilledOut ? Color.orange : Color.gray)
                        .cornerRadius(10)
                        .padding(.horizontal, 30)
                }
                .disabled(!viewModel.isFilledOut)
                
                Spacer()
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
                    .scaledToFit()
                    .tint(.orange)
                    .frame(height: 20)
                    .bold()
            }
            .frame(width: 50, height: 50)
            
            Text("Registrieren")
                .fontWeight(.bold)
                .foregroundColor(.orange)
                .font(.system(size: 20))
            
            Spacer()
        }
        .padding(.leading, 10)
        .padding(.trailing, 30)
    }
}

#Preview {
    RegisterView()
}
