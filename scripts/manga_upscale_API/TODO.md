Pré-requis:
===========
- Ajouter le path d'un titre dans son retour API GET TITLES / **OK**
- 

À faire:
========
1. POST JOB : **NODE/DB** Créer un job dans le JSON de synthèse des jobs courants + lancer un processus
    titre; PID; status[running, paused, completed]; / **OK**
2. GET JOB PAGE COUNT : **SCRIPT** Faire un script qui récupère juste le nombre de pages traitées / **OK**
3. GET JOB STATUS : **NODE/DB** Lire le PID du processus dans le JSON de synthèse des job courants **OU** vérifier si le processus(PID) est vivant => si oui [running], sinon[paused, completed]

4. GET JOB PAUSE : **NODE/DB** Tuer le processus au PID correspondant dans le JSON de synthèse des jobs courants
5. GET JOB RESUME : **NODE/DB** Faire correspondre le titre avec un élément de la liste, lancer un nouveau processus et remplacer le PID de la liste avec le nouveau PID (du processus actuel)
