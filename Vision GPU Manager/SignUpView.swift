//
//  SignUpView.swift
//  Vision GPU Manager
//
//  Created by Phoom Punpeng on 8/7/2565 BE.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import Firebase

struct SignUpView: View {
    enum Field: Hashable {
        case field
    }
    
    @FocusState private var focusedField: Field?
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var emailString: String = ""
    @State var passwordString: String = ""
    @State var secondPasswordString: String = ""
    @State var showCreateFailedAlert: Bool = false
        
    func determineEmailFieldColor() -> Color {
        if emailString != "" && emailString.contains("@") && emailString.contains(".") {
            return Color.green
        }
        else {
            return Color.red
        }
    }
    
    func determinepasswordFieldColor() -> Color {
        if passwordString == secondPasswordString && passwordString != "" && passwordString.count >= 6 {
            return Color.green
        }
        else {
            return Color.red
        }
    }
    
    func determineButtonDisabled() -> Bool {
        if passwordString == secondPasswordString && passwordString != "" && emailString != "" && emailString.contains("@") && emailString.contains(".") && passwordString.count >= 6 {
            return false
        }
        else {
            return true
        }
    }
    
    func signUptoFirebase() {
        Auth.auth().createUser(withEmail: emailString, password: passwordString) { authResult, error in
            print(authResult)
            print(error)
            if error == nil {
                presentationMode.wrappedValue.dismiss()
            } else {
                showCreateFailedAlert = true
            }
        }
    }
    
    var backBtn: some View {
        Button {
            presentationMode.wrappedValue.dismiss()
        } label: {
            HStack(spacing: 5) {
                Image(systemName: "chevron.backward").font(.system(.body, weight: .medium))
                Text("Back")
            }
        }

    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                VStack(alignment: .center, spacing: 25) {
                    Spacer()
                    Text("Create An Account")
                        .font(.system(size: 30, weight: .heavy, design: .default))
                        .padding(.bottom, 30)
                    
                    TextField("Email", text: $emailString)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 80)
                                .strokeBorder(determineEmailFieldColor())
                                .background(RoundedRectangle(cornerRadius: 80).fill(textFieldLightGray))
                        ).padding(.horizontal, 20)
                        .focused($focusedField, equals: .field)

                    SecureField("Password", text: $passwordString)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 80)
                                .strokeBorder(determinepasswordFieldColor())
                                .background(RoundedRectangle(cornerRadius: 80).fill(textFieldLightGray))
                            
                        ).padding(.horizontal, 20)
                        .focused($focusedField, equals: .field)
                    
                    SecureField("Confirm Password", text: $secondPasswordString)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 80)
                                .strokeBorder(determinepasswordFieldColor())
                                .background(RoundedRectangle(cornerRadius: 80).fill(textFieldLightGray))
                        ).padding(.horizontal, 20)
                        .focused($focusedField, equals: .field)
                    
                    Button {
                        print("Signing Up!")
                        signUptoFirebase()
                    } label: {
                        Text("Sign Up")
                            .frame(width: 200, height: 20)
                    }.padding()
                        .foregroundColor(.white)
                        .background(determineButtonDisabled() ? textFieldLightGray : Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                        .padding(.bottom, 10)
                        .disabled(
                            determineButtonDisabled()
                        ).alert("Error creating an account. Please try again.", isPresented: $showCreateFailedAlert) {
                            Button("Ok", role: .cancel) {}
                        }
                        
                    Spacer()

                }
            }
        }
//        .navigationBarBackButtonHidden(true)
//        .navigationBarItems(leading: backBtn)
    }
}

//struct SignUpView_Previews: PreviewProvider {
//    static var previews: some View {
//        SignUpView(presentationMode: <#Environment<Binding<EnvironmentValues>>#>)
//    }
//}
