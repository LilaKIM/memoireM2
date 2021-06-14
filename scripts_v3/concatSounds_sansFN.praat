#===============================================================================

form essai
	sentence chemin_vers_source ../NCCFr/
	sentence chemin_vers_txtFile ../temp/temps_voyelles/
	sentence chemin_vers_resultat D:\Lila\stage\resultat\temps_voyelles\
	word formatWav .wav
	word formatTextGrid .TextGrid
	word formatTxt .txt
	real margeExtraisSecondes 0.05
endform

var$ = "pbfvmntdszSZljwhkgr."
length = length(var$)
for i from 1 to length
	phoneme$ = mid$ (var$, i)
	if phoneme$ = "p" or phoneme$ = "b" or phoneme$ = "f" or phoneme$ = "v"
		value$ = "labial"
	elsif phoneme$ = "m" or phoneme$ = "n"
		value$ = phoneme$
	elsif phoneme$ = "t" or phoneme$ = "d" or phoneme$ = "s" or phoneme$ = "z" or phoneme$ = "Z" or phoneme$ = "S" or phoneme$ = "l"
		value$ = "coronal"
	elsif phoneme$ = "j" or phoneme$ = "w" or phoneme$ = "h" or phoneme$ = "k" or phoneme$ = "g" or phoneme$ = "r"
		value$ = "dorsal"
	elsif phoneme$ = "."
		value$ = "pause"
	endif
	dict$ ["'phoneme$'"] = value$
endfor

#===============================================================================
regex_chemin_vers_txt$ = chemin_vers_txtFile$ + "*.txt"
filesList = Create Strings as file list: "fileslist", regex_chemin_vers_txt$
nfiles = Get number of strings

for ifile to nfiles
	selectObject:filesList
	nomFichierTxt$ = Get string: ifile
	positionV = index(nomFichierTxt$, "V")
	nomFichierBase$ = left$(nomFichierTxt$ - formatTxt$, positionV-2)
	#pause 'nomFichierBase$'
	nomSave$ = nomFichierTxt$ - formatTxt$
	chemin_absolu_vers_txt$ = chemin_vers_txtFile$ + nomFichierTxt$
	chemin_absolu_vers_son$ = chemin_vers_source$ + nomFichierBase$ + formatWav$
	chemin_absolu_vers_textGrid$ = chemin_vers_source$ + nomFichierBase$ + formatTextGrid$
	chemin_absolu_vers_output$ = chemin_vers_resultat$ + nomSave$ + ".wav"
	#pause 'chemin_absolu_vers_textGrid$'
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
		label_precedent$ = Get label of interval: 1, interval-1
		label_prochain$ = Get label of interval: 1, interval+1
		for i from 1 to length
			phoneme$ = mid$ (var$, i)
			if label_precedent$ = phoneme$
				label_precedent$ = dict$["'phoneme$'"]
			endif
			if label_prochain$ = phoneme$
				label_prochain$ = dict$["'phoneme$'"]
			endif
		endfor
	#===============================================================================

		if segment$ == label$
			selectObject: sound
			extrait = Extract part: tDebcorrige, tFincorrige, "rectangular", 1, "no"
			Rename: "'nomFichierBase$'_'label$'_'interval'_'label_precedent$'_'label_prochain$'_'tDebut'_'tFin'"
		else
			pause "Error !"
		endif
	endfor
	select all
	minus 'filesList'
	minus 'textfile'
	minus 'txtGrid'
	minus 'sound'
	Concatenate recoverably
	pause save not automatic T_T
	# Save as WAV file: "'chemin_absolu_vers_output$'"
	select all
	minus 'filesList'
	Remove
endfor
