/*Inside your stored procedure, write a SQL IF statement to update the Leaders_Icon field in the CHICAGO_PUBLIC_SCHOOLS table for the school identified 
by in_School_ID using the following information.*/

delimiter @
CREATE PROCEDURE UPDATE_LEADERS_SCORE ( IN in_School_ID INTEGER, IN in_Leader_Score INTEGER ) 

MODIFIES SQL DATA  

BEGIN

	UPDATE chicago_public_schools
    SET Leaders_Score = in_Leader_Score
    WHERE in_School_ID = School_ID;

	IF in_Leader_Score > 0 AND in_Leader_Score < 20 THEN
		UPDATE chicago_public_schools
        SET Leaders_Icon = 'Very Weak'
        WHERE in_School_ID = School_ID;

	ELSEIF in_Leader_Score BETWEEN 20 AND  39 THEN
		UPDATE chicago_public_schools
		SET Leaders_Icon = 'Weak'
		WHERE in_School_ID = School_ID;
        
	ELSEIF in_Leader_Score BETWEEN 40 AND  59 THEN
		UPDATE chicago_public_schools
		SET Leaders_Icon = 'Average'
		WHERE in_School_ID = School_ID;
        
	ELSEIF in_Leader_Score BETWEEN 60 AND  79 THEN
		UPDATE chicago_public_schools
		SET Leaders_Icon = 'Strong'
        WHERE in_School_ID = School_ID;

	ELSEIF in_Leader_Score BETWEEN 80 AND 99 THEN
		UPDATE chicago_public_schools
		SET Leaders_Icon = 'Very Strong'
        WHERE in_School_ID = School_ID;

    ELSE
		ROLLBACK;

END IF;
		COMMIT WORK;
  
END
