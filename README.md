# MagyarTV

Csináld magad magyar TV csatornák Apple TV 4-re, iOS-re és Mac-re ingyen!

* M1
* M2
* M4 Sport (2021 óta a reklámok miatt nem működik, pull request-et elfogadok)
* M5
* Duna TV
* Duna World

![Menü](Doc/1.png)
![Belső képernyő](Doc/2.png)


## Telepítés

1. [Töltsd le](https://github.com/gklka/MagyarTV/archive/master.zip)
2. ha nincs fent, akkor telepítsd a CocoaPods-ot:

	```
	$ sudo gem install cocoapods
	```

3. lépj be Terminal-ban a project könyvtárába és telepítsd a pod-okat:

	```
	$ pod install
	```

4. A fehér ikonos `MagyarTV.xcworkspace` fájlt nyisd meg Xcode-dal

5. Állítsd be a MagyarTV → Targets / MagyarTV illetve Targets / MagyatTVMobile → Signing & Capabilities résznél a Team-ed és ajd egy egyedi Bundle Identifier-t az appnak (<tedomained>.MagyarTV pl)

6. A play gomb mellett tudod telepíteni a csatlakoztatott készülékedre. Válaszd a "MagyarTVMobile"-t az iOS/Mac verzióhoz, a "MagyarTV"-t pedig tvOS-hez! Az Apple TV 4-et csatlakoztatni kell USB-C kábellel a géphez és az Xcode felső sávjában ki kell választani. Apple TV 4K és afelett vezeték nélkül, párosítás után tudod telepíteni. Ennek részleteire keress rá!

## Tudnivalók

A program által megjelenített tartalom az MTVA szervereiről érkezik, ahogyan azt mediaklikk.hu honlap is megjeleníti. A program nem manipulálja ezeket a streameket.

## GYIK

### Miért nincs kint a program az App Store-ban?

Mert az MTVA nem méltatott válaszra, az ő engedélyük nélkül pedig nem lehetséges a program publikálása.

### Miért nincs TestFlight?

Mert nincs saját developer előfizetésem.

### Valami nem megy, hol talállak meg?

Nyiss itt ticketet vagy keress Twitteren: @gklka

