CREATE OR ALTER PROCEDURE [etl].[prc_full_load]
AS
BEGIN

DECLARE @v_seq FLOAT;
DECLARE @v_rows_count FLOAT;
DECLARE @v_message VARCHAR;

SET NOCOUNT ON -- don't return row count

SELECT @v_seq = NEXT VALUE FOR n_seq;

insert into etl.process_log_hdr(process_sequence, process_name, reference_id, 		status, message, row_count, start_date, end_date, duration)values(@v_seq, 'prc_full_load', 30 , 'STARTED', null, 0 , 	getdate(), null, null);/*select * into etl.Temp_Sales_Customer2from etl.Temp_Sales_Customerwhere 1 = 0*/TRUNCATE TABLE etl.Temp_Sales_Customer2;insert into etl.Temp_Sales_Customer2(CustomerID, PersonID, StoreID, 
			TerritoryID, AccountNumber, rowguid, ModifiedDate, date_run_etl)
select *, getdate()
FROM Sales.Customer

SET @v_rows_count = @@ROWCOUNT;

UPDATE etl.process_log_hdrSET status = 'COMPLETED',	message = 'Completed Successfully',    row_count = @v_rows_count,    end_date = getdate(),    duration = DATEDIFF(millisecond,start_date,end_date)    WHERE process_sequence = @v_seq;
END;