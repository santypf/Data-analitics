-- NIVELL 1
-- EXERCICI 1
-- La teva tasca és dissenyar i crear una taula anomenada "credit_card" que emmagatzemi
-- detalls crucials sobre les targetes de crèdit. La nova taula ha de ser capaç d'identificar
-- de manera única cada targeta i establir una relació adequada amb les altres dues taules ("transaction" i "company").
-- Després de crear la taula serà necessari que ingressis la informació del document denominat "dades_introduir_credit".
-- Recorda mostrar el diagrama i realitzar una breu descripció d'aquest.

-- Creamos nueva tabla 
CREATE TABLE credit_card (
	Id VARCHAR(15) PRIMARY KEY NOT NULL,
    Iban VARCHAR(50) NOT NULL,
    Pan VARCHAR(50) NOT NULL,
    PIN INT NOT NULL,
    CVV INT NOT NULL,
    expiring_date VARCHAR(15) NOT NULL -- Creamos como texto para salvar el formato diferente
);
-- Transformamos los datos de expiring_date a yy/mm/dd
-- Para hacer esto tengo que desconectar el modo seguro
SET SQL_SAFE_UPDATES = 0;

UPDATE credit_card
SET expiring_date = STR_TO_DATE(expiring_date, '%m/%d/%y');

SET SQL_SAFE_UPDATES = 1; -- Vuelvo a conectar el modo seguro

-- Vamos a pasar columna expiring_date de varchar a date
ALTER TABLE credit_card
MODIFY COLUMN expiring_date DATE;

-- Vamos a quitar los espacios de algunos registros de la columna Pan
-- Para hacer esto tengo que desconectar el modo seguro
SET SQL_SAFE_UPDATES = 0;

UPDATE credit_card SET Pan = REPLACE(Pan, ' ', '') WHERE Pan LIKE '% %';

SET SQL_SAFE_UPDATES = 1; -- Vuelvo a conectar el modo seguro

-- vamos ha hacer la relacion entre transaction y credit_card
ALTER TABLE transaction
ADD CONSTRAINT fk_credit_card_id
FOREIGN KEY (credit_card_id) REFERENCES credit_card(Id);

-- EXERCICI 2
-- El departament de Recursos Humans ha identificat un error en el número de compte de
-- l'usuari amb ID CcU-2938. La informació que ha de mostrar-se per a aquest registre és: R323456312213576817699999.
-- Recorda mostrar que el canvi es va realitzar.

-- El usuario tiene ahora este numero de cuenta.
SELECT Iban
FROM credit_card
WHERE id = 'Ccu-2938';

-- Vamos a cambiarle el valor
UPDATE credit_card
SET Iban = 'R323456312213576817699999'
WHERE id = 'Ccu-2938';

-- El usuario tiene ahora este numero de cuenta.
SELECT Iban
FROM credit_card
WHERE id = 'Ccu-2938';

-- EXERCICI 3
-- En la taula "transaction" ingressa un nou usuari amb la següent informació:
-- Id	108B1D1D-5B23-A76C-55EF-C568E49A99DD
-- credit_card_id	CcU-9999
-- company_id	b-9999
-- user_id	9999
-- lat	829.999
-- longitude	-117.999
-- amount	111.11
-- declined	0
-- Para insertarlo tengo que desactivar las restricciones de claves foraneas
SET FOREIGN_KEY_CHECKS = 0;

INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, timestamp, amount, declined)
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', 9999, 829.999, -117.999, CURRENT_TIMESTAMP(), 111.11, 0);

SET FOREIGN_KEY_CHECKS = 1; -- Vuelvo a activar las restricciones

-- Voy a ver el nuevo registro introducido
SELECT *
FROM transaction
WHERE id='108B1D1D-5B23-A76C-55EF-C568E49A99DD';

