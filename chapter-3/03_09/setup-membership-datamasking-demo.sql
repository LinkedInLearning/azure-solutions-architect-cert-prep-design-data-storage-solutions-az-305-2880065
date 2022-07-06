--Create two contained user for your database, these should be the UPNs for the two test users
CREATE USER [<Azure_AD_principal_name>] FROM EXTERNAL PROVIDER;
CREATE USER [<Azure_AD_principal_name>] FROM EXTERNAL PROVIDER;

-- Create a table
CREATE TABLE membership(
    memberid        int IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
    firstname        varchar(100) NULL,
    lastname        varchar(100) NOT NULL,
    phone            varchar(12)  NULL,
    email            varchar(100)  NOT NULL,
    discountcode    smallint NULL
    );

--Grant select on the table to the two test users
GRANT SELECT ON membership TO [<Azure_AD_principal_name>]; 
GRANT SELECT ON membership TO [<Azure_AD_principal_name>]; 


-- inserting sample data
INSERT INTO membership (firstname, lastname, phone, email, discountcode)
VALUES   
('Member', 'One', '555.123.4567', 'memone@email.com', 10),  
('Member', 'Two', '555.123.4568', 'memtwo@email.com.co', 5),  
('Member', 'Three', '555.123.4570', 'memthree@email.net', 50),  
('Member', 'Four', '555.123.4569', 'memfour@email.net', 40);  

--check the sample data
select * from membership;

--Grant UNMASK to the user who is in a supervisory role
GRANT UNMASK TO [<Azure_AD_principal_name>]; 

--Set firstname as a partial mask of two characters at the beginning
ALTER TABLE membership  
ALTER COLUMN firstname ADD MASKED WITH (FUNCTION = 'partial(2,"xxxx",0)');  

--Set phone as a default full mask
ALTER TABLE membership  
ALTER COLUMN phone ADD MASKED WITH (FUNCTION = 'default()');  

--Set email to show one character at the beginning and the suffix of the domain
ALTER TABLE membership  
ALTER COLUMN email ADD MASKED WITH (FUNCTION = 'email()');  

--Set discountcode as random, which will randomize any number
ALTER TABLE membership  
ALTER COLUMN discountcode ADD MASKED WITH (FUNCTION = 'random(1, 100)');  

--Check what the users can see
EXECUTE AS USER = '<Azure_AD_principal_name>';  
SELECT * FROM membership;  
REVERT;   
EXECUTE AS USER = '<Azure_AD_principal_name>';  
SELECT * FROM membership;  
REVERT; 

--Can still execute searches against masked data.
EXECUTE AS USER = '<Azure_AD_principal_name>';  
SELECT * FROM membership where firstname = 'Member' and lastname = 'Four';  
REVERT; 

