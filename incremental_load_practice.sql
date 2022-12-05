-- data from source ([Sales].[Customer])
-- moving to an operational datastore (etl schema) etl.Temp_Sales_Customer
-- create a stored procedure

-- use AdventureWorks2019;
/*
create schema etl;

select * 
into etl.Temp_Sales_Customer
from Sales.Customer
where 1 = 0;

select * from etl.Temp_Sales_Customer
*/

/*
ALTER TABLE etl.Temp_Sales_Customer
ADD date_run_etl DATETIME;
*/

/* CREATE SEQUENCE [etl].[n_seq]  AS [bigint] START WITH 1 INCREMENT BY 1 MINVALUE 1 MAXVALUE 10000 CYCLE -- start again once max value is reached NO CACHE;
 */

 /*CREATE TABLE etl.process_log_hdr(	[process_sequence] [int] NULL,	[process_name] [varchar](100) NULL,	[reference_id] [INT] NULL,	[status] [varchar](50) NULL,	[message] [varchar](500) NULL,	[row_count] [int] NULL,	[start_date] [datetime] NULL,	[end_date] [datetime] NULL,	[duration] [numeric](18, 0) NULL);	*/CREATE OR ALTER PROCEDURE [etl].[prc_incremental_load] (@TerritoryID INT)
AS
BEGIN

DECLARE @v_seq FLOAT;
DECLARE @v_rows_count FLOAT;
DECLARE @v_message VARCHAR;

SET NOCOUNT ON -- don't return row count

SELECT @v_seq = NEXT VALUE FOR n_seq;

insert into etl.process_log_hdr(process_sequence, process_name, reference_id, 		status, message, row_count, start_date, end_date, duration)values(@v_seq, 'prc_incremental_load', @TerritoryID, 'STARTED', null, 0 , 	getdate(), null, null);insert into etl.Temp_Sales_Customer(CustomerID, PersonID, StoreID, 
			TerritoryID, AccountNumber, rowguid, ModifiedDate, date_run_etl)
select *, getdate()
FROM Sales.Customer
WHERE TerritoryID = @TerritoryID
SET @v_rows_count = @@ROWCOUNT;

UPDATE etl.process_log_hdrSET status = 'COMPLETED',	message = 'Completed Successfully',    row_count = @v_rows_count,    end_date = getdate(),    duration = DATEDIFF(millisecond,start_date,end_date)    WHERE process_sequence = @v_seq;
END;
