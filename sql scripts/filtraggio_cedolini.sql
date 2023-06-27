-- filtraggio cedolini
CREATE TABLE "CEDOLINI" ( "CODICE_FISCALE" CHAR (16),"COGNOME" VARCHAR (30),"NOME" VARCHAR (30),"MESE" INTEGER (2),"ANNO" INTEGER (4),"LIVELLO" INTEGER (1),"STIPENDIO_MENSILE" FLOAT ,"COMPETENZE" FLOAT ,"STIPENDIO_NETTO" FLOAT ); 
delete from Cedolini C where C.codice_fiscale = 'FRNLDA70A29L400A' and C.anno >= 2006;
delete from Cedolini C where C.codice_fiscale = 'FRNLDA70A29L400A' and C.livello = 3;
delete from Cedolini C where C.codice_fiscale = 'CGLLGU00M21Z318E' and ((C.anno = 2019 and C.mese > 9) or (C.anno > 2019));
delete from Cedolini C
where C.stipendio_mensile in
(select TMP.stipendio_mensile
from (select
	 C.codice_fiscale,
	 C.cognome,
	 C.nome,
	 C.mese,
	 C.anno,
	 C.livello,
	 min(stipendio_mensile) as  "stipendio_mensile",
	 min(competenze) as  "competenze",
	 min(stipendio_netto) as  "stipendio_netto"
from
	 Cedolini  C
where
	 C.codice_fiscale= 'CGLLGU00M21Z318E'
group by
	 C.codice_fiscale,
	 C.cognome,
	 C.nome,
	 C.mese,
	 C.anno,
	 C.livello) TMP)
and C.stipendio_netto in 
(select TMP.stipendio_netto
from (select
	 C.codice_fiscale,
	 C.cognome,
	 C.nome,
	 C.mese,
	 C.anno,
	 C.livello,
	 min(stipendio_mensile) as  "stipendio_mensile",
	 min(competenze) as  "competenze",
	 min(stipendio_netto) as  "stipendio_netto"
from
	 Cedolini  C
where
	 C.codice_fiscale= 'CGLLGU00M21Z318E'
GROUP by
	 C.codice_fiscale,
	 C.cognome,
	 C.nome,
	 C.mese,
	 C.anno,
	 C.livello) TMP);
delete from Cedolini C where C.codice_fiscale = 'BNFPLA81H20L400C' and (C.anno > 2010 or (C.anno = 2010 and C.mese > 7));
delete from Cedolini C where C.codice_fiscale= 'BNFPLA81H20L400C' and (C.livello = 1 or C.livello = 2);
CREATE TABLE "TEMP" ( "CODICE_FISCALE" CHAR (16),"COGNOME" VARCHAR (30),"NOME" VARCHAR (30),"MESE" INTEGER (2),"ANNO" INTEGER (4),"LIVELLO" INTEGER (1),"STIPENDIO_MENSILE" FLOAT ,"COMPETENZE" FLOAT ,"STIPENDIO_NETTO" FLOAT ); 
insert into temp
select
	 C.codice_fiscale,
	 C.cognome,
	 C.nome,
	 C.mese,
	 C.anno,
	 C.livello,
	 min(C.stipendio_netto) as  "Stipendio_Netto",
	 min(C.competenze) as  "Competenze",
	 min(C.stipendio_mensile) as  "Stipendio_Mensile"
from
	 Cedolini  C
where
	 C.codice_fiscale= 'VCRNLL58L21H129B'
GROUP by
	 C.codice_fiscale,
	 C.cognome,
	 C.nome,
	 C.mese,
	 C.anno,
	 C.livello;
delete from temp T where anno > 2011 or (anno = 2011 and mese > 2);
delete from temp where anno >= 2009 and livello = 4;
delete from Cedolini C where C.codice_fiscale = 'VCRNLL58L21H129B';
insert into Cedolini select * from Temp;
drop table temp;

select C.codice_fiscale, C.cognome, C.nome, C.mese, C.anno, min(C.livello) as "livello", max(C.stipendio_mensile) as "stipendio_mensile", max(C.competenze) as "competenze", max(C.stipendio_netto) as "stipendio_netto"
from cedolini C
group by C.codice_fiscale, C.cognome, C.nome, C.mese, C.anno
ORDER BY C.anno, C.mese;