-- EXERCICI 4
-- Des de recursos humans et sol·liciten eliminar la columna "pan" de la taula credit_card.
-- Recorda mostrar el canvi realitzat.
-- Vamos a ver como es la tabla credit_card
SELECT * FROM credit_card;

-- Vamos a eliminar la columna PAN
ALTER TABLE credit_card DROP COLUMN Pan;

-- Vamos a ver como ha quedado la tabla credit_card
SELECT * FROM credit_card;

-- NIVELL 2
-- EXERCICI 1
-- Elimina de la taula transaction el registre amb ID 02C6201E-D90A-1859-B4EE-88D2986D3B02 de la base de dades.
-- Vamos a ver el registro
SELECT *
FROM transaction
WHERE id='02C6201E-D90A-1859-B4EE-88D2986D3B02';

-- Vamos a eliminar el registro
DELETE FROM transaction
WHERE id='02C6201E-D90A-1859-B4EE-88D2986D3B02';

-- Vamos a ver si aun existe ese registro
SELECT *
FROM transaction
WHERE id='02C6201E-D90A-1859-B4EE-88D2986D3B02';

-- EXERCICI 2
-- La secció de màrqueting desitja tenir accés a informació específica per a realitzar anàlisi
-- i estratègies efectives. S'ha sol·licitat crear una vista que proporcioni detalls clau sobre
-- les companyies i les seves transaccions. Serà necessària que creïs una vista anomenada VistaMarketing
-- que contingui la següent informació: Nom de la companyia. Telèfon de contacte. País de residència. 
-- Mitjana de compra realitzat per cada companyia. Presenta la vista creada, ordenant les dades de
-- major a menor mitjana de compra.
-- Vamos a crear la Vista
CREATE VIEW VistaMarketing AS
SELECT c.company_name AS Nom_Companyia, c.phone AS Telefon_Contacte,
    c.country AS Pais_Residencia, ROUND(AVG(t.amount), 2) AS Mitjana_Compra
FROM company c
JOIN transaction t ON c.id = t.company_id
GROUP BY c.company_name, c.phone, c.country
ORDER BY Mitjana_Compra DESC;

-- Vamos a ver la vista creada
SELECT *
FROM vistamarketing;

-- EXERCICI 3
-- Filtra la vista VistaMarketing per a mostrar només les companyies que tenen el seu país de residència en "Germany"
-- Tengo que tener en cuenta que en la vista country lo he llamado Pais_Residencia
SELECT *
FROM vistamarketing
WHERE Pais_Residencia='Germany';

-- NIVELL 3
-- EXERCICI 1
-- La setmana vinent tindràs una nova reunió amb els gerents de màrqueting.
-- Un company del teu equip va realitzar modificacions en la base de dades,
-- però no recorda com les va realitzar. Et demana que l'ajudis a deixar els
-- comandos executats per a obtenir el diagrama de mostra.
-- Tabla COMPANY
-- Eliminamos columna website
ALTER TABLE company DROP COLUMN website;
-- Tabla CREDIT_CARD
-- id pasamos de VARCHAR(15) a VARCHAR(20)
ALTER TABLE credit_card
MODIFY COLUMN Id VARCHAR(20);

-- pin pasamos de INT a VARCHAR(4)
ALTER TABLE credit_card
MODIFY COLUMN PIN VARCHAR(4);

-- expiring_date de DATE a VARCHAR(20)
ALTER TABLE credit_card
MODIFY COLUMN expiring_date VARCHAR(20);

-- creamos una nueva columna llamada fecha_actual del tipo DATE
ALTER TABLE credit_card
ADD COLUMN fecha_actual DATE;

-- Creamos la nueva tabla con el codigo que nos proporcionan y lo comprobamos
SELECT *
FROM user;

-- Cambiamos el nombre de la nueva tabla de user a data_user
RENAME TABLE user TO data_user;

-- En la nueva tabla renombramos la columna email a personal_email
ALTER TABLE data_user
CHANGE COLUMN email personal_email VARCHAR(150);

