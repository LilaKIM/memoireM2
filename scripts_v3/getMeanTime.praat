#----------------------ouverture du fichier-----------------------
form nccfr
	sentence chemin_vers_donnees ../NCCFr/
	integer iChamp 1
	real dureeMax 0.25
	real duree_E_mean 0
endform

regex_chemin_vers_son$ = chemin_vers_donnees$ + "*.wav"
filesList = Create Strings as file list: "fileslist", regex_chemin_vers_son$
nfiles = Get number of strings

nb_E_total = 0
duree_E_total = 0

for ifile to nfiles
	selectObject: filesList
	nomFichierSon$ = Get string: ifile
	chemin_absolu_vers_son$ = chemin_vers_donnees$ + nomFichierSon$
	nomFichierBase$ = nomFichierSon$ - ".wav"
	chemin_absolu_vers_text$ = chemin_vers_donnees$ + nomFichierBase$ + ".textGrid"

	son = Read from file: chemin_absolu_vers_son$
	textGrid = Read from file: chemin_absolu_vers_text$

	nb_I = 0
	nb_E = 0
	duree_E = 0
	tot = 0
	compteur_E = 0
	compteur_I = 0
	#---------------------------------------------------------------

	selectObject: textGrid
	nb_intervals = Get number of intervals: iChamp
	# writeInfoLine: "nb intervals : ", nb_intervals

	# Pour obtenir la moyenne de la duree de tous les a
	for iInterval from 1 to nb_intervals
		txt$ = Get label of interval: iChamp, iInterval

		if (txt$ == "a")
			nb_E += 1
			tDeb = Get start point: iChamp, iInterval
			tFin = Get end point: iChamp, iInterval
			duree = tFin - tDeb
			duree_E_total += duree
			nb_E_total += 1
		endif
	endfor

	select all
	minus 'filesList'
	Remove
	# appendInfoLine: duree_E_total
endfor
# appendInfoLine: "comp_max:", comp_max
duree_mean_total = duree_E_total/nb_E_total
appendInfoLine: duree_E_total, nb_E_total
appendInfoLine: "duree_mean_total :", duree_mean_total
