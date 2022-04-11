/* HOUSE RENTAL DATABASE DESIGN

Welcome to my simple house rental database design script, I hope you find it helpful

   1.	Create multiple sheets in a spreadsheet, name them seperately as you would like to have them in your relational database 
	in my example: [tenants, buildings, apartments, owners, transactions, caretakers].
   2.	Ensure there is a unique identifier for each row in each table for objects with perculiar attributes to create relations within the tables
	eg. [tenant_id, building_id, apartment_id, owner_id (i had a couple of owners in my case), caretaker_id]. The transaction table does not necessary need to have one.
   3.	Populate the details according to the headers, ensure your date is formatted to the acceptable MySQL (used for this work) date format 'yyyy-mm-dd' 
	to prevent errors while importing the data.
   4.	Save each sheet into a csv file and name the files as the table names to make sure we import them into the tables correctly 
   5.	Create a new schema in MySQL workbench with your preferred database(db) name and refresh the Schemas
   6.	Double click the db to make it active or run the "USE 'db name' " query
   7.	Import the populated spreadsheets into tables using the 'Table Data Import Wizard' 
*/

-- Once all tables have been imported sucessfully, inspect them to be sure they were correctly/completely imported

SELECT * FROM tenants;  -- Or SELECT COUNT(*) FROM 'table_name' if the imported data is quite large
SELECT * FROM buildings;
SELECT * FROM apartments;
SELECT * FROM owners;
SELECT * FROM transactions;
SELECT * FROM caretakers;

-- Let's add primary keys to our tables which will uniquely identify each row in the tables

ALTER TABLE tenants ADD PRIMARY KEY(tenant_id);
ALTER TABLE owners ADD PRIMARY KEY(owner_id);
ALTER TABLE buildings ADD PRIMARY KEY(building_id);
ALTER TABLE apartments ADD PRIMARY KEY(apartment_id);
ALTER TABLE caretakers ADD PRIMARY KEY(caretaker_id);


-- Now let's add some foreign keys which will make the tables relational and prevent link breakage between the tables

ALTER TABLE buildings ADD FOREIGN KEY(caretaker_id) REFERENCES caretakers (caretaker_id);
ALTER TABLE buildings ADD FOREIGN KEY(caretaker_id) REFERENCES owners(owner_id);
ALTER TABLE apartments ADD FOREIGN KEY(building_id) REFERENCES buildings (building_id);
ALTER TABLE apartments ADD FOREIGN KEY(tenant_id) REFERENCES tenants(tenant_id);
ALTER TABLE transactions ADD FOREIGN KEY(tenant_id) REFERENCES tenants (tenant_id);
ALTER TABLE transactions ADD FOREIGN KEY(apartment_id) REFERENCES apartments(apartment_id);

-- We will select and export required/important columns for the house owner's use as at today

SELECT  first_name, middle_name, last_name, phone_no, alternate_phone_no,
		gender, age_category, marital_status, family_size, occupation, 
        apartment_type, ap.rent, location, rent_due_date, last_payment_date,
        tot_amount_paid, outstanding_balance, current_date, no_of_days_defaulted
FROM tenants AS te
LEFT JOIN apartments AS ap
ON te.tenant_id = ap.tenant_id
LEFT JOIN buildings AS bu
ON ap.building_id = bu.building_id
LEFT JOIN transactions AS tr
ON te.tenant_id = tr.tenant_id;


-- Let's now create a stored procedure to retrieve updated details as at when needed

delimiter @
CREATE PROCEDURE rental_details_today (IN ok TEXT)

READS SQL DATA

BEGIN

	SELECT  first_name, middle_name, last_name, phone_no, alternate_phone_no,
			gender, apartment_type, ap.rent, location, rent_due_date, last_payment_date,
			tot_amount_paid, outstanding_balance, current_date() AS "today's_date", 
	CASE WHEN current_date() > rent_due_date THEN datediff(current_date(), rent_due_date)
		WHEN outstanding_balance > 0 THEN 'PLEASE PAY BALANCE'
		ELSE 'NULL' 
	END AS no_of_days_defaulted
		FROM tenants AS te
	LEFT JOIN apartments AS ap
	ON te.tenant_id = ap.tenant_id
	LEFT JOIN buildings AS bu
	ON ap.building_id = bu.building_id
	LEFT JOIN transactions AS tr
	ON te.tenant_id = tr.tenant_id;

END;

-- We can now call the procedure with the below query whenever we need to

CALL rental_details_today('ok');


/* Thank you for coming with me on this journey
I hope you had as much fun as I did while working on this, learning is fun and continuous

You can find help on google and stack overflow if you find some of the queries difficult to comprehend, they are 'Beginner Queries' though */
