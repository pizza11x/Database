CREATE OR REPLACE procedure                   aumento_stipendio (p_id  in varchar)

is

cont_premi      number;
cont_alb        number;
cont_contratto  number;
durata          date;
contratto_scaduto exception;

/*
  PROCEDURA NUMERO 6 :
 
  Se un artista ha ottenuto più di 3 premi (1° tabella coinvolta), ha prodotto più di 1 album (2° tabella coinvolta),
  e ha firmato più di 1 un contratto (3° tabella coinvolta), allora lo stipendio dell'artista verrà aumentato di 1000 euro.
*/

Begin

      Begin --Conteggio dei premi.
       
      select count (*) into cont_premi
        from ((riceve join canzone
        on canzone = id_canzone)join artista on artista = id_artista)
        where id_artista = p_id;  
        
        exception when others then dbms_output.put_line('Errore nel conteggio dei premi.'||sqlerrm);
                                 raise contratto_scaduto;
    
      End;
      
      
      Begin --Conteggio degli album.
      
      select count(*) into cont_alb
        from album join artista 
        on artista = id_artista
        where id_artista = p_id;
        
        exception when others then dbms_output.put_line('Errore nel conteggio degli album.'||sqlerrm);
                                  raise contratto_scaduto;
      
      End;
      
      Begin --Conteggio dei contratti.
      
        select count(*) into cont_contratto
        from album join artista 
        on artista = id_artista
        where id_artista = p_id;
        
        exception when others then dbms_output.put_line('Errore nel conteggio dei contratti.'||sqlerrm);
                                  raise contratto_scaduto;
      
      End;
      
      
      Begin --Selezione del contratto ancora in atto.
      
      select max(durata_contratto) into durata
      from contratto
      where artista = p_id;
      
      exception when others then dbms_output.put_line('Errore nella selezione dell''ultimo contratto.'||sqlerrm);
                               raise contratto_scaduto;

      End;
      
      
      if (durata > sysdate and cont_premi > 3 and cont_alb > 1) then
         
      Begin
          update contratto set stipendio_artista = stipendio_artista + 1000
           where artista = p_id and durata_contratto = durata;
      
      exception when others then dbms_output.put_line('Errore update'||sqlerrm);
                               raise contratto_scaduto;     
      
      end;
      
      else
       dbms_output.put_line('Errore ! Il contratto è scaduto.'||sqlerrm);
                                  raise contratto_scaduto;
      
      end if;
      
      commit;
      dbms_output.put_line('Elaborazione terminata con successo.');
      
exception when contratto_scaduto 
          then rollback;
               dbms_output.put_line('Elaborazione terminata con errori.'); 

end;
/


CREATE OR REPLACE procedure                   distributore_album (p_album    in varchar,
                                                p_nome     in varchar,
                                                p_sede     in varchar,
                                                p_email    in varchar,
                                                p_telefono in varchar,
                                                p_iva      in varchar,
                                                p_tipo     in varchar
                                                )

is

errore       exception;
v_id_dis     number;
contatore    number;

/*
  PROCEDURA NUMERO 5 :
  
  Aggiungere un nuovo distributore (1° tabella coinvolta) e la sua tipologia (2° tabella coinvolta) ad un album (3° tabella coinvolta).
*/


Begin

   Begin
   
     select count(id_citta) into contatore 
     from citta
     where nome_citta = p_sede;
     
     exception when others then dbms_output.put_line('Errore nel conteggio id citta'||sqlerrm);
                                  raise errore;
     
     end;
     
     Begin
     
     if (contatore = 0) then
        
       insert into citta (nome_citta) 
       values (p_sede);
      
     end if;   
     
     exception when others then dbms_output.put_line('If andato a buon fine.'||sqlerrm);
                                  raise errore;
     
     end;
     

   
    Begin
    
      select id_citta into v_id_dis
      from citta 
      where nome_citta = p_sede; 
      
      exception when others then dbms_output.put_line('Errore nella selezione del distributore.'||sqlerrm);
                                  raise errore;
    
    End;
    

   Begin --Inserimento nuovo distributore.
    
     insert into distributore (nome_distributore, id_citta_distributore, email_distributore, telefono_distributore, partita_iva)
     values (p_nome, v_id_dis, p_email, p_telefono, p_iva);
     
     exception when others then dbms_output.put_line('Errore nell''inserimento del distributore.'||sqlerrm);
                                  raise errore;
                                  
    end;
    
    
    Begin --Inserimento nuova tipologia distributore.
    
     insert into tipo_distributore (nome_societa, tipo_distributore)
     values (p_nome, p_tipo);
     
     exception when others then dbms_output.put_line('Errore nell''inserimento del tipo distributore.'||sqlerrm);
                                  raise errore;
     
    end;
    
    
    Begin --Associazione dell'album al distributore.
    
     insert into distribuito (album, distributore)
     values (p_album, p_nome);  
     
     exception when others then dbms_output.put_line('Errore nell''inserimento in distribuito.'||sqlerrm);
                                  raise errore;  
    
    end;
    

    
    commit;
    dbms_output.put_line('Elaborazione terminata con successo.');
