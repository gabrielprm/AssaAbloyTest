import SwiftUI

struct SignInView: View {
    @ObservedObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                    .onTapGesture {
                        hideKeyboard()
                    }
                
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text("Welcome Back")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Please sign in to continue")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom, 20)
                    
                    VStack(spacing: 16) {
                        TextField("Email", text: $viewModel.email)
                            .padding()
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(12)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                        
                        SecureField("Password", text: $viewModel.password)
                            .padding()
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(12)
                    }
                    
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)
                    }
                    
                    Button(action: {
                        hideKeyboard()
                        Task { await viewModel.signIn() }
                    }) {
                        Text("Login")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .cornerRadius(12)
                    }
                    .padding(.top, 8)
                    
                    Spacer()
                    
                    NavigationLink(destination: AuthFactory.makeSignUpView(viewModel: viewModel)) {
                        HStack(spacing: 4) {
                            Text("Not registered yet?")
                                .foregroundColor(.gray)
                            Text("Sign Up")
                                .fontWeight(.semibold)
                                .foregroundColor(.accentColor)
                        }
                    }
                    .padding(.bottom, 16)
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}