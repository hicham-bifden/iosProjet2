//
//  ContentView.swift
//  Projet-etape-1
//
//  Created by HICHAM BIFDEN on 2025-06-24.
//

import SwiftUI

// Sla structure pour representer  le dessert/produit
struct Dessert: Identifiable, Hashable {
    let id = UUID()  // Identifiant unique pour chaque dessert
    let name: String // Nom du dessert
    let type: String // Type/catégorie du dessert
    let price: Double // Prix du dessert
    let imageName: String // Nom ou URL de l'image
}

// Structure pour intreprer les  les données de l'API
struct ProductResponse: Codable {
    let title: String    // Titre du produit depuis l'API
    let price: Double    // Prix du produit depuis l'API
    let category: String // Catégorie du produit depuis l'API
    let image: String    // URL de l'image depuis l'API
}

//On crée un service pour gérer la logique d’appel réseau. Voici une version utilisant async/await.
class ProductService {
    func fetchProducts() async throws -> [ProductResponse] {
        guard let url = URL(string: "https://fakestoreapi.com/products") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([ProductResponse].self, from: data)
    }
}

// ci la class pour  gérer le panier d'achat
class Cart: ObservableObject {
    @Published var items: [Dessert] = [] // Liste des produits dans le panier
    
    // Ajouter un produit au panier ( verifie si le meme produit existe deja )
    func add(_ dessert: Dessert) {
        if !items.contains(dessert) {
            items.append(dessert)
        }
    }
    
    // la func pour supprimer le produit du pannier
    func remove(_ dessert: Dessert) {
        if let index = items.firstIndex(of: dessert) {
            items.remove(at: index)
        }
    }
    
    // calculer le  le total de le panier
    func total() -> Double {
        items.reduce(0) { $0 + $1.price }
    }
    
    // Vider le panier
    func clear() {
        items.removeAll()
    }
}

// la vu  principale de l'application
struct ContentView: View {
    @StateObject var cart = Cart() // instancier  le panier
    @State private var desserts: [Dessert] = []
    
    // la liste des desserts  ou produit a afichee
        // Contrôle l'animation d'affichage des carte
    @State private var showContent = false
    // pour
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Zone de défilement avec la liste des produits
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // le titre de la page
                        Text("Les desserts")
                            .font(.largeTitle).bold()
                            .padding(.horizontal)
                            .padding(.top)
                            .opacity(showContent ? 1 : 0)
                        // Animation des carte on  fade-in
                            .animation(.easeIn(duration: 0.6), value: showContent)
                        
                        // la list   des desserts / produit
                        ForEach(desserts) { dessert in
                            DessertRow(dessert: dessert)
                                .environmentObject(cart)
                                .opacity(showContent ? 1 : 0) // Animation de fade-in
                                .offset(y: showContent ? 0 : 20) // Animation de slide-up
                                .animation(.easeInOut(duration: 0.8).delay(Double(desserts.firstIndex(of: dessert) ?? 0) * 0.1), value: showContent)
                        }
                        Spacer()
                    }
                }
                // Vue du panier en bas de l'écran
                CartView()
                    .environmentObject(cart)
            }
            .background(Color.white)
            .navigationBarHidden(true)
            .onAppear {
                loadProducts() // Charger les produits au démarrage
            }
        }
    }
    
    // Fonction de loader les produits depuis l'API avec async/await
    func loadProducts() {
        Task {
            do {
                // Utiliser la nouvelle classe ProductService avec async/await
                let products = try await ProductService().fetchProducts()
                
                // Traiter les données sur le thread principal
                await MainActor.run {
                    self.desserts = products.prefix(6).map { product in
                        Dessert(
                            name: product.title,
                            type: product.category,
                            price: product.price,
                            imageName: product.image
                        )
                    }
                    
                    // Déclencher l'animation d'affichage
                    withAnimation {
                        showContent = true
                    }
                }
            } catch {
                print("Erreur: \(error)")
            }
        }
    }
}

// Vue pour afficher une ligne de dessert/produit
struct DessertRow: View {
    let dessert: Dessert // Le dessert à afficher
    @EnvironmentObject var cart: Cart // Référence au panier
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .bottom) {
                // Image du dessert (chargée depuis l'URL)
                AsyncImage(url: URL(string: dessert.imageName)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    // Placeholder pendant le chargement de l'image
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(height: 140)
                .clipped()
                .cornerRadius(16)
                
                // Bouton "Ajouter au panier" (visible seulement si pas dans le panier)
                if !cart.items.contains(dessert) {
                    Button(action: {
                        cart.add(dessert) // Ajouter au panier
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
            
            // Informations du dessert
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

// affichage de mon pannier
struct CartView: View {
    @EnvironmentObject var cart: Cart // Référence au panier
    
    // supprimer l'element avec une animation
    @State private var removingItems: Set<UUID> = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !cart.items.isEmpty {
                
                // titre de paniere
                Text("Votre panier (\(cart.items.count))")
                    .font(.headline)
                
                // un for each pour parcourir la list  des items dans le panier
                ForEach(cart.items) { dessert in
                    HStack {
                        Text(dessert.name)
                        Spacer()
                        
                        // ******  ici j'ajoute le Bouton de suppression apres
                        Button(action: {
                            removingItems.insert(dessert.id) // Marquer pour animation
                            
                            // Supprimer seulemt apres après la fin de l'animation
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                                cart.remove(dessert)
                                removingItems.remove(dessert.id)
                            }
                        }) {
                            Image("icon-remove-item")
                                .resizable()
                                .frame(width: 18, height: 18)
                        }
                    }
                    .opacity(removingItems.contains(dessert.id) ? 0.0 : 1.0) // Animation d'opacité
                    .animation(.easeInOut(duration: 0.9), value: removingItems.contains(dessert.id))
                }
                
                Divider()
                
                // calcul de Total de ma commande titre + totale
                HStack {
                    Text("Total de la commande")
                        .font(.headline)
                    Spacer()
                    Text(String(format: "$%.2f", cart.total()))
                        .font(.headline)
                }
                
                // Bouton de confirmation de la commande a faire marche apres
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
