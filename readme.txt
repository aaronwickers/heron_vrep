Die in dem Ordner "matlab" hinterlegten Dateien sind notwendig, damit die remote-Schnittstelle funktionieren kann. 
Ausgeführt wird jedoch einzig und allein die Datei "VREP_asynchron.m", welche als Argument eine nx2 Matrix mit Wegpunkten erwartet. 

Die im Ordner "vrep" hinterlegte Datei "the_heron" ist das entsprechende Gegenstück auf VREP Seite.

Damit der vorgegebene Polygonzug mit den hier entwickelten Dateien abgefahren werden kann, muss:

1) Das Programm Matlab mit einer Version 2013b (64bit) oder neuer gestartet und der Ordner "matlab" zum aktuellen Ordner hinzugefügt werden.
2) Das Programm V-REP mit einer Version 3.5.0 (rev4) (64bit) gestartet und die Datei "the_heron" aufgerufen werden.
3) Die Funktion "VREP_asynchron.m" per Eingabe in die Matlab Konsole gestartet werden mit 
>>VREP_asynchron(A)
wobei A in diesem Fall die gewünschte Wegpunkt-Matrix beinhaltet.

Nun sollte die Simulation starten und das Modell sich bewegen. Nach Erreichen des Zielpunkts wird die Simulation gestoppt und beendet. 
Zuletzt werden noch einige Plots ausgegeben. (Siehe Matlab-file)
