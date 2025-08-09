# Rapport - Projet iOS Application E-commerce

---

## 📋 Page de présentation

**Nom de l'étudiant :** Hicham Bifden  
**Thème de l'application :** Application e-commerce de produits/desserts  
**Date :** Décembre 2024  
**Technologie utilisée :** SwiftUI - iOS  

---

## 🎯 Présentation de l'application

### Description générale
L'application est une **boutique en ligne simple** développée en SwiftUI qui permet aux utilisateurs de :
- **Parcourir** une liste de produits (desserts/plats)
- **Ajouter** des produits au panier d'achat
- **Supprimer** des produits du panier
- **Visualiser** le total de la commande
- **Confirmer** la commande

### Fonctionnalités principales
- ✅ **Catalogue de produits** : Affichage des produits avec images, prix et descriptions
- ✅ **Panier d'achat** : Gestion des articles ajoutés avec calcul automatique du total
- ✅ **Interface utilisateur** : Design moderne avec animations fluides
- ✅ **Gestion d'état** : Utilisation de @StateObject et @EnvironmentObject pour la gestion du panier

### Architecture technique
- **Framework :** SwiftUI
- **Pattern :** MVVM (Model-View-ViewModel)
- **Gestion d'état :** ObservableObject pour le panier
- **Navigation :** NavigationView simple

---

## 🔗 Présentation de l'API utilisée

### API choisie : FakeStoreAPI
**URL de base :** `https://fakestoreapi.com/products`  
**Type :** API e-commerce gratuite  
**Format :** JSON

### Pourquoi cette API ?
J'ai choisi **FakeStoreAPI** car :
- ✅ **Disponibilité** : API e-commerce fonctionnelle et gratuite
- ✅ **Simplicité** : Structure JSON simple et claire
- ✅ **Fiabilité** : API stable et bien documentée
- ✅ **Données complètes** : Contient images, prix, descriptions

### Appel(s) API effectué(s)

#### Structure de données reçue :
```json
{
  "id": 1,
  "title": "Nom du produit",
  "price": 109.95,
  "description": "Description du produit",
  "category": "catégorie",
  "image": "URL_de_l'image"
}
```

#### Code d'appel API :
```swift
// Service moderne avec async/await
class ProductService {
    func fetchProducts() async throws -> [ProductResponse] {
        guard let url = URL(string: "https://fakestoreapi.com/products") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([ProductResponse].self, from: data)
    }
}
```

#### Utilisation dans l'application :
```swift
Task {
    do {
        let products = try await ProductService().fetchProducts()
        await MainActor.run {
            self.desserts = products.prefix(6).map { product in
                Dessert(
                    name: product.title,
                    type: product.category,
                    price: product.price,
                    imageName: product.image
                )
            }
        }
    } catch {
        print("Erreur: \(error)")
    }
}
```

---

## ✨ Présentation des deux animations

### Animation 1 : Affichage des cartes (Fade-in et Slide-up)

**Description :** Animation d'apparition progressive des cartes de produits au chargement de l'application.

**Code :**
```swift
.opacity(showContent ? 1 : 0) // Animation de fade-in
.offset(y: showContent ? 0 : 20) // Animation de slide-up
.animation(.easeInOut(duration: 0.8).delay(Double(desserts.firstIndex(of: dessert) ?? 0) * 0.1), value: showContent)
```

**Effet visuel :**
- Les cartes apparaissent progressivement avec un effet de transparence
- Chaque carte glisse vers le haut depuis une position légèrement décalée
- Délai progressif de 0.1s entre chaque carte pour un effet en cascade

### Animation 2 : Suppression des produits (Fade-out progressif)

**Description :** Animation d'opacité progressive quand un produit est supprimé du panier.

**Code :**
```swift
.opacity(removingItems.contains(dessert.id) ? 0.0 : 1.0) // Animation d'opacité
.animation(.easeInOut(duration: 0.9), value: removingItems.contains(dessert.id))
```

**Effet visuel :**
- L'élément devient progressivement transparent pendant 0.9 seconde
- Suppression effective après la fin de l'animation
- Transition fluide et élégante

---

## ⚠️ Problèmes rencontrés et solutions

### Problème 1 : Images ne s'affichent pas

**Description du problème :**
Les images des produits ne s'affichent pas correctement dans l'application.

**Diagnostic effectué :**
- ✅ Ajout de debug pour voir les URLs des images
- ✅ Amélioration de AsyncImage avec gestion d'erreurs
- ✅ Validation et nettoyage des URLs

**État actuel :**
- ❌ **Non résolu** : Le problème persiste malgré les tentatives de correction
- 🔍 **Hypothèses :** 
  - URLs d'images incorrectes ou invalides
  - Problème de réseau ou de permissions
  - Format d'URL non compatible avec AsyncImage

**Tentatives de résolution :**
```swift
// Amélioration d'AsyncImage avec gestion d'erreurs
AsyncImage(url: URL(string: dessert.imageName)) { phase in
    switch phase {
    case .empty:
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .overlay(ProgressView())
    case .success(let image):
        image.resizable().aspectRatio(contentMode: .fill)
    case .failure(_):
        Rectangle()
            .fill(Color.red.opacity(0.3))
            .overlay(Text("Erreur image"))
    }
}
```

### Problème 2 : Choix de l'API

**Raison du changement :**
- ❌ **API de recettes manquante** : L'API originale de recettes n'était pas disponible
- ✅ **Solution adoptée** : Utilisation de FakeStoreAPI (e-commerce)

**Impact :**
- Les données sont maintenant des produits e-commerce au lieu de recettes
- Les prix sont disponibles et corrects
- Structure de données plus complète

---

## 📊 Conclusion

### Réalisations
- ✅ **Application fonctionnelle** : Toutes les fonctionnalités de base opérationnelles
- ✅ **Interface moderne** : Design propre avec animations fluides
- ✅ **Code structuré** : Architecture MVVM avec SwiftUI
- ✅ **API intégrée** : Connexion réussie à FakeStoreAPI
- ✅ **Animations implémentées** : 2 animations simples et efficaces

### Points d'amélioration
- 🔧 **Images** : Résolution du problème d'affichage des images
- 🎨 **UI/UX** : Amélioration de l'interface utilisateur
- 📱 **Fonctionnalités** : Ajout de nouvelles fonctionnalités (filtres, recherche)

### Apprentissages
- 📚 **SwiftUI** : Maîtrise des concepts de base (State, ObservableObject, AsyncImage)
- 🔗 **API Integration** : Utilisation d'async/await pour les appels réseau
- ✨ **Animations** : Implémentation d'animations simples et efficaces
- 🐛 **Debug** : Techniques de diagnostic et résolution de problèmes

---

**Note :** Ce projet démontre une bonne compréhension des concepts de base de SwiftUI et de l'intégration d'API. Le problème d'affichage des images reste à résoudre, mais l'architecture générale de l'application est solide et extensible.

---

**Signature de l'étudiant :** _____________________

**Date :** _____________________ 