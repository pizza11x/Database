# Database University Project (ITA)

1) Exec_Procedure
2) export
3) script

La prima cartella contiene i 6 file con estensione ".sql" riferiti alle esecuzioni delle 6 procedure con i parametri suggeriti per testarle.
La seconda cartella, "export", contiene il dump del nostro database insieme al file con estensione ".log".

La terza cartella è quella degli script che vanno compilati nell'ordine in cui sono numerati.

Si parte dal file "0_create_user_admin.sql" che contiene lo script per creare l'utente proprietario, chiamato "casa_discografica" con password "musica", che va eseguito dall'utente SYS.
Successivamente c'è il file "1_create.sql" che contiene gli script per creare le tabelle con i constraints e le primary key.
Segue il file "2_foreign.sql" al cui interno troviamo le foreign key delle tabelle.
Poi c'è il file "3_procedure.sql" che contiene gli script per compilare le 6 procedure.
Successivamente c'è il file "4_insert.sql" che contiene tutti gli insert ordinati che andranno a popolare le tabelle.
E per ultimo va compilato il file "5_trigger.sql" dove al suo interno sono presenti i 9 triggers.

Il file "6_create_users" serve per creare gli utenti "impiegato" e "contabile" con i propri grant. Anche questo file va eseguito da SYS.

Se si vogliono eliminare le tabelle va compilato l'ultimo file "999_drop_table.sql".
