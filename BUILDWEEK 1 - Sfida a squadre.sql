#1. Quali prodotti vendono meglio in determinati periodi dell’anno?
SELECT t.ProdottoID, MONTH(t.DataTransazione), sum(p.prezzo)*t.QuantitaAcquistata AS Totale
FROM transazioni_dataset t
JOIN prodotti_dataset p ON p.ProdottoID=t.ProdottoID
GROUP BY ProdottoID, MONTH(t.DataTransazione), QuantitaAcquistata
ORDER BY sum(p.prezzo)*t.QuantitaAcquistata DESC;

#2. Selezione i primi 3 clienti che hanno il prezzo medio di acquisto più alto in ogni categoria di prodotto.
with cte as (
SELECT ClienteID, p.Prezzo*SUM(QuantitaAcquistata) as TotaleSpeso, Categoria
FROM prodotti_dataset p
JOIN transazioni_dataset t ON t.ProdottoID=p.ProdottoID
GROUP BY ClienteID, Prezzo, Categoria)
SELECT ClienteID, Categoria, AVG(TotaleSpeso)
FROM cte
GROUP BY ClienteID,Categoria
ORDER BY AVG(TotaleSpeso) DESC
LIMIT 3;

#3. Numero di prodotti con una quantità disponibile inferiore alla media.
SELECT AVG(QuantitaDisponibile)
FROM prodotti_dataset;
-- La media della quantità disponibile è pari a 50.6130

-- Selezionare tutti i prodotti che hanno una quantità disponibile inferiore a 50.6130
SELECT NomeProdotto, QuantitaDisponibile
FROM prodotti_dataset
WHERE (SELECT AVG(QuantitaDisponibile) FROM prodotti_dataset)>QuantitaDisponibile
ORDER BY QuantitaDisponibile;


#4. Media delle recensioni dei clienti il cui tempo di elaborazione dell'ordine è inferiore a 30gg
with cte as (
SELECT ClienteID, p.Prezzo*SUM(QuantitaAcquistata) as TotaleSpeso, Categoria
FROM prodotti_dataset p
JOIN transazioni_dataset t ON t.ProdottoID=p.ProdottoID
GROUP BY ClienteID, Prezzo, Categoria)
SELECT ClienteID, Categoria, AVG(TotaleSpeso)
FROM cte
GROUP BY ClienteID,Categoria
ORDER BY AVG(TotaleSpeso) DESC
LIMIT 3;


SELECT Rating
FROM ratings_dataset
JOIN transazioni_dataset ON ProductID=ProdottoID
WHERE dayofmonth(DataSpedizione-DataTransazione)<=30000;

SELECT IDTransazione, count(DataSpedizione)-dayofyear(DataTransazione)
FROM transazioni_dataset