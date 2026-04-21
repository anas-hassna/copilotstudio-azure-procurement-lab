# 🏥 Prompts de test — Agent Marchés Publics GHT Contoso

> Prompts classés par cas d'usage, basés sur les **29 documents réels** indexés dans Azure AI Search (`marches-index`).

---

## 📋 Cas d'usage 1 : Recherche de marché existant

### Par produit / équipement

| # | Prompt | Document(s) attendu(s) |
|---|--------|----------------------|
| 1 | Est-ce qu'on a un marché pour des gants d'examen ? | AO-2024-DM-0488 (gants examen et chirurgicaux) |
| 2 | On a quoi comme marché pour les lits médicaux électriques ? | AO-2024-EG-0234 (mobilier médical et literie) |
| 3 | Quel marché couvre les scanners et IRM ? | AO-2024-BIO-1203 (imagerie scanner IRM) |
| 4 | Existe-t-il un marché pour les pansements ? | AO-2024-DM-0621 (pansements et soins infirmiers) |
| 5 | Qu'est-ce qu'on a pour la nutrition entérale ? | AO-2023-MED-0892 (nutrition entérale et parentérale) |
| 6 | On a un marché pour des autoclaves de stérilisation ? | AO-2024-BIO-0955 (stérilisation autoclaves) |
| 7 | Quel marché couvre l'oxygène médical ? | AO-2024-MED-0723 (gaz médicaux) |
| 8 | Est-ce qu'il y a un marché pour les fauteuils roulants ? | AO-2023-EG-0567 (fauteuils roulants et mobilité) |

### Par référence

| # | Prompt | Document attendu |
|---|--------|-----------------|
| 9 | Donne-moi tous les détails du marché AO-2024-DM-0488 | Gants examen/chirurgicaux — 4.2M paires, 3 lots |
| 10 | Que contient le marché AO-2024-BIO-1203 ? | Imagerie — scanner 128 coupes + IRM 1.5T |
| 11 | Résume le marché AC-2023-MED-0567 | Accord-cadre médicaments — 147 lots, PUI |
| 12 | Détails du marché AO-2023-TR-0145 | Ambulances SMUR — 3 AR + 2 VLM |
| 13 | Que dit le marché AO-2024-IT-0234 ? | Cybersécurité SOC managé — NIS2, plan CaRE |

### Par catégorie

| # | Prompt | Documents attendus |
|---|--------|--------------------|
| 14 | Liste tous les marchés Dispositifs Médicaux | AO-2023-DM-0312, AO-2024-DM-0488, AO-2024-DM-0621 |
| 15 | Quels sont les marchés en informatique ? | AO-2023-IT-0156 (DPI), MAPA-2024-IT-0089 (réseau), AO-2024-IT-0234 (cybersécurité) |
| 16 | Montre-moi les marchés Laboratoire | AO-2024-LAB-0112 (hématologie), AO-2024-LAB-0345 (microbiologie), AO-2023-LAB-0891 (étude réactifs) |
| 17 | Quels sont les marchés Hôtellerie / Services ? | AO-2024-HOT-0412 (nettoyage), PA-2024-HOT-0156 (restauration), AO-2023-HOT-0298 (blanchisserie) |
| 18 | Liste les marchés Transport | AO-2023-TR-0145 (ambulances SMUR), PA-2024-TR-0201 (navettes inter-sites) |

### Par fournisseur

| # | Prompt | Résultat attendu |
|---|--------|-----------------|
| 19 | Sur quels marchés apparaît Air Liquide ? | AO-2024-MED-0723 — attributaire lots 1-4, 515K€ |
| 20 | Quels marchés a remporté MedTech Solutions ? | AO-2024-BIO-0847 — équipements biomédicaux |
| 21 | Trouve tous les marchés impliquant Pharma Dispositifs SA | AO-2023-DM-0312 — candidat (prix -4% mais qualité moindre) |

---

## 📋 Cas d'usage 2 : Étude de marché et conformité

### Conformité technique (normes)

