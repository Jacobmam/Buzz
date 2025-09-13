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
            VStack(alignment: .leading, spacing: 20) {
                headerView
                completedRegistrationStepsView
                VStack {
                    switch viewModel.registrationSteps {
                    case .emailVerification:
                        emailVerificationView
                    case .phoneVerification:
                        phoneVerificationView
                    case .name:
                        getFirstNameLastNameView
                    case .gender:
                        getGenderView
                    case .position:
                        positionView
                    case .birthDate:
                        getBirthdateView
                    case .username:
                        chooseUsernameView
                    case .password:
                        choosePasswordView
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer()
            }
            if viewModel.isLoading {
                JBLoadingView()
            }
            if viewModel.emailVerification.isLoading {
                JBLoadingView()
            }
            if viewModel.phoneVerification.isLoading {
                JBLoadingView()
            }
        }
        .alert(isPresented: $viewModel.showError) {
            Alert(
                title: Text(viewModel.errorTitle),
                message: Text(viewModel.errorMessage ?? ""),
                dismissButton: .default(Text("OK")) {
                    if viewModel.errorTitle == "Registration Complete" {
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
            
            Text("Register")
                .fontWeight(.bold)
                .foregroundColor(.orange)
                .font(.system(size: 20))
            
            Spacer()
        }
        .padding(.leading, 10)
        .padding(.trailing, 30)
    }
    
    var completedRegistrationStepsView: some View {
        
        Text("\(viewModel.getRegistrationStepNumber()) / 8 Steps")
            .font(.system(size: 16, weight: .light))
            .foregroundStyle(.orange)
            .padding(.horizontal)
            .padding(.vertical, 6)
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(lineWidth: 0.5)
                    .foregroundStyle(.orange)
            }
            .padding(.horizontal, 30)
    }
    
    // 1
    var emailVerificationView: some View {
        ZStack {
            VStack(alignment: .leading) {
                Text("Hey, What's your email ?")
                    .font(.system(size: 26, weight: .bold))
                    .multilineTextAlignment(.leading)
                
                EmailVerificationView(emailVerification: $viewModel.emailVerification,
                                      onTapVerifyEmail: {
                    viewModel.sendEmailOtp(email: viewModel.emailVerification.email) { success, message in
                        DispatchQueue.main.async {
                            viewModel.emailVerification.isEmailVerificationCodeSent = success
                            if success == false && message == "Email already registered." {
                                viewModel.errorTitle = "Email already registered"
                                viewModel.errorMessage = "Please register with another email, this email is already registered."
                                viewModel.showError = true
                            }
                        }
                    }
                },
                                      onTapVerifyEmailOTP: {
                    viewModel.verifyEmailOtp(email: viewModel.emailVerification.email,
                                             otp: viewModel.emailVerification.otp) {  success, message, recordId in
                        DispatchQueue.main.async {
                            viewModel.emailVerification.isEmailVerified = success
                            viewModel.recordId  = recordId ?? ""
                        }
                    }
                })
                
                if viewModel.emailVerification.isEmailVerified {
                    HStack {
                        Spacer()
                        
                        Button {
                            viewModel.registrationSteps = .phoneVerification
                        } label: {
                            Text("NEXT")
                                .foregroundStyle(.white)
                                .font(.system(size: 16, weight: .heavy))
                                .padding()
                        }
                        .background(.orange)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
            
            
        }
    }
    
    var getFirstNameLastNameView: some View {
        ZStack {
            VStack(alignment: .leading) {
                Text("Hey, what's your name?")
                    .font(.system(size: 26, weight: .bold))
                    .multilineTextAlignment(.leading)
                
                HStack(spacing: 20) {
                    TextField("First Name", text: $viewModel.firstName)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(lineWidth: 0.5)
                        }
                        .cornerRadius(10)
                    
                    TextField("Last Name", text: $viewModel.lastName)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(lineWidth: 0.5)
                        }
                        .cornerRadius(10)
                }
                .padding(.vertical)
                
                HStack {
                    Spacer()
                    
                    Button {
                        HelperClass.shared.endEditing()
                        viewModel.validateFirstAndLastName()
                    } label: {
                        Text("NEXT")
                            .foregroundStyle(.white)
                            .font(.system(size: 16, weight: .heavy))
                            .padding()
                    }
                    .background(.orange)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            
        }
    }
    
    var getBirthdateView: some View {
        VStack(alignment: .leading) {
            Text("\(viewModel.firstName), what's your birthdate?")
                .font(.system(size: 26, weight: .bold))
                .multilineTextAlignment(.leading)
            
            DatePicker(
                "Select Date",
                selection: $viewModel.birthDate,
                in: ...Date(),
                displayedComponents: .date // Or .dateAndtime, .hourAndMinute
            )
            .tint(.orange)
            .datePickerStyle(.graphical) // Or .compact, .wheel
            .padding(.vertical)
            
            HStack {
                Spacer()
                
                Button {
                    //                    viewModel.registrationSteps = .username
                    viewModel.updateBirthdate()
                } label: {
                    Text("NEXT")
                        .foregroundStyle(.white)
                        .font(.system(size: 16, weight: .heavy))
                        .padding()
                }
                .background(.orange)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
    
    var getGenderView: some View {
        VStack(alignment: .leading) {
            Text("Choose your gender \(viewModel.firstName)!")
                .font(.system(size: 26, weight: .bold))
                .multilineTextAlignment(.leading)
            
            HStack(spacing: 20) {
                Button {
                    if viewModel.isSelectedGenderFemale {
                        viewModel.isSelectedGenderFemale = false
                        viewModel.gender = "male"
                    }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: viewModel.isSelectedGenderFemale == false ? "checkmark.circle.fill" : "circle")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 22)
                        Text("Male")
                            .font(.system(size: 30, weight: .semibold))
                    }
                    .foregroundStyle(viewModel.isSelectedGenderFemale == false ? .orange : .white)
                }
                
                Button {
                    if !viewModel.isSelectedGenderFemale {
                        viewModel.isSelectedGenderFemale = true
                        viewModel.gender = "female"
                    }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: viewModel.isSelectedGenderFemale == true ? "checkmark.circle.fill" : "circle")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 22)
                        Text("Female")
                            .font(.system(size: 30, weight: .semibold))
                    }
                    .foregroundStyle(viewModel.isSelectedGenderFemale == true ? .orange : .white)
                }
            }
            .padding(.vertical)
            
            HStack {
                Spacer()
                
                Button {
                    viewModel.updateGender()
                } label: {
                    Text("NEXT")
                        .foregroundStyle(.white)
                        .font(.system(size: 16, weight: .heavy))
                        .padding()
                }
                .background(.orange)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
    
    var positionView: some View {
        VStack(alignment: .leading) {
            Text("Let's pick your position!")
                .font(.system(size: 26, weight: .bold))
                .multilineTextAlignment(.leading)
            GeometryReader { geometry in
                Image("positions")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        // Button overlay
                        ButtonOverlay(
                            geometry: geometry,
                            imageSize: CGSize(width: viewModel.imageWidth, height: viewModel.imageHeight),
                            buttons: viewModel.buttons,
                            selectedButton: $viewModel.selectedPositionButton
                        )
                    )
                    .clipped()
            }
            HStack {
                Spacer()
                Button {
                    viewModel.updatePosition()
                } label: {
                    Text("NEXT")
                        .foregroundStyle(.white)
                        .font(.system(size: 16, weight: .heavy))
                        .padding()
                }
                .background(.orange)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .disabled(viewModel.selectedPositionButton == nil)
                .opacity(viewModel.selectedPositionButton == nil ? 0.5 : 1)
            }
            
        }
    }
    
    var phoneVerificationView: some View {
        VStack(alignment: .leading) {
            Text("Let's verify your phone number!")
                .font(.system(size: 26, weight: .bold))
                .multilineTextAlignment(.leading)
            
            PhoneNumberVerificationView(phoneVerification: $viewModel.phoneVerification,
                                        onTapSendOTPForPhone: {
                viewModel.phoneNumberValidation()
            },
                                        onTapResendOTPForPhone: {
                viewModel.phoneNumberValidation()
            },
                                        onTapVerifyPhoneOTP: {
                viewModel.verifyOTPForPhoneNumber()
            })
            
            if viewModel.phoneVerification.isPhoneNumberVerified {
                HStack {
                    Spacer()
                    
                    Button {
                        viewModel.registrationSteps = .name
                    } label: {
                        Text("NEXT")
                            .foregroundStyle(.white)
                            .font(.system(size: 16, weight: .heavy))
                            .padding()
                    }
                    .background(.orange)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
    }
    
    var chooseUsernameView: some View {
        VStack(alignment: .leading) {
            Text("It's time choose your username.")
                .font(.system(size: 26, weight: .bold))
                .multilineTextAlignment(.leading)
            
            VStack(alignment: .leading) {
                TextField("username", text: $viewModel.username)
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(lineWidth: 0.5)
                    }
                    .cornerRadius(10)
                    .textInputAutocapitalization(.never) // prevent system auto-capitalization
                    .autocorrectionDisabled(true)
                
                Text("Username should be atleast 4 characters long!")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(.yellow)
                    .padding(.horizontal)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .layoutPriority(1)
            }
            .padding(.vertical)
            
            switch viewModel.usernameAvailabilityStatus {
            case .none:
                VStack {
                    Text("")
                }
            case .checking:
                HStack {
                    ProgressView()
                        .tint(.orange)
                    Text("Checking")
                        .font(.system(size: 16, weight: .regular))
                }
                .foregroundStyle(.orange)
                .padding(.horizontal)
                
            case .available:
                HStack {
                    Image(systemName: "checkmark")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 12)
                    
                    Text("Available")
                        .font(.system(size: 16, weight: .regular))
                }
                .foregroundStyle(.green)
                .padding(.horizontal)
            case .unavailable:
                HStack {
                    Image(systemName: "xmark")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 12)
                    
                    Text("Not available!")
                        .font(.system(size: 16, weight: .regular))
                }
                .foregroundStyle(.red)
                .padding(.horizontal)
            case .invalid:
                HStack {
                    Text("❌ Username can only contain lowercase letters, numbers, '.', and '_' with no spaces or emojis.")
                        .font(.system(size: 16, weight: .regular))
                }
                .foregroundStyle(.red)
                .padding(.horizontal)
            }
            
            HStack {
                Spacer()
                Button {
                    
                    if viewModel.usernameAvailabilityStatus == .available {
                        HelperClass.shared.endEditing()
                        viewModel.updateUsername()
                    }
                } label: {
                    Text("NEXT")
                        .foregroundStyle(.white)
                        .font(.system(size: 16, weight: .heavy))
                        .padding()
                }
                .background(.orange)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .disabled(!(viewModel.usernameAvailabilityStatus == .available))
                .opacity(!(viewModel.usernameAvailabilityStatus == .available) ? 0.5 : 1)
            }
        }
    }
    
    var choosePasswordView: some View {
        ZStack {
            VStack(alignment: .leading) {
                Text("Choose your secure password")
                    .font(.system(size: 26, weight: .bold))
                    .multilineTextAlignment(.leading)
                
                VStack(alignment: .leading) {
                    TextField("Choose Password", text: $viewModel.password)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(lineWidth: 0.5)
                        }
                        .cornerRadius(10)
                    
                    Text("Password should be atleast 8 characters long!")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(.yellow)
                        .padding(.horizontal)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .layoutPriority(1)
                }
                .padding(.vertical)
                
                HStack {
                    Spacer()
                    Button {
                        HelperClass.shared.endEditing()
                        //                        viewModel.validatePassword()
                        let (isValid, message) = HelperClass.shared.validatePassword(password: viewModel.password)
                        if isValid {
                            viewModel.updatePassword()
                        } else {
                            viewModel.errorTitle = "Error"
                            viewModel.errorMessage = message
                            viewModel.showError = true
                        }
                        
                    } label: {
                        Text("LET'S GO")
                            .foregroundStyle(.white)
                            .font(.system(size: 16, weight: .heavy))
                            .padding()
                    }
                    .background(.orange)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .alert(isPresented: $viewModel.showError) {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.errorMessage ?? ""),
                dismissButton: .default(Text("OK")) {
                    
                }
            )
        }
    }
}

// MARK: - Reusable Action Button
struct ActionButton: View {
    let button: ImageButton
    let action: () -> Void
    @Binding var selectedButton: ImageButton?
    //    let buttonId: Int
    
    var body: some View {
        Button(action: action) {
            Text(button.title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(selectedButton?.id == button.id ? .green : .orange)
                .clipShape(RoundedRectangle(cornerRadius: 22))
                .shadow(color: .black.opacity(0.75),
                        radius: 4,
                        x: 2, y: 2)
        }
    }
}

struct ButtonOverlay: View {
    let geometry: GeometryProxy
    let imageSize: CGSize
    let buttons: [ImageButton]
    @Binding var selectedButton: ImageButton?
    
    
    var body: some View {
        ZStack {
            ForEach(buttons, id: \.id) { button in
                ActionButton(
                    button: button,
                    action: { handleAction(button) },
                    selectedButton: $selectedButton,
                    
                )
                .position(calculatePosition(for: button))
            }
        }
    }
    
    private func calculatePosition(for button: ImageButton) -> CGPoint {
        // Calculate the actual image frame within the geometry
        let containerSize = geometry.size
        let imageAspectRatio = imageSize.width / imageSize.height
        let containerAspectRatio = containerSize.width / containerSize.height
        
        let imageFrame: CGRect
        
        if imageAspectRatio > containerAspectRatio {
            // Image is wider - fit to width
            let displayHeight = containerSize.width / imageAspectRatio
            let yOffset = (containerSize.height - displayHeight) / 2
            imageFrame = CGRect(x: 0, y: yOffset,
                                width: containerSize.width, height: displayHeight)
        } else {
            // Image is taller - fit to height
            let displayWidth = containerSize.height * imageAspectRatio
            let xOffset = (containerSize.width - displayWidth) / 2
            imageFrame = CGRect(x: xOffset, y: 0,
                                width: displayWidth, height: containerSize.height)
        }
        
        // Convert percentage to actual position
        let x = imageFrame.minX + (button.x * imageFrame.width)
        let y = imageFrame.minY + (button.y * imageFrame.height)
        
        return CGPoint(x: x, y: y)
    }
    
    private func handleAction(_ button: ImageButton) {
        switch button.id {
        case 1: selectedButton = button
        case 2: selectedButton = button
        case 3: selectedButton = button
        case 4: selectedButton = button
        case 5: selectedButton = button
            
        default: break
        }
    }
}

struct ImageButton: Identifiable {
    var id: Int
    let x: CGFloat  // 0.0 to 1.0 (left to right)
    let y: CGFloat  // 0.0 to 1.0 (top to bottom)
    let title: String
}
#Preview {
    RegisterView()
}
