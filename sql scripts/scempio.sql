-- stipendi annuali per dipendente (2017-2022)
create view stipendio_anno_17_22v as
select D.anno as "Anno", B.matricola as "Matricola", sum(B.stipendio_mensile) as "Stipendio"
from fact_busta_paga  as  B, dim_data as  D
where B.id_data = D.id_data and (datepart('YY', current_date) - D.anno) <= 6 and datepart('YY', current_date) > D.anno
group by D.anno, B.matricola;

--examples
select v1.matricola, v2.stipendio - v1.stipendio as delta, v1.anno, v2.anno
from stipendio_anno_17_22v as v1, stipendio_anno_17_22v as v2
where v1.matricola = v2.matricola and v1.anno = 2017 and v2.anno = 2018;

select v1.matricola, max(v2.stipendio - v1.stipendio) as max_aumento -- ci sono poveri cristi che non hanno aumenti ad 5 anni :(
from stipendio_anno_17_22v as v1, stipendio_anno_17_22v as v2
where v1.matricola = v2.matricola group by v1.matricola;

--stipendi annuali per dipendente (2005-2022)

create view stipendio_anno_v as
select D.anno as "Anno", B.matricola as "Matricola", sum(B.stipendio_mensile) as "Stipendio"
from fact_busta_paga  as  B, dim_data as  D
where B.id_data = D.id_data and datepart('YY', current_date) > D.anno
group by D.anno, B.matricola;

--delta stipendi anno per anno

create view  delta_stipendi as
select v1.anno as  Anno1, v2.anno as  Anno2, v2.stipendio - v1.stipendio as  delta, v1.matricola
from stipendio_anno_v  as  v1, stipendio_anno_v as  v2
where v1.matricola = v2.matricola;

delete from delta_stipendi where anno1 <> anno2 - 1;
