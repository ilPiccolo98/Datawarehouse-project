-- stipendi annuali per dipendente (2005-2022)

create view stipendio_anno_v as
select D.anno as "Anno", B.matricola as "Matricola", sum(B.stipendio_mensile) as "Stipendio"
from fact_busta_paga  as  B, dim_data as  D
where B.id_data = D.id_data and datepart('YY', current_date) > D.anno
group by D.anno, B.matricola;

-- delta stipendi annuali

create view delta_stipendi as
select v1.anno as  Anno1, v2.anno as  Anno2, v2.stipendio - v1.stipendio as  delta, v1.matricola
from stipendio_anno_v  as  v1, stipendio_anno_v as  v2
where v1.matricola = v2.matricola;

delete from delta_stipendi where anno1 <> anno2 - 1;

  -------------
  -- QUERIES
  -------------

  -- Top N stipendi (con info sull'impiegato)

  SELECT *
  FROM fact_busta_paga as B JOIN dim_anagrafica as D
  ON B.matricola = D.matricola
  ORDER BY B.stipendio_mensile DESC

  ------------------------------------------------------------------------------

  CREATE VIEW stipendi_con_media_livello AS
  SELECT B.stipendio_mensile, B.id_data, B.matricola, V.id_livello, V.stipendio_mensile as stipendio_medio
  FROM fact_busta_paga as B JOIN V6 as V
  ON B.id_livello = V.id_livello

  -- stipendi molto più alti (1k) rispetto alla media con pari livello
  SELECT * FROM stipendi_con_media_livello S JOIN dim_anagrafica as D ON D.matricola = S.matricola
  WHERE S.stipendio_mensile - S.stipendio_medio > 1000

  -- stipendi molto più bassi (1k) rispetto alla media con pari livello
  SELECT * FROM stipendi_con_media_livello S JOIN dim_anagrafica as D ON D.matricola = S.matricola
  WHERE S.stipendio_medio - S.stipendio_mensile > 1000

  ------------------------------------------------------------------------------

  