-- Modificamos foreign key de la columna user_id de la tabla transaction
-- Desconectamos seguridad para Foreign Key
SET FOREIGN_KEY_CHECKS = 0;
-- Anulamos foreign key crado
ALTER TABLE data_user
DROP FOREIGN KEY data_user_ibfk_1;
-- Creamos nuevo foreign key
ALTER TABLE transaction
ADD CONSTRAINT fk_user_id FOREIGN KEY (user_id) REFERENCES data_user(id);

SET FOREIGN_KEY_CHECKS = 1; -- Volvemos a activar la segurida

-- EXERCICI 2
-- L'empresa també et sol·licita crear una vista anomenada "InformeTecnico" que contingui la següent informació:
-- ID de la transacció
-- Nom de l'usuari/ària
-- Cognom de l'usuari/ària
-- IBAN de la targeta de crèdit usada.
-- Nom de la companyia de la transacció realitzada.
-- Assegura't d'incloure informació rellevant de totes dues taules i utilitza àlies per a canviar de nom columnes segons sigui necessari.
-- Mostra els resultats de la vista, ordena els resultats de manera descendent en funció de la variable ID de transaction.
-- Creamos vista
CREATE VIEW InformeTecnico AS
SELECT t.id AS IdTransaccion, d.name AS NomClient, d.surname AS CognomClient,
    cc.iban AS IbanTarjeta, c.company_name AS NomEmpresa
FROM transaction t
JOIN data_user d ON t.user_id = d.id
JOIN credit_card cc ON t.credit_card_id = cc.id
JOIN company c ON t.company_id = c.id
ORDER BY t.id DESC;

-- Comprobamos su existencia
SELECT *
FROM informetecnico;

-- MODIFICACION NIVELL 1 EXERCICI 3

-- Primero eliminamos la informacion introducida para realizar bien el ejercicio
DELETE FROM transaction
WHERE id='108B1D1D-5B23-A76C-55EF-C568E49A99DD';

-- vamos a crear el mismo credit_card_id en la tabla credit_card
INSERT INTO credit_card (id, Iban, PIN, CVV, expiring_date, fecha_actual)
VALUES ('CcU-9999', '9999999999999', '9999', '999', '2099-12-12', CURRENT_DATE);

-- comprobamos el id nuevo en la tabla credit_cards
SELECT *
FROM credit_card
WHERE id='CcU-9999';

-- vamos a crear el mismo company_id en la tabla company
INSERT INTO company (id, company_name, phone, email, country)
VALUES ('b-9999', 'Nueve', '99999999', '9999@99.com', 'Noveno');

-- comprobamos el id nuevo en la tabla company
SELECT *
FROM company
WHERE id='b-9999';

-- vamos a crear el mismo user_id en la tabla data_user
INSERT INTO data_user (id)
VALUES ('9999');

-- comprobamos el id nuevo en la tabla data_user
SELECT *
FROM data_user
WHERE id='9999';

-- Ahora ya podemos ingresar el nuevo registro en la tabla transaction
INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, timestamp, amount, declined)
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', 9999, 829.999, -117.999, CURRENT_TIMESTAMP(), 111.11, 0);

-- Comprobamos el nuevo registro de la tabla transaction
SELECT *
FROM transaction
WHERE id='108B1D1D-5B23-A76C-55EF-C568E49A99DD';

-- MODIFICACION NIVELL 3 EXERCICI 1

-- primero tenemos que saber que nombre tiene nuestra foreign key
SHOW CREATE TABLE data_user;

-- Anulamos foreign key creado
ALTER TABLE data_user
DROP FOREIGN KEY data_user_ibfk_1;

-- Creamos nuevo foreign key
ALTER TABLE transaction
ADD CONSTRAINT fk_user_id FOREIGN KEY (user_id) REFERENCES data_user(id);
