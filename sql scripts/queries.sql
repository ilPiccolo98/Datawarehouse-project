-- organico totale
select count(matricola) from dim_anagrafica;

-- organico per sedi
select F.sede as "Sede", count(*) as "Personale"
from dim_anagrafica as A, dim_filiale as F
where A.id_filiale = F.id_filiale
group by F.sede;

-- organico per dipartimento
select D.nome as "Dipartimento", count(*) as "Personale"
from dim_anagrafica as A, dim_dipartimento as D
where A.id_dipartimento = D.id_dipartimento
group by D.nome;

-- età media
select avg(datediff('YY', A.data_nascita, current_date)) as "Età media"
from dim_anagrafica as A;

-- assunti ultimo e penultimo anno
select *
from dim_anagrafica as A
where datepart('YY', A.data_assunzione) = (datepart('YY', current_date) - 1) or
      datepart('YY', A.data_assunzione) = (datepart('YY', current_date) - 2);

-- dimessi ultimo e penultimo anno
select *
from dim_anagrafica as A
where A.data_dimissione is not null and
      (datepart('YY', A.data_dimissione) = (datepart('YY', current_date) - 1) or
      datepart('YY', A.data_dimissione) = (datepart('YY', current_date) - 2));

-- STATISTICHE STIPENDI
-- somma stipendi ultimi 3 anni
select sum(B.stipendio_lordo) as "Somma Stipendi"
from fact_busta_paga as B, dim_data as D
where B.id_data = D.id_data and
      (datepart('YY', current_date) - D.anno) <= 2;

-- somma stipendi mensili negli ultimi 12 mesi
select sum(B.stipendio_lordo) as "Somma stipendi"
from fact_busta_paga as B, dim_data as D
where B.id_data = D.id_data and 
      ((datepart('YY', current_date) - D.anno = 0 or 
        datepart('YY', current_date) - D.anno = 1) and 
        D.mese >= datepart('MM', current_date));

--VISTE
-- stipendio medio per dipartimento aggregazione_per_dipartimento
insert into nome_dipartimento_aggregazione_per_dipartimento
select *
from dim_dipartimento;

insert into aggregazione_per_dipartimento
select D.id_dipartimento, avg(B.stipendio_lordo), avg(B.stipendio_netto), avg(B.competenze)
from  fact_busta_paga as B, dim_anagrafica as A, dim_dipartimento as D
where B.matricola = A.matricola and
      A.id_dipartimento = D.id_dipartimento
group by D.id_dipartimento;

-- stipendio medio per livello aggregazione_per_livello
insert into livello_aggregazione_per_livello
select *
from dim_livello;

insert into aggregazione_per_livello
select L.grado, avg(B.stipendio_lordo), avg(B.stipendio_netto), avg(B.competenze)
from  fact_busta_paga as B, livello_aggregazione_per_livello as L
where B.id_livello = L.id_livello
group by L.grado;

-- stipendio medio orario, calcolato su media ultimo anno solare AGGREGAZIONE_PER_STIPENDIO_MEDIO_ORARIO
insert into matricola_aggregazione_per_stipendio_medio_orario
select matricola
from dim_anagrafica;

insert into anno_aggregazione_per_stipendio_medio_orario
select distinct anno - (select min(anno) from dim_data), anno
from dim_data
where datepart('YY', current_date) <> anno;

insert into aggregazione_per_stipendio_medio_orario
select B.matricola, A.id_anno, (sum(B.stipendio_lordo) / (40 * 48)) as stipendio_lordo, (sum(B.stipendio_netto) / (40 * 48)) as stipendio_netto, sum(B.competenze) / (40 * 48) as competenze
from fact_busta_paga as B, dim_data as D, anno_aggregazione_per_stipendio_medio_orario as A
where B.id_data = D.id_data and A.anno = D.anno
group by B.matricola, A.id_anno;

select *
from aggregazione_per_stipendio_medio_orario V, anno_aggregazione_per_stipendio_medio_orario A
where V.id_anno = A.id_anno and V.matricola = $matricola and datepart('YY', current_date) - 1 = A.anno;

-- stipendio medio mensile, calcolato su media ultimo anno solare AGGREGAZIONE_PER_STIPENDIO_MEDIO_MENSILE
insert into matricola_aggregazione_per_stipendio_medio_mensile
select matricola
from dim_anagrafica;

insert into anno_aggregazione_per_stipendio_medio_mensile
select distinct anno - (select min(anno) from dim_data), anno
from dim_data
where datepart('YY', current_date) <> anno;

insert into aggregazione_per_stipendio_medio_mensile
select B.matricola, A.id_anno, avg(stipendio_lordo) as stipendio_lordo, avg(stipendio_netto) as stipendio_netto, avg(competenze) as competenze
from fact_busta_paga as B, dim_data as D, anno_aggregazione_per_stipendio_medio_mensile as A
where B.id_data = D.id_data and A.anno = D.anno
group by B.matricola, A.id_anno;

select *
from aggregazione_per_stipendio_medio_mensile V, anno_aggregazione_per_stipendio_medio_mensile A
where V.id_anno = A.id_anno and V.matricola = $matricola and datepart('YY', current_date) - 1 = A.anno;

