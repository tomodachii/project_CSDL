CREATE TABLE "buyer" (
	"id_buyer" int NOT NULL,
	"first_name" character varying(20) NOT NULL,
	"last_name" character varying(20) NOT NULL,
	"tel" character varying(11) NOT NULL,
	"email" character varying(40) NOT NULL,
	"user_name" character varying(40) NOT NULL UNIQUE,
	"address_detail" varchar(255) NOT NULL,
	"id_location" int NOT NULL,
	CONSTRAINT "buyer_pk" PRIMARY KEY ("id_buyer")
) WITH (
  OIDS=FALSE
);



CREATE TABLE "vip" (
	"id_shop" int NOT NULL,
	"start_date" DATE NOT NULL,
	"use_time" interval NOT NULL,
	CONSTRAINT "vip_pk" PRIMARY KEY ("id_shop")
) WITH (
  OIDS=FALSE
);



CREATE TABLE "shops" (
	"id_shop" int NOT NULL,
	"name_shop" varchar(40) NOT NULL,
	"is_vip" int NOT NULL,
	"id_location" int NOT NULL,
	"start_date" DATE NOT NULL,
	CONSTRAINT "shops_pk" PRIMARY KEY ("id_shop")
) WITH (
  OIDS=FALSE
);



CREATE TABLE "cart" (
	"id_buyer" int NOT NULL,
	"id_supply" int NOT NULL,
	"quantity" int NOT NULL,
	CONSTRAINT "cart_pk" PRIMARY KEY ("id_buyer","id_supply")
) WITH (
  OIDS=FALSE
);



CREATE TABLE "transactions" (
	"id_transaction" int NOT NULL,
	"id_customer" int NOT NULL,
	"id_shop" int NOT NULL,
	"id_product" int NOT NULL,
	"quantity" int NOT NULL,
	"price" float4 NOT NULL,
	"buy_date" DATE NOT NULL,
	CONSTRAINT "transactions_pk" PRIMARY KEY ("id_transaction")
) WITH (
  OIDS=FALSE
);



CREATE TABLE "supply" (
	"id_supply" int NOT NULL,
	"id_shop" int NOT NULL,
	"id_product" int NOT NULL,
	"price" float4 NOT NULL,
	"quantity" int NOT NULL,
	"sold" int NOT NULL,
	CONSTRAINT "supply_pk" PRIMARY KEY ("id_supply")
) WITH (
  OIDS=FALSE
);



CREATE TABLE "products" (
	"id_product" int NOT NULL,
	"name" character varying(40) NOT NULL,
	"type" character varying(40) NOT NULL,
	"manufacturer" character varying(20) NOT NULL,
	"year" DATE NOT NULL,
	CONSTRAINT "products_pk" PRIMARY KEY ("id_product")
) WITH (
  OIDS=FALSE
);



CREATE TABLE "locations" (
	"id_location" int NOT NULL,
	"city" character varying(20) NOT NULL,
	"district" character varying(20) NOT NULL,
	CONSTRAINT "locations_pk" PRIMARY KEY ("id_location")
) WITH (
  OIDS=FALSE
);



CREATE TABLE "seller" (
	"id_seller" int NOT NULL,
	CONSTRAINT "seller_pk" PRIMARY KEY ("id_seller")
) WITH (
  OIDS=FALSE
);



ALTER TABLE "buyer" ADD CONSTRAINT "buyer_fk0" FOREIGN KEY ("id_location") REFERENCES "locations"("id_location");

ALTER TABLE "vip" ADD CONSTRAINT "vip_fk0" FOREIGN KEY ("id_shop") REFERENCES "shops"("id_shop");

ALTER TABLE "shops" ADD CONSTRAINT "shops_fk0" FOREIGN KEY ("id_shop") REFERENCES "seller"("id_seller");
ALTER TABLE "shops" ADD CONSTRAINT "shops_fk1" FOREIGN KEY ("id_location") REFERENCES "locations"("id_location");

ALTER TABLE "cart" ADD CONSTRAINT "cart_fk0" FOREIGN KEY ("id_buyer") REFERENCES "buyer"("id_buyer");
ALTER TABLE "cart" ADD CONSTRAINT "cart_fk1" FOREIGN KEY ("id_supply") REFERENCES "supply"("id_supply");

ALTER TABLE "transactions" ADD CONSTRAINT "transactions_fk0" FOREIGN KEY ("id_customer") REFERENCES "buyer"("id_buyer");
ALTER TABLE "transactions" ADD CONSTRAINT "transactions_fk1" FOREIGN KEY ("id_shop") REFERENCES "shops"("id_shop");

ALTER TABLE "supply" ADD CONSTRAINT "supply_fk0" FOREIGN KEY ("id_shop") REFERENCES "shops"("id_shop");
ALTER TABLE "supply" ADD CONSTRAINT "supply_fk1" FOREIGN KEY ("id_product") REFERENCES "products"("id_product");



ALTER TABLE "seller" ADD CONSTRAINT "seller_fk0" FOREIGN KEY ("id_seller") REFERENCES "buyer"("id_buyer");

