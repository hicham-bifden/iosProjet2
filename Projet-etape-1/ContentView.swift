//
//  ContentView.swift
//  Projet-etape-1
//
//  Created by HICHAM BIFDEN on 2025-06-24.
//

import SwiftUI

// Modèle de dessert
struct Dessert: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let type: String
    let price: Double
    let imageName: String
}

// Modèle de panier
class Cart: ObservableObject {
    @Published var items: [Dessert] = []
    
    func add(_ dessert: Dessert) {
        if !items.contains(dessert) {
            items.append(dessert)
        }
    }
    
    func remove(_ dessert: Dessert) {
        if let index = items.firstIndex(of: dessert) {
            items.remove(at: index)
        }
    }
    
    func total() -> Double {
        items.reduce(0) { $0 + $1.price }
    }
    
    func clear() {
        items.removeAll()
    }
}

// Liste des desserts
let desserts: [Dessert] = [
    Dessert(name: "Brownie Sundae", type: "Waffle", price: 6.5, imageName: "image-brownie-mobile"),
    Dessert(name: "Macaron Mix of Five", type: "Macaron", price: 8.0, imageName: "image-macaron-mobile"),
    Dessert(name: "Classic Tiramisu", type: "Tiramisu", price: 5.5, imageName: "image-tiramisu-mobile"),
    Dessert(name: "Pistachio Baklava", type: "Baklava", price: 4.0, imageName: "image-baklava-mobile"),
    Dessert(name: "Lemon Meringue Pie", type: "Pie", price: 5.0, imageName: "image-meringue-mobile"),
    Dessert(name: "Vanilla Panakota", type: "Cake", price: 4.5, imageName: "image-panna-cotta-mobile"),
    Dessert(name: "Salted Caramel Brownie", type: "Brownie", price: 5.5, imageName: "image-brownie-mobile")
]

struct ContentView: View {
    @StateObject var cart = Cart()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        Text("Les desserts")
                            .font(.largeTitle).bold()
                            .padding(.horizontal)
                            .padding(.top)
                        ForEach(desserts) { dessert in
                            DessertRow(dessert: dessert)
                                .environmentObject(cart)
                        }
                        Spacer()
                    }
                }
                CartView()
                    .environmentObject(cart)
            }
            .background(Color.white)
            .navigationBarHidden(true)
        }
    }
}

struct DessertRow: View {
    let dessert: Dessert
    @EnvironmentObject var cart: Cart
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .bottom) {
                Image(dessert.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 140)
                    .clipped()
                    .cornerRadius(16)
                
                if !cart.items.contains(dessert) {
                    Button(action: { cart.add(dessert) }) {
                        HStack(spacing: 8) {
                            Image("icon-add-to-cart")
                                .resizable()
                                .frame(width: 16, height: 16)
                            Text("Ajouter au panier")
                                .font(.caption)
                                .bold()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(16)
                        .shadow(radius: 2)
                    }
                    .padding(.bottom, 8)
                }
            }
            
            Text(dessert.type)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(dessert.name)
                .font(.headline)
            Text(String(format: "$%.2f", dessert.price))
                .font(.subheadline)
                .foregroundColor(Color("orangeh"))
                .bold()
        }
        .padding(.horizontal)
    }
}

struct CartView: View {
    @EnvironmentObject var cart: Cart
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !cart.items.isEmpty {
                Text("Votre panier (\(cart.items.count))")
                    .font(.headline)
                ForEach(cart.items) { dessert in
                    HStack {
                        Text("\(dessert.name)")
                        Spacer()
                        Button(action: { cart.remove(dessert) }) {
                            Image("icon-remove-item")
                                .resizable()
                                .frame(width: 18, height: 18)
                        }
                    }
                }
                Divider()
                HStack {
                    Text("Total de la commande")
                        .font(.headline)
                    Spacer()
                    Text(String(format: "$%.2f", cart.total()))
                        .font(.headline)
                }
               
                Button(action: { cart.clear() }) {
                    HStack {
                        Image("icon-order-confirmed")
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text("Confirmer votre commande")
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(24)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(24)
        .shadow(radius: 8)
        .padding([.horizontal, .bottom])
    }
}

#Preview {
    ContentView()
}