| # | Prompt | Document | Points attendus |
|---|--------|----------|----------------|
| 22 | Vérifie les normes techniques du marché AO-2024-DM-0488 gants chirurgicaux | AO-2024-DM-0488 | Normes CE, marquage, spécifications gants nitrile/latex |
| 23 | Le marché AO-2023-TR-0145 ambulances est-il conforme aux normes ? | AO-2023-TR-0145 | Norme NF EN 1789, véhicules type A |
| 24 | Quelles certifications sont exigées pour le marché stérilisation AO-2024-BIO-0955 ? | AO-2024-BIO-0955 | Normes autoclaves, cycles de stérilisation |
| 25 | Le marché AO-2024-LAB-0345 microbiologie exige-t-il la conformité REMIC ? | AO-2024-LAB-0345 | Objectif J+1 hémocultures, spectrométrie de masse |
| 26 | Quelles normes ISO sont demandées pour le marché imagerie AO-2024-BIO-1203 ? | AO-2024-BIO-1203 | ISO 13485, CE, installation + maintenance 8 ans |

### Conformité procédurale

| # | Prompt | Document | Points attendus |
|---|--------|----------|----------------|
| 27 | La procédure du MAPA-2024-IT-0089 est-elle adaptée au montant ? | MAPA-2024-IT-0089 | MAPA = procédure adaptée, vérifier seuils |
| 28 | Le marché AO-2024-HOT-0412 nettoyage respecte-t-il les délais de publicité ? | AO-2024-HOT-0412 | Publication 15/05, clôture 30/07 — AO ouvert |
| 29 | L'allotissement du marché AO-2023-DM-0312 est-il justifié ? | AO-2023-DM-0312 | 4 lots (sondes, cathéters, kits drapage, consommables monitoring) |

### Conformité financière

| # | Prompt | Document | Points attendus |
|---|--------|----------|----------------|
| 30 | Y a-t-il des offres anormalement basses sur le marché AO-2023-DM-0312 ? | AO-2023-DM-0312 | Pharma Dispositifs -4% mais qualité moindre lots 1-2 |
| 31 | Analyse financière du marché restauration PA-2024-HOT-0156 | PA-2024-HOT-0156 | 2.4M€ HT/an, 5 ans, multi-sites |

### Étude de marché

| # | Prompt | Document | Points attendus |
|---|--------|----------|----------------|
| 32 | Que dit l'étude de marché pour les réactifs de laboratoire ? | AO-2023-LAB-0891 | 1.8M analyses/an, modèle "réactif + automate en prêt", recommandations |
| 33 | Quelles sont les recommandations de l'étude de marché réactifs pour le futur marché ? | AO-2023-LAB-0891 | Allotissement par discipline, interconnexion SIL, coût complet |

---

## 📋 Cas d'usage 3 : Vérification SLA et pénalités

### Délais de livraison

| # | Prompt | Document | Points attendus |
|---|--------|----------|----------------|
| 34 | Quels sont les délais de livraison exigés pour le marché AO-2024-DM-0488 gants ? | AO-2024-DM-0488 | Délais pour 4.2M paires/an |
| 35 | Quelles pénalités de retard pour le marché AO-2023-DM-0312 dispositifs médicaux ? | AO-2023-DM-0312 | Stock sécurité 15 jours, délai MediSupply 48h vs Pharma 72h |
| 36 | Délais de livraison du marché blanchisserie AO-2023-HOT-0298 ? | AO-2023-HOT-0298 | 420 tonnes linge plat, 85 tonnes vêtements pro |

### GTI / GTR / Astreinte

| # | Prompt | Document | Points attendus |
|---|--------|----------|----------------|
| 37 | Quelles sont les GTI et astreinte du marché gaz médicaux AO-2024-MED-0723 ? | AO-2024-MED-0723 | Astreinte 24/7, intervention garantie sous 2h, télémonitoring cuves |
| 38 | Quel est le temps d'intervention garanti pour le marché AO-2024-BIO-0847 ? | AO-2024-BIO-0847 | Maintenance intégrée, intervention sous 4h |
| 39 | GTI et maintenance pour le marché imagerie AO-2024-BIO-1203 ? | AO-2024-BIO-1203 | Maintenance tous risques 8 ans |

### Analyse complète SLA

| # | Prompt | Document | Points attendus |
|---|--------|----------|----------------|
| 40 | Fais une analyse complète des SLA du marché nettoyage AO-2024-HOT-0412 | AO-2024-HOT-0412 | Zone 4 (très haut risque), bio-nettoyage entre chaque intervention, fréquences 3x/jour |
| 41 | Toutes les clauses contractuelles du marché DPI AO-2023-IT-0156 | AO-2023-IT-0156 | DPI pour 3 établissements, 750 lits, 2200 utilisateurs, migration |
| 42 | Compare les SLA du marché gaz médicaux avec le marché équipements biomédicaux | AO-2024-MED-0723 vs AO-2024-BIO-0847 | 2h vs 4h intervention, astreinte 24/7 vs standard |

