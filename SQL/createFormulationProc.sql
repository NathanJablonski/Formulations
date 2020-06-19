CREATE OR ALTER PROCEDURE CreateFormulation
@seqType VarChar(20),
@universalID VarChar(10),
@componentName VarChar(300),
@componentVendor VarChar(100),
@pctByWeight Decimal(5,2),
@type VarChar(10),
@createdBy VarChar(60),
@lastRow VarChar(5),
@formCounter Int,
@formStatus VarChar(20),
@newFormID VarChar(10) = NULL OUTPUT

AS
SET NOCOUNT ON;
	Begin Tran "CreateFormulation";
		DECLARE @formCounter INT;
		DECLARE @currentDate DATETIME;
		DECLARE @formPrefix VarChar(30);

		SELECT @currentDate = SYSDATETIME(), /*@formCounter = sc.Counter + 1,*/ @formPrefix = sc.Prefix FROM SeqCounter sc WHERE sc.SeqType = @seqType;

		INSERT INTO FormulationComponents (Formulation_ID, Component, Manufacturer,Pct_By_Weight, Formulation_Type, Created_By, Created_Datetime)
		VALUES(CONCAT(@formPrefix, @formCounter), @componentName, @componentVendor, @pctByWeight, @type, @createdBy, @currentDate);

		INSERT INTO Formulation (Formulation_ID, Formulation_Status)
		VALUES(CONCAT(@formPrefix, @formCounter), @formStatus);

		IF @lastRow = "TRUE"
			Begin
				UPDATE SeqCounter SET Counter = @formCounter + 1 where SeqType = @seqType;
			End		
;
commit