//
//  RegisterView.swift
//  Buzz
//
//  Created by Jacob Mampuya on 20.02.25.
//


import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel = RegisterViewModel()
    private var minBirthDate: Date {
        Calendar.current.date(byAdding: .year, value: -6, to: Date()) ?? Date()
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                
                Text("Registrieren")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                VStack(spacing: 15) {
                    TextField("Vorname", text: $viewModel.firstName)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                  
                    TextField("Nachname", text: $viewModel.lastName)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)

                    TextField("Vollständiger Name", text: $viewModel.fullName)
                        .padding()
                        .background(Color.white.opacity(0.6))
                        .cornerRadius(10)
                        .disabled(true)
                    
                 
                    TextField("E-Mail", text: $viewModel.email)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .keyboardType(.emailAddress)
                    
                   
                    DatePicker("Geburtstag", selection: $viewModel.birthDate, in: ...minBirthDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                    
                   
                    TextField("Benutzername", text: $viewModel.username)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                    
                
                    SecureField("Passwort", text: $viewModel.password)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 30)
                
                Button(action: {
                    viewModel.register { _ in }
                }) {
                    Text("REGISTRIEREN")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(viewModel.isFormValid ? Color.orange : Color.gray)
                        .cornerRadius(10)
                        .padding(.horizontal, 30)
                }
                .disabled(!viewModel.isFormValid)
                
                Spacer()
            }
        }
    }
}

#Preview {
    RegisterView()
}
