//
//  EditProfileViewModel.swift
//  Buzz
//
//  Created by Jay Borania on 05/09/25.
//

import Foundation

class EditProfileViewModel: ObservableObject {
    @Published var userId: String = ""
    @Published var username: String = ""
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var gender: String = ""
    @Published var email: String = ""
    @Published var birthDate = Date()
    @Published var birthDateString: String = ""
    @Published var showDatePicker: Bool = false
    @Published var phoneNumber: String = ""
    @Published var isSelectedGenderFemale: Bool = false
    @Published var errorMessage: String = ""
    @Published var errorTitle: String = ""
    @Published var showError: Bool = false
    @Published var isLoading: Bool = false
    

    init(){}
    
    func getProfileData(){
        guard let userData = UserLoginCache.get() else {return}
        userId = userData.id ?? ""
        username = userData.username ?? ""
        firstName = userData.firstName ?? ""
        lastName = userData.lastName ?? ""
        gender = userData.gender ?? ""
        birthDateString = userData.birthDate ?? ""
        if gender == "female" {
            isSelectedGenderFemale = true
        }
        email = userData.emailAddress ?? ""
        phoneNumber = userData.phoneNumber ?? ""
    }
    func validateprofileData() {
        if firstName.isEmpty || firstName == "" {
            errorMessage = "Please enter your first name."
            errorTitle = "Error"
            showError = true
            return
        }
        if lastName.isEmpty || lastName == "" {
            errorMessage = "Please enter your first name."
            errorTitle = "Error"
            showError = true
            return
        }
        
        editProfileData()
    }
    func editProfileData() {
        let db = Firestore.firestore()
        self.isLoading = true
        db.collection("users").document(userId).updateData([
            "firstName": firstName,
            "lastName": lastName,
            "gender": gender,
            "birthDate": birthDateString
        ]) { error in
            self.isLoading = false
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Success - Updated data in users")
//
                if var userData = UserLoginCache.get() {
                    userData.birthDate = self.birthDateString
                    userData.firstName = self.firstName
                    userData.lastName = self.lastName
                    userData.gender = self.gender
                    UserLoginCache.save(userData)
                }
                self.errorTitle = "Success"
                self.errorMessage = "Profile Updated Successfully!"
                self.showError = true
                
            }
        }
    }
    func setBirthDateString() {
        showDatePicker.toggle()
        birthDateString = formattedDate(date: birthDate)
    }
    func formattedDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy" // "dd" for day, "MM" for month, "yyyy" for year
        return formatter.string(from: date)
    }
}
