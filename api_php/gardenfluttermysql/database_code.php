CREATE TABLE users (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    firebase_uid VARCHAR(128) NOT NULL,
    username VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL,
    role ENUM('admin', 'general') NOT NULL DEFAULT 'general',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    UNIQUE KEY unique_firebase_uid (firebase_uid),
    UNIQUE KEY unique_email (email)
);

CREATE TABLE gardens (
    garden_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    garden_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (garden_id)
) ENGINE=InnoDB;

CREATE TABLE owners (
    owner_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    owner_name VARCHAR(100) NOT NULL,
    owner_photo VARCHAR(255) DEFAULT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (owner_id)
) ENGINE=InnoDB;

CREATE TABLE garden_owners (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    garden_id INT UNSIGNED NOT NULL,
    owner_id INT UNSIGNED NOT NULL,

    PRIMARY KEY (id),

    UNIQUE KEY unique_garden_owner (garden_id, owner_id),

    FOREIGN KEY (garden_id)
        REFERENCES gardens(garden_id)
        ON DELETE CASCADE,

    FOREIGN KEY (owner_id)
        REFERENCES owners(owner_id)
        ON DELETE CASCADE
);

CREATE TABLE financial_partners (
    partner_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    partner_name VARCHAR(100) NOT NULL,
    partner_institution VARCHAR(150) NOT NULL,
    partner_photo VARCHAR(255) DEFAULT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (partner_id)
) ENGINE=InnoDB;

CREATE TABLE partner_gardens (
    partner_id INT UNSIGNED NOT NULL,
    garden_id INT UNSIGNED NOT NULL,

    PRIMARY KEY (partner_id, garden_id),

    CONSTRAINT fk_partner_gardens_partner
        FOREIGN KEY (partner_id)
        REFERENCES financial_partners(partner_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_partner_gardens_garden
        FOREIGN KEY (garden_id)
        REFERENCES gardens(garden_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE funds (
    fund_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    owner_id INT UNSIGNED NOT NULL,
    garden_id INT UNSIGNED NOT NULL,
    fund_amount DECIMAL(12,2) NOT NULL,
    fund_date DATE NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (fund_id),

    INDEX idx_funds_owner (owner_id),
    INDEX idx_funds_garden (garden_id),
    INDEX idx_funds_date (fund_date),

    CONSTRAINT fk_funds_owner
        FOREIGN KEY (owner_id)
        REFERENCES owners(owner_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_funds_garden
        FOREIGN KEY (garden_id)
        REFERENCES gardens(garden_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE expenses (
    expense_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    owner_id INT UNSIGNED NOT NULL,
    garden_id INT UNSIGNED NOT NULL,
    expense_description VARCHAR(255) NOT NULL,
    expense_amount DECIMAL(12,2) NOT NULL,
    expense_date DATE NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (expense_id),

    INDEX idx_expenses_owner (owner_id),
    INDEX idx_expenses_garden (garden_id),
    INDEX idx_expenses_date (expense_date),

    CONSTRAINT fk_expenses_owner
        FOREIGN KEY (owner_id)
        REFERENCES owners(owner_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_expenses_garden
        FOREIGN KEY (garden_id)
        REFERENCES gardens(garden_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE loans (
    loan_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    partner_id INT UNSIGNED NOT NULL,
    loan_purpose VARCHAR(255) NOT NULL,
    garden_id INT UNSIGNED NOT NULL,
    loan_amount DECIMAL(12,2) NOT NULL,
    loan_date DATE NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (loan_id),

    INDEX idx_loans_partner (partner_id),
    INDEX idx_loans_garden (garden_id),
    INDEX idx_loans_date (loan_date),

    CONSTRAINT fk_loans_partner
        FOREIGN KEY (partner_id)
        REFERENCES financial_partners(partner_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_loans_garden
        FOREIGN KEY (garden_id)
        REFERENCES gardens(garden_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE incomes (
    income_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    owner_id INT UNSIGNED NOT NULL,
    garden_id INT UNSIGNED NOT NULL,
    income_source VARCHAR(255) NOT NULL,
    income_amount DECIMAL(12,2) NOT NULL,
    income_date DATE NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (income_id),

    INDEX idx_incomes_owner (owner_id),
    INDEX idx_incomes_garden (garden_id),
    INDEX idx_incomes_date (income_date),

    CONSTRAINT fk_incomes_owner
        FOREIGN KEY (owner_id)
        REFERENCES owners(owner_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_incomes_garden
        FOREIGN KEY (garden_id)
        REFERENCES gardens(garden_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

ALTER TABLE owners
ADD COLUMN user_id INT UNSIGNED NULL AFTER owner_name;

ALTER TABLE owners
ADD CONSTRAINT fk_owners_user
FOREIGN KEY (user_id)
REFERENCES users(id)
ON DELETE SET NULL;

ALTER TABLE owners
ADD UNIQUE KEY unique_owner_user (user_id);

CREATE TABLE profit_transactions (
    profit_transaction_id INT UNSIGNED NOT NULL AUTO_INCREMENT,

    owner_id INT UNSIGNED NOT NULL,
    garden_id INT UNSIGNED NOT NULL,

    profit_amount DECIMAL(12,2) NOT NULL,
    profit_date DATE NOT NULL,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (profit_transaction_id),

    INDEX idx_profit_transactions_owner (owner_id),
    INDEX idx_profit_transactions_garden (garden_id),
    INDEX idx_profit_transactions_date (profit_date),

    CONSTRAINT fk_profit_transactions_garden_owner
        FOREIGN KEY (garden_id, owner_id)
        REFERENCES garden_owners(garden_id, owner_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE

) ENGINE=InnoDB;


