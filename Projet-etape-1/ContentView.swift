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

// Modèle pour l'API Fakestoreapi
struct ProductResponse: Codable {
    let title: String
    let price: Double
    let category: String
    let image: String
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

struct ContentView: View {
    @StateObject var cart = Cart()
    @State private var desserts: [Dessert] = []
    @State private var isLoading = true
    @State private var showContent = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        Text("Les desserts")
                            .font(.largeTitle).bold()
                            .padding(.horizontal)
                            .padding(.top)
                            .opacity(showContent ? 1 : 0)
                            .animation(.easeIn(duration: 0.6), value: showContent)
                        
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding()
                        } else {
                            ForEach(desserts) { dessert in
                                DessertRow(dessert: dessert)
                                    .environmentObject(cart)
                                    .opacity(showContent ? 1 : 0)
                                    .offset(y: showContent ? 0 : 20)
                                    .animation(.easeInOut(duration: 0.8).delay(Double(desserts.firstIndex(of: dessert) ?? 0) * 0.1), value: showContent)
                            }
                        }
                        Spacer()
                    }
                }
                CartView()
                    .environmentObject(cart)
            }
            .background(Color.white)
            .navigationBarHidden(true)
            .onAppear {
                loadProducts()
            }
        }
    }
    
    func loadProducts() {
        guard let url = URL(string: "https://fakestoreapi.com/products") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let data = data {
                    do {
                        let products = try JSONDecoder().decode([ProductResponse].self, from: data)
                        self.desserts = products.prefix(6).map { product in
                            Dessert(
                                name: product.title,
                                type: product.category,
                                price: product.price,
                                imageName: product.image
                            )
                        }
                        
                        withAnimation {
                            showContent = true
                        }
                    } catch {
                        print("Erreur: \(error)")
                    }
                }
            }
        }.resume()
    }
}

struct DessertRow: View {
    let dessert: Dessert
    @EnvironmentObject var cart: Cart
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .bottom) {
                AsyncImage(url: URL(string: dessert.imageName)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(height: 140)
                .clipped()
                .cornerRadius(16)
                
                if !cart.items.contains(dessert) {
                    Button(action: {
                        cart.add(dessert)
                    }) {
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
    @State private var removingItems: Set<UUID> = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !cart.items.isEmpty {
                Text("Votre panier (\(cart.items.count))")
                    .font(.headline)
                
                ForEach(cart.items) { dessert in
                    HStack {
                        Text(dessert.name)
                        Spacer()
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                removingItems.insert(dessert.id)
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                cart.remove(dessert)
                                removingItems.remove(dessert.id)
                            }
                        }) {
                            Image("icon-remove-item")
                                .resizable()
                                .frame(width: 18, height: 18)
                        }
                    }
                    .opacity(removingItems.contains(dessert.id) ? 0.0 : 1.0)
                    .animation(.easeInOut(duration: 0.5), value: removingItems.contains(dessert.id))
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
