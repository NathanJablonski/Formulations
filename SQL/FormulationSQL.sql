--Create stored procedure for creating new Formulation
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
				INSERT INTO Formulation (Formulation_ID, Formulation_Status, createdby, createdt, Audit_Sequence)
				VALUES(CONCAT(@formPrefix, @formCounter), @formStatus, @createdBy, @currentDate, 1);

				UPDATE SeqCounter SET Counter = @formCounter + 1 where SeqType = @seqType;
			End	
			
		SELECT @newFormID = Formulation_ID FROM FormulationComponents WHERE Formulation_ID = 	CONCAT(@formPrefix, @formCounter);

		IF @newFormID = CONCAT(@formPrefix, @formCounter)
			BEGIN
				COMMIT Tran "CreateFormulation";
				SELECT @newFormID as newFormID
			END
		ELSE
			BEGIN
				ROLLBACK Tran "CreateFormulation";
				SELECT 'Failed to add Formulation' as newFormID
			END
;
	commit
	
	
Create Table Formulation(
	Formulation_ID VarChar(50) NOT NULL Primary Key,
	Formulation_Status VarChar(50),
	Parent_Formulation VarChar(50),
	Flag VarChar(50),
	SForm VarChar(50),
	Approval_1 VarChar(50),
	Approval_1_Date date,
	Approval_1_Notes VarChar(200),
	Notes VarChar(200),
	createdby VarChar(50),
	createdt datetime,
	modby VarChar(50),
	moddt datetime,
	Audit_Sequence INT
);

Create Table FormulationAudit(
	Formulation_ID VarChar(50) NOT NULL,
	Formulation_Status VarChar(50),
	Parent_Formulation VarChar(50),
	Flag VarChar(50),
	SForm VarChar(50),
	Approval_1 VarChar(50),
	Approval_1_Date date,
	Approval_1_Notes VarChar(200),
	Notes VarChar(200),
	createdby VarChar(50),
	createdt datetime,
	modby VarChar(50),
	moddt datetime,
	Audit_Sequence INT
	PRIMARY KEY(Formulation_ID,Audit_Sequence)
);

--Trigger for updating FormulationAudit table
BEGIN TRANSACTION
GO
Alter trigger FormulationAuditTigger on Formulation
	after Insert, update
	as
	BEGIN
		INSERT into FormulationAudit
		select i.* from Formulation f
				inner join inserted i on f.Formulation_ID = i.Formulation_ID

	End
GO
Commit TRANSACTION	

Create Table ChemicalInventory(
	Chemical_ID INT NOT NULL PRIMARY KEY,
	Chemical_Name VarChar(200) NOT NULL,
	Quantity INT,
	Manufacturer VarChar(50),
	Catalog_Number VarChar(50),
	Chemical_Description VarChar(200),
	Location VarChar(50),
	Receipt_Date date,
	Open_Date date,
	Expiration_Date date,
	Active VarChar(1)
);

Create Table FormulationComponents(
	Formulation_ID VarChar(50) NOT NULL,
	Component VarChar(100),
	Manufacturer VarChar(100),
	Pct_By_Weight Decimal(6,3) NOT NULL,
	Component_Type VarChar(50),
	Created_By VarChar(100),
	Created_Datetime DATETIME
	PRIMARY KEY(Formulation_ID, Component, Manufacturer)
);