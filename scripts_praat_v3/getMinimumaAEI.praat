#----------------------ouverture du fichier-----------------------
form nccfr
	sentence chemin_vers_donnees NCCFr/
	integer iChamp 1
	real dureeMax 0.25
	integer minimum 275
	real duree_a_mean 0.061034940811618206
endform

writeFileLine: "resultat.txt", "yes"
writeInfoLine: "new"
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

regex_chemin_vers_son$ = chemin_vers_donnees$ + "*.wav"
filesList = Create Strings as file list: "fileslist", regex_chemin_vers_son$
nfiles = Get number of strings

for ifile to nfiles
	selectObject: filesList
	nomFichierSon$ = Get string: ifile
	chemin_absolu_vers_son$ = chemin_vers_donnees$ + nomFichierSon$
	nomFichierBase$ = nomFichierSon$ - ".wav"
	chemin_absolu_vers_text$ = chemin_vers_donnees$ + nomFichierBase$ + ".textGrid"
	appendInfoLine: nomFichierBase$
	son = Read from file: chemin_absolu_vers_son$
	textGrid = Read from file: chemin_absolu_vers_text$

	nb_A = 0
	nb_I = 0
	tot = 0
	tot_E = 0
	check1_a = 0
	check2_a = 0
	check1_A = 0
	check2_A = 0
	#---------------------------------------------------------------

	selectObject: textGrid
	nb_intervals = Get number of intervals: iChamp

	# pour obtenir le nombre total de a qui a une duree superieure a la duree en moyenne de a
	for iInterval from 2 to nb_intervals-1
		txtAvant$ = Get label of interval: iChamp, iInterval - 1
		txt$ = Get label of interval: iChamp, iInterval
		txtApres$ = Get label of interval: iChamp, iInterval + 1
		if (txt$ == "A")
			for i from 1 to length
				phoneme$ = mid$ (var$, i)
				if txtAvant$ = phoneme$
					txtAvantFinale$ = dict$["'phoneme$'"]
					check1_A = 1
				endif
				if txtApres$ = phoneme$
					txtApresFinale$ = dict$["'phoneme$'"]
					check2_A = 1
				endif
			endfor
			if check1_A = 1 and check2_A = 1
				# pause 'txtAvant$', 'txtAvantFinale$', "A", 'txtApres$', 'txtApresFinale$', 'iInterval'
				tDeb = Get start point: iChamp, iInterval
				tFin = Get end point: iChamp, iInterval
				duree = tFin - tDeb
				if (duree <= dureeMax)
					nb_A += 1
					appendFileLine: "resultat.txt", txtAvantFinale$, tab$, txtAvant$, tab$, txt$, tab$, txtApresFinale$, tab$, txtApres$, tab$, iInterval
				endif
			endif
		endif
		if (txt$ = "a")
			for i from 1 to length
				phoneme$ = mid$ (var$, i)
				if txtAvant$ = phoneme$
					txtAvantFinale$ = dict$["'phoneme$'"]
					check1_a = 1
				endif
				if txtApres$ = phoneme$
					txtApresFinale$ = dict$["'phoneme$'"]
					check2_a = 1
				endif
			endfor
			if check1_a = 1 and check2_a = 1
				# pause 'txtAvant$', 'txtAvantFinale$', "A", 'txtApres$', 'txtApresFinale$', 'iInterval'
				tDeb = Get start point: iChamp, iInterval
				tFin = Get end point: iChamp, iInterval
				duree = tFin - tDeb
				if (duree >= duree_a_mean) and (duree <= dureeMax)
					tot += 1
					appendFileLine: "resultat.txt", txtAvantFinale$, tab$, txtAvant$, tab$, txt$, tab$, txtApresFinale$, tab$, txtApres$, tab$, iInterval
				endif
			endif
		endif
		if (txt$ == "I")
			for i from 1 to length
				phoneme$ = mid$ (var$, i)
				if txtAvant$ = phoneme$
					txtAvantFinale$ = dict$["'phoneme$'"]
					check1_I = 1
				endif
				if txtApres$ = phoneme$
					txtApresFinale$ = dict$["'phoneme$'"]
					check2_I = 1
				endif
			endfor
			if check1_I = 1 and check2_I = 1
				# pause 'txtAvant$', 'txtAvantFinale$', "A", 'txtApres$', 'txtApresFinale$', 'iInterval'
				tDeb = Get start point: iChamp, iInterval
				tFin = Get end point: iChamp, iInterval
				duree = tFin - tDeb
				if (duree <= dureeMax)
					nb_I += 1
					appendFileLine: "resultat.txt", txtAvantFinale$, tab$, txtAvant$, tab$, txt$, tab$, txtApresFinale$, tab$, txtApres$, tab$, iInterval
				endif
			endif
		endif
		if (txt$ = "E")
			for i from 1 to length
				phoneme$ = mid$ (var$, i)
				if txtAvant$ = phoneme$
					txtAvantFinale$ = dict$["'phoneme$'"]
					check1_E = 1
				endif
				if txtApres$ = phoneme$
					txtApresFinale$ = dict$["'phoneme$'"]
					check2_E = 1
				endif
			endfor
			if check1_E = 1 and check2_E = 1
				# pause 'txtAvant$', 'txtAvantFinale$', "A", 'txtApres$', 'txtApresFinale$', 'iInterval'
				tDeb = Get start point: iChamp, iInterval
				tFin = Get end point: iChamp, iInterval
				duree = tFin - tDeb
				if (duree >= duree_a_mean) and (duree <= dureeMax)
					tot_E += 1
					appendFileLine: "resultat.txt", txtAvantFinale$, tab$, txtAvant$, tab$, txt$, tab$, txtApresFinale$, tab$, txtApres$, tab$, iInterval
				endif
			endif
		endif
		check1_A = 0
		check2_A = 0
		check1_a = 0
		check2_a = 0
		check1_E = 0
		check2_E = 0
		check1_I = 0
		check2_I = 0
	endfor
	appendFileLine: "resultat.txt", "total a :", tot, "total A : ", nb_A
	appendFileLine: "resultat.txt", "total E :", tot_E, "total I : ", nb_I
	if nb_A < nb_I
		min_nasal = nb_A
	else
		min_nasal = nb_I
	endif
	if tot < tot_E
		min_oral = tot
	else
		min_oral = tot_E
	endif
	appendInfoLine: "total oral : ", min_oral, " total nasal: ", min_nasal
	if min_oral < min_nasal and min_oral < minimum
		minimum = min_oral
	elsif min_nasal < min_oral and min_nasal < minimum
		minimum = min_nasal
	endif
	appendInfoLine: "minimum :", minimum

	select all
	minus 'filesList'
	Remove
endfor

appendInfoLine: "minimum final: ", minimum
