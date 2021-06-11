# Database University Project (ITA)

The first folder contains the 6 files with ".sql" extension referring to the executions of the 6 procedures with the suggested parameters to test them. The second folder, "export", contains the dump of our database together with the file with the ".log" extension.

The third folder is that of the scripts that must be compiled in the order in which they are numbered.

It starts from the file "0_create_user_admin.sql" which contains the script to create the owner user, called "casa_discografica" with password "musica", which must be executed by the SYS user. Then there is the "1_create.sql" file which contains the scripts to create the tables with constraints and primary keys. The file "2_foreign.sql" follows, inside which we find the foreign keys of the tables. Then there is the "3_procedure.sql" file which contains the scripts to compile the 6 procedures. Then there is the "4_insert.sql" file which contains all the sorted inserts that will populate the tables. And lastly, the "5_trigger.sql" file must be compiled where the 9 triggers are present.

The "6_create_users" file is used to create "employee" and "accountant" users with their grants. This file must also be run by SYS.

If you want to delete the tables you have to fill in the last file "999_drop_table.sql".
