<?php
	$host = 'localhost';
	$db   = 'gardenfluttermysql';
	$user = 'root';
	$pass = '';
	$charset = 'utf8mb4';

	$dsn = "mysql:host=$host;dbname=$db;charset=$charset";
	$options = [
		PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
		PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
		PDO::ATTR_EMULATE_PREPARES   => false,
	];

	try {
		 $conn = new PDO($dsn, $user, $pass, $options);
	} catch (\PDOException $e) {
		 // For security, do not echo $e->getMessage() in production
		 throw new \PDOException($e->getMessage(), (int)$e->getCode());
	}
?>
<?php

/*CREATE TABLE owner (
	owner_id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
	owner_name VARCHAR(50) NOT NULL,
	owner_photo VARCHAR(50) NOT NULL,
	garden_index VARCHAR(100) DEFAULT '',
	PRIMARY KEY (owner_id)
);

CREATE TABLE gardenIndex (
	garden_id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
	garden_name VARCHAR(100) NOT NULL,
	PRIMARY KEY (garden_id)
);

CREATE TABLE fund (
	fund_id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
	owner_id INT(10) NOT NULL,
	garden_id INT(10) NOT NULL,
	fund_amount INT(10) NOT NULL,
	fund_date VARCHAR(20) NOT NULL,	
	PRIMARY KEY (fund_id)
);

CREATE TABLE exp (
	exp_id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
	owner_id INT(10) NOT NULL,
	garden_id INT(10) NOT NULL,
	exp_amount INT(10) NOT NULL,
	exp_date VARCHAR(20) NOT NULL,
	exp_desc VARCHAR(100) NOT NULL,
	PRIMARY KEY (exp_id)
);

CREATE TABLE loan (
	loan_id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
	loan_inst VARCHAR(100) NOT NULL,
	loan_purpose VARCHAR(100) NOT NULL,
	garden_id INT(10) NOT NULL,
	loan_amount INT(10) NOT NULL,
	loan_date VARCHAR(20) NOT NULL,
	PRIMARY KEY (loan_id)
);

CREATE TABLE income (
	income_id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
	owner_id INT(10) NOT NULL,
	garden_id INT(10) NOT NULL,
	income_source VARCHAR(100) NOT NULL,
	income_amount INT(10) NOT NULL,
	income_date VARCHAR(20) NOT NULL,
	PRIMARY KEY (income_id)
);

CREATE TABLE fin_partner (
	partner_id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
	partner_name VARCHAR(50) NOT NULL,
	partner_inst VARCHAR(100) NOT NULL,
	partner_photo VARCHAR(50) NOT NULL,
	garden_index VARCHAR(100) DEFAULT '',
	PRIMARY KEY (partner_id)
);

$sql = "SELECT 
		o.owner_name,
		o.owner_photo,
		SUM(f.fund_amount) AS total_fund
	FROM fund f
	JOIN owner o ON f.owner_id = o.owner_id
	WHERE f.garden_id = $gid
	GROUP BY f.owner_id";
					
$sql = 'SELECT 
		g.garden_id,
		g.garden_name,
	GROUP_CONCAT(o.owner_name ORDER BY o.owner_id ASC) AS owners
	FROM gardenindex g
	LEFT JOIN owner o 
	ON FIND_IN_SET(g.garden_id, o.garden_index)
	GROUP BY g.garden_id, g.garden_name;';

$sql = 'SELECT 
		o.owner_id,
		o.owner_name,
		o.owner_photo,
		o.garden_index,
	GROUP_CONCAT(g.garden_name) AS garden_names
	FROM owner o
	LEFT JOIN gardenindex g 
	ON FIND_IN_SET(g.garden_id, o.garden_index)
	GROUP BY o.owner_id, o.owner_name, o.owner_photo, o.garden_index;';
	
$sql = 'SELECT 
		p.partner_id,
		p.partner_name,
		p.partner_inst,
		p.partner_photo,
		p.garden_index,
		g.garden_name											
	FROM fin_partner p
	LEFT JOIN gardenindex g ON g.garden_id = p.garden_index;';

$sql = 'SELECT 
		l.loan_id,
		l.loan_inst,
		f.partner_inst,
		f.partner_name,
		l.loan_purpose,
		l.garden_id,
		g.garden_name,
		l.loan_amount,
		l.loan_date
	FROM loan l
	LEFT JOIN fin_partner f ON l.loan_inst = f.partner_id
	LEFT JOIN gardenindex g ON l.garden_id = g.garden_id;';

$sql = 'SELECT 
		f.fund_id,
		f.owner_id,
		o.owner_name,
		f.garden_id,
		g.garden_name,
		f.fund_amount,
		f.fund_date
	FROM fund f
	LEFT JOIN owner o ON f.owner_id = o.owner_id
	LEFT JOIN gardenindex g ON f.garden_id = g.garden_id
	ORDER BY f.garden_id ASC, f.owner_id ASC, f.fund_id ASC;';

$sql = 'SELECT 
		i.income_id,
		i.owner_id,
		o.owner_name,
		i.garden_id,
		g.garden_name,
		i.income_source,
		i.income_amount,
		i.income_date
	FROM income i
	LEFT JOIN owner o ON i.owner_id = o.owner_id
	LEFT JOIN gardenindex g ON i.garden_id = g.garden_id
	ORDER BY i.garden_id ASC, i.income_id ASC;';

$sql = 'SELECT 
		e.exp_id,
		e.owner_id,
		o.owner_name,
		e.garden_id,
		g.garden_name,
		e.exp_amount,
		e.exp_date
	FROM exp e
	LEFT JOIN owner o ON e.owner_id = o.owner_id
	LEFT JOIN gardenindex g ON e.garden_id = g.garden_id
	ORDER BY e.garden_id ASC, e.exp_id ASC;';


 */

?>