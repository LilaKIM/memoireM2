#===============================================================================

form essai
	sentence chemin_vers_source ../NCCFr/
	sentence chemin_vers_txtFile ../temp/non_troncons/train_test_aAEI/
	sentence chemin_vers_resultat ../resultat/
	word formatWav .wav
	word formatTextGrid .TextGrid
	word formatTxt .txt
	word formatCsv .csv
	real margeExtraisSecondes 0.05
endform

#===============================================================================
regex_chemin_vers_txt$ = chemin_vers_txtFile$ + "*.txt"
filesList = Create Strings as file list: "fileslist", regex_chemin_vers_txt$
nfiles = Get number of strings

for ifile to nfiles
	selectObject:filesList
	nomFichierTxt$ = Get string: ifile
	nomFichierBase$ = nomFichierTxt$ - formatTxt$
	chemin_absolu_vers_txt$ = chemin_vers_txtFile$ + nomFichierTxt$
	chemin_absolu_vers_son$ = chemin_vers_source$ + nomFichierBase$ + formatWav$
	chemin_absolu_vers_textGrid$ = chemin_vers_source$ + nomFichierBase$ + formatTextGrid$
	chemin_absolu_vers_output$ = chemin_vers_resultat$ + nomFichierBase$ + formatCsv$
	writeFileLine: chemin_absolu_vers_output$, "son", tab$, "temps_debut", tab$, "temps_fin", tab$, "f0_milieuV", tab$, "f0_mean", tab$, "intensite_milieuV", tab$, "intensite_mean"

	txtGrid = Read from file: chemin_absolu_vers_textGrid$
	sound = Read from file: chemin_absolu_vers_son$
	tEnregistrement = Get total duration

	textfile = Read Strings from raw text file: chemin_absolu_vers_txt$
	numberOfStrings = Get number of strings

	for stringNumber from 2 to numberOfStrings
	#===============================================================================
		selectObject: textfile
		string$ = Get string: stringNumber
		tab1 = index(string$, tab$)
		tab2 = rindex(string$, tab$)

		segment$ = left$(string$, tab1-1)
		tDebut = number(mid$(string$, tab1+1, tab2 - tab1))
		pause 'tDebut'
		
		tDebcorrige = tDebut - margeExtraisSecondes
		if tDebcorrige < 0
			tDebcorrige = 0
		endif

		tFin = number(right$(string$, length(string$) - tab2))
		tFincorrige = tFin + margeExtraisSecondes
		if tFincorrige > tEnregistrement
			tFincorrige = tEnregistrement
		endif
		tMilieu = tDebut + (tFin - tDebut) / 2

		selectObject: txtGrid
		interval = Get interval at time: 1, tMilieu
		label$ = Get label of interval: 1, interval
	#===============================================================================

		if segment$ == label$
			appendFile: chemin_absolu_vers_output$, segment$
			appendFile: chemin_absolu_vers_output$, tab$, tDebut
			appendFile: chemin_absolu_vers_output$, tab$, tFin

			selectObject: sound
			extrait = Extract part: tDebcorrige, tFincorrige, "rectangular", 1, "yes"
			To Pitch: 0, 75, 600
			f0milieuV = Get value at time: tMilieu, "Hertz", "linear"
			f0moyV = Get mean: tDebut, tFin, "Hertz"
			appendFile: chemin_absolu_vers_output$, tab$, f0milieuV
			appendFile: chemin_absolu_vers_output$, tab$, f0moyV

			selectObject: extrait
			To Intensity: 100, 0, "yes"
			intmilieuV = Get value at time: tMilieu, "cubic"
			intmoyV = Get mean: tDebut, tFin, "energy"
			appendFile: chemin_absolu_vers_output$, tab$, intmilieuV
			appendFile: chemin_absolu_vers_output$, tab$, intmoyV

			appendFile: chemin_absolu_vers_output$, newline$
		else
			pause "Error !"
		endif
	endfor
	select all
	minus 'filesList'
	Remove
endfor
