Begin

/*
   EXEC PROCEDURA NUMERO 5 :
   
   Aggiungere un nuovo distributore e la sua tipologia ad un album.
   
   Parametri da inserire per testare la procedura : 
   
   - p_album     = A21
   - p_nome      = Itunes
   - p_sede      = Taormina
   - p_email     = itunes.05@gmail.com
   - p_telefono  = 3380005016
   - p_iva       = partiva017
   - p_tipo      = Fisico

*/

distributore_album (    
                    :p_album,   
                    :p_nome, 
                    :p_sede, 
                    :p_email,
                    :p_telefono,
                    :p_iva,     
                    :p_tipo
                   );    

End;