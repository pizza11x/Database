
CREATE OR REPLACE TRIGGER TRIG_ALB
before insert or update on canzone
for each row
declare

cont_1            number (2,0);
troppe_canzoni    exception;

/*
  TRIGGER NUMERO 2 :
  
  Non è possibile inserire più di 10 canzoni in uno stesso album.

*/

begin

   select count(*) --Conteggio canzoni nell'album.
     into cont_1
     from canzone
     where album =:new.album;
   
   
   if cont_1 >= 10 then
   
        raise troppe_canzoni;
        
    end if;

exception

when troppe_canzoni then
raise_application_error (-20008, 'Non puoi inserire più di 10 canzoni in un album.');

end;
/


CREATE OR REPLACE TRIGGER trig_citta
before insert on citta
for each row
declare
	
	progressivo       number:=0;
/*
  TRIGGER NUMERO 13 : 

   CALCOLO PROGRESSIVO CITTA

*/


begin
    begin
        select nvl(max(id_citta),0)+1
          into :new.id_citta
          from citta;   
    end;
     
end;
/


CREATE OR REPLACE trigger TRIG_CONT
before insert or update on CONTRATTO
for each row

/*
  TRIGGER NUMERO 1 : 
  
  Un contratto non può avere una data di inizio diversa da quella odierna.
  Il trigger scatterà quando si inserirà una data diversa da quella odierna e automaticamente l'aggiornerà ad essa.
*/

begin

   if trunc (:new.inizio_contratto) < trunc(sysdate) then
        :new.inizio_contratto := trunc(sysdate);
       
      dbms_output.put_line('Il contratto ha una data infiore a quella odierna. Pertanto al campo inizio contratto è stata sostituita la data odierna');
   end if;

end;
/


CREATE OR REPLACE TRIGGER TRIG_CONTR
before insert ON CONTRATTO
for each row
declare
	progressivo       number:=0;
/*
  TRIGGER NUMERO 11 : 

   CALCOLO PROGRESSIVO CONTRATTI

*/


begin
    Begin
        select nvl(max(id_contratto),0)+1
          into :new.id_contratto
          from contratto;   
    end;
     
end;
/


CREATE OR REPLACE TRIGGER trig_dis
before insert or update on distribuito
for each row
declare

tipo_cd            formato.formato%type;
tipo_dis           tipo_distributore.tipo_distributore%type;
cont_tp            number;
cont_fis           number;
cont_dig           number;
cont2 number;

incompatibili_1    exception;
incompatibili_2    exception;


begin
    select count(formato) into cont2
     from formato
     where album = :new.album;

     select count(tipo_distributore) into cont_tp
     from tipo_distributore
     where nome_societa = :new.distributore;


     if (cont_tp < 2) then 
     select tipo_distributore into tipo_dis
     from tipo_distributore
     where nome_societa = :new.distributore;

      if(cont2>1)then
      select count(formato) into cont_dig
      from formato
      where album = :new.album and formato = 'Digitale';

      select count(formato) into cont_fis
      from formato
      where album = :new.album and formato != 'Digitale';

      if(cont_dig > 0 and cont_fis<1 and tipo_dis = 'Fisico')then
        raise incompatibili_1;
      end if;

      if(cont_fis >0 and cont_dig<1 and tipo_dis = 'Digitale') then
        raise incompatibili_2;
        end if;
    end if;
    if(cont2=1)then
    select formato into tipo_cd
    from formato
    where album = :new.album;
    if (tipo_cd = 'Digitale' and tipo_dis = 'Fisico') then
          raise incompatibili_1;
    end if;

    if (tipo_cd != 'Digitale' and tipo_dis = 'Digitale') then
        raise incompatibili_2;
        end if;
        end if;

end if;
exception

when incompatibili_1 then
raise_application_error (-20011, 'Un album digitale non può essere distribuito da un tipo distributore fisico.');

when incompatibili_2 then
raise_application_error (-20012, 'Un album fisico non può essere distribuito da un tipo distributore digitale.');


