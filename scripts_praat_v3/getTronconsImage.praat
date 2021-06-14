#----------------------ouverture du fichier-----------------------
form nccfr
	sentence chemin_vers_donnees NCCFr/
	word generatedFolder corpus_troncons_2
	integer iChamp 1
	real dureeMax 0.25
	integer minimum 275
	real duree_a_mean 0.062150786510958365
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

check1_a = 0
check2_a = 0
check1_A = 0
check2_A = 0

regex_chemin_vers_son$ = chemin_vers_donnees$ + "*.wav"
filesList = Create Strings as file list: "fileslist", regex_chemin_vers_son$
nfiles = Get number of strings

generatedSampleImagesFolder$ = generatedFolder$ + "/images"
generatedTrainImagesFolder$ = generatedSampleImagesFolder$ + "/train"
generatedTrainImagesNasalFolder$ = generatedTrainImagesFolder$ + "/nasal"
generatedTrainImagesNonNasalFolder$ = generatedTrainImagesFolder$ + "/non_nasal"

generatedTestImagesFolder$ = generatedSampleImagesFolder$ + "/test"
generatedTestImagesNasalFolder$ = generatedTestImagesFolder$ + "/nasal"
generatedTestImagesNonNasalFolder$ = generatedTestImagesFolder$ + "/non_nasal"


generatedSampleSoundsFolder$ = generatedFolder$ + "/wav"
generatedTrainSoundsFolder$ = generatedSampleSoundsFolder$ + "/train"
generatedTrainSoundsNasalFolder$ = generatedTrainSoundsFolder$ + "/nasal"
generatedTrainSoundsNonNasalFolder$ = generatedTrainSoundsFolder$ + "/non_nasal"

generatedTestSoundsFolder$ = generatedSampleSoundsFolder$ + "/test"
generatedTestSoundsNasalFolder$ = generatedTestSoundsFolder$ + "/nasal"
generatedTestSoundsNonNasalFolder$ = generatedTestSoundsFolder$ + "/non_nasal"

createDirectory: generatedFolder$
createDirectory: generatedSampleImagesFolder$
createDirectory: generatedTrainImagesFolder$
createDirectory: generatedTrainImagesNasalFolder$
createDirectory: generatedTrainImagesNonNasalFolder$
createDirectory: generatedTestImagesFolder$
createDirectory: generatedTestImagesNasalFolder$
createDirectory: generatedTestImagesNonNasalFolder$

createDirectory: generatedSampleSoundsFolder$
createDirectory: generatedTrainSoundsFolder$
createDirectory: generatedTrainSoundsNasalFolder$
createDirectory: generatedTrainSoundsNonNasalFolder$
createDirectory: generatedTestSoundsFolder$
createDirectory: generatedTestSoundsNasalFolder$
createDirectory: generatedTestSoundsNonNasalFolder$

