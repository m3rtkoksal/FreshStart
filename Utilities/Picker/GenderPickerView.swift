//
//  GenderPickerView.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

struct GenderPickerView: View {
    @StateObject private var viewModel = DetailsAboutMeVM()
    @Binding var genderOptions: [FSDropdownItemModel]
    @Binding var selectedItem: FSDropdownItemModel
    @Binding var isExpanded: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Done Button
            HStack {
                Spacer()
                Button(action: {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }) {
                    HStack {
                        Spacer()
                        Text("Please select your gender")
                            .font(.montserrat(.medium, size: 17))
                            .foregroundColor(.black)
                        Image("done-filled")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .padding(.leading, 40)
                    }
                }
            }
          
            if isExpanded {
                VStack(spacing: 20) {
                    ForEach(genderOptions, id: \.self) { item in
                        Button(action: {
                            withAnimation {
                                selectedItem = item
                                isExpanded = false
                            }
                        }) {
                            HStack {
                                Text(item.text)
                                    .font(.montserrat(.medium, size: 17))
                                    .foregroundColor(.black)
                                Spacer()
                                Image(item.icon ?? "")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .padding(.leading, 10)
                            }
                            .frame(width: 200, height: 60)
                            .padding(.horizontal, 30)
                            .background(
                                selectedItem == item ? Color.mkPurple.opacity(0.3) : Color.clear
                            )
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.mkPurple, lineWidth: 1)
                            )
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
                .frame(maxHeight: 200)
                .transition(.opacity)
                .animation(.easeInOut, value: isExpanded)
                .padding(.bottom, 25)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}
