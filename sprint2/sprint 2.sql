-- SPRINT 2

-- NIVELL 1

-- EXERCICI 1
-- Tot explicat en el pdf.

-- EXERCICI 2
-- Utilitzant JOIN realitzaras les següents consultes
-- Llistat dels països que estan fent compres
SELECT DISTINCT c.country AS Paises
FROM company c
JOIN transaction t ON c.id = t.company_id
WHERE t.declined=0; -- Solo tengo en cuenta transacciones finalizadas

-- Des de quants països es realitzen les compres
SELECT COUNT(DISTINCT c.country) AS Paises
FROM company c
JOIN transaction t ON c.id = t.company_id
WHERE t.declined=0; -- Solo tengo en cuenta transacciones finalizadas

-- Identifica la companyia amb la mitjana més gran de vendes
SELECT c.company_name, ROUND(AVG(t.amount), 2) AS MediaVentas
FROM company c
JOIN transaction t ON c.id = t.company_id
WHERE t.declined=0 -- Solo tengo en cuenta transacciones finalizadas
GROUP BY c.company_name
ORDER BY MediaVentas DESC
LIMIT 1;

-- EXERCICI 3
-- Utilitzant només subconsultes (sense utilitzar JOIN)
-- Mostra totes les transaccions realitzades per empreses d'Alemanya
SELECT *
FROM transaction
WHERE company_id IN (
    SELECT id
    FROM company
    WHERE country = 'Germany' -- Tengo en cuenta TODAS las transacciones
);

-- Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions
SELECT DISTINCT c.company_name
FROM company c
WHERE c.id IN (
	SELECT t.company_id
    FROM transaction t
    WHERE t.declined=0 AND t.amount > (  -- Solo tengo en cuenta transacciones finalizadas
		SELECT AVG(amount) FROM transaction
	)
);

-- Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.
-- Llistat de empreses sense transaccions
SELECT id, company_name
FROM company
WHERE id NOT IN (
	SELECT DISTINCT company_id
    FROM transaction
);
-- Eliminar empreses sense transaccions
SET SQL_SAFE_UPDATES = 0; -- desbloquear seguridad de no borrado tablas con primary key

DELETE FROM company
WHERE id NOT IN (
	SELECT DISTINCT company_id
    FROM transaction
);

SET SQL_SAFE_UPDATES = 1; -- restablecer seguridad de no borrado tablas con primary key


-- NIVELL 2

-- EXERCICI 1
-- Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes.
-- Mostra la data de cada transacció juntament amb el total de les vendes.
SELECT DATE(timestamp), SUM(amount) AS total_sales
FROM transaction
WHERE declined=0 -- Solo tengo en cuenta transacciones finalizadas
GROUP BY DATE(timestamp)
ORDER BY total_sales DESC
LIMIT 5;

-- EXERCICI 2
-- Quina és la mitjana de vendes per país? Presenta els resultats ordenats de major a menor mitjà.
SELECT c.country, ROUND(AVG(t.amount), 2) AS average_sales
FROM transaction t
JOIN company c ON t.company_id=c.id
WHERE declined=0 -- Solo tengo en cuenta transacciones finalizadas
GROUP BY c.country
ORDER BY average_sales DESC;

-- EXERCICI 3
-- En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries per a fer
-- competència a la companyia "Non Institute". Per a això, et demanen la llista de totes les transaccions
-- realitzades per empreses que estan situades en el mateix país que aquesta companyia.

-- Mostra el llistat aplicant JOIN i subconsultes.
SELECT t.*
FROM transaction t
JOIN company c ON t.company_id=c.id
WHERE c.country=(
	SELECT country
    FROM company
    WHERE company_name='Non Institute' AND declined=0 -- Solo tengo en cuenta transacciones finalizadas
);

-- Mostra el llistat aplicant solament subconsultes.
SELECT *
FROM transaction
WHERE declined=0 AND company_id IN ( -- Solo tengo en cuenta transacciones finalizadas
	SELECT id
    FROM company
    WHERE country = (
		SELECT country
        FROM company
        WHERE company_name = 'Non Institute'
	)
);

-- NIVELL 3

-- EXERCICI 1
-- Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar transaccions amb
-- un valor comprès entre 100 i 200 euros i en alguna d'aquestes dates: 29 d'abril del 2021, 20 de juliol
-- del 2021 i 13 de març del 2022. Ordena els resultats de major a menor quantitat.
SELECT c.company_name, c.phone, c.country, DATE(t.timestamp), t.amount
FROM transaction t
JOIN company c ON t.company_id=c.id
WHERE amount BETWEEN 100 AND 200
AND DATE(t.timestamp) IN ('2021-04-29', '2021-07-20', '2022-03-13')
AND t.declined=0 -- Solo tengo en cuenta transacciones finalizadas
ORDER BY t.amount DESC;

-- EXERCICI 2
-- Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi,
-- per la qual cosa et demanen la informació sobre la quantitat de transaccions que realitzen les empreses,
-- però el departament de recursos humans és exigent i vol un llistat de les empreses on especifiquis
-- si tenen més de 4 transaccions o menys.
SELECT c.id, c.company_name, COUNT(t.id) AS total_transacciones,
	CASE
		WHEN COUNT(t.id) >= 4 THEN 'mas de 4'
        ELSE 'menos de 4'
	END AS clasificacion
FROM company c
LEFT JOIN transaction t ON c.id=t.company_id
GROUP BY c.id, c.company_name
ORDER BY total_transacciones DESC;
