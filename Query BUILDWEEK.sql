-- Modifichiamo il nome della colonna ImportoTotaleTransazione della tabella transazioni_dataset, essendo la stessa ambigua per quanto riguarda l'importo totale di ogni transazione se visualizziamo il prezzo e la quantità di ogni prodotto. La rinominiamo in ImportoSpedizione
ALTER TABLE transazioni_dataset RENAME COLUMN ImportoTotaleTransazione TO ImportoSpedizione;

-- DOMANDA NUMERO 1: Trova il totale delle vendite per ogni mese.
SELECT MONTH(DataTransazione) AS Mese, ROUND(sum(prodotti_dataset.Prezzo*transazioni_dataset.QuantitaAcquistata),2) AS TOTTransazioni
FROM transazioni_dataset
JOIN prodotti_dataset ON prodotti_dataset.ProdottoID=transazioni_dataset.ProdottoID
GROUP BY Mese
ORDER BY Mese;


-- DOMANDA NUMERO 2
SELECT ProdottoID, SUM(QuantitaAcquistata) AS QuantitaVenduta
FROM transazioni_dataset
GROUP BY ProdottoID
ORDER BY QuantitaVenduta DESC
LIMIT 3;


-- DOMANDA NUMERO 3
SELECT ClienteID, COUNT(IDTransazione) AS Conteggio_transazioni
FROM transazioni_dataset
GROUP BY ClienteID
ORDER BY Conteggio_transazioni DESC, ClienteID
LIMIT 2;


-- DOMANDA NUMERO 4
SELECT AVG(prodotti_dataset.Prezzo*transazioni_dataset.QuantitaAcquistata+ImportoSpedizione) AS Media
FROM transazioni_dataset
JOIN prodotti_dataset ON prodotti_dataset.ProdottoID=transazioni_dataset.ProdottoID;


-- DOMANDA NUMERO 5
SELECT Categoria, SUM(QuantitaAcquistata) AS UnitàVendute
FROM prodotti_dataset
JOIN transazioni_dataset ON prodotti_dataset.ProdottoID=transazioni_dataset.ProdottoID
GROUP BY Categoria
ORDER BY UnitàVendute DESC
LIMIT 1;


-- DOMANDA NUMERO 6
SELECT transazioni_dataset.ClienteID, Clienti_dataset.NomeCliente, SUM(prodotti_dataset.Prezzo*transazioni_dataset.QuantitaAcquistata+transazioni_dataset.ImportoSpedizione) AS TOTAcquisti
FROM transazioni_dataset
JOIN prodotti_dataset ON transazioni_dataset.ProdottoID=prodotti_dataset.ProdottoID
JOIN Clienti_dataset ON transazioni_dataset.ClienteID = Clienti_dataset.ClienteID
GROUP BY transazioni_dataset.ClienteID, NomeCliente
ORDER BY TOTAcquisti DESC
LIMIT 1;


-- DOMANDA NUMERO 7 METODO CON FUNZIONE WITH
with cte1 as(
SELECT COUNT(StatusConsegna) AS ConsegneRiuscite
FROM transazioni_dataset
WHERE StatusConsegna="Consegna Riuscita"),
cte2 as(
SELECT COUNT(StatusConsegna) AS TOTConsegne
FROM transazioni_dataset),
cte3 as(
SELECT ConsegneRiuscite*100/TOTConsegne FROM cte1,cte2)
SELECT * FROM cte3;

-- DOMANDA NUMERO 7 METODO SENZA FUNZIONE WITH
SELECT ((SELECT COUNT(StatusConsegna)
FROM transazioni_dataset
WHERE StatusConsegna="Consegna Riuscita")*100/(SELECT COUNT(StatusConsegna)
FROM transazioni_dataset)) AS PercentualeConsegnaRiuscita;


-- DOMANDA NUMERO 8
-- Per trovare i prodotti ordinati in ordine decrescente in base alla Recensione Media:
SELECT ProdottoID,NomeProdotto,AVG(Rating) AS RecensioneMedia
FROM prodotti_dataset
JOIN ratings_dataset ON ProductID=ProdottoID
GROUP BY ProdottoID,Nomeprodotto
ORDER BY RecensioneMedia DESC,ProdottoID;

-- Per trovare i prodotti con la media della recensione uguale a 5:
SELECT ProdottoID,NomeProdotto,AVG(Rating) AS RecensioneMedia
FROM prodotti_dataset
JOIN ratings_dataset ON ProductID=ProdottoID
GROUP BY ProdottoID,Nomeprodotto
HAVING RecensioneMedia=5
ORDER BY ProdottoID;


-- DOMANDA NUMERO 9 METODO CON FUNZIONE WITH
with trans_grouped as (
	select sum(p.Prezzo*t.QuantitaAcquistata) importo
        , year(t.DataTransazione) anno
        , month(t.DataTransazione) mese
		from transazioni_dataset t
        JOIN prodotti_dataset p ON p.ProdottoID=t.ProdottoID
		group by year(t.DataTransazione), month(t.DataTransazione)
), 
analisi as (
select 
    anno,
    mese, 
    importo,
	(select importo 
		from trans_grouped g 
        where g.mese = t.mese -1
	) mese_precedente,
    convert(importo*100 / (select importo 
		from trans_grouped g 
        where g.mese = t.mese -1
	), decimal(10,2)) percentuale
from trans_grouped t 
order by anno, mese
)
select anno, mese, round(importo,2) AS importo, round(mese_precedente,2) AS mese_precedente, percentuale, 
case when percentuale is null then 'ND' when percentuale >= 100 then 'Positivo' else 'Negativo' end andamento 
from analisi;


