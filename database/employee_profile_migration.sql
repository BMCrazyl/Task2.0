/*
  Employee personal profile and avatar migration.
  Safe to run repeatedly on existing Task Manager databases.
  Profile data is stored on dbo.Employee so the employee and admin screens
  always read and write the same record.
*/
IF OBJECT_ID(N'dbo.Employee', N'U') IS NULL
BEGIN
    THROW 50001, 'dbo.Employee must exist before running this migration.', 1;
END;
GO

IF COL_LENGTH(N'dbo.Employee', N'family_name') IS NULL ALTER TABLE dbo.Employee ADD family_name NVARCHAR(100) NULL;
IF COL_LENGTH(N'dbo.Employee', N'given_name') IS NULL ALTER TABLE dbo.Employee ADD given_name NVARCHAR(100) NULL;
IF COL_LENGTH(N'dbo.Employee', N'date_of_birth') IS NULL ALTER TABLE dbo.Employee ADD date_of_birth DATE NULL;
IF COL_LENGTH(N'dbo.Employee', N'identity_number') IS NULL ALTER TABLE dbo.Employee ADD identity_number NVARCHAR(30) NULL;
IF COL_LENGTH(N'dbo.Employee', N'region') IS NULL ALTER TABLE dbo.Employee ADD region NVARCHAR(150) NULL;
IF COL_LENGTH(N'dbo.Employee', N'permanent_address') IS NULL ALTER TABLE dbo.Employee ADD permanent_address NVARCHAR(500) NULL;
IF COL_LENGTH(N'dbo.Employee', N'bank_name') IS NULL ALTER TABLE dbo.Employee ADD bank_name NVARCHAR(150) NULL;
IF COL_LENGTH(N'dbo.Employee', N'bank_account_number') IS NULL ALTER TABLE dbo.Employee ADD bank_account_number NVARCHAR(50) NULL;
IF COL_LENGTH(N'dbo.Employee', N'avatar_content_type') IS NULL ALTER TABLE dbo.Employee ADD avatar_content_type VARCHAR(50) NULL;
IF COL_LENGTH(N'dbo.Employee', N'avatar_data') IS NULL ALTER TABLE dbo.Employee ADD avatar_data VARBINARY(MAX) NULL;
IF COL_LENGTH(N'dbo.Employee', N'account_id') IS NULL ALTER TABLE dbo.Employee ADD account_id INT NULL;
GO

UPDATE dbo.Employee
SET family_name =
    CASE WHEN NULLIF(LTRIM(RTRIM(family_name)), N'') IS NOT NULL THEN family_name
         WHEN CHARINDEX(N' ', LTRIM(RTRIM(ISNULL(name, N'')))) > 0
         THEN LEFT(LTRIM(RTRIM(name)), LEN(LTRIM(RTRIM(name))) - CHARINDEX(N' ', REVERSE(LTRIM(RTRIM(name)))))
         ELSE LTRIM(RTRIM(ISNULL(name, N''))) END,
    given_name =
    CASE WHEN NULLIF(LTRIM(RTRIM(given_name)), N'') IS NOT NULL THEN given_name
         WHEN CHARINDEX(N' ', LTRIM(RTRIM(ISNULL(name, N'')))) > 0
         THEN RIGHT(LTRIM(RTRIM(name)), CHARINDEX(N' ', REVERSE(LTRIM(RTRIM(name)))) - 1)
         ELSE N'' END
WHERE family_name IS NULL OR given_name IS NULL;
GO

IF OBJECT_ID(N'dbo.Account', N'U') IS NOT NULL
BEGIN
    UPDATE e
       SET account_id = a.id
      FROM dbo.Employee e
      JOIN dbo.Account a ON LTRIM(RTRIM(a.fullname)) = LTRIM(RTRIM(e.name))
     WHERE e.account_id IS NULL
       AND (SELECT COUNT(*) FROM dbo.Account aa WHERE LTRIM(RTRIM(aa.fullname))=LTRIM(RTRIM(e.name))) = 1
       AND (SELECT COUNT(*) FROM dbo.Employee ee WHERE LTRIM(RTRIM(ee.name))=LTRIM(RTRIM(e.name))) = 1;
END;
GO