for ifile to nfiles
	selectObject: filesList
	nomFichierSon$ = Get string: ifile
	chemin_absolu_vers_son$ = chemin_vers_donnees$ + nomFichierSon$
	nomFichierBase$ = nomFichierSon$ - ".wav"
	chemin_absolu_vers_text$ = chemin_vers_donnees$ + nomFichierBase$ + ".textGrid"

	son = Read from file: chemin_absolu_vers_son$
	textGrid = Read from file: chemin_absolu_vers_text$

	compteur_a = 0
	compteur_A = 0
	#---------------------------------------------------------------
	selectObject: son
	spectrogramme = To Spectrogram: 0.005, 8000, 0.002, 20, "Gaussian"

	selectObject: textGrid
	nb_intervals = Get number of intervals: iChamp
	writeInfoLine: "nb intervals : ", nb_intervals

	train = round(minimum*0.8)

	appendInfoLine: "le nombre de train : ", train*2
	appendInfoLine: "le nombre de test : ", round(minimum*2*0.2)

	for iInterval from 2 to nb_intervals-1

		selectObject: textGrid

		txtAvant$ = Get label of interval: iChamp, iInterval - 1
		txt$ = Get label of interval: iChamp, iInterval
		txtApres$ = Get label of interval: iChamp, iInterval + 1

		if compteur_a < minimum
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
						compteur_a += 1

						if compteur_a <= train
							folder$ = generatedTrainImagesNonNasalFolder$
							folderSounds$ = generatedTrainSoundsNonNasalFolder$
						else
							folder$ = generatedTestImagesNonNasalFolder$
							folderSounds$ = generatedTestSoundsNonNasalFolder$
						endif
						tempsTroncon = duree / 3
						for ind from 1 to 3
							if ind <> 1
								tDeb = tFinTroncon
							endif
							tFinTroncon = tDeb + tempsTroncon
							selectObject: son
							Extract part: tDeb, tFinTroncon, "rectangular", 1, "no"
							Save as WAV file: folderSounds$ + "/" + nomFichierBase$ + "_" + txt$ + "_" + string$(iInterval) + "_" + txtAvantFinale$ + "_" + txtApresFinale$ + "_" + string$(tDeb) + "_" + string$(tFinTroncon) + "_" + string$(ind) + "_part.wav"

							selectObject: spectrogramme
							zero_padding_factor = 5 / (dureeMax/tempsTroncon)
							Select outer viewport: 0, zero_padding_factor, 0, 3
							Paint: tDeb, tFinTroncon, 0, 0, 100, "yes", 50, 6, 0, "no"
							Select outer viewport: 0, 5, 0, 3
							Save as 300-dpi PNG file: folder$ + "/" + nomFichierBase$ + "_" + txt$ + "_" + string$(iInterval) + "_" + txtAvantFinale$ + "_" + txtApresFinale$ + "_" + string$(tDeb) + "_" + string$(tFinTroncon) + "_" + string$(ind) + ".png"
							Erase all
						endfor
					endif
				endif
			endif
		endif
		if compteur_A < minimum
			if (txt$ = "A")
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
						compteur_A += 1

						if compteur_A <= train
							folder$ = generatedTrainImagesNasalFolder$
							folderSounds$ = generatedTrainSoundsNasalFolder$
						else
							folder$ = generatedTestImagesNasalFolder$
							folderSounds$ = generatedTestSoundsNasalFolder$
						endif
						tempsTroncon = duree / 3
						for ind from 1 to 3
							if ind <> 1
								tDeb = tFinTroncon
							endif
							tFinTroncon = tDeb + tempsTroncon
							selectObject: son
							Extract part: tDeb, tFinTroncon, "rectangular", 1, "no"
							Save as WAV file: folderSounds$ + "/" + nomFichierBase$ + "_" + txt$ + "_" + string$(iInterval) + "_" + txtAvantFinale$ + "_" + txtApresFinale$ + "_" + string$(tDeb) + "_" + string$(tFinTroncon) + "_" + string$(ind) + "_part.wav"

							selectObject: spectrogramme
							zero_padding_factor = 5 / (dureeMax/tempsTroncon)
							Select outer viewport: 0, zero_padding_factor, 0, 3
							Paint: tDeb, tFinTroncon, 0, 0, 100, "yes", 50, 6, 0, "no"
							Select outer viewport: 0, 5, 0, 3
							Save as 300-dpi PNG file: folder$ + "/" + nomFichierBase$ + "_" + txt$ + "_" + string$(iInterval) + "_" + txtAvantFinale$ + "_" + txtApresFinale$ + "_" + string$(tDeb) + "_" + string$(tFinTroncon) + "_" + string$(ind) + ".png"
							Erase all
						endfor
					endif
				endif
			endif
		endif
		check1_a = 0
		check2_a = 0
		check1_A = 0
		check2_A = 0
	endfor
	appendInfoLine: "Aa : ", compteur_A+compteur_a,"  A : ", compteur_A, "  a : ", compteur_a
	appendInfoLine: "ok"
	select all
	minus 'filesList'
	Remove
endfor
