
codeunit 99001 "PTE Get Metadata"
{
    TableNo = "PTE SQL Database";

    trigger OnRun()
    begin
        if Rec."Metadata Exists" then
            if not Confirm(DBASchemaExistsConfMsg, FALSE, rec."Code") then
                exit;

        GetDBForbiddenChars(Rec);//
        GetDatabaseSchema(Rec);//
        GetSQLTablesNumberOfRows(Rec);//
        GetInstalledApps(Rec);//
        GetAppVersion(Rec);//
        GetObjectsMetadata(Rec);//
        GetObjectNamesAndAppID(Rec);//
        if not CheckIfTableNamesAreUnique(Rec) then
            exit;
        GetAllObjectDetail(Rec);
        FindSQLTableNames(Rec);
        GetCompanyNames(Rec);
        Rec."Metadata Exists" := true;
        Rec.Modify();
        Message(DownloadingCompletedMsg);
    end;

    var
        DBASchemaExistsConfMsg: Label 'The metadata for the %1 database has already been downloaded. Do you want to delete existing data and download again?', Comment = '%1 = Database Code';
        DownloadingDataMsg: Label 'Processing - Step 1 of 7\Downloading tables and fields schema from %1 database.\No Of Records: %2', Comment = '%1 = Database Code, %2 = No Of Records';
        DownloadingInstalledAppsMsg: Label 'Processing - Step 2 of 7\Downloading Installed Apps from %1 database.\No Of Records: %2', Comment = '%1 = Database Code, %2 = No Of Records';
        DownloadingAppObjMsg: Label 'Processing - Step 3 of 7\Downloading Application Objects from %1 database.\No Of Records: %2', Comment = '%1 = Database Code, %2 = No Of Records';
        DownloadingMetaDataMsg1: Label 'Processing - Step 4 of 7\Downloading object names and related APP - database: %1.\No Of Objects: %2', Comment = '%1 = Database code, %2 = Number of objects';
        CheckingDuplicates: Label 'Processing - Step 5 of 7\Checking duplicates in downloaded data - database: %1.\No Of Objects: %2', Comment = '%1 = Database code, %2 = Number of objects';
        DownloadingMetaDataMsg: Label 'Processing - Step 5 of 7\Downloading metadata from %1 database.\No Of Objects: %2', Comment = '%1 = Database code, %2 = Number of objects';
        FindingSQLTableNamesMsg: Label 'Processing - Step 6 of 7\Finding SQL table names for data from  %1 database.\No Of Tables: %2', Comment = '%1 = Database code, %2 = Number of Tables';
        DownloadingCompanyNamesMsg: Label 'Processing - Step 7 of 7\Downloading company names from  %1 database.', Comment = '%1 = Database code';
        DownloadingCompletedMsg: Label 'Download completed.';





        DuplicatedTableNamesMsg: Label 'Duplicate table names from different applications were detected. Data Migration Tool does not cover such cases. Select the tables you do not want to include in the migration process and add them to the skipped objects. Then download the metadata again.';

    local procedure GetDatabaseSchema(var PTESQLDatabase: Record "PTE SQL Database")
    var
        PTESQLDatabaseTableField: Record "PTE SQL Database Table Field";
        PTESQLDatabaseTable: Record "PTE SQL Database Table";
        Matches: Record Matches;
        RegEx: Codeunit Regex;
        SQLConnection: DotNet SqlConnection;
        SQLCommand: DotNet SqlCommand;
        SQLReader: DotNet SqlDataReader;
        SQLQueryText: Text;
        SQLQueryText2: Text;
        SQLQueryText3: Text;
        SQLQueryText4: Text;
        FieldEntryNo: Integer;
        TableEntryNo: Integer;
        NumberOfColumns: Integer;
        NumberOfTables: Integer;
        NumberOfRecords: Integer;
        DialogProgress: Dialog;
        ProgressTotal: Integer;
        CurrentProgress: Integer;
        ConnectionString: Text;
        TableName: Text;


        Pattern: Text;
    begin
        //Build SQL queries to run
        SQLQueryText := 'SELECT COUNT([TABLE_CATALOG]) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_CATALOG = ''' + PTESQLDatabase."Database Name" + '''';
        SQLQueryText2 := 'SELECT [TABLE_CATALOG],[TABLE_SCHEMA],[TABLE_NAME],[COLUMN_NAME],[ORDINAL_POSITION],[DATA_TYPE],CONVERT(varchar,[CHARACTER_MAXIMUM_LENGTH]) as [CHARACTER_MAXIMUM_LENGTH],CONVERT(varchar,[CHARACTER_OCTET_LENGTH])as [CHARACTER_OCTET_LENGTH], [IS_NULLABLE], CONVERT(varchar, [COLUMN_DEFAULT]) AS [COLUMN_DEFAULT], COLUMNPROPERTY(OBJECT_ID(TABLE_NAME), COLUMN_NAME, ''IsIdentity'') as [AUTOINCREMENT], [COLLATION_NAME], [CHARACTER_SET_NAME] FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_CATALOG=''' + PTESQLDatabase."Database Name" + '''';
        SQLQueryText3 := 'SELECT COUNT([TABLE_CATALOG]) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_CATALOG = ''' + PTESQLDatabase."Database Name" + '''';
        SQLQueryText4 := 'SELECT [TABLE_CATALOG],[TABLE_SCHEMA],[TABLE_NAME],[TABLE_TYPE] FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_CATALOG = ''' + PTESQLDatabase."Database Name" + '''';
        ConnectionString := PTESQLDatabase.GetDatabaseConnectionString();

        //Get number of records
        SQLConnection := SQLConnection.SqlConnection(ConnectionString);
        SQLConnection.Open();

        SQLCommand := SQLCommand.SqlCommand(SQLQueryText, SQLConnection);
        SQLCommand.CommandTimeout := 10 * 60 * 100; // 10 min.

        SQLReader := SQLCommand.ExecuteReader();
        SQLReader.Read();
        EVALUATE(NumberOfColumns, FORMAT(SQLReader.GetValue(0)));
        SQLConnection.Close();

        SQLConnection := SQLConnection.SqlConnection(ConnectionString);
        SQLConnection.Open();

        SQLCommand := SQLCommand.SqlCommand(SQLQueryText3, SQLConnection);
        SQLCommand.CommandTimeout := 10 * 60 * 100; // 10 min.
        SQLReader := SQLCommand.ExecuteReader();
        SQLReader.Read();
        EVALUATE(NumberOfTables, FORMAT(SQLReader.GetValue(0)));
        SQLConnection.Close();

        NumberOfRecords := NumberOfTables + NumberOfColumns;

        SQLConnection.Close();
        //Delete data if exists
        PTESQLDatabaseTableField.SETRANGE("SQL Database Code", PTESQLDatabase."Code");
        PTESQLDatabaseTable.SETRANGE("SQL Database Code", PTESQLDatabase."Code");
        PTESQLDatabaseTableField.DeleteAll();
        PTESQLDatabaseTable.DeleteAll();


        //Open progress bar
        CurrentProgress := 0;
        ProgressTotal := NumberOfRecords;
        DialogProgress.OPEN(STRSUBSTNO(DownloadingDataMsg, PTESQLDatabase."Code", ProgressTotal) + ': #1#####', CurrentProgress);

        //Download schema data
        SQLConnection := SQLConnection.SqlConnection(ConnectionString);
        SQLConnection.Open();

        //Download Columns

        SQLCommand := SQLCommand.SqlCommand(SQLQueryText2, SQLConnection);
        SQLCommand.CommandTimeout := 10 * 60 * 100; // 10 min.
        SQLReader := SQLCommand.ExecuteReader();

        FieldEntryNo := 0;
        //Read columns data and put to the SQLColumns table
        while SQLReader.Read() do begin
            FieldEntryNo := FieldEntryNo + 1;
            PTESQLDatabaseTableField.init();
            PTESQLDatabaseTableField."SQL Database Code" := PTESQLDatabase."Code";
            PTESQLDatabaseTableField."Entry No." := FieldEntryNo;
            //[TABLE_CATALOG]
            if not SQLReader.IsDBNull(0) then
                PTESQLDatabaseTableField."Table Catalog" := SQLReader.GetString(0);
            //[TABLE_SCHEMA]
            if not SQLReader.IsDBNull(1) then
                PTESQLDatabaseTableField."Table Schema" := SQLReader.GetString(1);
            //[TABLE_NAME]
            if not SQLReader.IsDBNull(2) then
                PTESQLDatabaseTableField."Table Name" := SQLReader.GetString(2);
            //[COLUMN_NAME]
            if not SQLReader.IsDBNull(3) then
                PTESQLDatabaseTableField."Column Name" := SQLReader.GetString(3);
            //[ORDINAL_POSITION]
            if not SQLReader.IsDBNull(4) then
                PTESQLDatabaseTableField."Ordinal Position" := GetInteger(Format(SQLReader.GetValue(4)));
            //[DATA_TYPE]
            if not SQLReader.IsDBNull(5) then
                PTESQLDatabaseTableField."Data Type" := SQLReader.GetString(5);
            //[CHARACTER_MAXIMUM_LENGTH]
            if not SQLReader.IsDBNull(6) then
                PTESQLDatabaseTableField."Character Maximum Length" := GetInteger(SQLReader.GetString(6));
            //[CHARACTER_OCTET_LENGTH]
            if not SQLReader.IsDBNull(7) then
                PTESQLDatabaseTableField."Character Octet Lenght" := GetInteger(SQLReader.GetString(7));
            if not SQLReader.IsDBNull(8) then
                PTESQLDatabaseTableField."Allow Nulls" := GetBoolean(Format(SQLReader.GetValue(8)));
            //[COLUMN_DEFAULT]
            if not SQLReader.IsDBNull(9) then
                PTESQLDatabaseTableField."Column Default" := FORMAT(SQLReader.GetString(9))
            else
                PTESQLDatabaseTableField."Column Default" := '#NULL#';
            //[AUTOINCREMENT]
            if not SQLReader.IsDBNull(10) then
                if GetInteger(Format(SQLReader.GetValue(10))) > 0 then
                    PTESQLDatabaseTableField.Autoincrement := true
                else
                    PTESQLDatabaseTableField.Autoincrement := false;
            //[COLLATION_NAME] 
            if not SQLReader.IsDBNull(11) then
                PTESQLDatabaseTableField."Collation Name" := SQLReader.GetString(11);
            //[CHARACTER_SET_NAME]
            if not SQLReader.IsDBNull(12) then
                PTESQLDatabaseTableField."Character Set Name" := SQLReader.GetString(12);
            PTESQLDatabaseTableField.insert();
            //update progress bar
            CurrentProgress := CurrentProgress + 1;
            DialogProgress.Update(1, CurrentProgress);
        end;
        SQLConnection.Close();
        //Download Tables

        SQLConnection := SQLConnection.SqlConnection(ConnectionString);
        SQLConnection.Open();

        SQLCommand := SQLCommand.SqlCommand(SQLQueryText4, SQLConnection);
        SQLCommand.CommandTimeout := 10 * 60 * 100; // 10 min.
        SQLReader := SQLCommand.ExecuteReader();

        TableEntryNo := 0;

        //Read columns data and put to the SQLColumns table
        while SQLReader.Read() do begin

            TableEntryNo := TableEntryNo + 1;
            PTESQLDatabaseTable.INIT();
            PTESQLDatabaseTable."SQL Database Code" := PTESQLDatabase."Code";
            ;
            PTESQLDatabaseTable."Entry No." := TableEntryNo;
            //[TABLE_CATALOG]
            if not SQLReader.IsDBNull(0) then
                PTESQLDatabaseTable."Table Catalog" := SQLReader.GetString(0);
            //[TABLE_SCHEMA]
            if not SQLReader.IsDBNull(1) then
                PTESQLDatabaseTable."Table Schema" := SQLReader.GetString(1);
            //[TABLE_NAME]
            if not SQLReader.IsDBNull(2) then
                PTESQLDatabaseTable."Table Name" := SQLReader.GetString(2);
            //[TABLE_TYPE]
            if not SQLReader.IsDBNull(3) then
                PTESQLDatabaseTable."Table Type" := SQLReader.GetString(3);
            TableName := PTESQLDatabaseTable."Table Name";
            Pattern := '[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}';
            RegEx.Match(TableName, Pattern, Matches);
            PTESQLDatabaseTable."App ID" := CopyStr(UPPERCASE(FORMAT(Matches.ReadValue())), 1, MaxStrLen(PTESQLDatabaseTable."App ID"));
            PTESQLDatabaseTable.Insert();

            //update progress bar
            CurrentProgress := CurrentProgress + 1;
            DialogProgress.UPDATE(1, CurrentProgress);
        end;

        DialogProgress.CLOSE();
        SQLConnection.Close();
    end;

    local procedure GetCompanyNames(var PTESQLDatabase: Record "PTE SQL Database")
    var
        PTESQLDatabaseCompany: Record "PTE SQL Database Company";
        SQLConnection: DotNet SqlConnection;
        SQLCommand: DotNet SqlCommand;
        SQLReader: DotNet SqlDataReader;
        SQLQueryText: Text;
        ConnectionString: Text;
        DialogProgress: Dialog;
    begin
        DialogProgress.OPEN(STRSUBSTNO(DownloadingCompanyNamesMsg, PTESQLDatabase.Code));
        //Build SQL queries to run
        SQLQueryText := 'SELECT [Name] FROM [dbo].[Company]';

        //Delete data if exists
        PTESQLDatabaseCompany.SetRange("SQL Database Code", PTESQLDatabase."Code");
        PTESQLDatabaseCompany.DeleteAll();


        //Download company names
        ConnectionString := PTESQLDatabase.GetDatabaseConnectionString();
        SQLConnection := SQLConnection.SqlConnection(ConnectionString);
        SQLConnection.Open();

        SQLCommand := SQLCommand.SqlCommand(SQLQueryText, SQLConnection);
        SQLCommand.CommandTimeout := 10 * 60 * 100; // 10 min.
        SQLReader := SQLCommand.ExecuteReader();

        //Read columns data and put to the SQLColumns table
        While SQLReader.Read() do begin
            PTESQLDatabaseCompany.Init();
            PTESQLDatabaseCompany."SQL Database Code" := PTESQLDatabase."Code";
            //[Name]
            PTESQLDatabaseCompany.Name := SQLReader.GetValue(0);
            //SQL Name
            PTESQLDatabaseCompany."SQL Name" := CopyStr(GetSQLName(PTESQLDatabase, PTESQLDatabaseCompany.Name), 1, MaxStrLen(PTESQLDatabaseCompany.Name));
            PTESQLDatabaseCompany.Insert();
        end;
        SQLConnection.Close();
        DialogProgress.Close();
    end;

    local procedure GetAppVersion(var PTESQLDatabase: Record "PTE SQL Database")
    var
        SQLConnection: DotNet SqlConnection;
        SQLCommand: DotNet SqlCommand;
        SQLReader: DotNet SqlDataReader;
        SQLQueryText: Text;
        ConnectionString: Text;
    begin
        if not (DatabaseFieldExists(PTESQLDatabase."Code", '$ndo$dbproperty', 'applicationversion') and DatabaseFieldExists(PTESQLDatabase."Code", '$ndo$dbproperty', 'applicationfamily')) then
            exit;
        SQLQueryText := 'SELECT TOP (1) [applicationversion], [applicationfamily] FROM [dbo].[$ndo$dbproperty]';
        ConnectionString := PTESQLDatabase.GetDatabaseConnectionString();
        SQLConnection := SQLConnection.SqlConnection(ConnectionString);
        SQLConnection.Open();
        SQLCommand := SQLCommand.SqlCommand(SQLQueryText, SQLConnection);
        SQLCommand.CommandTimeout := 10 * 60 * 100; // 10 min.
        SQLReader := SQLCommand.ExecuteReader();

        WHILE SQLReader.Read() DO BEGIN
            //[applicationversion]
            PTESQLDatabase."Application Version" := FORMAT(SQLReader.GetValue(0));
            //[applicationfamily]
            PTESQLDatabase."Application Family" := FORMAT(SQLReader.GetValue(1));
            PTESQLDatabase.Modify();
        end;
        SQLConnection.Close();
    end;

    local procedure GetInstalledApps(var PTESQLDatabase: Record "PTE SQL Database")
    var
        PTESQLDatabaseInstalledApps: Record "PTE SQL Database Installed App";
        SQLConnection: DotNet SqlConnection;
        SQLCommand: DotNet SqlCommand;
        SQLReader: DotNet SqlDataReader;
        SQLQueryText: Text;
        SQLQueryText2: Text;
        NumberOfRecords: Integer;
        DialogProgress: Dialog;
        ProgressTotal: Integer;
        CurrentProgress: Integer;
        ConnectionString: Text;
    begin
        //Delete data if exists
        PTESQLDatabaseInstalledApps.SetRange("SQL Database Code", PTESQLDatabase."Code");
        PTESQLDatabaseInstalledApps.DeleteAll();
        //Check if NAV App Installed App table exists
        if not DatabaseTableExists(PTESQLDatabase."Code", 'NAV App Installed App') then
            exit;

        //Build SQL queries to run
        SQLQueryText := 'SELECT COUNT([App ID]) FROM [dbo].[NAV App Installed App]';
        SQLQueryText2 := 'SELECT [App ID],[Package ID],[Name],[Publisher],[Version Major],[Version Minor],[Version Build],[Version Revision]';
        if DatabaseFieldExists(PTESQLDatabase."Code", 'NAV App Installed App', '$systemId') then
            SQLQueryText2 := SQLQueryText2 + ',[$systemId]';
        SQLQueryText2 := SQLQueryText2 + ' FROM[dbo].[NAV App Installed App]';
        ConnectionString := PTESQLDatabase.GetDatabaseConnectionString();

        //Get number of records
        SQLConnection := SQLConnection.SqlConnection(ConnectionString);
        SQLConnection.Open();

        SQLCommand := SQLCommand.SqlCommand(SQLQueryText, SQLConnection);
        SQLCommand.CommandTimeout := 10 * 60 * 100; // 10 min.
        SQLReader := SQLCommand.ExecuteReader();
        SQLReader.Read();
        EVALUATE(NumberOfRecords, Format(SQLReader.GetValue(0)));
        SQLConnection.Close();



        //Open progress bar
        CurrentProgress := 0;
        ProgressTotal := NumberOfRecords;
        DialogProgress.Open(STRSUBSTNO(DownloadingInstalledAppsMsg, PTESQLDatabase."Code", ProgressTotal) + ': #1#####', CurrentProgress);


        //Download installed apps data data
        SQLConnection := SQLConnection.SqlConnection(ConnectionString);
        SQLConnection.Open();
        SQLCommand := SQLCommand.SqlCommand(SQLQueryText2, SQLConnection);
        SQLCommand.CommandTimeout := 10 * 60 * 100; // 10 min.
        SQLReader := SQLCommand.ExecuteReader();

        //Read columns data and put to the SQLColumns table
        WHILE SQLReader.Read() DO BEGIN
            PTESQLDatabaseInstalledApps.Init();
            PTESQLDatabaseInstalledApps."SQL Database Code" := PTESQLDatabase."Code";

            //[App ID]
            PTESQLDatabaseInstalledApps."ID" := CopyStr(UPPERCASE(FORMAT(SQLReader.GetValue(0))), 1, MaxStrLen(PTESQLDatabaseInstalledApps."ID"));
            PTESQLDatabaseInstalledApps."ID" := DELCHR(PTESQLDatabaseInstalledApps."ID", '=', '{}');
            //[Package ID]
            PTESQLDatabaseInstalledApps."Package ID" := FORMAT(SQLReader.GetValue(1));
            PTESQLDatabaseInstalledApps."Package ID" := DELCHR(PTESQLDatabaseInstalledApps."Package ID", '=', '{}');
            //[Name]
            PTESQLDatabaseInstalledApps.Name := SQLReader.GetValue(2);
            //[Publisher]
            PTESQLDatabaseInstalledApps.Publisher := SQLReader.GetValue(3);
            //[Version Major]
            if not SQLReader.IsDBNull(4) then
                PTESQLDatabaseInstalledApps."Version Major" := GetInteger(FORMAT(SQLReader.GetValue(4)));
            //[Version Minor]
            if not SQLReader.IsDBNull(5) then
                PTESQLDatabaseInstalledApps."Version Major" := GetInteger(FORMAT(SQLReader.GetValue(5)));
            //[Version Build]
            if not SQLReader.IsDBNull(6) then
                PTESQLDatabaseInstalledApps."Version Build" := GetInteger(FORMAT(SQLReader.GetValue(6)));
            //[Version Revision]
            if not SQLReader.IsDBNull(7) then
                PTESQLDatabaseInstalledApps."Version Revision" := GetInteger(FORMAT(SQLReader.GetValue(7)));
            //[$systemId]
            if DatabaseFieldExists(PTESQLDatabase."Code", 'NAV App Installed App', '$systemId') then begin
                PTESQLDatabaseInstalledApps."System ID" := FORMAT(SQLReader.GetValue(8));
                PTESQLDatabaseInstalledApps."System ID" := DELCHR(PTESQLDatabaseInstalledApps."System ID", '=', '{}');
            end;
            PTESQLDatabaseInstalledApps.Insert();

            //update progress bar
            CurrentProgress := CurrentProgress + 1;
            DialogProgress.Update();
        end;
        SQLConnection.Close();
        DialogProgress.Close();
    end;

    local procedure DatabaseFieldExists(SQLDatabaseCode: code[20]; TableName: Text; FieldName: Text): Boolean
    var
        PTESQLDatabaseTableField: record "PTE SQL Database Table Field";
    begin
        PTESQLDatabaseTableField.SetRange("SQL Database Code", SQLDatabaseCode);
        PTESQLDatabaseTableField.SetRange("Table Name", TableName);
        PTESQLDatabaseTableField.SetRange("Column Name", FieldName);
        exit(not PTESQLDatabaseTableField.IsEmpty);
    end;

    local procedure DatabaseTableExists(SQLDatabaseCode: code[20]; TableName: Text): Boolean
    var
        PTESQLDatabaseTable: Record "PTE SQL Database Table";
    begin
        PTESQLDatabaseTable.SetRange("SQL Database Code", SQLDatabaseCode);
        PTESQLDatabaseTable.SetRange("Table Name", TableName);
        exit(not PTESQLDatabaseTable.IsEmpty);
    end;

    local procedure GetObjectsMetadata(var PTESQLDatabase: Record "PTE SQL Database")
    var
        PTEAppObject: Record "PTE App. Object";
    begin
        //Delete data if exists
        PTEAppObject.SetRange("SQL Database Code", PTESQLDatabase."Code");
        PTEAppObject.DeleteAll();

        if PTESQLDatabase."Use Metadata Set Code" <> '' then begin
            GetObjectsMetadataFromMetadataSet(PTESQLDatabase);
            exit;
        end;
        //Object Metadata
        if DatabaseTableExists(PTESQLDatabase."Code", 'Object Metadata') then
            GetObjectsMetadataFromSource(PTESQLDatabase, 'Object Metadata');

        //Object Metadata Snapshot
        //PTESQLServerTables.SETRANGE("Server Code", PTESQLServerSetup."Server Code");
        //PTESQLServerTables.SETFILTER("Table Name", 'Object Metadata Snapshot');
        //if NOT PTESQLServerTables.IsEmpty then
        //    GetObjectsMetadataFromSource(PTESQLServerSetup, 'Object Metadata Snapshot');

        //NAV App Object Metadata
        if DatabaseTableExists(PTESQLDatabase."Code", 'NAV App Object Metadata') then
            GetObjectsMetadataFromSource(PTESQLDatabase, 'NAV App Object Metadata');

        //Application Object Metadata
        if DatabaseTableExists(PTESQLDatabase."Code", 'Application Object Metadata') then
            GetObjectsMetadataFromSource(PTESQLDatabase, 'Application Object Metadata');
    end;


    local procedure GetObjectsMetadataFromMetadataSet(var PTESQLDatabase: Record "PTE SQL Database");
    var
        PTEAppMetadataSetObject: Record "PTE App. Metadata Set Object";
        PTEAppObject: Record "PTE App. Object";
        NumberOfRecords: Integer;
        DialogProgress: Dialog;
        ProgressTotal: Integer;
        CurrentProgress: Integer;
    begin

        if PTESQLDatabase."Use Metadata Set Code" <> '' then begin
            PTEAppMetadataSetObject.SetRange("App. Metadata Set Code", PTESQLDatabase."Use Metadata Set Code");
            NumberOfRecords := PTEAppMetadataSetObject.Count;
            //Open progress bar
            CurrentProgress := 0;
            ProgressTotal := NumberOfRecords;
            DialogProgress.OPEN(STRSUBSTNO(DownloadingAppObjMsg, PTESQLDatabase."Code", ProgressTotal) + ': #1#####', CurrentProgress);

            if PTEAppMetadataSetObject.FindSet() then
                repeat
                    PTEAppObject.INIT();
                    PTEAppObject."SQL Database Code" := PTESQLDatabase."Code";
                    PTEAppObject.Source := '';
                    PTEAppObject."Type" := PTEAppMetadataSetObject."Object Type";
                    PTEAppObject."ID" := PTEAppMetadataSetObject."Object ID";
                    PTEAppObject."Subtype" := PTEAppMetadataSetObject."Object Subtype";
                    PTEAppObject."Package ID" := '';
                    PTEAppObject."Runtime Package ID" := '';
                    if PTEAppObject."Package ID" <> '' then begin
                        if IsPackageInstalled(PTEAppObject."Package ID") then
                            if not PTEAppObject.Insert() then;
                    end else
                        if not PTEAppObject.Insert() then;
                    //update progress bar
                    CurrentProgress := CurrentProgress + 1;
                    DialogProgress.Update();
                until PTEAppMetadataSetObject.Next() = 0;
            DialogProgress.Close();
        end;
    end;


    local procedure GetObjectsMetadataFromSource(var PTESQLDatabase: Record "PTE SQL Database"; SourceTable: Text[250]);
    var
        PTEAppObject: Record "PTE App. Object";
        SQLConnection: DotNet SqlConnection;
        SQLCommand: DotNet SqlCommand;
        SQLReader: DotNet SqlDataReader;
        SQLQueryText: Text;
        SQLQueryText2: Text;
        NumberOfRecords: Integer;
        DialogProgress: Dialog;
        ProgressTotal: Integer;
        CurrentProgress: Integer;
        ConnectionString: Text;
        FieldColumnNo: Dictionary of [Text, Integer];
        ColumnNo: Integer;
    begin
        //Build SQL queries to run
        SQLQueryText := 'SELECT COUNT([Object ID]) FROM [' + SourceTable + ']';
        SQLQueryText2 := 'SELECT [Object Type],[Object ID]';

        FieldColumnNo.Add('[Object Type]', 0);
        FieldColumnNo.Add('[Object ID]', 1);
        ColumnNo := 1;

        if DatabaseFieldExists(PTESQLDatabase.Code, SourceTable, 'Object Subtype') then begin
            SQLQueryText2 := SQLQueryText2 + ',[Object Subtype]';
            ColumnNo := ColumnNo + 1;
            FieldColumnNo.Add('[Object Subtype]', ColumnNo);
        end;
        if DatabaseFieldExists(PTESQLDatabase.Code, SourceTable, 'Package ID') then begin
            SQLQueryText2 := SQLQueryText2 + ',[Package ID]';
            ColumnNo := ColumnNo + 1;
            FieldColumnNo.Add('[Package ID]', ColumnNo);
        end;
        if DatabaseFieldExists(PTESQLDatabase.Code, SourceTable, 'Runtime Package ID') then begin
            SQLQueryText2 := SQLQueryText2 + ',[Runtime Package ID]';
            ColumnNo := ColumnNo + 1;
            FieldColumnNo.Add('[Runtime Package ID]', ColumnNo);
        end;
        if DatabaseFieldExists(PTESQLDatabase.Code, SourceTable, 'Object Name') then begin
            SQLQueryText2 := SQLQueryText2 + ',[Object Name]';
            ColumnNo := ColumnNo + 1;
            FieldColumnNo.Add('[Object Name]', ColumnNo);
        end;
        SQLQueryText2 := SQLQueryText2 + ' FROM [' + SourceTable + ']';
        ConnectionString := PTESQLDatabase.GetDatabaseConnectionString();

        //Get number of records
        SQLConnection := SQLConnection.SqlConnection(ConnectionString);
        SQLConnection.Open();
        SQLCommand := SQLCommand.SqlCommand(SQLQueryText, SQLConnection);
        SQLCommand.CommandTimeout := 10 * 60 * 100; // 10 min.
        SQLReader := SQLCommand.ExecuteReader();
        SQLReader.Read();
        Evaluate(NumberOfRecords, Format(SQLReader.GetValue(0)));
        SQLConnection.Close();

        //Open progress bar
        CurrentProgress := 0;
        ProgressTotal := NumberOfRecords;
        DialogProgress.OPEN(STRSUBSTNO(DownloadingAppObjMsg, PTESQLDatabase."Code", ProgressTotal) + ': #1#####', CurrentProgress);

        //Download metadata
        SQLConnection := SQLConnection.SqlConnection(ConnectionString);
        SQLConnection.Open();
        SQLCommand := SQLCommand.SqlCommand(SQLQueryText2, SQLConnection);
        SQLCommand.CommandTimeout := 10 * 60 * 100; // 10 min.
        SQLReader := SQLCommand.ExecuteReader();

        //Read columns data and put to the NAV table
        while SQLReader.Read() do begin
            PTEAppObject.INIT();
            PTEAppObject."SQL Database Code" := PTESQLDatabase."Code";
            PTEAppObject.Source := SourceTable;
            //[Object Type]
            if not SQLReader.IsDBNull(FieldColumnNo.Get('[Object Type]')) then
                Evaluate(PTEAppObject."Type", FORMAT(SQLReader.GetValue(FieldColumnNo.Get('[Object Type]'))));
            //[Object ID]
            if not SQLReader.IsDBNull(FieldColumnNo.Get('[Object ID]')) then
                PTEAppObject."ID" := GetInteger(FORMAT(SQLReader.GetValue(FieldColumnNo.Get('[Object ID]'))));
            //[Object Subtype]
            if DatabaseFieldExists(PTESQLDatabase.Code, SourceTable, 'Object Subtype') then
                if not SQLReader.IsDBNull(FieldColumnNo.Get('[Object Subtype]')) then
                    Evaluate(PTEAppObject."Subtype", FORMAT(SQLReader.GetString(FieldColumnNo.Get('[Object Subtype]'))));
            //[Package ID]
            if DatabaseFieldExists(PTESQLDatabase.Code, SourceTable, 'Package ID') then
                if not SQLReader.IsDBNull(FieldColumnNo.Get('[Package ID]')) then begin
                    Evaluate(PTEAppObject."Package ID", FORMAT(SQLReader.GetValue(FieldColumnNo.Get('[Package ID]'))));
                    PTEAppObject."Package ID" := DELCHR(PTEAppObject."Package ID", '=', '{}');
                end;
            //[Runtime Package ID]
            if DatabaseFieldExists(PTESQLDatabase.Code, SourceTable, 'Runtime Package ID') then
                if not SQLReader.IsDBNull(FieldColumnNo.Get('[Runtime Package ID]')) then begin
                    Evaluate(PTEAppObject."Runtime Package ID", FORMAT(SQLReader.GetValue(FieldColumnNo.Get('[Runtime Package ID]'))));
                    PTEAppObject."Runtime Package ID" := DELCHR(PTEAppObject."Runtime Package ID", '=', '{}');
                end;
            //[Object Name]
            if DatabaseFieldExists(PTESQLDatabase.Code, SourceTable, 'Object Name') then
                if not SQLReader.IsDBNull(FieldColumnNo.Get('[Object Name]')) then
                    Evaluate(PTEAppObject."Name", FORMAT(SQLReader.GetString(FieldColumnNo.Get('[Object Name]'))));

            if PTEAppObject."Package ID" <> '' then begin
                if IsPackageInstalled(PTEAppObject."Package ID") then
                    if not PTEAppObject.Insert() then;
            end else
                if not PTEAppObject.Insert() then;
            //update progress bar
            CurrentProgress := CurrentProgress + 1;
            DialogProgress.Update();
        end;
        SQLConnection.Close();

        DialogProgress.Close();
    end;

    local procedure CheckIfTableNamesAreUnique(var PTESQLDatabase: Record "PTE SQL Database"): Boolean;
    var
        PTEAppObject1: Record "PTE App. Object";
        PTEAppObject2: Record "PTE App. Object";
        PTEAppSkippedObjects: Record "PTE App Skipped Objects";
        PTEAppObjectsPage: Page "PTE App. Objects";
        NumberOfRecords: Integer;
        DialogProgress: Dialog;
        ProgressTotal: Integer;
        CurrentProgress: Integer;
        TheSameNameQty: Integer;
        SkippedQty: Integer;
        HasDuplicatedNotSkipped: Boolean;
    begin
        PTEAppObject1.SetRange("SQL Database Code", PTESQLDatabase."Code");
        PTEAppObject1.SetFilter("Type", '%1', PTEAppObject1."Type"::Table);
        PTEAppObject2.SetRange("SQL Database Code", PTESQLDatabase."Code");
        PTEAppObject2.SetFilter("Type", '%1', PTEAppObject1."Type"::Table);
        PTEAppSkippedObjects.SetRange("SQL Database Code", PTESQLDatabase."Code");
        PTEAppSkippedObjects.SetFilter("Type", '%1', PTEAppObject1."Type"::Table);
        ProgressTotal := PTEAppObject1.count();
        HasDuplicatedNotSkipped := false;
        DialogProgress.Open(STRSUBSTNO(CheckingDuplicates, PTESQLDatabase."Code", ProgressTotal) + ': #1#####', CurrentProgress);
        if PTEAppObject1.FindSet() then
            repeat
                PTEAppObject2.SetRange(Name, PTEAppObject1.Name);
                PTEAppSkippedObjects.SetRange(Name, PTEAppObject1.Name);
                TheSameNameQty := PTEAppObject2.Count();
                SkippedQty := PTEAppSkippedObjects.Count();
                if TheSameNameQty > 1 then begin
                    PTEAppObject1."Duplicated Name" := true;
                    PTEAppObject1.Modify();
                End;
                CurrentProgress := CurrentProgress + 1;
                DialogProgress.Update();
                if (TheSameNameQty - SkippedQty) > 1 then
                    HasDuplicatedNotSkipped := true;
            until PTEAppObject1.Next() = 0;
        DialogProgress.Close();
        PTEAppObject1.SetRange("Duplicated Name", true);
        if HasDuplicatedNotSkipped then begin
            PTEAppObject1.SetRange(Skipped);
            PTEAppObjectsPage.SetTableView(PTEAppObject1);
            PTEAppObjectsPage.Editable(true);
            PTEAppObjectsPage.Run();
            Message(DuplicatedTableNamesMsg);
            exit(false);
        end;
        exit(true);
    end;


    local procedure GetObjectNamesAndAppID(var PTESQLDatabase: Record "PTE SQL Database")
    var
        PTEAppObject: Record "PTE App. Object";
        PTEAppObjectTable: Record "PTE App. Object Table";
        PTEAppObjectTableField: Record "PTE App. Object Table Field";
        PTEAppObjectTblFieldOpt: Record "PTE App. Object Tbl.Field Opt.";
        PTEAppObjectEnum: Record "PTE App. Object Enum";
        PTEAppObjectEnumValue: Record "PTE App. Object Enum Value";
        DialogProgress: Dialog;
        ProgressTotal: Integer;
        CurrentProgress: Integer;
    begin
        //read parse and insert objects from metadata
        PTEAppObject.SetRange("SQL Database Code", PTESQLDatabase."Code");
        //filter all objects to find total number for count
        PTEAppObject.SetFilter("Type", '%1|%2|%3|%4', PTEAppObject."Type"::Table, PTEAppObject."Type"::"TableExtension", PTEAppObject."Type"::Enum, PTEAppObject."Type"::EnumExtension);
        ProgressTotal := PTEAppObject.count();
        DialogProgress.Open(STRSUBSTNO(DownloadingMetaDataMsg1, PTESQLDatabase."Code", ProgressTotal) + ': #1#####', CurrentProgress);
        //get objects without table extensions
        PTEAppObject.SetFilter("Type", '%1|%2|%3', PTEAppObject."Type"::Table, PTEAppObject."Type"::Enum, PTEAppObject."Type"::EnumExtension);
        if PTEAppObject.FindSet() then
            repeat
                GetObjectNameAndAppID(PTEAppObject);
                CurrentProgress := CurrentProgress + 1;
                DialogProgress.Update();
            until PTEAppObject.Next() = 0;
    end;


    local procedure IsPackageInstalled(PackageID: text): Boolean
    var
        PTESQLDatabaseInstalledApp: Record "PTE SQL Database Installed App";
    begin
        if PTESQLDatabaseInstalledApp.IsEmpty then
            exit(false);
        PTESQLDatabaseInstalledApp.SetFilter("Package ID", '@' + PackageID);
        exit(not PTESQLDatabaseInstalledApp.IsEmpty);
    end;

    local procedure GetAllObjectDetail(var PTESQLDatabase: Record "PTE SQL Database")
    var
        PTEAppObject: Record "PTE App. Object";
        PTEAppObjectTable: Record "PTE App. Object Table";
        PTEAppObjectTableField: Record "PTE App. Object Table Field";
        PTEAppObjectTblFieldOpt: Record "PTE App. Object Tbl.Field Opt.";
        PTEAppObjectEnum: Record "PTE App. Object Enum";
        PTEAppObjectEnumValue: Record "PTE App. Object Enum Value";
        DialogProgress: Dialog;
        ProgressTotal: Integer;
        CurrentProgress: Integer;
    begin
        //delete existing objects
        PTEAppObjectTable.SetRange("SQL Database Code", PTESQLDatabase."Code");
        PTEAppObjectTableField.SetRange("SQL Database Code", PTESQLDatabase."Code");
        PTEAppObjectTblFieldOpt.SetRange("SQL Database Code", PTESQLDatabase."Code");
        PTEAppObjectEnum.SetRange("SQL Database Code", PTESQLDatabase."Code");
        PTEAppObjectEnumValue.SetRange("SQL Database Code", PTESQLDatabase."Code");
        PTEAppObjectTable.DeleteAll();
        PTEAppObjectTableField.DeleteAll();
        PTEAppObjectTblFieldOpt.DeleteAll();
        PTEAppObjectEnum.DeleteAll();
        PTEAppObjectEnumValue.DeleteAll();

        //read parse and insert objects from metadata
        PTEAppObject.SetRange("SQL Database Code", PTESQLDatabase."Code");
        PTEAppObject.SetRange(Skipped, false);
        //filter all objects to find total number for count
        PTEAppObject.SetFilter("Type", '%1|%2|%3|%4', PTEAppObject."Type"::Table, PTEAppObject."Type"::"TableExtension", PTEAppObject."Type"::Enum, PTEAppObject."Type"::EnumExtension);
        ProgressTotal := PTEAppObject.count();
        DialogProgress.Open(STRSUBSTNO(DownloadingMetaDataMsg, PTESQLDatabase."Code", ProgressTotal) + ': #1#####', CurrentProgress);
        //get objects without table extensions
        PTEAppObject.SetFilter("Type", '%1|%2|%3', PTEAppObject."Type"::Table, PTEAppObject."Type"::Enum, PTEAppObject."Type"::EnumExtension);
        if PTEAppObject.FindSet() then
            repeat
                GetObjectDetail(PTEAppObject);
                CurrentProgress := CurrentProgress + 1;
                DialogProgress.Update();
            until PTEAppObject.Next() = 0;
        //get objects table extensions - it was not possible in previous loop, because extended table object is needed before
        PTEAppObject.SetRange("Type", PTEAppObject."Type"::"TableExtension");
        if PTEAppObject.FindSet() then
            repeat
                GetObjectDetail(PTEAppObject);
                CurrentProgress := CurrentProgress + 1;
                DialogProgress.Update();
            until PTEAppObject.Next() = 0;
        DialogProgress.Close();

        //Fill in Options based Enum
        PTEAppObjectTableField.SetRange("SQL Database Code", PTESQLDatabase."Code");
        PTEAppObjectTableField.SetFilter(EnumTypeID, '<>0');
        if PTEAppObjectTableField.FindSet() then
            repeat
                PTEAppObjectEnumValue.SetRange("SQL Database Code", PTEAppObjectTableField."SQL Database Code");
                PTEAppObjectEnumValue.SetRange("Enum ID", PTEAppObjectTableField.EnumTypeID);
                if PTEAppObjectEnumValue.FindSet() then
                    repeat
                        PTEAppObjectTblFieldOpt.Init();
                        PTEAppObjectTblFieldOpt."SQL Database Code" := PTEAppObjectTableField."SQL Database Code";
                        PTEAppObjectTblFieldOpt."Table ID" := PTEAppObjectTableField."Table ID";
                        PTEAppObjectTblFieldOpt."Table Name" := PTEAppObjectTableField."Table Name";
                        PTEAppObjectTblFieldOpt."Field ID" := PTEAppObjectTableField."ID";
                        PTEAppObjectTblFieldOpt."Field Name" := PTEAppObjectTableField."Name";
                        PTEAppObjectTblFieldOpt."Option ID" := PTEAppObjectEnumValue.Ordinal;
                        PTEAppObjectTblFieldOpt.Name := PTEAppObjectEnumValue.Name;
                        if not PTEAppObjectTblFieldOpt.Insert() then
                            PTEAppObjectTblFieldOpt.Modify();
                    until PTEAppObjectEnumValue.Next() = 0;
            until PTEAppObjectTableField.Next() = 0;
    end;

    procedure FindSQLTableNames(var PTESQLDatabase: Record "PTE SQL Database")
    var
        PTEAppObjectTable: Record "PTE App. Object Table";
        PTEAppObjectTableField: Record "PTE App. Object Table Field";
        PTESQLDatabaseTable: Record "PTE SQL Database Table";
        PTESQLDatabaseTableField: Record "PTE SQL Database Table Field";
        DialogProgress: Dialog;
        ProgressTotal: Integer;
        CurrentProgress: Integer;
        CheckedTables: Boolean;
        SQLTableName: Text;
        SQLTableNameWithAppID: Text;
        TableNameFilter: Text;
    begin
        PTEAppObjectTable.Reset();
        PTEAppObjectTableField.Reset();
        PTEAppObjectTable.SetRange("SQL Database Code", PTESQLDatabase."Code");
        ProgressTotal := PTEAppObjectTable.count();
        CurrentProgress := 0;
        DialogProgress.OPEN(STRSUBSTNO(FindingSQLTableNamesMsg, PTESQLDatabase."Code", ProgressTotal) + ': #1#####', CurrentProgress);
        if PTEAppObjectTable.FindSet() then
            repeat
                CheckedTables := false;
                PTEAppObjectTableField.SetRange("SQL Database Code", PTEAppObjectTable."SQL Database Code");
                PTEAppObjectTableField.SetRange("Table ID", PTEAppObjectTable."ID");
                PTEAppObjectTableField.SetFilter(FieldClass, '%1|Normal', '');
                PTEAppObjectTableField.SetFilter(Datatype, '<>TableFilter', '');
                PTESQLDatabaseTable.SetRange("SQL Database Code", PTEAppObjectTable."SQL Database Code");
                PTESQLDatabaseTable.SetRange("Table Type", 'BASE TABLE');
                SQLTableName := GetSQLName(PTESQLDatabase, PTEAppObjectTable.Name);
                if PTEAppObjectTableField.FindSet() then
                    repeat
                        TableNameFilter := '';
                        if PTEAppObjectTableField."App ID" <> '' then
                            SQLTableNameWithAppID := SQLTableName + '$' + PTEAppObjectTableField."App ID"
                        else
                            SQLTableNameWithAppID := SQLTableName;
                        if PTEAppObjectTable.DataPerCompany then
                            TableNameFilter := '''' + '*$' + SQLTableNameWithAppID + ''''
                        else
                            TableNameFilter := '''' + SQLTableNameWithAppID + '''';
                        PTESQLDatabaseTable.SetFilter("Table Name", TableNameFilter);

                        //support for the new BC23 structure
                        if PTESQLDatabaseTable.IsEmpty then
                            if LowerCase(PTEAppObjectTableField."App ID") <> LowerCase(PTEAppObjectTable.SourceAppId) then begin
                                TableNameFilter := '';
                                if PTEAppObjectTable.SourceAppId <> '' then
                                    SQLTableNameWithAppID := SQLTableName + '$' + PTEAppObjectTable.SourceAppId + '$ext'
                                else
                                    SQLTableNameWithAppID := SQLTableName + '$ext';

                                if PTEAppObjectTable.DataPerCompany then
                                    TableNameFilter := '''' + '*$' + SQLTableNameWithAppID + ''''
                                else
                                    TableNameFilter := '''' + SQLTableNameWithAppID + '''';
                                PTESQLDatabaseTable.SetFilter("Table Name", TableNameFilter);
                            end;


                        if not PTESQLDatabaseTable.IsEmpty then begin
                            PTESQLDatabaseTableField.SetRange("SQL Database Code", PTEAppObjectTable."SQL Database Code");
                            PTESQLDatabaseTableField.SetFilter("Table Name", TableNameFilter);
                            PTESQLDatabaseTableField.SetRange("Column Name", PTEAppObjectTableField."SQL Field Name Candidate");
                            if not PTESQLDatabaseTableField.IsEmpty then begin
                                PTEAppObjectTableField."SQL Field Name" := PTEAppObjectTableField."SQL Field Name Candidate";
                                PTEAppObjectTableField."SQL Table Name Excl. C. Name" := CopyStr(SQLTableNameWithAppID, 1, MaxStrLen(PTEAppObjectTableField."SQL Table Name Excl. C. Name"));
                                PTEAppObjectTableField.Modify();
                            end else begin
                                PTESQLDatabaseTableField.SetRange("Column Name", PTEAppObjectTableField."SQL Field Name Candidate 2");
                                if not PTESQLDatabaseTableField.IsEmpty then begin
                                    PTEAppObjectTableField."SQL Field Name" := PTEAppObjectTableField."SQL Field Name Candidate 2";
                                    PTEAppObjectTableField."SQL Table Name Excl. C. Name" := CopyStr(SQLTableNameWithAppID, 1, MaxStrLen(PTEAppObjectTableField."SQL Table Name Excl. C. Name"));
                                    PTEAppObjectTableField.Modify();
                                end;
                            end;

                            if PTESQLDatabaseTable.FindSet() and not CheckedTables then begin
                                PTEAppObjectTable."Number Of Records" := 0;
                                repeat
                                    if PTEAppObjectTable."Number Of Records" < PTESQLDatabaseTable."Number Of Records" then
                                        PTEAppObjectTable."Number Of Records" := PTESQLDatabaseTable."Number Of Records";
                                until PTESQLDatabaseTable.Next() = 0;
                                PTEAppObjectTable.Modify();
                                CheckedTables := true;
                            end;
                        end;
                    until PTEAppObjectTableField.Next() = 0;
                CurrentProgress := CurrentProgress + 1;
                DialogProgress.Update();
            until PTEAppObjectTable.Next() = 0;
        DialogProgress.Close();
    end;

    procedure DownloadObject(PTEAppObject: Record "PTE App. Object")
    var
        FileManagement: Codeunit "File Management";
        ObjectMetadata: BigText;
        DataFile: File;
        FileName: Text;

    begin
        ObjectMetadata := GetObjectMetadataXMLFromSQL(PTEAppObject);
        FileName := FileManagement.ServerTempFileName('xml');
        DataFile.TEXTMODE(TRUE);
        DataFile.CREATE(FileName);
        DataFile.WRITE(FORMAT(ObjectMetadata));
        DataFile.close();
        FileManagement.DownloadHandler(FileName, 'Object Metadata', '', '', 'Object.txt');
    end;

    local procedure GetXMLMetadata(ObjectMetadata: BigText; var XmlDocument: DotNet DotNetXmlDocument);
    var
        TempBlob: Codeunit "Temp Blob";
        StreamReader: DotNet SStreamReader;
        Instream: InStream;
        Outstream: OutStream;
        Encoding: DotNet EEncoding;
    begin
        TempBlob.CREATEOUTSTREAM(Outstream, TEXTENCODING::UTF8);
        ObjectMetadata.WRITE(Outstream);
        XmlDocument := XmlDocument.XmlDocument();
        TempBlob.CREATEINSTREAM(Instream, TEXTENCODING::UTF8);
        StreamReader := StreamReader.StreamReader(Instream, Encoding.UTF8, TRUE);
        XmlDocument.Load(StreamReader);
    end;


    local procedure GetObjectNameAndAppID(var PTEAppObject: Record "PTE App. Object")
    var
        PTESQLDatabase: Record "PTE SQL Database";
        PTEAppMetadataSetObject: Record "PTE App. Metadata Set Object";
        PTESQLDatabaseInstalledApp: Record "PTE SQL Database Installed App";
        ObjectMetadata: BigText;
        OptionString: Text;
        XmlDocument: DotNet DotNetXmlDocument;
        XmlNodeReader: DotNet XmlNodeReader;


    begin
        PTESQLDatabase.GET(PTEAppObject."SQL Database Code");
        if PTESQLDatabase."Use Metadata Set Code" <> '' then begin
            PTEAppMetadataSetObject.Get(PTESQLDatabase."Use Metadata Set Code", PTEAppObject.ID, PTEAppObject.Type);
            ObjectMetadata := PTEAppMetadataSetObject.GetMetadataText();
        end else
            ObjectMetadata := GetObjectMetadataXMLFromSQL(PTEAppObject);

        GetXMLMetadata(ObjectMetadata, XmlDocument);
        XmlNodeReader := XmlNodeReader.XmlNodeReader(XmlDocument);
        while XmlNodeReader.Read() do
            case PTEAppObject."Type" of
                //table
                //<MetaTable Name="Currency" SourceAppId="437dbf0e-84ff-417a-965d-ed2bb9650972"
                PTEAppObject."Type"::Table:
                    begin
                        if XmlNodeReader.Name() = 'MetaTable' then begin
                            PTEAppObject.Name := XmlNodeReader.GetAttribute('Name');
                            PTEAppObject."Application ID" := UpperCase(XmlNodeReader.GetAttribute('SourceAppId'));
                            if PTESQLDatabaseInstalledApp.Get(PTEAppObject."SQL Database Code", PTEAppObject."Application ID") then
                                PTEAppObject."Application Name" := PTESQLDatabaseInstalledApp.Name;
                            PTEAppObject.Modify();
                        end;
                    end;

                //table extension
                PTEAppObject."Type"::TableExtension:
                    begin
                        if XmlNodeReader.Name() = 'MetadataRuntimeDeltas' then begin
                            PTEAppObject.Name := XmlNodeReader.GetAttribute('Name');
                            PTEAppObject.Modify();
                        end;
                    end;
                //Enum
                PTEAppObject."Type"::Enum:
                    begin
                        if XmlNodeReader.Name() = 'Enum' then begin
                            PTEAppObject.Name := XmlNodeReader.GetAttribute('Name');
                            PTEAppObject.Modify();
                        end;
                    END;
                //Enum Extension
                PTEAppObject."Type"::EnumExtension:
                    begin
                        IF XmlNodeReader.Name() = 'Value' then begin
                            PTEAppObject.Name := XmlNodeReader.GetAttribute('Name');
                            PTEAppObject.Modify();
                        end;
                    end;
            end;
    end;


    local procedure GetObjectDetail(PTEAppObject: Record "PTE App. Object")
    var
        PTESQLDatabase: Record "PTE SQL Database";
        PTEAppObjectTable: Record "PTE App. Object Table";
        PTEAppObjectTable2: Record "PTE App. Object Table";
        PTEAppObjectTableField: Record "PTE App. Object Table Field";
        PTEAppObjectTableField2: Record "PTE App. Object Table Field";
        PTEAppObjectEnum: Record "PTE App. Object Enum";
        PTEAppObjectEnumValue: Record "PTE App. Object Enum Value";
        PTEAppObjectTblFieldOpt: Record "PTE App. Object Tbl.Field Opt.";
        PTESQLDatabaseTable: Record "PTE SQL Database Table";
        PTEAppMetadataSetObject: Record "PTE App. Metadata Set Object";
        ObjectMetadata: BigText;
        OptionString: Text;
        XmlDocument: DotNet DotNetXmlDocument;
        XmlNodeReader: DotNet XmlNodeReader;
        AllowedCharacters: Text;
        SQFieldName: Text;
        ReplaceCharacters: Text;
        TableID: Integer;
        TableName: Text[150];
        EnumID: Integer;
        NoOfOptions: Integer;
        i: Integer;
        KeyFieldNo: Integer;
        KeyFieldNoText: Text;
        KeyInserted: Boolean;

    begin
        PTESQLDatabase.GET(PTEAppObject."SQL Database Code");
        if PTESQLDatabase."Use Metadata Set Code" <> '' then begin
            PTEAppMetadataSetObject.Get(PTESQLDatabase."Use Metadata Set Code", PTEAppObject.ID, PTEAppObject.Type);
            ObjectMetadata := PTEAppMetadataSetObject.GetMetadataText();
        end else
            ObjectMetadata := GetObjectMetadataXMLFromSQL(PTEAppObject);

        GetXMLMetadata(ObjectMetadata, XmlDocument);
        XmlNodeReader := XmlNodeReader.XmlNodeReader(XmlDocument);
        while XmlNodeReader.Read() do
            case PTEAppObject."Type" of
                //table
                PTEAppObject."Type"::Table:
                    begin
                        if XmlNodeReader.Name() = 'MetaTable' then begin
                            PTEAppObjectTable."SQL Database Code" := PTEAppObject."SQL Database Code";
                            TableID := GetInteger(XmlNodeReader.GetAttribute('ID'));
                            TableName := XmlNodeReader.GetAttribute('Name');
                            PTEAppObjectTable."ID" := TableID;
                            PTEAppObjectTable.Name := TableName;
                            PTEAppObjectTable.TableType := XmlNodeReader.GetAttribute('TableType');
                            PTEAppObjectTable.CompressionType := XmlNodeReader.GetAttribute('CompressionType');
                            PTEAppObjectTable.Access := XmlNodeReader.GetAttribute('Access');
                            PTEAppObjectTable.PasteIsValid := GetBoolean(XmlNodeReader.GetAttribute('PasteIsValid'));
                            PTEAppObjectTable.LinkedObject := XmlNodeReader.GetAttribute('LinkedObject');
                            PTEAppObjectTable.Extensible := GetBoolean(XmlNodeReader.GetAttribute('Extensible'));
                            PTEAppObjectTable.ReplicateData := GetBoolean(XmlNodeReader.GetAttribute('ReplicateData'));
                            PTEAppObjectTable.DataClassification := XmlNodeReader.GetAttribute('DataClassification');
                            if PTESQLDatabase."Use Metadata Set Code" <> '' then
                                PTEAppObjectTable.DataPerCompany := PTEAppMetadataSetObject."Data Per Company"
                            else
                                PTEAppObjectTable.DataPerCompany := GetBoolean(XmlNodeReader.GetAttribute('DataPerCompany'));
                            PTEAppObjectTable.SourceAppId := XmlNodeReader.GetAttribute('SourceAppId');
                            PTEAppObjectTable.SourceExtensionType := XmlNodeReader.GetAttribute('SourceExtensionType');
                            PTEAppObjectTable.ObsoleteState := XmlNodeReader.GetAttribute('ObsoleteState');
                            if PTEAppObjectTable.ObsoleteState = 'No' then
                                PTEAppObjectTable.ObsoleteState := '';
                            PTEAppObjectTable.ObsoleteReason := XmlNodeReader.GetAttribute('ObsoleteReason');

                            if not PTEAppObjectTable.Insert() then begin
                                PTEAppObjectTable2.SetRange("SQL Database Code", PTEAppObject."SQL Database Code");
                                PTEAppObjectTable2.SetRange(Name, PTEAppObjectTable.Name);
                                PTEAppObjectTable2.SetFilter(ID, '<>%1', PTEAppObjectTable."ID");
                                if PTEAppObjectTable2.IsEmpty then
                                    PTEAppObjectTable.Modify();
                            end;
                        END;
                        IF XmlNodeReader.Name() = 'Field' then begin
                            SQFieldName := XmlNodeReader.GetAttribute('Name');
                            SQFieldName := GetSQLName(PTESQLDatabase, XmlNodeReader.GetAttribute('Name'));
                            PTESQLDatabaseTable.SetRange("SQL Database Code", PTEAppObject."SQL Database Code");
                            if SQFieldName <> '' then begin
                                PTEAppObjectTableField.INIT();
                                PTEAppObjectTableField."SQL Database Code" := PTEAppObject."SQL Database Code";
                                PTEAppObjectTableField."Table ID" := TableID;
                                PTEAppObjectTableField."Table Name" := TableName;


                                PTEAppObjectTableField."ID" := GetInteger(XmlNodeReader.GetAttribute('ID'));
                                PTEAppObjectTableField.Name := XmlNodeReader.GetAttribute('Name');
                                PTEAppObjectTableField.Datatype := XmlNodeReader.GetAttribute('Datatype');
                                PTEAppObjectTableField.DataLength := GetInteger(XmlNodeReader.GetAttribute('DataLength'));
                                PTEAppObjectTableField."App ID" := XmlNodeReader.GetAttribute('SourceAppId');
                                PTEAppObjectTableField.SourceExtensionType := GetInteger(XmlNodeReader.GetAttribute('SourceExtensionType'));
                                PTEAppObjectTableField.NotBlank := GetBoolean(XmlNodeReader.GetAttribute('NotBlank'));
                                PTEAppObjectTableField.FieldClass := XmlNodeReader.GetAttribute('FieldClass');
                                PTEAppObjectTableField."SQL Field Name" := '';
                                if (UpperCase(PTEAppObjectTableField.FieldClass) = 'NORMAL') or (PTEAppObjectTableField.FieldClass = '') then begin
                                    PTEAppObjectTableField."SQL Field Name Candidate" := CopyStr(SQFieldName, 1, MaxStrLen(PTEAppObjectTableField."SQL Field Name"));
                                    PTEAppObjectTableField."SQL Field Name Candidate 2" := StrSubstNo('%1$%2', SQFieldName, LowerCase(PTEAppObjectTableField."App ID"));
                                end else begin
                                    PTEAppObjectTableField."SQL Field Name Candidate" := '';
                                    PTEAppObjectTableField."SQL Field Name Candidate 2" := '';
                                end;
                                PTEAppObjectTableField.DateFormula := XmlNodeReader.GetAttribute('DateFormula');
                                PTEAppObjectTableField.Editable := GetBoolean(XmlNodeReader.GetAttribute('Editable'));
                                PTEAppObjectTableField.Access := XmlNodeReader.GetAttribute('Access');
                                PTEAppObjectTableField.Numeric := GetBoolean(XmlNodeReader.GetAttribute('Numeric'));
                                PTEAppObjectTableField.ExternalAccess := XmlNodeReader.GetAttribute('ExternalAccess');
                                PTEAppObjectTableField.ValidateTableRelation := GetBoolean(XmlNodeReader.GetAttribute('ValidateTableRelation'));
                                PTEAppObjectTableField.DataClassification := XmlNodeReader.GetAttribute('DataClassification');
                                PTEAppObjectTableField.EnumTypeName := XmlNodeReader.GetAttribute('EnumTypeName');
                                PTEAppObjectTableField.EnumTypeId := GetInteger(XmlNodeReader.GetAttribute('EnumTypeId'));
                                PTEAppObjectTableField.InitValue := XmlNodeReader.GetAttribute('InitValue');
                                PTEAppObjectTableField.ObsoleteState := XmlNodeReader.GetAttribute('ObsoleteState');
                                if PTEAppObjectTableField.ObsoleteState = 'No' then
                                    PTEAppObjectTableField.ObsoleteState := '';
                                PTEAppObjectTableField.ObsoleteReason := XmlNodeReader.GetAttribute('ObsoleteReason');
                                if (uppercase(XmlNodeReader.GetAttribute('Enabled')) <> 'NULL') and (XmlNodeReader.GetAttribute('Enabled') <> '') then
                                    PTEAppObjectTableField.Enabled := GetBoolean(XmlNodeReader.GetAttribute('Enabled'))
                                else
                                    PTEAppObjectTableField.Enabled := true;
                                if not PTEAppObjectTableField.Insert() then begin
                                    PTEAppObjectTableField2.SetRange("SQL Database Code", PTEAppObjectTableField."SQL Database Code");
                                    PTEAppObjectTableField2.SetRange("Table Name", PTEAppObjectTableField."Table Name");
                                    PTEAppObjectTableField2.SetRange(Name, PTEAppObjectTableField.Name);
                                    PTEAppObjectTableField2.SetRange(FieldClass, PTEAppObjectTableField.FieldClass);
                                    PTEAppObjectTableField2.SetFilter("Table ID", '<>%1', PTEAppObjectTableField2."Table ID");
                                    PTEAppObjectTableField2.SetFilter(ID, '<>%1', PTEAppObjectTableField2.ID);
                                    if PTEAppObjectTableField2.IsEmpty then
                                        PTEAppObjectTableField.Modify();
                                end;


                                if XmlNodeReader.GetAttribute('Datatype') = 'Option' then begin
                                    OptionString := XmlNodeReader.GetAttribute('OptionString');
                                    NoOfOptions := StrLen(DelChr(OptionString, '=', DELCHR(OptionString, '=', ','))) + 1;
                                    for i := 1 to NoOfOptions do begin
                                        PTEAppObjectTblFieldOpt.Init();
                                        PTEAppObjectTblFieldOpt."SQL Database Code" := PTEAppObjectTableField."SQL Database Code";
                                        PTEAppObjectTblFieldOpt."Table ID" := PTEAppObjectTableField."Table ID";
                                        PTEAppObjectTblFieldOpt."Table Name" := PTEAppObjectTableField."Table Name";
                                        PTEAppObjectTblFieldOpt."Field Name" := PTEAppObjectTableField.Name;
                                        PTEAppObjectTblFieldOpt."Field ID" := PTEAppObjectTableField."ID";
                                        PTEAppObjectTblFieldOpt."Option ID" := i - 1;
                                        PTEAppObjectTblFieldOpt.Name := CopyStr(SelectStr(i, OptionString), 1, MaxStrLen(PTEAppObjectTblFieldOpt.Name));
                                        if PTEAppObjectTblFieldOpt.Name <> '' then
                                            IF not PTEAppObjectTblFieldOpt.Insert() then;
                                    end;
                                end;
                            end;
                        end;
                        if (XmlNodeReader.Name() = 'Key') and (not KeyInserted) then begin
                            OptionString := XmlNodeReader.GetAttribute('Key');
                            NoOfOptions := StrLen(DELCHR(OptionString, '=', DELCHR(OptionString, '=', ','))) + 1;
                            for i := 1 to NoOfOptions do begin
                                KeyFieldNoText := SelectStr(i, OptionString);
                                KeyFieldNoText := DELCHR(KeyFieldNoText, '=', DELCHR(KeyFieldNoText, '=', '1234567890'));
                                Evaluate(KeyFieldNo, KeyFieldNoText);
                                if PTEAppObjectTableField.GET(PTEAppObject."SQL Database Code", TableID, KeyFieldNo) then begin
                                    PTEAppObjectTableField."Key" := true;
                                    PTEAppObjectTableField.Modify()
                                end;
                            end;
                            KeyInserted := true;
                        end;
                    end;

                //table extension
                PTEAppObject."Type"::TableExtension:
                    begin
                        TableID := GetInteger(PTEAppObject."Subtype");
                        if PTEAppObjectTable.GET(PTEAppObject."SQL Database Code", TableID) then
                            TableName := PTEAppObjectTable.Name
                        else
                            TableName := '';
                        if XmlNodeReader.Name() = 'FieldAdd' then begin
                            SQFieldName := XmlNodeReader.GetAttribute('Name');
                            SQFieldName := CONVERTSTR(SQFieldName, AllowedCharacters, ReplaceCharacters);
                            //PTESQLServerTables.SETRANGE("Server Code", PTESQLObjectsMetadata."Server Code");
                            //PTESQLServerTables.SETFILTER("Table Name", STRSUBSTNO('*%1*'));
                            SQFieldName := GetSQLName(PTESQLDatabase, XmlNodeReader.GetAttribute('Name'));
                            if SQFieldName <> '' then begin
                                PTEAppObjectTableField.init();
                                PTEAppObjectTableField."SQL Database Code" := PTEAppObject."SQL Database Code";
                                PTEAppObjectTableField."Table ID" := TableID;
                                PTEAppObjectTableField."Table Name" := TableName;
                                PTEAppObjectTableField.FieldClass := XmlNodeReader.GetAttribute('FieldClass');
                                PTEAppObjectTableField."App ID" := XmlNodeReader.GetAttribute('SourceAppId');
                                if (UpperCase(PTEAppObjectTableField.FieldClass) = 'NORMAL') or (PTEAppObjectTableField.FieldClass = '') then begin
                                    PTEAppObjectTableField."SQL Field Name Candidate" := CopyStr(SQFieldName, 1, MaxStrLen(PTEAppObjectTableField."SQL Field Name"));
                                    PTEAppObjectTableField."SQL Field Name Candidate 2" := StrSubstNo('%1$%2', SQFieldName, LowerCase(PTEAppObjectTableField."App ID"));
                                end else begin
                                    PTEAppObjectTableField."SQL Field Name Candidate" := '';
                                    PTEAppObjectTableField."SQL Field Name Candidate 2" := '';
                                end;
                                PTEAppObjectTableField."ID" := GetInteger(XmlNodeReader.GetAttribute('ID'));
                                PTEAppObjectTableField.Name := XmlNodeReader.GetAttribute('Name');
                                PTEAppObjectTableField.Datatype := XmlNodeReader.GetAttribute('Datatype');
                                PTEAppObjectTableField.DataLength := GetInteger(XmlNodeReader.GetAttribute('DataLength'));

                                PTEAppObjectTableField.SourceExtensionType := GetInteger(XmlNodeReader.GetAttribute('SourceExtensionType'));
                                PTEAppObjectTableField.NotBlank := GetBoolean(XmlNodeReader.GetAttribute('NotBlank'));

                                PTEAppObjectTableField.DateFormula := XmlNodeReader.GetAttribute('DateFormula');
                                PTEAppObjectTableField.Editable := GetBoolean(XmlNodeReader.GetAttribute('Editable'));
                                PTEAppObjectTableField.Access := XmlNodeReader.GetAttribute('Access');
                                PTEAppObjectTableField.Numeric := GetBoolean(XmlNodeReader.GetAttribute('Numeric'));
                                PTEAppObjectTableField.ExternalAccess := XmlNodeReader.GetAttribute('ExternalAccess');
                                PTEAppObjectTableField.ValidateTableRelation := GetBoolean(XmlNodeReader.GetAttribute('ValidateTableRelation'));
                                PTEAppObjectTableField.DataClassification := XmlNodeReader.GetAttribute('DataClassification');
                                PTEAppObjectTableField.EnumTypeName := XmlNodeReader.GetAttribute('EnumTypeName');
                                PTEAppObjectTableField.EnumTypeId := GetInteger(XmlNodeReader.GetAttribute('EnumTypeId'));
                                PTEAppObjectTableField.InitValue := XmlNodeReader.GetAttribute('InitValue');
                                PTEAppObjectTableField.ObsoleteState := XmlNodeReader.GetAttribute('ObsoleteState');
                                if PTEAppObjectTableField.ObsoleteState = 'No' then
                                    PTEAppObjectTableField.ObsoleteState := '';
                                PTEAppObjectTableField.ObsoleteReason := XmlNodeReader.GetAttribute('ObsoleteReason');
                                if (uppercase(XmlNodeReader.GetAttribute('Enabled')) <> 'NULL') and (XmlNodeReader.GetAttribute('Enabled') <> '') then
                                    PTEAppObjectTableField.Enabled := GetBoolean(XmlNodeReader.GetAttribute('Enabled'))
                                else
                                    PTEAppObjectTableField.Enabled := true;
                                if not PTEAppObjectTableField.Insert() then
                                    PTEAppObjectTableField.Modify();

                                if XmlNodeReader.GetAttribute('Datatype') = 'Option' then begin
                                    OptionString := XmlNodeReader.GetAttribute('OptionString');
                                    NoOfOptions := StrLen(DelChr(OptionString, '=', DELCHR(OptionString, '=', ','))) + 1;
                                    for i := 1 to NoOfOptions do begin
                                        PTEAppObjectTblFieldOpt.Init();
                                        PTEAppObjectTblFieldOpt."SQL Database Code" := PTEAppObjectTableField."SQL Database Code";
                                        PTEAppObjectTblFieldOpt."Table ID" := PTEAppObjectTableField."Table ID";
                                        PTEAppObjectTblFieldOpt."Table Name" := PTEAppObjectTableField."Table Name";
                                        PTEAppObjectTblFieldOpt."Field Name" := PTEAppObjectTableField.Name;
                                        PTEAppObjectTblFieldOpt."Field ID" := PTEAppObjectTableField."ID";
                                        PTEAppObjectTblFieldOpt."Option ID" := i - 1;
                                        PTEAppObjectTblFieldOpt.Name := CopyStr(SelectStr(i, OptionString), 1, MaxStrLen(PTEAppObjectTblFieldOpt.Name));
                                        if PTEAppObjectTblFieldOpt.Name <> '' then
                                            IF not PTEAppObjectTblFieldOpt.Insert() then;
                                    end;
                                end;
                            end;
                        end;
                    end;
                //Enum
                PTEAppObject."Type"::Enum:
                    begin
                        if XmlNodeReader.Name() = 'Enum' then begin
                            PTEAppObjectEnum.Init();
                            PTEAppObjectEnum."SQL Database Code" := PTEAppObject."SQL Database Code";
                            EnumID := GetInteger(XmlNodeReader.GetAttribute('ID'));
                            PTEAppObjectEnum."ID" := EnumID;
                            PTEAppObjectEnum.Name := XmlNodeReader.GetAttribute('Name');
                            PTEAppObjectEnum.Extensible := GetBoolean(XmlNodeReader.GetAttribute('Extensible'));
                            PTEAppObjectEnum.AssignmentCompatibility := FORMAT(XmlNodeReader.GetAttribute('AssignmentCompatibility'));
                            if not PTEAppObjectEnum.Insert() then
                                PTEAppObjectEnum.Modify();
                        end;
                        if XmlNodeReader.Name() = 'Value' then begin

                            PTEAppObjectEnumValue.INIT();
                            PTEAppObjectEnumValue."SQL Database Code" := PTEAppObject."SQL Database Code";
                            PTEAppObjectEnumValue."Enum ID" := EnumID;
                            PTEAppObjectEnumValue.Ordinal := GetInteger(XmlNodeReader.GetAttribute('Ordinal'));
                            PTEAppObjectEnumValue.Name := XmlNodeReader.GetAttribute('Name');
                            if not PTEAppObjectEnumValue.insert() then
                                PTEAppObjectEnumValue.modify();
                        END;
                    END;
                //Enum Extension
                PTEAppObject."Type"::EnumExtension:
                    begin
                        EnumID := GetInteger(PTEAppObject."Subtype");
                        IF XmlNodeReader.Name() = 'Value' then begin
                            PTEAppObjectEnumValue.INIT();
                            PTEAppObjectEnumValue."SQL Database Code" := PTEAppObject."SQL Database Code";
                            PTEAppObjectEnumValue."Enum ID" := EnumID;
                            PTEAppObjectEnumValue.Ordinal := GetInteger(XmlNodeReader.GetAttribute('Ordinal'));
                            PTEAppObjectEnumValue.Name := XmlNodeReader.GetAttribute('Name');
                            IF NOT PTEAppObjectEnumValue.Insert() then
                                PTEAppObjectEnumValue.Modify();
                        end;
                    end;
            end;
    end;



    local procedure GetObjectMetadataXMLFromSQL(PTEAppObject: Record "PTE App. Object"): BigText
    var
        PTESQLDatabase: Record "PTE SQL Database";
        ObjectMetadata: BigText;
        SQLConnection: DotNet SqlConnection;
        SQLCommand: DotNet SqlCommand;
        SQLReader: DotNet SqlDataReader;
        SQLQueryText: Text;
        ConnectionString: Text;
        NewLine: Text;
        char13: Char;
        char10: Char;
    begin
        PTESQLDatabase.GET(PTEAppObject."SQL Database Code");
        //Build SQL queries to run
        char13 := 13;
        char10 := 10;
        NewLine := FORMAT(char13) + FORMAT(char10);
        SQLQueryText := '';
        SQLQueryText := SQLQueryText + 'SELECT TOP 1' + NewLine;
        SQLQueryText := SQLQueryText + '  CAST(  ' + NewLine;
        SQLQueryText := SQLQueryText + '     DECOMPRESS(CONVERT(varbinary(max),CONCAT(' + NewLine;
        SQLQueryText := SQLQueryText + '        CONVERT(varbinary(max), 0x1F8B0800000000000400),' + NewLine;
        SQLQueryText := SQLQueryText + '        CONVERT(varbinary(max), SUBSTRING([Metadata],5,5000)),' + NewLine;
        SQLQueryText := SQLQueryText + 'CONVERT(varbinary(max), SUBSTRING([Metadata],5005,5000)),' + NewLine;
        SQLQueryText := SQLQueryText + 'CONVERT(varbinary(max), SUBSTRING([Metadata],10005,5000)),' + NewLine;
        SQLQueryText := SQLQueryText + 'CONVERT(varbinary(max), SUBSTRING([Metadata],15005,5000)),' + NewLine;
        SQLQueryText := SQLQueryText + 'CONVERT(varbinary(max), SUBSTRING([Metadata],20005,5000)),' + NewLine;
        SQLQueryText := SQLQueryText + 'CONVERT(varbinary(max), SUBSTRING([Metadata],25005,5000)),' + NewLine;
        SQLQueryText := SQLQueryText + 'CONVERT(varbinary(max), SUBSTRING([Metadata],30005,5000)),' + NewLine;
        SQLQueryText := SQLQueryText + 'CONVERT(varbinary(max), SUBSTRING([Metadata],35005,5000)),' + NewLine;
        SQLQueryText := SQLQueryText + 'CONVERT(varbinary(max), SUBSTRING([Metadata],40005,5000)),' + NewLine;
        SQLQueryText := SQLQueryText + 'CONVERT(varbinary(max), SUBSTRING([Metadata],45005,5000)),' + NewLine;
        SQLQueryText := SQLQueryText + 'CONVERT(varbinary(max), SUBSTRING([Metadata],50005,5000)),' + NewLine;
        SQLQueryText := SQLQueryText + 'CONVERT(varbinary(max), SUBSTRING([Metadata],55005,5000)),' + NewLine;
        SQLQueryText := SQLQueryText + 'CONVERT(varbinary(max), SUBSTRING([Metadata],60005,5000)),' + NewLine;
        SQLQueryText := SQLQueryText + 'CONVERT(varbinary(max), SUBSTRING([Metadata],65005,5000)),' + NewLine;
        SQLQueryText := SQLQueryText + 'CONVERT(varbinary(max), SUBSTRING([Metadata],70005,5000)),' + NewLine;
        SQLQueryText := SQLQueryText + 'CONVERT(varbinary(max), SUBSTRING([Metadata],75005,5000)),' + NewLine;
        SQLQueryText := SQLQueryText + 'CONVERT(varbinary(max), SUBSTRING([Metadata],80005,5000)),' + NewLine;
        SQLQueryText := SQLQueryText + 'CONVERT(varbinary(max), SUBSTRING([Metadata],85005,5000)),' + NewLine;
        SQLQueryText := SQLQueryText + 'CONVERT(varbinary(max), SUBSTRING([Metadata],90005,5000)),' + NewLine;
        SQLQueryText := SQLQueryText + 'CONVERT(varbinary(max), SUBSTRING([Metadata],95005,5000)),' + NewLine;
        SQLQueryText := SQLQueryText + 'CONVERT(varbinary(max), SUBSTRING([Metadata],100005,5000)),' + NewLine;
        SQLQueryText := SQLQueryText + 'CONVERT(varbinary(max), SUBSTRING([Metadata],105005,5000))' + NewLine;
        SQLQueryText := SQLQueryText + '))' + NewLine;
        SQLQueryText := SQLQueryText + '      )' + NewLine;
        SQLQueryText := SQLQueryText + '   as XML) as XML' + NewLine;
        SQLQueryText := SQLQueryText + 'from' + NewLine;
        SQLQueryText := SQLQueryText + '  [dbo].[' + PTEAppObject.Source + '] ' + NewLine;
        SQLQueryText := SQLQueryText + 'where ' + NewLine;
        SQLQueryText := SQLQueryText + '  [Object Type] = ' + FORMAT(PTEAppObject."Type", 0, 9) + ' and [Object ID] = ' + FORMAT(PTEAppObject."ID", 0, 9) + NewLine;
        if PTEAppObject."Package ID" <> '' then
            SQLQueryText := SQLQueryText + ' and [Package ID] = ''' + PTEAppObject."Package ID" + '''';
        ConnectionString := PTESQLDatabase.GetDatabaseConnectionString();
        SQLConnection := SQLConnection.SqlConnection(ConnectionString);
        SQLConnection.Open();
        SQLCommand := SQLCommand.SqlCommand(SQLQueryText, SQLConnection);
        SQLCommand.CommandTimeout := 10 * 60 * 100; // 10 min.
        SQLReader := SQLCommand.ExecuteReader();
        While SQLReader.Read() do
            ObjectMetadata.ADDTEXT(SQLReader.GetString(0));
        SQLConnection.Close();
        exit(ObjectMetadata);
    end;


    local procedure Strreplace(TextToChange: Text; Search: Text; Replace: Text): Text
    var
        i: Integer;
    begin
        i := STRPOS(TextToChange, Search);
        IF (i > 0) THEN BEGIN
            TextToChange := DELSTR(TextToChange, i, STRLEN(Search));
            EXIT(COPYSTR(TextToChange, 1, i - 1) +
              Replace +
              Strreplace(COPYSTR(TextToChange, i, STRLEN(TextToChange) - i + 1), Search, Replace));
        END ELSE
            EXIT(TextToChange);
    end;

    local procedure GetDBForbiddenChars(var PTESQLDatabase: Record "PTE SQL Database"): Text
    var
        SQLConnection: DotNet SQLConnection;
        SQLCommand: DotNet SqlCommand;
        SQLQueryText1: Text;
        SQLQueryText2: Text;
        ConnectionString: Text;
    begin
        PTESQLDatabase."Forbidden Chars" := '';
        PTESQLDatabase.Modify();

        SQLQueryText1 := 'select top 1 convertidentifiers from [$ndo$dbproperty]';
        SQLQueryText2 := 'select top 1 invalididentifierchars from [$ndo$dbproperty]';
        ConnectionString := PTESQLDatabase.GetDatabaseConnectionString();
        SQLConnection := SQLConnection.SqlConnection(ConnectionString);
        SQLConnection.Open();
        SQLCommand := SQLCommand.SqlCommand(SQLQueryText1, SQLConnection);
        SQLCommand.CommandTimeout := 10 * 60 * 100; // 10 min.
        IF FORMAT(SQLCommand.ExecuteScalar()) = '1' THEN BEGIN
            SQLCommand := SQLCommand.SqlCommand(SQLQueryText2, SQLConnection);
            SQLCommand.CommandTimeout := 10 * 60 * 100; // 10 min.
            PTESQLDatabase."Forbidden Chars" := FORMAT(SQLCommand.ExecuteScalar());
            PTESQLDatabase.Modify();
        END;
        SQLConnection.Close();
    end;

    local procedure GetSQLName(var PTESQLDatabase: Record "PTE SQL Database"; Name: Text): Text
    var
        ReplaceCharacters: Text;
        FindCharacters: Text;
    begin
        FindCharacters := PTESQLDatabase."Forbidden Chars";
        IF FindCharacters = '' THEN
            EXIT(Name);
        ReplaceCharacters := PADSTR(ReplaceCharacters, STRLEN(FindCharacters), '_');
        EXIT(CONVERTSTR(Name, FindCharacters, ReplaceCharacters));
    end;

    local procedure GetInteger(TextValue: Text): Integer
    var
        i: Integer;
    begin
        CASE uppercase(TextValue) OF
            'NULL':
                exit(0);
            '':
                exit(0);
        end;
        if EVALUATE(i, TextValue) then
            exit(i)
        else
            exit(0);
    end;

    local procedure GetBoolean(TextValue: Text): Boolean
    begin
        CASE uppercase(TextValue) OF
            'NULL':
                exit(false);
            '':
                exit(FALSE);
            '1':
                exit(TRUE);
            '0':
                exit(FALSE);
            'TRUE':
                exit(TRUE);
            'FALSE':
                exit(FALSE);
            'YES':
                exit(true);
            'NO':
                exit(false);
            else
                exit(FALSE);
        end;
    end;

    local procedure GetSQLTablesNumberOfRows(var PTESQLDatabase: Record "PTE SQL Database")
    var
        PTESQLDatabaseTable: Record "PTE SQL Database Table";
        SQLConnection: DotNet SqlConnection;
        SQLCommand: DotNet SqlCommand;
        SQLReader: DotNet SqlDataReader;
        SQLQueryText: Text;
        ConnectionString: Text;
        NewLine: Text;
        char13: Char;
        char10: Char;
    begin
        char13 := 13;
        char10 := 10;
        NewLine := FORMAT(char13) + FORMAT(char10);
        //Build SQL queries to run
        SQLQueryText := '';
        SQLQueryText := SQLQueryText + 'select tab.name as [table], ' + NewLine;
        SQLQueryText := SQLQueryText + 'sum(part.rows) as [rows]' + NewLine;
        SQLQueryText := SQLQueryText + 'from sys.tables tab' + NewLine;
        SQLQueryText := SQLQueryText + '        inner join sys.partitions part' + NewLine;
        SQLQueryText := SQLQueryText + '            on tab.object_id = part.object_id' + NewLine;
        SQLQueryText := SQLQueryText + 'where part.index_id IN (1, 0)' + NewLine;
        SQLQueryText := SQLQueryText + 'group by tab.name;' + NewLine;
        //Run query and download data
        ConnectionString := PTESQLDatabase.GetDatabaseConnectionString();
        SQLConnection := SQLConnection.SqlConnection(ConnectionString);
        SQLConnection.Open();

        SQLCommand := SQLCommand.SqlCommand(SQLQueryText, SQLConnection);
        SQLCommand.CommandTimeout := 10 * 60 * 100; // 10 min.
        SQLReader := SQLCommand.ExecuteReader();

        //Read columns data and put to the SQLColumns table
        While SQLReader.Read() do begin
            PTESQLDatabaseTable.SetRange("SQL Database Code", PTESQLDatabase.Code);
            PTESQLDatabaseTable.SetRange("Table Name", SQLReader.GetString(0));
            if PTESQLDatabaseTable.FindFirst() then begin
                PTESQLDatabaseTable."Number Of Records" := GetInteger(Format(SQLReader.GetValue(1)));
                PTESQLDatabaseTable.Modify();
            end;
        end;
        SQLConnection.Close();
    end;
}

