CREATE OR ALTER PROCEDURE CreateFormulation
@seqType VarChar(20),
@componentName VarChar(300),
@componentVendor VarChar(100),
@pctByWeight Decimal(5,2),
@componentType VarChar(10),
@createdBy VarChar(60),
@lastRow VarChar(5),
@formCounter Int,
@formStatus VarChar(20),
@newFormID VarChar(60) = NULL OUTPUT

AS
SET NOCOUNT ON;
	Begin Tran "CreateFormulation";
		DECLARE @currentDate DATETIME;
		DECLARE @formPrefix VarChar(30);		

		SELECT @currentDate = SYSDATETIME(), /*@formCounter = sc.Counter + 1,*/ @formPrefix = sc.Prefix FROM SeqCounter sc WHERE sc.SeqType = @seqType;

		INSERT INTO FormulationComponents (Formulation_ID, Component, Manufacturer,Pct_By_Weight, Component_Type, Created_By, Created_Datetime)
		VALUES(CONCAT(@formPrefix, @formCounter), @componentName, @componentVendor, @pctByWeight, @componentType, @createdBy, @currentDate);		

		IF @lastRow = 'TRUE'
			Begin
				INSERT INTO Formulation (Formulation_ID, Formulation_Status)
				VALUES(CONCAT(@formPrefix, @formCounter), @formStatus);

				UPDATE SeqCounter SET Counter = @formCounter + 1 where SeqType = @seqType;
			End	
			
		SELECT @newFormID = Formulation_ID FROM FormulationComponents WHERE Formulation_ID = 	CONCAT(@formPrefix, @formCounter);

		IF @newFormID = CONCAT(@formPrefix, @formCounter)
			BEGIN
				COMMIT Tran "CreateFormulation";
			END
		ELSE
			BEGIN
				ROLLBACK Tran "CreateFormulation";
				SELECT 'Failed to add Formulation' as newFormID
			END
;
--commit
RETURN