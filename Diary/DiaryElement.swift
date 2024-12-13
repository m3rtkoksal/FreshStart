//
//  DiaryElement.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

struct DiaryElement: View {
    var date: String
    var purpose: String
    var purposeImage: String
    var kcal: Int
    var protein: Int
    var carbohydrate: Int
    var fat: Int
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.white)
                .overlay(
                    Rectangle()
                        .stroke(Color.black, lineWidth: 1)
                )
            HStack {
                VStack(spacing: 8) {
                    HStack(spacing: 10) {
                        Image(purposeImage)
                            .resizable()
                            .frame(width: 30, height: 30)
                        Text(purpose)
                            .frame(width: 160, alignment: .leading)
                            .font(.montserrat(.semiBold, size: 18))
                        Spacer()
                        Text(date)
                            .frame(width: 80, alignment: .leading)
                            .font(.montserrat(.bold, size: 12))
                            .padding(.leading,10)
                    }
                    .padding(.leading)
                    .foregroundStyle(.black)
                    .font(.montserrat(.semiBold, size: 16))
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    HStack {
                        VStack {
                            Text("kcal".localized())
                                .foregroundColor(.mkPurple)
                            Text("\(self.kcal)")
                                .foregroundColor(.black)
                        }
                        .frame(maxWidth: .infinity)
                        VStack {
                            Text("protein".localized())
                                .foregroundColor(.mkPurple)
                            Text("\(self.protein) gr")
                                .foregroundColor(.black)
                        }
                        .frame(maxWidth: .infinity)
                        VStack {
                            Text("carbohydrate".localized())
                                .foregroundColor(.mkPurple)
                            Text("\(self.carbohydrate) gr")
                                .foregroundColor(.black)
                        }
                        .frame(maxWidth: .infinity)
                        VStack {
                            Text("fat".localized())
                                .foregroundColor(.mkPurple)
                            Text("\(self.fat) gr")
                                .foregroundColor(.black)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .font(.montserrat(.medium, size: 10))
                    .padding(.bottom, 15)
                }
            }
        }
        .background(Color.white)
        .frame(height: 111)
        .padding(.horizontal, 20)
    }
}
