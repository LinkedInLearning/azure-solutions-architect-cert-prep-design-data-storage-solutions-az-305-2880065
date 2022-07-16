DROP TABLE IF EXISTS employees;
CREATE TABLE employees
(
	employee_name NVARCHAR(30) NOT NULL PRIMARY KEY,
    ssn NVARCHAR(11),
    salary MONEY
);
GO

INSERT INTO employees VALUES ('Employee One', '555-99-888',25000);
GO

INSERT INTO employees VALUES ('Employee Two', '555-44-555',26000);
GO

INSERT INTO employees VALUES ('Employee Three', '555-33-777',23000);
GO

INSERT INTO employees VALUES ('Employee Four', '555-22-999',29000);
GO

INSERT INTO employees VALUES ('Employee Five', '555-11-222',28000);
GO

SELECT * FROM employees;
GO

--View the  CMK
--SELECT * FROM sys.column_master_keys;

--View the CEK
--SELECT * FROM sys.column_encryption_keys;