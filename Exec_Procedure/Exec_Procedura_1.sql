Begin

/*
  EXEC PROCEDURA NUMERO 1 :

  Quando l'admin inserisce un nuovo contratto gli associa ad un'artista il 
  manager più giovane che attualmente ha meno contratti.
  
  Parametri da inserire per testare la procedura : 
  
  - p_id_artista         = 020
  - p_data_inizio        = 28/07/2020 ***Se si proverà ad inserire un data antecedente a quella odierna, il trigger automaticamente la aggiornerà ad essa.
  - p_stipendio_artista  = 2300
  - p_durata             = 28/07/2025
  - p_stipendio_manager  = 1775 
*/


  casa_discografica.nuovo_contratto(
                                   :p_id_artista,    
                                   :p_data_inizio,   
                                   :p_stipendio_artista, 
                                   :p_durata,            
                                   :p_stipendio_manager 
                                   );
end;                     