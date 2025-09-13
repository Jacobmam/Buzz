//
//  PhoneNumberVerificationView.swift
//  Buzz
//
//  Created by Jay Borania on 19/08/25.
//

import PhoneNumberKit
import SwiftUI

extension Country {
    var flag: String {
        // Convert country code to emoji flag (e.g., "US" -> 🇺🇸)
        let base : UInt32 = 127397
        var s = ""
        for v in code.unicodeScalars {
            s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
        }
        return s
    }
}


struct PhoneNumberVerificationView: View {
    @Binding var phoneVerification: PhoneVerificationModel
    @State private var arrCountries: [Country] = []
    @State private var selectedCountry: Country? = Country(name: "United States", dial_code: "+1", code: "US")
//    @State private var selectedCountry: Country? = Country(name: "India", dial_code: "+91", code: "IN")
  
    @State private var showCountryPicker: Bool = false
    private let phoneNumberUtility = PhoneNumberUtility()
    @State var otpTimer: Timer!
    
    func startResendOTPTimer() {
        guard phoneVerification.resendVerificationCodeLimit > 0 else { return }
        phoneVerification.resendVerificationCodeLimit -= 1
        phoneVerification.resendVerificationCodeCountdown = 60
        otpTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { timer in
            if self.phoneVerification.resendVerificationCodeCountdown > 0 {
                self.phoneVerification.resendVerificationCodeCountdown -= 1
            } else {
                self.otpTimer.invalidate()
            }
        })
    }
    
