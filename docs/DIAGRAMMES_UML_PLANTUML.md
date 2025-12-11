# Diagrammes UML NutriScan (PlantUML)

Ce document regroupe les principaux diagrammes UML du projet NutriScan au **format PlantUML**, prêts à être copiés dans un outil comme PlantUML, IntelliJ, VS Code, etc.

---

## 1. Diagramme de classes principal (backend métier)

```plantuml
@startuml

skinparam classAttributeIconSize 0
skinparam classFontSize 12
skinparam classAttributeFontSize 11
skinparam classBorderColor #2E7D32
skinparam classBackgroundColor #E8F5E9

' =====================
'      ÉNUMÉRATIONS
' =====================

enum Genre {
  HOMME
  FEMME
  AUTRE
}

enum RoleUtilisateur {
  USER
  ADMIN
}

enum NiveauActivite {
  SEDENTAIRE
  LEGER
  MODERE
  INTENSE
}

enum TypeObjectif {
  PERTE_POIDS
  PRISE_MASSE
  MAINTIEN
}

enum TypeRepas {
  PETIT_DEJEUNER
  DEJEUNER
  DINER
  COLLATION
}

enum SourceRepas {
  MANUEL
  PLANIFIE
  SCAN
}

enum TypePlan {
  JOURNALIER
  HEBDOMADAIRE
}

' =====================
'        CLASSES
' =====================

class Utilisateur {
  +Long id
  +String email
  +String motDePasseHash
  +String nomComplet
  +Genre genre
  +int age
  +int tailleCm
  +double poidsInitialKg
  +RoleUtilisateur role
  +NiveauActivite niveauActivite
  +TypeObjectif typeObjectif
  +String preferencesAlimentaires
  +String allergies
  +LocalDateTime dateCreation
  --
  +double calculerBMR()
  +double calculerTDEE()
  +double getCibleCaloriesJour()
}

class Repas {
  +Long id
  +LocalDate date
  +LocalTime heure
  +TypeRepas typeRepas
  +SourceRepas source
  +double totalCalories
  +double totalProteines
  +double totalGlucides
  +double totalLipides
  --
  +void calculerTotaux()
}

class ElementRepas {
  +Long id
  +Long alimentId
  +String nomAliment
  +double quantite
  +String unite
  +double calories
  +double proteines
  +double glucides
  +double lipides
}

class HistoriquePoids {
  +Long id
  +LocalDate dateMesure
  +double poidsKg
  +double imc
  --
  +double calculerIMC()
}

class PlanRepas {
  +Long id
  +LocalDate dateDebut
  +LocalDate dateFin
  +TypePlan typePlan
  +String typeRegime
  +int caloriesCibleParJour
  --
  +List<RepasPlanifie> getRepasPourDate(LocalDate d)
}

class RepasPlanifie {
  +Long id
  +LocalDate date
  +TypeRepas typeRepas
  +int ordre
}

class ListeCourses {
  +Long id
  +LocalDate dateCreation
  +int nbArticles
}

class ElementCourse {
  +Long id
  +String nomIngredient
  +String quantite
  +String categorie
  +boolean achete
}

class ScanResultat {
  +Long id
  +String type
  +String referenceExterne
  +String resumeNutritionnel
  +double scoreSante
}

class Recette {
  +Long id
  +String titre
  +String source
  +int portions
  +double caloriesParPortion
}

class AnalyseNutritionnelle {
  +Long id
  +LocalDate date
  +String typeCible
  +String resume
  +String conseilsIA
}

' =====================
'      ASSOCIATIONS
' =====================

Utilisateur "1" -- "0..*" Repas : consomme >
Repas "1" -- "1..*" ElementRepas : contient >

Utilisateur "1" -- "0..*" HistoriquePoids : enregistre >

Utilisateur "1" -- "0..*" PlanRepas : possede >
PlanRepas "1" -- "0..*" RepasPlanifie : comprend >

Utilisateur "1" -- "0..*" ListeCourses : genere >
ListeCourses "1" -- "0..*" ElementCourse : contient >

Utilisateur "1" -- "0..*" ScanResultat : effectue >

Recette "1" -- "0..*" ElementRepas : utilise >

Utilisateur "1" -- "0..*" AnalyseNutritionnelle : recoit >

@enduml
```

---

## 2. Diagramme de cas d’utilisation global

