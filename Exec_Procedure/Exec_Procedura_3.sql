Begin

/*
   EXEC PROCEDURA NUMERO 3 :
   
   Quando si inserisce un concerto, organizzato dall'agenzia booking
   che gestisce più concerti, automaticamente gli viene assegnato una promozione e la tipologia promozione "Televisiva".
   
   Parametri da inserire per testare la procedura : 
   
   - p_nome      = Eros tour
   - p_struttura = Stadio San Paolo
   - p_data      = 22/06/2020
   - p_citta     = Napoli
   - p_artista   = 017

*/

live(
     :p_nome,
     :p_struttura,
     :p_citta,
     :p_data,
     :p_artista
    );

End;