-- DOMANDA NUMERO 10
SELECT Categoria, AVG(QuantitaDisponibile) AS MediaDisponibile
FROM prodotti_dataset
GROUP BY Categoria
ORDER BY Categoria;


-- DOMANDA NUMERO 11
SELECT MetodoSpedizione,COUNT(MetodoSpedizione) AS Conteggio
FROM spedizioni_dataset
GROUP BY MetodoSpedizione
ORDER BY Conteggio DESC;
-- Nella tabella spedizioni_dataset il metodo di spedizione più utilizzato è Posta Prioritaria

SELECT MetodoSpedizione,COUNT(MetodoSpedizione) AS Conteggio
FROM transazioni_dataset
GROUP BY MetodoSpedizione
ORDER BY Conteggio DESC;
-- Nella tabella transazioni_dataset il metodo di spedizione più utilizzato è Corriere Express


-- DOMANDA NUMERO 12
-- Per selezionare l'anno 2022:
SELECT year(DataRegistrazione) AS Anno, count(ClienteID)/12 AS Media
FROM clienti_dataset
WHERE year(DataRegistrazione)="2022"
GROUP BY Anno;

-- Per selezionare l'anno 2023:
SELECT year(DataRegistrazione) AS Anno, count(ClienteID) AS Media
FROM clienti_dataset
WHERE year(DataRegistrazione)="2023"
GROUP BY Anno;


-- DOMANDA NUMERO 13
SELECT AVG(QuantitaDisponibile)
FROM prodotti_dataset;
-- La media della quantità disponibile è pari a 50.6130

-- Selezionare tutti i prodotti che hanno una quantità disponibile inferiore a 50.6130
SELECT NomeProdotto, QuantitaDisponibile
FROM prodotti_dataset
WHERE (SELECT AVG(QuantitaDisponibile) FROM prodotti_dataset)>QuantitaDisponibile
ORDER BY QuantitaDisponibile;


-- DOMANDA NUMERO 14: Per ogni cliente, elenca i prodotti acquistati e il totale speso.
SELECT ClienteID, p.NomeProdotto, round(SUM(p.Prezzo*t.QuantitaAcquistata),2) AS TotaleSpeso
FROM transazioni_dataset as t
JOIN prodotti_dataset as p ON t.ProdottoID=p.ProdottoID
GROUP BY ClienteID, NomeProdotto
ORDER BY ClienteID;



-- DOMANDA NUMERO 15: Identifica il mese con il maggior importo totale delle vendite.
SELECT MONTHNAME(DataTransazione) AS Mese, ROUND(sum(P.Prezzo*t.QuantitaAcquistata),2) AS TOTVendite
FROM transazioni_dataset t
JOIN prodotti_dataset p ON t.ProdottoID=p.ProdottoID
GROUP BY Mese
ORDER BY TOTVendite DESC
LIMIT 1;


-- DOMANDA NUMERO 16: Trova la quantità totale di prodotti disponibili in magazzino.
SELECT SUM(QuantitaDisponibile) as TOTProdotti FROM prodotti_dataset;


-- DOMANDA NUMERO 17: Identifica i clienti che non hanno effettuato alcun acquisto.
SELECT ClienteID 
FROM clienti_dataset
WHERE ClienteID NOT IN (SELECT ClienteID FROM transazioni_dataset);


-- DOMANDA NUMERO 18: Calcola il totale delle vendite per ogni anno.
SELECT YEAR(DataTransazione) AS Anno, ROUND(sum(p.Prezzo*t.QuantitaAcquistata),2) AS TOTTransazioni
FROM transazioni_dataset t
JOIN prodotti_dataset p ON t.ProdottoID=p.ProdottoID
GROUP BY Anno;

-- DOMANDA NUMERO 19: Trova la percentuale di spedizioni con "In Consegna" rispetto al totale (CON FUNZIONE WITH)
with new_cte as (
select count(StatusConsegna) as InConsegna
from transazioni_dataset
where StatusConsegna = 'In Consegna'
),
cte_consegna_complessivo as (
select count(StatusConsegna) as Totale_consegne
from transazioni_dataset)
SELECT
round((new_cte.InConsegna/cte_consegna_complessivo.Totale_consegne*100),1)
as PercentualeInConsegna
from new_cte, cte_consegna_complessivo;

-- DOMANDA NUMERO 19: Trova la percentuale di spedizioni con "In Consegna" rispetto al totale (SENZA FUNZIONE WITH)
SELECT ((SELECT COUNT(StatusConsegna)
FROM transazioni_dataset
WHERE StatusConsegna="In Consegna")*100/(SELECT COUNT(StatusConsegna)
FROM transazioni_dataset)) AS PercentualeInConsegna;