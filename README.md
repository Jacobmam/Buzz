# **Overview**  

Buzz🏀 ist eine Swift-basierte iOS-App, die Basketballspielern hilft, schnell und einfach einen Basketballplatz in deutschen Städten zu finden. Die App bietet eine interaktive Karte mit Standorten von Courts und ermöglicht es Nutzern, Plätze zu bewerten und Matches zu organisieren.  
Die Anwendung wird in Zukunft auf die **Google Maps API** setzen, um eine präzisere Standortsuche und Navigation zu ermöglichen.  


# Installation

Clone the Buzz App Code for Xcode using Git.

https://github.com/Jacobmam/Buzz.git


# 🚀 Features

1. Find Court
  
Filtermöglichkeiten:
Stadt
Indoor/Outdoor
Bewertungen

2. Community-Features

Matches erstellen:
Datum, Uhrzeit, Court, Spiellevel festlegen. 1v1, 3v3 oder 5v5.
Spieler einladen und Matches planen.

Chat für Matches:
Austausch vor dem Spiel

Bewertungen:
Court-Bewertung nach Spielen
Spieler-Bewertung für Fairness und Skill etc...


3. Gamification & Challenges

Challenges:
Besuche neue Courts, spiele Matches, schließe Aufgaben ab
Verdiene Badges und Punkte.

Ranking-System:
Vergleiche dich mit anderen Spielern in deiner Stadt.

Achievements:
Unlock-Badges für besondere Leistungen (z. B. „Explorer: Berlin“ oder „100 Spiele“)


# IOS Technology Implementation

- XCode
- MVVM Pattern
- ViewModel
- Navigation components


# Backend Functionality with Firebase

Authentifizierung:

Die Benutzerregistrierung und Anmeldung werden durch Firebase Authentication ermöglicht.
Sichere und flexible Anmeldemethoden sorgen für eine bequeme Nutzung der App.


Datenbank:

Firebase Firestore wird für eine effiziente Datenspeicherung genutzt.
Informationen zu Basketballplätzen, Matches und anderen nutzerbezogenen Daten werden sicher in Firestore gespeichert und verwaltet.
