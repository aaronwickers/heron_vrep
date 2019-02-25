Damit ein vorgegebener Polygonzug mit den hier entwickelten Dateien abgefahren werden kann, muss:

1) Das Programm Matlab mit einer Version 2013b (64bit) oder neuer gestartet und der Ordner "matlab" zum aktuellen Arbeits-Ordner hinzugefügt werden.
2) Das Programm V-REP mit einer Version 3.5.0 (rev4) (64bit) gestartet und die Datei "the_heron" aufgerufen werden.
3) Die Funktion "VREP_asynchron.m" per Eingabe in die Matlab Konsole gestartet werden mit 
>>VREP_asynchron(A) 
,wobei A in diesem Fall die gewünschte Wegpunkt-Matrix der Form [nx2] beinhaltet.

Nun sollte die Simulation starten und das Modell sich bewegen. Nach Erreichen des Zielpunkts wird die Simulation gestoppt und beendet. 
Zuletzt werden noch einige Plots ausgegeben. (Siehe Matlab-file)


----------------Hinweise----------------
.Die Dateien im Ordner "matlab" sind notwendig für eine funktionierende Schnittstelle zwischen VREP und matlab. Diese funktioniert nur unter Windows oder Linux, iOS user müssen sich die entsprechende remote-datei aus dem Programm VREP heraussuchen.
.Die Datei "the_heron_no_matlab" ist für den Fall vorgesehen, dass Antriebskräfte für das Modell in VREP selbst entworfen/berechnet werden sollen. Sie funktioniert ohne eine Verbindung zu Matlab. Kräfte können in den jeweiligen Child-Skripten der Schwimmkörper manuell eingegeben werden. Sie ist allerdings nur als eine Art Bonus-Material zu sehen.
.Die Konventionen, Reglerparameter und Begrenzungen der Kräfte sowie die Bedingungen für die Detektionsradien sind der zugehörigen Bachelorarbeit zu entnehmen. Bei widersprüchlichen Angaben der Radien wird die Simulation selbstverständlich fehlschlagen. 
