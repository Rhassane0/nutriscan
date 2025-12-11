# Guide de Soutenance - NutriScan

## Points Clés à Présenter

---

## 1. Introduction (2-3 min)

### Accroche
> "Saviez-vous que plus de 60% des personnes qui essaient de suivre un régime abandonnent dans les premières semaines par manque d'outils adaptés ?"

### Présentation du projet
- **Nom** : NutriScan
- **Objectif** : Application mobile de suivi nutritionnel intelligent
- **Équipe** : 2 étudiants, 2 mois de développement
- **Technologies** : Flutter + Spring Boot + IA (Google Gemini)

---

## 2. Problématique & Solution (3-4 min)

### Problématique
- Difficulté à estimer les calories des repas
- Manque de temps pour la planification alimentaire
- Besoin de conseils personnalisés
- Interfaces souvent complexes

### Notre solution
| Problème | Solution NutriScan |
|----------|-------------------|
| Estimation difficile | Scan code-barres + IA photo |
| Manque de temps | Planificateur automatique |
| Conseils génériques | IA personnalisée |
| Interface complexe | Design moderne et intuitif |

---

## 3. Démonstration (8-10 min)

### Scénario 1 : Première utilisation
1. **Inscription** - Créer un compte
2. **Profil** - Configurer objectifs (perte de poids)
3. **Première pesée** - Enregistrer le poids initial

### Scénario 2 : Scan de produit
1. **Scanner un code-barres** (ex: Nutella)
2. **Afficher les résultats** :
   - Nutri-Score, Eco-Score, NOVA
   - Calories, macros
   - Allergènes, additifs
3. **Ajouter au journal**

### Scénario 3 : Planification
1. **Générer un plan hebdomadaire**
2. **Visualiser les repas suggérés**
3. **Générer la liste de courses**

### Scénario 4 : Suivi quotidien
1. **Dashboard** avec résumé
2. **Journal alimentaire** du jour
3. **Graphique de poids**

---

## 4. Architecture Technique (4-5 min)

### Stack technologique
```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│     Flutter     │────▶│   Spring Boot   │────▶│   PostgreSQL    │
│   (Frontend)    │     │    (Backend)    │     │   (Database)    │
└─────────────────┘     └─────────────────┘     └─────────────────┘
                               │
                               ▼
                  ┌─────────────────────────┐
                  │    Services Externes     │
                  │ Gemini │ OFF │ Edamam   │
                  └─────────────────────────┘
```

### Points forts techniques
1. **Architecture REST** bien structurée
2. **Sécurité JWT** avec Spring Security
3. **Intégration IA** (Google Gemini)
4. **APIs nutritionnelles** (OpenFoodFacts, Edamam)
5. **State management** avec Provider (Flutter)

---

## 5. Intégration IA (3-4 min)

### Google Gemini
- **Analyse d'images** : Reconnaissance des aliments
- **Génération de texte** : Conseils personnalisés
- **Estimation nutritionnelle** : Calcul des macros

### Pipeline de scan photo
```
Photo → Gemini Vision → Identification aliments → Estimation portions → Calcul nutrition
```

### Exemple de prompt
```
"Analyze this meal image and identify each food item with estimated 
portions and nutritional values (calories, protein, carbs, fat)."
```

---

## 6. Résultats & Métriques (2-3 min)

### Fonctionnalités livrées
| Fonctionnalité | Statut |
|----------------|--------|
| Authentification JWT | ✅ |
| Scan code-barres | ✅ |
| Scan photo (IA) | ✅ |
| Journal alimentaire | ✅ |
| Planificateur repas | ✅ |
| Liste de courses | ✅ |
| Suivi poids/IMC | ✅ |
| Thème sombre | ✅ |

### Performances
- Temps scan code-barres : **~1.5s**
- Temps analyse photo : **~3s**
- 27 tests API : **100% réussite**

---

## 7. Difficultés & Solutions (2 min)

| Difficulté | Solution |
|------------|----------|
| Précision IA variable | Validation utilisateur + fallback |
| Intégration APIs multiples | Service d'abstraction |
| Cohérence thème clair/sombre | Système de couleurs centralisé |
| Performance des scans | Mise en cache + optimisation requêtes |

---

## 8. Perspectives (2 min)

### Court terme
- Mode hors-ligne
- Notifications intelligentes
- Export PDF

### Moyen terme
- Intégration Google Fit / Apple Health
- Reconnaissance vocale
- Gamification

### Long terme
- Version iOS optimisée
- Multilingue
- Social features

---

## 9. Conclusion (1-2 min)

### Bilan
- ✅ Tous les objectifs du cahier des charges atteints
- ✅ Fonctionnalités bonus (liste courses, thème sombre)
- ✅ Architecture robuste et extensible
- ✅ Intégration IA réussie

### Compétences acquises
- Développement mobile cross-platform
- Conception API REST
- Intégration services d'IA
- Gestion de projet

### Remerciements
- Encadrant(s)
- Établissement
- Ressources utilisées (APIs, documentation)

---

## 10. Questions Types & Réponses

### Q: Pourquoi Flutter plutôt que React Native ?
> Flutter offre de meilleures performances, un écosystème Google cohérent (avec Gemini), et une courbe d'apprentissage plus douce.

### Q: Comment gérez-vous les erreurs d'estimation de l'IA ?
> L'utilisateur peut toujours modifier les valeurs proposées, et nous avons un seuil de confiance pour demander une validation.

### Q: Quelle est la précision de l'estimation des calories ?
> Pour les produits scannés par code-barres, les données sont exactes (OpenFoodFacts). Pour les photos, la précision est d'environ 80-85%.

### Q: Comment protégez-vous les données utilisateur ?
> JWT sécurisé, mots de passe hashés avec BCrypt, HTTPS en production, et respect des principes RGPD.

### Q: Quelles sont les limites actuelles ?
> Mode hors-ligne non disponible, précision IA variable sur plats complexes, pas de sync avec appareils de santé.

---

## Checklist Avant Soutenance

- [ ] Application démarrée et fonctionnelle
- [ ] Backend connecté à la base de données
- [ ] Compte test prêt (ahmed@example.com)
- [ ] Produits tests scannables (Nutella, Coca-Cola)
- [ ] Slides de présentation prêts
- [ ] Chronométrage des démos
- [ ] Questions anticipées

---

## Ressources à Montrer

1. **Collection Postman** : `nutriscan/POSTMAN_COMPLETE_TESTS.json`
2. **Architecture** : `docs/ARCHITECTURE_TECHNIQUE.md`
3. **Rapport complet** : `docs/RAPPORT_PROJET.md`
4. **Code source** : Structure des dossiers

---

*Bonne chance pour votre soutenance ! 🎓*

