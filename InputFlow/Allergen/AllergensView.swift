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
    let allergenWidth = UIScreen.screenWidth * 0.3
    let typeWidth = UIScreen.screenWidth * 0.2
    let severityWidth = UIScreen.screenWidth * 0.2
    let addWidth = UIScreen.screenWidth * 0.1
    
    var body: some View {
        FreshStartBaseView(currentViewModel: viewModel,
               background: .solidWhite,
               showIndicator: $viewModel.showIndicator
        ) {
            VStack {
                FSTitle(
                    title: "allergens_title".localized(),
                    subtitle: "allergens_subtitle".localized(),
                    bottomPadding: 0)
                ScrollView {
                    HStack {
                        Text("allergen".localized())
                            .frame(width: allergenWidth, alignment: .center)
                        Text("allergen_type".localized())
                            .frame(width: typeWidth, alignment: .center)
                        Text("severity_level".localized())
                            .frame(width: severityWidth, alignment: .center)
                        Text("add".localized())
                            .frame(width: addWidth, alignment: .center)
                    }
                    .padding(.horizontal, 20)
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
                FreshStartButton(text: "create_diet_plan".localized(), backgroundColor: .mkOrange) {
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
            .frame(maxWidth: UIScreen.screenWidth)
            .navigationDestination(isPresented: $viewModel.goToLoadingView) {
                LoadingView()
            }
            .onAppear {
                viewModel.fetchAllergens()
            }
            .onDisappear {
                viewModel.showIndicator = false
            }
            .navigationTitle("")
            .navigationBarBackButtonHidden()
            .navigationBarItems(
                leading:
                    FreshStartBackButton(),
                trailing:
                    HStack {
                        FSProgressBar(progressCount: Constant.progressCount, currentProgress: 6, color: .mkPurple, dotColor: .mkPurple.opacity(0.5))
                        Spacer()
                            .frame(width: UIScreen.screenWidth / Constant.progressTrailingScale)
                    }
            )
        }
    }
}