//    selectedCountry = Country(name: Locale.current.localizedString(forRegionCode: countryCode), dial_code: Locale.current.region, code: Locale.current.region)
//    let countryCode = Locale.current.regionCode!
//    self.lastSelectedCountryName = Locale.current.localizedString(forRegionCode: countryCode)
//    self.lastSelectedCountryCode = countryCode
    
    var onTapSendOTPForPhone: () -> Void
    var onTapResendOTPForPhone: () -> Void
    var onTapVerifyPhoneOTP: () -> Void
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                if let selectedCountry,
                   !phoneVerification.isPhoneNumberVerified {
                    HStack {
                        Button {
                            showCountryPicker.toggle()
                        } label: {
                            HStack {
                                Text("\(selectedCountry.flag)  \(selectedCountry.dial_code)")
                                Image(systemName: "chevron.down")
                                    .foregroundStyle(.white.opacity(0.5))
                            }
                        }
                        .padding()
                        .foregroundStyle(.white)
                        .background(phoneVerification.resendVerificationCodeLimit <= 0 || phoneVerification.isPhoneNumberVerificationCodeSent ? .clear : Color.white.opacity(0.2))
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(lineWidth: 0.5)
                        }
                        .cornerRadius(10)
                        .disabled(phoneVerification.resendVerificationCodeLimit <= 0)
                        .disabled(phoneVerification.isPhoneNumberVerificationCodeSent)
                        
                        TextField("Phone Number", text: $phoneVerification.phoneNumber)
                            .keyboardType(.phonePad)
                            .padding()
                            .background(phoneVerification.resendVerificationCodeLimit <= 0 || phoneVerification.isPhoneNumberVerificationCodeSent ? .clear : Color.white.opacity(0.2))
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(lineWidth: 0.5)
                            }
                            .cornerRadius(10)
                            .onChange(of: phoneVerification.phoneNumber) {
                                formatNumber()
                            }
                            .disabled(phoneVerification.resendVerificationCodeLimit <= 0)
                            .disabled(phoneVerification.isPhoneNumberVerificationCodeSent)
                    }
                }
                
                if phoneVerification.isPhoneNumberVerified {
                    HStack {
                        Text("\(selectedCountry?.dial_code ?? "") \(phoneVerification.phoneNumber)")
                            .font(.system(size: 20, weight: .regular))
                            .foregroundStyle(.white)
                        
                        Spacer()
                        
                        HStack {
                            Image(systemName: "checkmark.seal")
                            Text("Verified")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundStyle(.green)
                        .padding(.horizontal)
                    }
                    .padding()
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(lineWidth: 0.5)
                    }
                }
                
                if !phoneVerification.isPhoneNumberVerificationCodeSent &&  phoneVerification.resendVerificationCodeLimit == 3 {
                    Button {
                        HelperClass.shared.endEditing()
                        onTapSendOTPForPhone()
                    } label: {
                        Text("SEND OTP")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(.orange)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                }
                
                if phoneVerification.isPhoneNumberVerificationCodeSent &&
                    !phoneVerification.isPhoneNumberVerified && phoneVerification.resendVerificationCodeLimit > 0 {
                    HStack {
                        TextField("OTP", text: $phoneVerification.otp)
                            .padding()
                            .frame(height: 50)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
                            .autocapitalization(.none)
                            .keyboardType(.numberPad)
                            .textContentType(.oneTimeCode)
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(lineWidth: 0.5)
                            }
                        
                        Button {
                            HelperClass.shared.endEditing()
                            onTapVerifyPhoneOTP()
                        } label: {
                            Text("Verify")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.white)
                                .padding()
                                .frame(height: 50)
                                .background(.orange)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                       
                    }
                }
                if phoneVerification.resendVerificationCodeLimit == 0 {
                    HStack {
                        Text("You have exceeded the maximum number of attempts to resend the OTP. Please try again later.")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(.white)
                            .padding()
                        Spacer()
                    }
                }
                
                if phoneVerification.isPhoneNumberVerificationCodeSent &&
                    !phoneVerification.isPhoneNumberVerified &&
                    phoneVerification.resendVerificationCodeCountdown > 0 && phoneVerification.resendVerificationCodeLimit > 0 {
                    Text("You can resend code in \(phoneVerification.resendVerificationCodeCountdown) seconds.")
                        .font(.system(size: 13, weight: .thin))
                        .foregroundStyle(.white)
                        .padding()
                }
                
                if phoneVerification.isPhoneNumberVerificationCodeSent &&
                    !phoneVerification.isPhoneNumberVerified && phoneVerification.resendVerificationCodeLimit > 0 && phoneVerification.resendVerificationCodeCountdown <= 0  {
                    Button {
                        phoneVerification.otp = ""
                        phoneVerification.isPhoneNumberVerificationCodeSent = false
                        onTapSendOTPForPhone()
                    } label: {
                        Text("Resend")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.orange)
                            .padding()
                            .frame(height: 50)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                
                }
            }
        }
        .onChange(of: phoneVerification.isPhoneNumberVerificationCodeSent) {
            if phoneVerification.isPhoneNumberVerificationCodeSent {
                startResendOTPTimer()
            }
        }
        .onAppear {
            if arrCountries.isEmpty {
                arrCountries = loadCountries()
                if let localeCountry = getLocaleCountry(from: arrCountries) {
                            selectedCountry = localeCountry
                                    phoneVerification.country = selectedCountry

                        }
            }
        }
        .sheet(isPresented: $showCountryPicker, content: {
            CountryPickerView(arrCountries: arrCountries,
                              onSelectCountry: { country in
                if let country {
                    selectedCountry = country
                    phoneVerification.country = selectedCountry
                    formatNumber()
                }
            })
        })
    }
    func getLocaleCountry(from countries: [Country]) -> Country? {
        guard let regionCode = Locale.current.region?.identifier else { return nil }
        return countries.first { $0.code.uppercased() == regionCode.uppercased() }
    }

    func loadCountries() -> [Country] {
        guard let url = Bundle.main.url(forResource: "Countries", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return []
        }
        return (try? JSONDecoder().decode([Country].self, from: data)) ?? []
    }
    
    func formatNumber() {
        guard let country = selectedCountry else { return }
        let region = country.code  // ISO code like "US", "IN"
        
        do {
            let parsed = try phoneNumberUtility.parse(phoneVerification.phoneNumber, withRegion: region, ignoreType: true)
            phoneVerification.phoneNumber = phoneNumberUtility.format(parsed, toType: .international, withPrefix: false)
        } catch {
            phoneVerification.phoneNumber = phoneVerification.phoneNumber // fallback to raw
        }
    }
}

#Preview {
    PhoneNumberVerificationView(phoneVerification: .constant(PhoneVerificationModel(phoneNumber: "", otp: "")),
                                onTapSendOTPForPhone: { }, onTapResendOTPForPhone: { }, onTapVerifyPhoneOTP: { })
}