---

## 📋 Cas d'usage 4 : Analyse et challenge des candidats

### Reconstitution de la grille de notation

| # | Prompt | Document | Points attendus |
|---|--------|----------|----------------|
| 43 | Reconstitue la grille de notation du marché AO-2023-DM-0312 | AO-2023-DM-0312 | Rapport d'analyse, 850K€/an, 4 lots, notation multi-candidats |
| 44 | Montre-moi le classement des candidats pour le marché gaz médicaux AO-2024-MED-0723 | AO-2024-MED-0723 | Air Liquide 85/100, Linde 83.5/100, SOL France 79/100 |
| 45 | Quelles sont les notes des candidats pour le marché AO-2024-BIO-0847 ? | AO-2024-BIO-0847 | MedTech Solutions = attributaire |

### Challenger le choix de l'acheteur

| # | Prompt | Document | Points attendus |
|---|--------|----------|----------------|
| 46 | Challenge le choix d'Air Liquide pour le marché AO-2024-MED-0723. Linde était moins cher, pourquoi ce choix ? | AO-2024-MED-0723 | Air Liquide 515K€ vs Linde 498K€, mais technique 47.5 vs 44 — télémonitoring, astreinte 24/7, ISO 13485 |
| 47 | Tu es d'accord avec l'attribution à MedTech Solutions pour AO-2024-BIO-0847 ? | AO-2024-BIO-0847 | Couverture tous lots, maintenance 4h, CE + ISO 13485 |
| 48 | Pharma Dispositifs était 4% moins cher sur le marché AO-2023-DM-0312, pourquoi ne pas l'avoir retenu ? | AO-2023-DM-0312 | Qualité technique moindre lots 1-2 (sondes, cathéters), délai 72h vs 48h |

### Comparer avec son propre choix

| # | Prompt | Document | Points attendus |
|---|--------|----------|----------------|
| 49 | J'hésite entre Linde et Air Liquide pour les gaz médicaux, compare les deux | AO-2024-MED-0723 | Prix Linde 498K vs Air Liquide 515K, mais tech 44 vs 47.5, SOL France que lots 1+3 |
| 50 | Si je devais choisir SOL France pour le marché gaz médicaux, quels seraient les risques ? | AO-2024-MED-0723 | Couverture partielle (lots 1+3 seulement), note technique 40/55, pas de lot maintenance |

### Simulation de pondération

| # | Prompt | Document | Points attendus |
|---|--------|----------|----------------|
| 51 | Recalcule le classement du marché AO-2024-MED-0723 avec technique 70% et prix 30% | AO-2024-MED-0723 | Shift probable en faveur d'Air Liquide (meilleure note technique) |
| 52 | Et si on mettait prix 60% et technique 40% pour le marché gaz médicaux ? | AO-2024-MED-0723 | Shift probable en faveur de SOL France ou Linde |

---

## 🌟 Prompts "Wow" pour la démo acheteurs

> Ces prompts démontrent directement la valeur ajoutée de l'IA aux acheteurs.

| # | Prompt | Valeur démontrée |
|---|--------|-----------------|
| 53 | Compare les marchés biomédicaux 2023 vs 2024 : tendances de prix et fournisseurs récurrents | Analyse transverse multi-marchés |
| 54 | Si je lance un nouveau marché pour des réactifs de labo, qu'est-ce que l'étude de marché existante me recommande ? | Capitalisation sur l'existant (AO-2023-LAB-0891) |
| 55 | Quels fournisseurs apparaissent sur plusieurs marchés du GHT ? | Détection de fournisseurs récurrents |
| 56 | Donne-moi un résumé exécutif de tous les marchés de la catégorie Médicaments avec montants et attributaires | Synthèse dirigeant — AC-2023-MED-0567, AO-2024-MED-0723, AO-2023-MED-0892 |
| 57 | Le GHT est-il conforme NIS2 vu les marchés IT en cours ? | Conformité réglementaire croisée (AO-2024-IT-0234 cybersécurité) |
| 58 | Quel est le budget total des marchés en cours par catégorie ? | Vue consolidée achats |
| 59 | Air Liquide a remporté le marché gaz à 515K€ alors que Linde proposait 498K€. Explique pourquoi c'est justifié et chiffre l'écart technique. | Challenge argumenté avec données |
| 60 | Prépare-moi un argumentaire pour justifier le renouvellement du marché stérilisation AO-2024-BIO-0955 | Aide à la rédaction — 8500 interventions/an, 45000 cycles |
