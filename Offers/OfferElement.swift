//
//  OfferElement.swift
//  FreshStart
//
//  Created by Mert Köksal on 2.12.2024.
//

import SwiftUI
import StoreKit

struct OfferElement: View, Identifiable {
    let id = UUID()
    let product: SKProduct
    let image: String
    let purchaseAction: (SKProduct) -> Void
    
    var body: some View {
        Button(action: {
            purchaseAction(product)
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.black)
                VStack {
                    VStack {
                        HStack {
                            Text(product.localizedTitle)
                                .font(.montserrat(.bold, size: 24))
                                .frame(alignment: .leading)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        HStack {
                            Text(product.localizedDescription)
                                .font(.montserrat(.medium, size: 10))
                                .frame(alignment: .leading)
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        .frame(height: 15)
                    }
                    .padding(.leading, 30)
                    .padding(.top, 20)
                    HStack {
                        VStack {
                            HStack {
                                Text(product.localizedPriceString)
                                    .font(.montserrat(.bold, size: 20))
                                    .foregroundColor(.white)
                                    .padding(.top, 10)
                                    .lineLimit(1)
                                Spacer()
                            }
                            .padding(.leading, 30)
                            HStack {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 38)
                                        .fill(Color.mkOrange)
                                    Text("Purchase")
                                        .font(.montserrat(.bold, size: 17))
                                        .foregroundColor(.black)
                                }
                                .frame(width: 140, height: 45)
                                Spacer()
                            }
                            .padding(.bottom,15)
                            .padding(.leading, 30)
                        }
                        Image(image)
                            .resizable()
                            .frame(width: 100, height: 100)
                            .padding(.trailing, 15)
                            .padding(.bottom, 15)
                    }
                }
            }
            .frame(width: UIScreen.screenWidth * 0.8, height: 180)
        }
    }
}