exception when errore then rollback;
dbms_output.put_line('Elaborazione terminata con errori.');

End;
/


CREATE OR REPLACE procedure                   live 
                                 (p_nome            in varchar,
                                  p_struttura       in varchar,
                                  p_citta           in varchar,
                                  p_data            in date,
                                  p_artista         in varchar                                  
                                  )

is

v_iban        agenzia_booking.iban%type;
v_data        date;
v_durata      date;
v_id_concerto number;
v_id_promo    number;
v_struttura   number;
eccezione    exception;

/*
  PROCEDURA NUMERO 3 :
  
  Quando si inserisce un concerto (1° tabella coinvolta), organizzato dall'agenzia booking(2° tabella coinvolta)
  che gestisce più concerti, automaticamente gli viene inserita una promozione (3° tabella coinvolta) e la tipologia promozione (4° tabella coinvolta) "Televisiva".
*/

begin
 
     --Calcolo dell'agenzia booking che gestisce più concerti.
     begin
     
        select iban into v_iban
          from agenzia_booking join concerti
          on iban = codice_iban
          group by iban
          having count (iban) = 
                                (select max(num_conc)
                                from(
                                select count (codice_iban) num_conc
                                from concerti
                                group by codice_iban)); 
          
          exception when others then dbms_output.put_line('Errore nella query.'||sqlerrm);
                                raise eccezione;   
        
        end;
        
        Begin
        
        select id_struttura into v_struttura
        from strutture s join citta c
        on s.id_citta = c.id_citta
        where nome_struttura = p_struttura and nome_citta = p_citta;
        
        exception when others then dbms_output.put_line('Errore nella selezione dell''id struttura.'||sqlerrm);
                                raise eccezione;
        
        end;
            
    --Inserimento del concerto.
     begin
        
        insert into concerti (nome_concerto, id_struttura, data_concerto, artista, codice_iban) 
        values (p_nome, v_struttura, p_data, p_artista, v_iban);
        
        exception when others then dbms_output.put_line('Errore nell''inserimento del concerto.'||sqlerrm);
                                raise eccezione;
                                        
        end;
        
    --Inserimento della promozione.
     begin
        
       v_data := p_data - 30;
       v_durata := p_data - 1;
        Begin
           select max(id_concerto) into v_id_concerto from concerti;
            exception when others then dbms_output.put_line('Errore recupero id  concerto.'||sqlerrm);
                                raise eccezione;
        end;
        
        insert into promozione (id_concerto,inizio_promozione, durata)
        values (v_id_concerto,v_data, v_durata);
        
        exception when others then dbms_output.put_line('Errore nell''inserimento della promozione.'||sqlerrm);
                                raise eccezione;
        
        end;
        
     --Inserimento della tipologia promozione "Televisiva".
        Begin
           select max(id_promozione) into v_id_promo from promozione;
            exception when others then dbms_output.put_line('Errore recupero id  promozione.'||sqlerrm);
                                raise eccezione;
        end;
        begin
       
        
            insert into tipologia_promozione (id_promozione, tipo_promozione) 
            values (v_id_promo, 'Televisiva');
        
        exception when others then dbms_output.put_line('Errore nell''inserimento della tipologia promozione.'||sqlerrm);
                                raise eccezione;
                                        
        end;
        
        commit;
        dbms_output.put_line('Procedura terminata con successo');