end;
/


CREATE OR REPLACE TRIGGER TRIG_INDIRIZZI
before insert ON indirizzi_studio
for each row
declare
	
	progressivo       number:=0;
/*
  TRIGGER NUMERO 13 : 

   CALCOLO PROGRESSIVO INDIRIZZI STUDIO

*/


begin
    begin
        select nvl(max(id_indirizzo),0)+1
          into :new.id_indirizzo
          from indirizzi_studio;   
    end;
     
end;
/


CREATE OR REPLACE TRIGGER trig_manager
before insert or update on contratto
for each row
declare

man_anz         manager.data_nascita%type;     
man_gio         manager.data_nascita%type;
man_ins         manager.data_nascita%type;

/*
  TRIGGER NUMERO 3 :
  
  Quando è immesso un nuovo contratto, si aggiorni il valore dello stipendio del manager 
  aggiornandolo del 10% se egli è il manager più giovane o quello più anziano.
*/

begin

      select max(data_nascita), min(data_nascita) 
        into man_gio, man_anz
        from manager
      ;
      
      dbms_output.put_line('Data manager piu'' giovane : '||man_gio);      
      dbms_output.put_line('Data manager piu'' vecchio : '||man_anz);

      Begin      
          
          select data_nascita
              into man_ins
              from manager
              where cf_manager = :new.manager;
              
          exception when others then 
                                    dbms_output.put_line('Errore nella selezione della data di nascita.'||sqlerrm);
                                    
      End;

      
      if (man_ins = man_anz or man_ins = man_gio) then

        :new.stipendio_manager := :new.stipendio_manager * 1.1; --Aumento dello stipendio del 10%.
                   
      end if;       

end;
/


CREATE OR REPLACE TRIGGER TRIG_PREM
before insert on riceve
for each row
declare

disco         number; 
platino       number;

ex_prem       exception;
ex_plat       exception;

/*
  TRIGGER NUMERO 6 :
  
  Non si può inserire un disco di platino se prima non ha ottenuto un disco d'oro nello stesso paese.
  Inoltre non si può inserire un premio Fimi se prima l'artista non ha ottenuto un disco di platino nello stesso paese.
  
*/

begin

    if (:new.premio = 'Disco platino') then
    
          select count(premio) into disco
          from riceve
          where canzone = :new.canzone and premio = 'Disco oro' and paese = :new.paese;   
    
          
    
     if (disco != 1) then
    
        raise ex_prem;
    
     end if;
     end if;
       
       if (:new.premio = 'Fimi') then 
       
            select count(premio) into platino
               from riceve
               where canzone = :new.canzone and premio = 'Disco platino' and paese = :new.paese; 
               
       
           if (platino != 1) then
           
               raise ex_plat;
         
           end if;
           
      end if;
    

exception

when ex_prem then
raise_application_error (-20004, 'Non puoi inserire un disco di platino se prima l''artista non ha ottenuto un disco d''oro nello stesso paese.');

when ex_plat then
raise_application_error (-20005, 'Non puoi inserire un premio Fimi se prima l''artista non ha ottenuto un disco di platino nello stesso paese.');

end;
/


CREATE OR REPLACE TRIGGER TRIG_PROM
before insert ON PROMOZIONE
for each row
declare
	progressivo       number:=0;
/*
  TRIGGER NUMERO 10 : 

   CALCOLO PROGRESSIVO PROMOZIONI

*/


begin
    Begin
        select nvl(max(id_promozione),0)+1
          into :new.id_promozione
          from PROMOZIONE;   
    end;
     
end;
/


CREATE OR REPLACE TRIGGER TRIG_REC
before insert or update on registrata
for each row
declare

data_sc       scritta.data_scrittura%type;
data_cd       album.data_uscita%type;


data_errata   exception;
wrong_rec     exception;

/* 
  TRIGGER NUMERO 7 :
  
  Una canzone non può essere registrata se prima non è stata scritta.
  Inoltre la canzone dell'artista non può essere registrata dopo l'uscita dell'album.
  
*/