```plantuml
@startuml

left to right direction
skinparam usecaseBackgroundColor #E3F2FD
skinparam usecaseBorderColor #1565C0
skinparam actorStyle awesome

actor "Utilisateur" as U

rectangle "Système NutriScan" {

  ' Authentification
  usecase "UC01 - S'enregistrer" as UC01
  usecase "UC02 - Se connecter" as UC02

  ' Profil et préférences
  usecase "UC03 - Gérer son profil" as UC03
  usecase "UC19 - Modifier les préférences\n(thème, langue)" as UC19

  ' Scan & IA
  usecase "UC04 - Scanner un produit\n(code-barres)" as UC04
  usecase "UC05 - Scanner un repas\n(par photo)" as UC05

  ' Journal alimentaire
  usecase "UC06 - Ajouter un repas\nconsommé" as UC06
  usecase "UC07 - Gérer un repas\n(consulter / modifier / supprimer)" as UC07

  ' Planification & courses
  usecase "UC08 - Générer un plan\nde repas" as UC08
  usecase "UC09 - Consulter / supprimer\nun plan de repas" as UC09
  usecase "UC10 - Ajouter un repas\nplanifié au journal" as UC10
  usecase "UC11 - Générer une liste\nde courses" as UC11
  usecase "UC12 - Gérer la liste\nde courses" as UC12

  ' Suivi du poids & analyses
  usecase "UC13 - Ajouter une mesure\nde poids" as UC13
  usecase "UC14 - Consulter l'historique\net les graphiques de poids" as UC14
  usecase "UC15 - Consulter l'analyse IA\nde progression" as UC15

  ' Recettes
  usecase "UC16 - Rechercher des recettes" as UC16
  usecase "UC17 - Consulter le détail\nd'une recette" as UC17
  usecase "UC18 - Ajouter une recette\nà un plan de repas" as UC18

  ' Déconnexion
  usecase "UC20 - Se déconnecter" as UC20
}

U --> UC01
U --> UC02
U --> UC03
U --> UC04
U --> UC05
U --> UC06
U --> UC07
U --> UC08
U --> UC09
U --> UC10
U --> UC11
U --> UC12
U --> UC13
U --> UC14
U --> UC15
U --> UC16
U --> UC17
U --> UC18
U --> UC19
U --> UC20

' ====== Relations d'inclusion (connexion requise) ======

UC03 ..> UC02 : <<include>>
UC04 ..> UC02 : <<include>>
UC05 ..> UC02 : <<include>>
UC06 ..> UC02 : <<include>>
UC07 ..> UC02 : <<include>>
UC08 ..> UC02 : <<include>>
UC09 ..> UC02 : <<include>>
UC10 ..> UC02 : <<include>>
UC11 ..> UC02 : <<include>>
UC12 ..> UC02 : <<include>>
UC13 ..> UC02 : <<include>>
UC14 ..> UC02 : <<include>>
UC15 ..> UC02 : <<include>>
UC16 ..> UC02 : <<include>>
UC17 ..> UC02 : <<include>>
UC18 ..> UC02 : <<include>>
UC19 ..> UC02 : <<include>>
UC20 ..> UC02 : <<include>>

' ====== Autres inclusions ======

UC08 ..> UC16 : <<include>>
UC09 ..> UC08 : <<include>>
UC10 ..> UC06 : <<include>>
UC11 ..> UC08 : <<include>>
UC14 ..> UC13 : <<include>>
UC15 ..> UC14 : <<include>>
UC17 ..> UC16 : <<include>>
UC18 ..> UC17 : <<include>>

@enduml
```

---

## 3. Diagramme de cas d’utilisation détaillé – Scan produit (exemple)

```plantuml
@startuml

left to right direction
skinparam usecaseBackgroundColor #FFF3E0
skinparam usecaseBorderColor #EF6C00
skinparam actorStyle awesome

actor "Utilisateur" as U

rectangle "Scan produit (code-barres)" {
  usecase "UC02 - Se connecter" as UC02
  usecase "UC04 - Scanner un produit\n(code-barres)" as UC04
}

U --> UC04
UC04 ..> UC02 : <<include>>

@enduml
```

---

Ces snippets PlantUML peuvent être copiés directement dans n'importe quel éditeur compatible, ou dans un bloc `@startuml` / `@enduml` dans votre IDE pour générer les diagrammes graphiques.