exception when eccezione then rollback;
                              dbms_output.put_line('Procedura Terminata con errori');     
        
End;
/


CREATE OR REPLACE procedure nuovo_contratto (  p_id_artista          in varchar
                                             , p_data_inizio         in date
                                             , p_stipendio_artista   in number
                                             , p_durata              in date
                                             , p_stipendio_manager   in number
                                             ) 
                   
is
v_manager     contratto.manager%type;
ex            exception; 
  
/*
  PROCEDURA NUMERO 1 :

  Quando l'admin inserisce un nuovo contratto (1° tabella coinvolta) gli associa ad un'artista (2° tabella coinvolta)
  il manager (3° tabella coinvolta) più giovane che attualmente ha meno contratti.
*/  

begin
  
  --Calcolo manager piu' giovane
  begin
      select cf_manager 
        into v_manager
        from manager
        where data_nascita =(select  max(data_nascita) data
                               from (select manager 
                                          ,(select data_nascita from manager m1 where m1.CF_MANAGER=c.manager) data_nascita
                                          , count(manager) 
                                            from contratto c, manager m1
                                            where m1.cf_manager=c.manager
                                            group by c.manager
                                            having count(manager) = (select min(cont)
                                                                     from (select manager , count(manager) cont
                                                                     from contratto 
                                                                     group by manager))
                              ) );  
      
      exception when others then dbms_output.put_line('Errore nella selezione del manager piu'' giovane');
                                 raise ex;
  end;

  --Inserimento del nuovo contratto.  
  begin
     insert into contratto (inizio_contratto, stipendio_artista, durata_contratto, artista, manager, stipendio_manager) 
     values (p_data_inizio,p_stipendio_artista,p_durata,p_id_artista,v_manager,p_stipendio_manager);
     
     exception when others then dbms_output.put_line('Errore nell''inserimento del contratto.'||sqlerrm);
                                raise ex;
  end;
  
    commit;
    dbms_output.put_line('Ok. Procedura terminata con successo.');
    
exception when ex then rollback;
                        dbms_output.put_line('Procedura terminata con errori.');
                      
end;
/


CREATE OR REPLACE procedure                   promo_concerto
                                           (p_nome           in concerti.nome_concerto%type,
                                            p_data           in concerti.data_concerto%type,
                                            p_datapromo      in promozione.inizio_promozione%type,
                                            p_datapromo_new  in promozione.inizio_promozione%type,
                                            p_tipo_new       in tipologia_promozione.tipo_promozione%type,
                                            p_struttura_new  in strutture.nome_struttura%type,
                                            p_durata         in promozione.durata%type,
                                            p_id_promozione  in promozione.id_promozione%type
                                           )                                           
                                           
is

ex            exception;
v_id_concerto number;
v_id_promo    number;
v_struttura   number;
/*
  PROCEDURA NUMERO 4 :
  
  Dato un concerto, si vuole cancellare la vecchia promozione (1° tabella coinvolta) 
  e la sua tipologia (2° tabella coinvolta) e inserirne delle nuove aggiornando anche la struttura del concerto (3° tabella coinvolta).

*/