begin

    select data_scrittura into data_sc
    from scritta
    where canzone = :new.canzone;
    
    
    select data_uscita into data_cd
    from album join canzone
    on id_album = album
    where id_canzone = :new.canzone;
    
    
    if (:new.data_registrazione < data_sc) then
        
        raise data_errata;
        
    end if;  
    
    
    if (:new.data_registrazione > data_cd) then
    
        raise wrong_rec;
        
    end if;
    

exception

when data_errata then
raise_application_error (-20009, 'L''artista non può registrare una canzone prima di essere scritta.');

when wrong_rec then
raise_application_error (-20010, 'La canzone dell''artista non può essere registrata dopo l''uscita dell''album.');


end;
/


CREATE OR REPLACE TRIGGER TRIG_SHOW
BEFORE INSERT
ON CONCERTI
REFERENCING NEW AS NEW OLD AS OLD
FOR EACH ROW
declare

data_conc         number;
date_uguali       exception; 
progressivo       number:=0;
/*
  TRIGGER NUMERO 4 : 

  Un artista non può partecipare a più di un concerto in una stessa data. 
*/
Begin
        Begin
            select nvl(max(id_concerto),0)+1
              into :new.id_concerto
              from concerti;   
        end;

    begin

        select count(data_concerto) into data_conc --Conteggio date del concerto.
          from concerti 
          where data_concerto = :new.data_concerto and artista = :new.artista;
    
          if (data_conc > 0)
                  then raise date_uguali;
          end if;

    exception when date_uguali 
              then raise_application_error (-20011, 'Un artista non può svolgere due concerti in uno stesso giorno.');
    

    end;
end;
/


CREATE OR REPLACE TRIGGER trig_struttura
before insert on strutture
for each row
declare
	
	progressivo       number:=0;
/*
  TRIGGER NUMERO 14 : 

   CALCOLO PROGRESSVO STRUTTURE

*/


begin
    begin
        select nvl(max(id_struttura),0)+1
          into :new.id_struttura
          from strutture;   
    end;
     
end;
/


CREATE OR REPLACE TRIGGER TRIG_TIPOPROM
before insert ON TIPOLOGIA_PROMOZIONE
for each row
declare
	progressivo       number:=0;
/*
  TRIGGER NUMERO 11 : 

   CALCOLO PROGRESSIVO TIPOLOGIA PROMOZIONI

*/


begin
    begin
        select nvl(max(id_tipo_promozione),0)+1
          into :new.id_tipo_promozione
          from tipologia_promozione;   
    end;
     
end;
/


CREATE OR REPLACE TRIGGER TRIG_VEN
before insert on album
for each row
declare


ex_trig      exception;
ex_trig2     exception;


/*
  TRIGGER NUMERO 5 :
  
  Un album puo' uscire solo di venerdi' e non prima di oggi.

*/


begin


   
   if ( to_char(:new.data_uscita, 'D') !=  5) then --Controlla se la data di uscita del nuovo album è di venerdì.
      
       raise ex_trig;
       
   end if;
   
   if (:new.data_uscita <  sysdate) then 
      
      raise ex_trig2;
      
   end if;
   

exception

when ex_trig then
raise_application_error (-20015, 'L''album può uscire solo di venerdì.');

when ex_trig2 then
raise_application_error (-20016, 'L''album non può uscire prima di oggi.');


end;
/


CREATE OR REPLACE TRIGGER TRIG_VID
before insert or update on videoclip
for each row
declare

video     number;
lyric     exception;

/*
  TRIGGER NUMERO 9 :
  
  Il costo di un video lyric non deve superare 100 euro.
  
*/

begin
       
   if (:new.nome_video like '%(lyric)' and :new.costo > 100) then
   
      raise lyric;
      
   end if;


exception

when lyric then
raise_application_error (-20012, 'Il video di un lyric non può costare più di 100 euro.');


end;
/
