//
//  EditProfileView.swift
//  Buzz
//
//  Created by Jay Borania on 05/09/25.
//

import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userStateViewModel: UserStateViewModel
    @StateObject private var editProfileViewModel = EditProfileViewModel()
    var body: some View {
        ZStack {
            VStack {
                ScrollView {
                    headerView
                    editDetailView
                }
                Spacer()
                saveButtonView
            }
            if editProfileViewModel.showDatePicker {
                birthdatePickerView
                    .background(.black)
            }
            if editProfileViewModel.isLoading {
                JBLoadingView()
            }
        }
        .onAppear() {
            editProfileViewModel.getProfileData()
        }
        .alert(isPresented: $editProfileViewModel.showError) {
            Alert(
                title: Text(editProfileViewModel.errorTitle),
                message: Text(editProfileViewModel.errorMessage),
                dismissButton: .default(Text("OK")) {
                    if editProfileViewModel.errorTitle == "Success" {
                        dismiss()
                    }
                }
            )
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
            
            Text("Edit Profile")
                .fontWeight(.bold)
                .foregroundColor(.orange)
                .font(.system(size: 20))
            
            Spacer()
        }
        .padding(.leading, 10)
        .padding(.trailing, 30)
    }
    
    var editDetailView: some View {
        VStack(alignment: .leading, spacing: 15) {
            userNameView
            firstNameView
            lastNameView
            genderView
            birthdateView
            emailAdressView
            phoneNumberView
        }
        .padding(.horizontal, 30)
    }
    
    var userNameView: some View {
        VStack(alignment: .leading) {
            Text("Username")
                .fontWeight(.regular)
                .foregroundColor(.white)
                .font(.system(size: 15))
            //                .padding(5)
            TextField("Username", text: $editProfileViewModel.username)
                .padding()
                .background(Color.white.opacity(0.2))
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 0.5)
                }
                .cornerRadius(10)
                .disabled(true)
                .opacity(0.5)
        }
    }
    var firstNameView: some View {
        VStack(alignment: .leading) {
            Text("First Name")
                .fontWeight(.regular)
                .foregroundColor(.white)
                .font(.system(size: 15))
            
            TextField("First Name", text: $editProfileViewModel.firstName)
                .padding()
                .background(Color.white.opacity(0.2))
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 0.5)
                }
                .cornerRadius(10)
        }
    }
    var lastNameView: some View {
        VStack(alignment: .leading) {
            Text("Last Name")
                .fontWeight(.regular)
                .foregroundColor(.white)
                .font(.system(size: 15))
            
            TextField("Last Name", text: $editProfileViewModel.lastName)
                .padding()
                .background(Color.white.opacity(0.2))
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 0.5)
                }
                .cornerRadius(10)
        }
    }
    var genderView: some View {
        VStack(alignment: .leading) {
            Text("Gender")
                .fontWeight(.regular)
                .foregroundColor(.white)
                .font(.system(size: 15))
            
            HStack(spacing: 20) {
                Button {
                    if editProfileViewModel.isSelectedGenderFemale {
                        editProfileViewModel.isSelectedGenderFemale = false
                        editProfileViewModel.gender = "male"
                    }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: editProfileViewModel.isSelectedGenderFemale == false ? "checkmark.circle.fill" : "circle")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 22)
                        Text("Male")
                            .font(.system(size: 30, weight: .semibold))
                    }
                    .foregroundStyle(editProfileViewModel.isSelectedGenderFemale == false ? .orange : .white)
                }
                
                Button {
                    if !editProfileViewModel.isSelectedGenderFemale {
                        editProfileViewModel.isSelectedGenderFemale = true
                        editProfileViewModel.gender = "female"
                    }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: editProfileViewModel.isSelectedGenderFemale == true ? "checkmark.circle.fill" : "circle")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 22)
                        Text("Female")
                            .font(.system(size: 30, weight: .semibold))
                    }
                    .foregroundStyle(editProfileViewModel.isSelectedGenderFemale == true ? .orange : .white)
                }
            }
        }
    }
    
    var birthdateView: some View {
        ZStack {
            VStack(alignment: .leading) {
                Text("Birth Date")
                    .fontWeight(.regular)
                    .foregroundColor(.white)
                    .font(.system(size: 15))
                Button {
                    editProfileViewModel.showDatePicker.toggle()
                } label: {
                    TextField("Birth Date", text: $editProfileViewModel.birthDateString)
                        .multilineTextAlignment(.leading)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(lineWidth: 0.5)
                        }
                        .cornerRadius(10)
                        .disabled(true)
                }
            }
        }
    }
    
    var emailAdressView: some View {
        VStack(alignment: .leading) {
            Text("Email Address")
                .fontWeight(.regular)
                .foregroundColor(.white)
                .font(.system(size: 15))
            
            TextField("Email Address", text: $editProfileViewModel.email)
                .padding()
                .background(Color.white.opacity(0.2))
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 0.5)
                }
                .cornerRadius(10)
                .disabled(true)
                .opacity(0.5)
        }
    }
    
    var phoneNumberView: some View {
        VStack(alignment: .leading) {
            Text("Phone Number")
                .fontWeight(.regular)
                .foregroundColor(.white)
                .font(.system(size: 15))
            
            TextField("Phone Number", text: $editProfileViewModel.phoneNumber)
                .padding()
                .background(Color.white.opacity(0.2))
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 0.5)
                }
                .cornerRadius(10)
                .disabled(true)
                .opacity(0.5)
        }
    }
    
    var birthdatePickerView: some View {
        VStack {
            Spacer()
            DatePicker(
                "Select Date",
                selection: $editProfileViewModel.birthDate,
                in: ...Date(),
                displayedComponents: .date // Or .dateAndtime, .hourAndMinute
            )
            .tint(.orange)
            .datePickerStyle(.graphical) // Or .compact, .wheel
            .padding(.vertical)
            HStack {
                Spacer()
                Button {
                    editProfileViewModel.setBirthDateString()
                }  label: {
                    Text("Done")
                        .foregroundStyle(.white)
                        .font(.system(size: 16, weight: .heavy))
                        .padding()
                }
                .background(.orange)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal,30)

            }
            Spacer()
        }
    }
    
    var saveButtonView: some View {
        Button(action: {
            editProfileViewModel.validateprofileData()
        }) {
            Text("Save")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.orange)
                .cornerRadius(10)
                .padding(.horizontal, 30)
            
        }
        .padding(.vertical)
    }
}

#Preview {
    EditProfileView()
}
