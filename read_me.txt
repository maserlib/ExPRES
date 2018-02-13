SERPE V6.1

/trunk/ : contient les routines nécessaires au fonctionnement de SERPE
/data/mfl/ : contient les lignes de champs magnétiques utilisées par SERPE (+ les routines permettant de les calculer -> pas nécessaires)
/ephemerides/ : contient des fichiers .sav contenant les éphémérides de sondes non disponibles via MIRIADE
/cdawlib/ : contient la librairie utile à la création des fichiers cdf

Il faut donc que idl soit capable de lire les routines dans les dossiers trunk & cdawlib
Au début il faut faire un :
> @serpe_compile
afin de compiler toutes les routines (de trunk et cdawlib)

ensuite, la simulation se lance en faisant :
> main,filename

Afin que les routines de SERPE aillent bien chercher les éphémérides et les lignes de champs au bon endroit, et écrive les fichiers dans le répertoire voulu, 
il faut noter le nom de ces répertoires dans la routine "loadpath.pro"

Si on veut écrire les résultats directement sur kronos, il faut monter kronos en sshfs :
et ajouter l'appel dans "serpe_compile.pro"