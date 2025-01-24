-- SPRINT 4
-- NIVELL 1

-- Creamos la base de datos
CREATE DATABASE TransactionsDB;
USE TransactionsDB;

-- Creamos la tabla `users`
CREATE TABLE users (
    id INT PRIMARY KEY,
    name VARCHAR(50),
    surname VARCHAR(50),
    phone VARCHAR(20),
    email VARCHAR(100),
    birth_date VARCHAR(20),
    country VARCHAR(50),
    city VARCHAR(50),
    postal_code VARCHAR(20),
    address VARCHAR(100)
);

-- Creamos la tabla `credit_cards`
CREATE TABLE credit_cards (
    id VARCHAR(20) PRIMARY KEY,
    user_id INT,
    iban VARCHAR(34),
    pan VARCHAR(19),
    pin VARCHAR(10),
    cvv INT,
    track1 VARCHAR(100),
    track2 VARCHAR(100),
    expiring_date VARCHAR(20),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Creamos la tabla `companies`
CREATE TABLE companies (
    company_id VARCHAR(20) PRIMARY KEY,
    company_name VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100),
    country VARCHAR(50),
    website VARCHAR(100)
);

-- Creamos la tabla `transactions`
CREATE TABLE transactions (
    id VARCHAR(50) PRIMARY KEY,
    card_id VARCHAR(20),
    business_id VARCHAR(20),
    timestamp DATETIME,
    amount DECIMAL(10,2),
    declined BOOLEAN,
    product_ids VARCHAR(255),
    user_id INT,
    lat VARCHAR(50),
    longitude VARCHAR(50),
    FOREIGN KEY (card_id) REFERENCES credit_cards(id),
    FOREIGN KEY (business_id) REFERENCES companies(company_id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Ahora vamos a introducir la informacion usando la herramienta de Workbench Table Data import wizard
-- Comprobamos informacion introducida
SELECT *
FROM companies;

SELECT *
FROM credit_cards;

SELECT *
FROM transactions;

SELECT *
FROM users;

-- EXERCICI 1
-- Realitza una subconsulta que mostri tots els usuaris amb més de 30 transaccions utilitzant almenys 2 taules.
SELECT u.name, u.surname
FROM users u
WHERE u.id IN (
    SELECT t.user_id
    FROM transactions t
    GROUP BY t.user_id
    HAVING COUNT(*) > 30
);

-- EXERCICI 2
-- Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules.
SELECT cc.iban, ROUND(AVG(t.amount), 2) as mitjana_amount
FROM credit_cards cc
JOIN transactions t ON cc.id = t.card_id
JOIN companies c ON t.business_id = c.company_id
WHERE c.company_name = 'Donec Ltd'
GROUP BY cc.iban;

-- NIVELL 2
-- Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en
-- si les últimes tres transaccions van ser declinades i genera la següent consulta
-- Vamos a crear la tabla
CREATE TABLE credit_card_status (
    card_id VARCHAR(20) PRIMARY KEY,
    status VARCHAR(50) NOT NULL
);

-- Vamos a llenarla de datos
INSERT INTO credit_card_status (card_id, status)
SELECT c.id AS card_id,
    CASE
        WHEN COUNT(t.id) >= 3 AND SUM(t.declined) = 3 THEN 'Bloquejada'
        ELSE 'Activa'
    END AS status
FROM credit_cards c
LEFT JOIN transactions t ON c.id = t.card_id
GROUP BY c.id;

-- Vamos a ver los valores introducidos    
SELECT * 
FROM credit_card_status;

-- EXERCICI 1
SELECT DISTINCT COUNT(card_id) AS TarjetasActivas
FROM credit_card_status
WHERE status='Activa';

-- NIVELL 3
-- Crea una taula amb la qual puguem unir les dades del nou arxiu products.csv amb la base de dades creada,
-- tenint en compte que des de transaction tens product_ids. Genera la següent consulta:

-- Voy a crear la nueva tabla products
CREATE TABLE products (
    id INT PRIMARY KEY,
    product_name VARCHAR(100),
    price VARCHAR(20),
    colour VARCHAR(7),
    weight DECIMAL(10, 2),
    warehouse_id VARCHAR(10)
);

-- Entramos los datos con la herramienta de Workbench y lo comprobamos
SELECT *
FROM products;

-- creamos una tabla entremedia para relacionar products con transactions
CREATE TABLE transaction_products (
    transaction_id VARCHAR(50),
    product_id INT,
    FOREIGN KEY (transaction_id) REFERENCES transactions(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- Insertamos los datos a la nueva tabla transaction_products
-- Los datos de product_id los convertimos en una array list
-- y estos los convertimos en una Json_table asi
-- cada elemento de la array se convierte en una fila
INSERT INTO transaction_products (transaction_id, product_id)
SELECT t.id, p.value
FROM transactions t
CROSS JOIN JSON_TABLE(
    CONCAT('["', REPLACE(t.product_ids, ', ', '","'), '"]'),
    '$[*]' COLUMNS (value VARCHAR(255) PATH '$')
) AS p;

-- Comprovamos los datos introducidos
SELECT *
FROM transaction_products;

-- EXERCICI 1
-- Necessitem conèixer el nombre de vegades que s'ha venut cada producte.
SELECT p.id, p.product_name, p.colour, COUNT(tp.product_id) AS sales_count
FROM products p
LEFT JOIN transaction_products tp ON p.id = tp.product_id
GROUP BY p.id, p.product_name, p.colour
ORDER BY sales_count DESC;