Begin
    

    Begin
     
     select id_struttura into v_struttura
     from strutture
     where nome_struttura = p_struttura_new;
     
     exception when others then dbms_output.put_line('Errore nella selezione dell''id struttura.'||sqlerrm);
                                  raise ex;    
    
    end;

    Begin --Aggiornamento della struttura del concerto.
    
      update concerti
      set id_struttura = v_struttura
      where nome_concerto = p_nome and data_concerto = p_data;
      
      exception when others then dbms_output.put_line('Errore nell''aggiornamento della struttura.'||sqlerrm);
                                  raise ex;
                                    
    end;


    Begin --Cancellazione della vecchia tipologia promozione.
        
      delete tipologia_promozione
      where id_promozione=p_id_promozione;
                                                      
      exception when others then dbms_output.put_line('Errore nella cancellazione della tipologia promozione.'||sqlerrm);
                                raise ex;  
         
    end;


    Begin --Cancellazione della vecchia promozione.           
            
       delete promozione
       where id_promozione=p_id_promozione;
            
       exception when others then dbms_output.put_line('Errore nella cancellazione della promozione.'||sqlerrm);
                                raise ex;
                                
    end;
    -- recupero id del concerto selezionandolo per nome e data
    Begin
        select id_concerto
          into v_id_concerto
          from concerti
          where nome_concerto=p_nome
            and data_concerto=p_data;
          exception when others then dbms_output.put_line('Errore recupero id concerto.'||sqlerrm);
                                  raise ex;
                                    
    End;
      
    Begin --Inserimento della nuova promozione.
    
      insert into promozione (id_concerto, inizio_promozione, durata)
      values (v_id_concerto,p_datapromo_new, p_durata); 
    
      exception when others then dbms_output.put_line('Errore nell''inserimento della nuova promozione.'||sqlerrm);
                                  raise ex;
                                  
    end;
        Begin
           select max(id_promozione) into v_id_promo from promozione;
            exception when others then dbms_output.put_line('Errore recupero id  promozione.'||sqlerrm);
                                raise ex;
        end;    
    
    Begin --Inserimento della nuova tipologia promozione.

      insert into tipologia_promozione (id_promozione, tipo_promozione )
      values (v_id_promo, p_tipo_new);
    
      exception when others then dbms_output.put_line('Errore nell''inserimento della nuova tipologia promozione.'||sqlerrm);
                                raise ex;    
    end;
    
         
    commit;  
    dbms_output.put_line('Elaborazione terminata.'); 

exception when ex then rollback;
dbms_output.put_line('Elaborazione terminata con errori.');

end;
/


CREATE OR REPLACE procedure                   tot_spese (p_anno in varchar)

is

stip_art     number;
stip_man     number;
costo_video  number;
tar_studio   number;
totale       number;
ex_2         exception;

/*  
  PROCEDURA NUMERO 2 :
  
  Calcolo totale delle spese d'uscita dell'etichetta : 
  stipendio manager e stipendio artista  (1° tabella coinvolta = CONTRATTO)
  tariffa studio registrazione           (2° tabella coinvolta = STUDIO)
  costo videoclip                        (3° tabella coinvolta = VIDEOCLIP).
  
  Operazione effettuata dall'admin (casa_discografica) e dall'utente (contabile).
  Seguono le credenziali di accesso. 
  
  1)
    ID       : casa_discografica
    Password : musica
    
  2)
    ID       : contabile
    Password : password1
*/

begin
 
      --Selezione dello stipendio dell'artista e del manager.
      begin 
      
        select nvl(sum(stipendio_artista),0), nvl(sum(stipendio_manager),0)
        into stip_art, stip_man
        from contratto
        where to_char(inizio_contratto, 'YYYY') <= p_anno and to_char(durata_contratto, 'YYYY') >= p_anno;
    
        exception when others then stip_art := 0; stip_man := 0;
     
     end;
     
      --Selezione del costo del video.
      begin
     
       select nvl(sum(costo),0) 
       into costo_video
       from videoclip join ha
       on id_video = videoclip
       where to_char (uscita_video, 'YYYY') = p_anno;
     
       exception when others then costo_video := 0;
        
      end;
     
      --Selezione della tariffa dello studio di registrazione.
      begin
     
       select nvl(sum(tariffa),0)
       into tar_studio
       from studio join registrata
       on nome_studio = studio
       where to_char (data_registrazione, 'YYYY') = p_anno;
     
       exception when others then tar_studio := 0;
        
      end;
     
     
      totale := (stip_art*12) + (stip_man*12) + costo_video + tar_studio;
     
      dbms_output.put_line('Ok. Procedura terminata con successo.' || chr(13) || 'Il totale e'' ' || totale);
     
      /*Inserimento all'interno della tabella "tot_spese_log" che indica 
       la data in cui è stata effettuata, l'utente che ha effettuato la procedura, il totale e l'anno inserito.*/
      begin
     
       insert into tot_spese_log (Data, Utente, Totale, Anno) 
       values (sysdate, user, totale, p_anno);
     
       exception when others then dbms_output.put_line('Errore nell''inserimento del totale.'||sqlerrm);
                                raise ex_2;
                                
      end;
    
     commit; 
     
exception when ex_2 then rollback;        

end;
/
