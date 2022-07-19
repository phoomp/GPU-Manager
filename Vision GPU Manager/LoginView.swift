//
//  LoginView.swift
//  Vision GPU Manager
//
//  Created by Phoom Punpeng on 8/7/2565 BE.
//

import Foundation
import SwiftUI
import FirebaseCore
import FirebaseAuth
import Firebase


let textFieldLightGray: Color = Color(red: 239/255, green: 243/255, blue: 244/255, opacity: 1)

struct FirebaseUser {
    var uid: String?
    var email: String?
    var isEmailVerified: Bool
    var displayName: String?
}


struct LoginView: View {
    enum Field: Hashable {
        case field
    }
    
    @State var usernameString: String = ""
    @State var passwordString: String = ""
    
    @State var showSignInFailedAlert: Bool = false
    @State var isShowingGPUView: Bool = false
    
    @FocusState private var focusedField: Field?
    
    @State var user: FirebaseUser = FirebaseUser(isEmailVerified: false)
    
    func signInFirebase(username: String, password: String, automatic: Bool) {
        Auth.auth().signIn(withEmail: username, password: password) { authResult, error in
            if authResult == nil && !automatic {
                showSignInFailedAlert = true
            } else {
                user.uid = authResult!.user.uid
                user.email = authResult!.user.email
                user.isEmailVerified = authResult!.user.isEmailVerified
                user.displayName = authResult!.user.displayName
                isShowingGPUView = true
                
                if !automatic {
                    UserDefaults.standard.set(username, forKey: "username")
                    UserDefaults.standard.set(password, forKey: "password")
                }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 30) {
                NavigationLink(destination: GPUView(user: user), isActive: $isShowingGPUView) { EmptyView() }
                Text("Vision GPU Manager")
                    .font(.system(size: 30, weight: .heavy, design: .default))
                    .padding(.top, 150)
                    .padding(.bottom, 50)
                
                TextField("Email", text: $usernameString)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 50)
                            .stroke(textFieldLightGray)
                            .background(RoundedRectangle(cornerRadius: 50).fill(textFieldLightGray))
                    ).padding(.horizontal, 20)
                    .focused($focusedField, equals: .field)

                SecureField("Password", text: $passwordString)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 50)
                            .stroke(textFieldLightGray)
                            .background(RoundedRectangle(cornerRadius: 50).fill(textFieldLightGray))
                    ).padding(.horizontal, 20)
                    .focused($focusedField, equals: .field)
                
                Button {
                    print("Signing in")
                    signInFirebase(username: usernameString, password: passwordString, automatic: false)
                } label: {
                    Text("Login")
                        .frame(width: 200, height: 40)
                }.padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                    .alert("Sign in failed. Please try again.", isPresented: $showSignInFailedAlert) { }
                
                Spacer()
                NavigationLink(destination: SignUpView()) {
                    Text("No Account? Sign Up")
                        .fontWeight(.light)
                        .padding(.bottom, 20)
                }

            }
        }.onAppear {
            let username: String? = UserDefaults.standard.string(forKey: "username")
            let password: String? = UserDefaults.standard.string(forKey: "password")
            
            if username != nil && password != nil {
                signInFirebase(username: username!, password: password!, automatic: true)
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
