#!/bin/bash
 set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "auto_db" <<-EOSQL
	INSERT INTO
	  autos (year,make,model,color,price,mileage)
	VALUES
	  ('2017', 'Hyundai', 'Tucson', 'Silver', '21,500', '46380'),
	  ('2015', 'Mitsubishi', 'Outlander', 'Blue', '10,260', '91330'),
	  ('2018', 'Hyundai', 'Kona', 'Red', '10,580', '139350'),
	  ('2016', 'Porsche', 'Macan', 'Black', '48,590', '17130'),
	  ('2014', 'Audi', 'Q3', 'White', '16,390', '93250'),
	  ('2000', 'Ford', 'Explorer', 'Black', '10,590', '99900'),
	  ('2020', 'Nissan', 'Rogue', 'Black', '32,590', '12600'),
	  ('2018', 'Toyota', 'RAV4', 'Blue', '14,990', '89150'),
	  ('2021', 'Chevrolet', 'Traverse', 'White', '35,990', '7030'),
	  ('2018', 'Mercedes', 'GLA', 'Red', '43,990', '6790'),
	  ('2017', 'Infiniti', 'QX50', 'Black', '27990', '37580'),
	  ('2015', 'Chevrolet', 'Equinox', 'White', '14,590', '82450'),
	  ('2019', 'BMW', 'X2', 'Black', '38,590', '2700'),
	  ('2020', 'Alfa Romeo', 'Stelvio', 'Black', '77,900', '9520'),
	  ('2015', 'Volkswagen', 'Tiguan', 'White', '13,590', '81700'),
	  ('2014', 'Jeep', 'Wrangler', 'Blue', '10,990', '96100'),
	  ('2020', 'Range Rover', 'Land Rover', 'Black', '23,590', '53900'),
	  ('2022', 'Subaru', 'Outback', 'Black', '53,300', '400'),
	  ('2019', 'Hyundai', 'Tucson', 'White', '20,590', '56380'),
	  ('2022', 'Mitsubishi', 'Outlander', 'White', '21,560', '71330'),
	  ('2020', 'Hyundai', 'Kona', 'Silver', '20,580', '39350'),
	  ('2018', 'Porsche', 'Macan', 'Black', '38,590', '67130'),
	  ('2018', 'Audi', 'Q3', 'Silver', '26,590', '53250'),
	  ('2016', 'Ford', 'Explorer', 'Black', '20,590', '89900'),
	  ('2019', 'Nissan', 'Rogue', 'Silver', '22,590', '32600'),
	  ('2016', 'Toyota', 'RAV4', 'Red', '26,990', '29150'),
	  ('2020', 'Chevrolet', 'Traverse', 'White', '25,990', '77030'),
	  ('2016', 'Mercedes', 'GLA', 'White', '23,990', '46790'),
	  ('2022', 'Infiniti', 'QX50', 'Silver', '37990', '7580'),
	  ('2020', 'Chevrolet', 'Equinox', 'Green', '24,590', '22450'),
	  ('2018', 'BMW', 'X2', 'Black', '28,590', '32700'),
	  ('2018', 'Alfa Romeo', 'Stelvio', 'White', '27,900', '39520'),
	  ('2019', 'Volkswagen', 'Tiguan', 'Red', '23,590', '41700'),
	  ('2010', 'Jeep', 'Wrangler', 'White', '20,990', '76100'),
	  ('2018', 'Range Rover', 'Land Rover', 'Black', '43,590', '33900'),
	  ('2016', 'Subaru', 'Outback', 'Green', '23,300', '3400'),
	  ('2021', 'Ford', 'F-150', 'Black', '45,500', '500'),
	  ('2015', 'Ford', 'Mustang', 'Blue', '10,000', '40000');
EOSQL
