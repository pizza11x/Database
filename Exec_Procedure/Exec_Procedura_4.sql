Begin

/*
   EXEC PROCEDURA NUMERO 4 :
   
   Dato un concerto, si vuole cancellare la vecchia promozione
   e la sua tipologia e inserirne delle nuove aggiornando anche la struttura del concerto.
   
   Parametri da inserire per testare la procedura : 
   
   - p_nome              = Ligabue tour
   - p_data              = 29/05/2004
   - p_datapromo         = 02/05/2004
   - p_datapromo_new     = 03/05/2004
   - p_tipo_new          = Radiofonica
   - p_struttura_new     = Alcatraz
   - p_durata            = 28/05/2004
   - p_id_promozione     = 34

*/
promo_concerto (:p_nome,          
                :p_data,
                :p_datapromo,
                :p_datapromo_new,
                :p_tipo_new,
                :p_struttura_new,
                :p_durata,
                :p_id_promozione
                );

End;