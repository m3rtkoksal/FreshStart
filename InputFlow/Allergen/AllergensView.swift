//
//  AllergensView.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct AllergensView: View {
    @StateObject private var viewModel = AllergensVM()
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    @State private var selectedAllergens: Set<String> = []
    
    var body: some View {
        DGView(currentViewModel: viewModel,
               background: .solidWhite,
               showIndicator: $viewModel.showIndicator
        ) {
            VStack {
                DGTitle(
                    title: "Allergens",
                    subtitle: "If you have any allergies, please select your   allergens from the list.",
                    bottomPadding: 0)
                ScrollView {
                    HStack {
                        Text("Allergen")
                            .frame(width: 100, alignment: .center)
                        Text("Allergen Type")
                            .frame(width: 140, alignment: .center)
                        Text("Severity Level")
                            .frame(width: 90, alignment: .center)
                            .offset(x: -5)
                        Text("Add")
                            .frame(width: 60, alignment: .center)
                            .offset(x: 5)
                    }
                    .font(.montserrat(.medium, size: 12))
                    .foregroundColor(.black)

                    VStack{
                        ForEach(viewModel.fetchedAllergens.indices, id: \.self) { index in
                            let allergen = viewModel.fetchedAllergens[index]
                            AllergenItemView(allergen: allergen, selectedAllergen: selectedAllergens)
                                .onTapGesture {
                                    if let allergenId = allergen.id {
                                        if selectedAllergens.contains(allergenId) {
                                            selectedAllergens.remove(allergenId)
                                        } else {
                                            selectedAllergens.insert(allergenId)
                                        }
                                    }
                                }
                        }
                    }
                    Divider()
                        .frame(width: UIScreen.screenWidth, height: 1)
                        .background(Color.black.opacity(0.3))
                    Spacer()
                        .frame(height: 30)
                }
                .padding(.top, 30)
                DGButton(text: "Create Diet Plan", backgroundColor: .mkOrange) {
                    viewModel.showIndicator = true
                    // Set selected allergens to user input model
                    ProfileManager.shared.setUserAllergens(
                        viewModel.fetchedAllergens.filter { allergen in
                            if let id = allergen.id {
                                return selectedAllergens.contains(id)
                            }
                            return false
                        }
                    )
                    viewModel.saveHealthDataToFirestore()
                    viewModel.goToLoadingView = true
                }
            }
            .navigationDestination(isPresented: $viewModel.goToLoadingView) {
                LoadingView()
            }
            .onAppear {
                viewModel.fetchAllergens()
            }
            .navigationTitle("")
            .navigationBarBackButtonHidden()
            .navigationBarItems(
                leading:
                    DGBackButton(),
                trailing:
                    HStack {
                        DGProgressBar(progressCount: Constant.progressCount, currentProgress: 6, color: .mkPurple, dotColor: .mkPurple.opacity(0.5))
                        Spacer()
                            .frame(width: UIScreen.screenWidth / Constant.progressTrailingScale)
                    }
            )
        }
    }
}
