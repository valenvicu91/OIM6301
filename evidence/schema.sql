PRAGMA foreign_keys = ON;


-- Parents
CREATE TABLE Customer (
  customer_id    INTEGER PRIMARY KEY,
  first_name     TEXT NOT NULL,
  last_name      TEXT NOT NULL,
  email          TEXT,
  join_date      TEXT,
  points_balance INTEGER
);

CREATE TABLE Product (
  product_id    INTEGER PRIMARY KEY,
  product_name  TEXT NOT NULL,
  category      TEXT,
  size          TEXT,
  price         REAL,
  cost          REAL,
  is_available  INTEGER   -- use 1/0 when importing
);

CREATE TABLE Barista (
  barista_id        INTEGER PRIMARY KEY,
  first_name        TEXT NOT NULL,
  last_name         TEXT NOT NULL,
  hire_date         TEXT,
  is_active         INTEGER,        -- use 1/0 when importing
  years_experience  INTEGER,
  specialty         TEXT
);

CREATE TABLE Promotion (
  promotion_id   INTEGER PRIMARY KEY,
  promotion_name TEXT,
  coupon_code    TEXT UNIQUE,       -- this is what "order" will reference
  start_date     TEXT,
  end_date       TEXT,
  discount_type  TEXT,
  discount_value REAL,
  is_active      INTEGER            -- use 1/0 when importing
);

-- Order (child of Customer, Barista, Promotion via coupon_code)
CREATE TABLE "order" (
  order_id        INTEGER PRIMARY KEY,
  customer_id     INTEGER NOT NULL,
  barista_id      INTEGER NOT NULL,
  coupon_code     TEXT,              -- leave blank (NULL) if no promo
  order_datetime  TEXT NOT NULL,
  payment_method  TEXT,
  order_channel   TEXT,
  points_redeemed INTEGER,
  FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
  FOREIGN KEY (barista_id)  REFERENCES Barista(barista_id),
  FOREIGN KEY (coupon_code) REFERENCES Promotion(coupon_code)
);

-- Order line items (child of Order & Product)
CREATE TABLE OrderLineItem (
  line_item_id INTEGER PRIMARY KEY,
  order_id     INTEGER NOT NULL,
  product_id   INTEGER NOT NULL,
  quantity     INTEGER,
  unit_price   REAL,
  unit_cost    REAL,
  notes        TEXT,
  FOREIGN KEY (order_id)   REFERENCES "order"(order_id),
  FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

-- Loyalty transactions (child of Customer; optional link to Order)
CREATE TABLE loyalty_transaction (
  loyalty_txn_id INTEGER PRIMARY KEY,
  customer_id    INTEGER NOT NULL,
  order_id       INTEGER,       -- can be NULL for manual adjustments
  txn_datetime   TEXT,
  txn_type       TEXT,
  points         INTEGER,
  memo           TEXT,
  FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
  FOREIGN KEY (order_id)    REFERENCES "order"(order_id)
);