-- stipendio annuale, calcolato su la somma dell'ultimo anno solare AGGREGAZIONE_PER_STIPENDIO_ANNUO
insert into matricola_aggregazione_per_stipendio_annuo
select matricola
from dim_anagrafica;

insert into anno_aggregazione_per_stipendio_annuo
select distinct anno - (select min(anno) from dim_data), anno
from dim_data
where datepart('YY', current_date) <> anno;

insert into aggregazione_per_stipendio_annuo
select B.matricola, A.id_anno, sum(stipendio_lordo) as stipendio_lordo, sum(stipendio_netto) as stipendio_netto, sum(competenze) as competenze
from fact_busta_paga as B, dim_data as D, anno_aggregazione_per_stipendio_annuo as A
where B.id_data = D.id_data and A.anno = D.anno
group by B.matricola, A.id_anno;

select *
from aggregazione_per_stipendio_annuo V, anno_aggregazione_per_stipendio_annuo A
where V.id_anno = A.id_anno and V.matricola = $matricola and datepart('YY', current_date) - 1 = A.anno;



-- stipendi annuali per dipendente (2017-2022)
create view stipendio_anno_17_22v as
select D.anno as "Anno", B.matricola as "Matricola", sum(B.stipendio_lordo) as "Stipendio"
from fact_busta_paga  as  B, dim_data as  D
where B.id_data = D.id_data and (datepart('YY', current_date) - D.anno) <= 6 and datepart('YY', current_date) > D.anno
group by D.anno, B.matricola;

--examples
select v1.matricola, v2.stipendio - v1.stipendio as delta, v1.anno, v2.anno
from stipendio_anno_17_22v as v1, stipendio_anno_17_22v as v2
where v1.matricola = v2.matricola and v1.anno = 2017 and v2.anno = 2018;

select v1.matricola, max(v2.stipendio - v1.stipendio) as max_aumento 
from stipendio_anno_17_22v as v1, stipendio_anno_17_22v as v2
where v1.matricola = v2.matricola group by v1.matricola;

--stipendi annuali per dipendente (2005-2022)
create view stipendio_anno_v as
select D.anno as "Anno", B.matricola as "Matricola", sum(B.stipendio_lordo) as "Stipendio"
from fact_busta_paga  as  B, dim_data as  D
where B.id_data = D.id_data and datepart('YY', current_date) > D.anno
group by D.anno, B.matricola;

--delta stipendi anno per anno
create view  delta_stipendi as
select v1.anno as  Anno1, v2.anno as  Anno2, v2.stipendio - v1.stipendio as  delta, v1.matricola
from stipendio_anno_v  as  v1, stipendio_anno_v as  v2
where v1.matricola = v2.matricola;

delete from delta_stipendi where anno1 <> anno2 - 1;

-- stipendi annuali per dipendente (2005-2022)
create view stipendio_anno_v as
select D.anno as "Anno", B.matricola as "Matricola", sum(B.stipendio_lordo) as "Stipendio"
from fact_busta_paga  as  B, dim_data as  D
where B.id_data = D.id_data and datepart('YY', current_date) > D.anno
group by D.anno, B.matricola;

-- delta stipendi annuali
create view delta_stipendi as
select v1.anno as  Anno1, v2.anno as  Anno2, v2.stipendio - v1.stipendio as  delta, v1.matricola
from stipendio_anno_v  as  v1, stipendio_anno_v as  v2
where v1.matricola = v2.matricola;

delete from delta_stipendi where anno1 <> anno2 - 1;

-- Top N stipendi (con info sull'impiegato)
SELECT *
FROM fact_busta_paga as B JOIN dim_anagrafica as D
ON B.matricola = D.matricola
ORDER BY B.stipendio_lordo DESC


-- stipendi molto più alti (1k) rispetto alla media con pari livello
CREATE VIEW stipendi_con_media_livello AS
SELECT B.stipendio_lordo, B.id_data, B.matricola, V.id_livello, V.stipendio_lordo as stipendio_medio
FROM fact_busta_paga as B JOIN aggregazione_per_livello as V
ON B.id_livello = V.id_livello

SELECT * FROM stipendi_con_media_livello S JOIN dim_anagrafica as D ON D.matricola = S.matricola
WHERE S.stipendio_lordo - S.stipendio_medio > 1000

-- stipendi molto più bassi (1k) rispetto alla media con pari livello
SELECT * FROM stipendi_con_media_livello S JOIN dim_anagrafica as D ON D.matricola = S.matricola
WHERE S.stipendio_medio - S.stipendio_lordo > 1000

-- TOP N STIPENDI CHE NON RICEVONO AUMENTI
select *
from (select V.matricola, max((TMP.anno - A.anno)) as "Differenza_anni"
      from aggregazione_per_stipendio_annuo as V, anno_aggregazione_per_stipendio_annuo as A, (select *
                  from aggregazione_per_stipendio_annuo as V, anno_aggregazione_per_stipendio_annuo as A
                  where V.id_anno = A.id_anno and A.anno = (select max(anno)
                                                            from anno_aggregazione_per_stipendio_annuo )) as  TMP
      where V.matricola = TMP.matricola and A.id_anno = V.id_anno and (TMP.stipendio_lordo - V.stipendio_lordo) = 0
      group by V.matricola) as Differenze
order by Differenze.Differenza_anni desc