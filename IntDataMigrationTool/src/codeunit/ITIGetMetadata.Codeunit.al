
codeunit 99001 "ITI Get Metadata"
{
    TableNo = "ITI SQL Database";

    trigger OnRun()
    begin
        if Rec."Metadata Exists" then
            if not Confirm(DBASchemaExistsConfMsg, FALSE, rec."Code") then
                exit;

        GetDBForbiddenChars(Rec);
        GetDatabaseSchema(Rec);
        GetSQLTablesNumberOfRows(Rec);
        GetInstalledApps(Rec);
        GetAppVersion(Rec);
        GetObjectsMetadata(Rec);
        GetAllObjectDetail(Rec);
        FindSQLTableNames(Rec);
        GetCompanyNames(Rec);
        Rec."Metadata Exists" := true;
        Rec.Modify();
        Message(DownloadingCompletedMsg);
    end;

    var
        DBASchemaExistsConfMsg: Label 'The metadata for the %1 server has already been downloaded. Do you want to delete existing data and download again?', Comment = '%1 = Server Code';
        DownloadingDataMsg: Label 'Downloading tables and fields schema from %1 server. No Of Records: %2', Comment = '%1 = Server Code, %2 = No Of Records';
        DownloadingAppObjMsg: Label 'Downloading Application Objects from %1 server. No Of Records: %2', Comment = '%1 = Server Code, %2 = No Of Records';
        DownloadingInstalledAppsMsg: Label 'Downloading Installed Apps from %1 server. No Of Records: %2', Comment = '%1 = Server Code, %2 = No Of Records';
        DownloadingCompletedMsg: Label 'Downloading completed.';
        DownloadingMetaDataMsg: Label 'Downloading metadata from %1 server. No Of Objects: %2', Comment = '%1 = Server code, %2 = Number of objects';
        FindingSQLTableNamesMsg: Label 'Finding SQL table names for data from  %1 server. No Of Tables: %2', Comment = '%1 = Server code, %2 = Number of Tables';
        DownloadingCompanyNamesMsg: Label 'Downloading company names from  %1 server.', Comment = '%1 = Server code';

    local procedure GetDatabaseSchema(var ITISQLDatabase: Record "ITI SQL Database")
    var
        ITISQLDatabaseTableField: Record "ITI SQL Database Table Field";
        ITISQLDatabaseTable: Record "ITI SQL Database Table";
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
        SQLQueryText := 'SELECT COUNT([TABLE_CATALOG]) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_CATALOG = ''' + ITISQLDatabase."Database Name" + '''';
        SQLQueryText2 := 'SELECT [TABLE_CATALOG],[TABLE_SCHEMA],[TABLE_NAME],[COLUMN_NAME],[ORDINAL_POSITION],[DATA_TYPE],CONVERT(varchar,[CHARACTER_MAXIMUM_LENGTH]) as [CHARACTER_MAXIMUM_LENGTH],CONVERT(varchar,[CHARACTER_OCTET_LENGTH])as [CHARACTER_OCTET_LENGTH], [IS_NULLABLE], CONVERT(varchar, [COLUMN_DEFAULT]) AS [COLUMN_DEFAULT], COLUMNPROPERTY(OBJECT_ID(TABLE_NAME), COLUMN_NAME, ''IsIdentity'') as [AUTOINCREMENT], [COLLATION_NAME], [CHARACTER_SET_NAME] FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_CATALOG=''' + ITISQLDatabase."Database Name" + '''';
        SQLQueryText3 := 'SELECT COUNT([TABLE_CATALOG]) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_CATALOG = ''' + ITISQLDatabase."Database Name" + '''';
        SQLQueryText4 := 'SELECT [TABLE_CATALOG],[TABLE_SCHEMA],[TABLE_NAME],[TABLE_TYPE] FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_CATALOG = ''' + ITISQLDatabase."Database Name" + '''';
        ConnectionString := ITISQLDatabase.GetDatabaseConnectionString();

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
        ITISQLDatabaseTableField.SETRANGE("SQL Database Code", ITISQLDatabase."Code");
        ITISQLDatabaseTable.SETRANGE("SQL Database Code", ITISQLDatabase."Code");
        ITISQLDatabaseTableField.DeleteAll();
        ITISQLDatabaseTable.DeleteAll();


        //Open progress bar
        CurrentProgress := 0;
        ProgressTotal := NumberOfRecords;
        DialogProgress.OPEN(STRSUBSTNO(DownloadingDataMsg, ITISQLDatabase."Code", ProgressTotal) + ': #1#####', CurrentProgress);

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
            ITISQLDatabaseTableField.init();
            ITISQLDatabaseTableField."SQL Database Code" := ITISQLDatabase."Code";
            ITISQLDatabaseTableField."Entry No." := FieldEntryNo;
            //[TABLE_CATALOG]
            if not SQLReader.IsDBNull(0) then
                ITISQLDatabaseTableField."Table Catalog" := SQLReader.GetString(0);
            //[TABLE_SCHEMA]
            if not SQLReader.IsDBNull(1) then
                ITISQLDatabaseTableField."Table Schema" := SQLReader.GetString(1);
            //[TABLE_NAME]
            if not SQLReader.IsDBNull(2) then
                ITISQLDatabaseTableField."Table Name" := SQLReader.GetString(2);
            //[COLUMN_NAME]
            if not SQLReader.IsDBNull(3) then
                ITISQLDatabaseTableField."Column Name" := SQLReader.GetString(3);
            //[ORDINAL_POSITION]
            if not SQLReader.IsDBNull(4) then
                ITISQLDatabaseTableField."Ordinal Position" := GetInteger(Format(SQLReader.GetValue(4)));
            //[DATA_TYPE]
            if not SQLReader.IsDBNull(5) then
                ITISQLDatabaseTableField."Data Type" := SQLReader.GetString(5);
            //[CHARACTER_MAXIMUM_LENGTH]
            if not SQLReader.IsDBNull(6) then
                ITISQLDatabaseTableField."Character Maximum Length" := GetInteger(SQLReader.GetString(6));
            //[CHARACTER_OCTET_LENGTH]
            if not SQLReader.IsDBNull(7) then
                ITISQLDatabaseTableField."Character Octet Lenght" := GetInteger(SQLReader.GetString(7));
            if not SQLReader.IsDBNull(8) then
                ITISQLDatabaseTableField."Allow Nulls" := GetBoolean(Format(SQLReader.GetValue(8)));
            //[COLUMN_DEFAULT]
            if not SQLReader.IsDBNull(9) then
                ITISQLDatabaseTableField."Column Default" := FORMAT(SQLReader.GetString(9))
            else
                ITISQLDatabaseTableField."Column Default" := '#NULL#';
            //[AUTOINCREMENT]
            if not SQLReader.IsDBNull(10) then
                if GetInteger(Format(SQLReader.GetValue(10))) > 0 then
                    ITISQLDatabaseTableField.Autoincrement := true
                else
                    ITISQLDatabaseTableField.Autoincrement := false;
            //[COLLATION_NAME] 
            if not SQLReader.IsDBNull(11) then
                ITISQLDatabaseTableField."Collation Name" := SQLReader.GetString(11);
            //[CHARACTER_SET_NAME]
            if not SQLReader.IsDBNull(12) then
                ITISQLDatabaseTableField."Character Set Name" := SQLReader.GetString(12);
            ITISQLDatabaseTableField.insert();
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
            ITISQLDatabaseTable.INIT();
            ITISQLDatabaseTable."SQL Database Code" := ITISQLDatabase."Code";
            ;
            ITISQLDatabaseTable."Entry No." := TableEntryNo;
            //[TABLE_CATALOG]
            if not SQLReader.IsDBNull(0) then
                ITISQLDatabaseTable."Table Catalog" := SQLReader.GetString(0);
            //[TABLE_SCHEMA]
            if not SQLReader.IsDBNull(1) then
                ITISQLDatabaseTable."Table Schema" := SQLReader.GetString(1);
            //[TABLE_NAME]
            if not SQLReader.IsDBNull(2) then
                ITISQLDatabaseTable."Table Name" := SQLReader.GetString(2);
            //[TABLE_TYPE]
            if not SQLReader.IsDBNull(3) then
                ITISQLDatabaseTable."Table Type" := SQLReader.GetString(3);
            TableName := ITISQLDatabaseTable."Table Name";
            Pattern := '[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}';
            RegEx.Match(TableName, Pattern, Matches);
            ITISQLDatabaseTable."App ID" := CopyStr(UPPERCASE(FORMAT(Matches.ReadValue())), 1, MaxStrLen(ITISQLDatabaseTable."App ID"));
            ITISQLDatabaseTable.Insert();

            //update progress bar
            CurrentProgress := CurrentProgress + 1;
            DialogProgress.UPDATE(1, CurrentProgress);
        end;

        DialogProgress.CLOSE();
        SQLConnection.Close();
    end;

    local procedure GetCompanyNames(var ITISQLDatabase: Record "ITI SQL Database")
    var
        ITISQLDatabaseCompany: Record "ITI SQL Database Company";
        SQLConnection: DotNet SqlConnection;
        SQLCommand: DotNet SqlCommand;
        SQLReader: DotNet SqlDataReader;
        SQLQueryText: Text;
        ConnectionString: Text;
        DialogProgress: Dialog;
    begin
        DialogProgress.OPEN(STRSUBSTNO(DownloadingCompanyNamesMsg, ITISQLDatabase.Code));
        //Build SQL queries to run
        SQLQueryText := 'SELECT [Name] FROM [dbo].[Company]';

        //Delete data if exists
        ITISQLDatabaseCompany.SetRange("SQL Database Code", ITISQLDatabase."Code");
        ITISQLDatabaseCompany.DeleteAll();


        //Download company names
        ConnectionString := ITISQLDatabase.GetDatabaseConnectionString();
        SQLConnection := SQLConnection.SqlConnection(ConnectionString);
        SQLConnection.Open();

        SQLCommand := SQLCommand.SqlCommand(SQLQueryText, SQLConnection);
        SQLCommand.CommandTimeout := 10 * 60 * 100; // 10 min.
        SQLReader := SQLCommand.ExecuteReader();

        //Read columns data and put to the SQLColumns table
        While SQLReader.Read() do begin
            ITISQLDatabaseCompany.Init();
            ITISQLDatabaseCompany."SQL Database Code" := ITISQLDatabase."Code";
            //[Name]
            ITISQLDatabaseCompany.Name := SQLReader.GetValue(0);
            //SQL Name
            ITISQLDatabaseCompany."SQL Name" := CopyStr(GetSQLName(ITISQLDatabase, ITISQLDatabaseCompany.Name), 1, MaxStrLen(ITISQLDatabaseCompany.Name));
            ITISQLDatabaseCompany.Insert();
        end;
        SQLConnection.Close();
        DialogProgress.Close();
    end;

    local procedure GetAppVersion(var ITISQLDatabase: Record "ITI SQL Database")
    var
        SQLConnection: DotNet SqlConnection;
        SQLCommand: DotNet SqlCommand;
        SQLReader: DotNet SqlDataReader;
        SQLQueryText: Text;
        ConnectionString: Text;
    begin
        if not (DatabaseFieldExists(ITISQLDatabase."Code", '$ndo$dbproperty', 'applicationversion') and DatabaseFieldExists(ITISQLDatabase."Code", '$ndo$dbproperty', 'applicationfamily')) then
            exit;
        SQLQueryText := 'SELECT TOP (1) [applicationversion], [applicationfamily] FROM [dbo].[$ndo$dbproperty]';
        ConnectionString := ITISQLDatabase.GetDatabaseConnectionString();
        SQLConnection := SQLConnection.SqlConnection(ConnectionString);
        SQLConnection.Open();
        SQLCommand := SQLCommand.SqlCommand(SQLQueryText, SQLConnection);
        SQLCommand.CommandTimeout := 10 * 60 * 100; // 10 min.
        SQLReader := SQLCommand.ExecuteReader();

        WHILE SQLReader.Read() DO BEGIN
            //[applicationversion]
            ITISQLDatabase."Application Version" := FORMAT(SQLReader.GetValue(0));
            //[applicationfamily]
            ITISQLDatabase."Application Family" := FORMAT(SQLReader.GetValue(1));
            ITISQLDatabase.Modify();
        end;
        SQLConnection.Close();
    end;

    local procedure GetInstalledApps(var ITISQLDatabase: Record "ITI SQL Database")
    var
        ITISQLDatabaseInstalledApps: Record "ITI SQL Database Installed App";
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
        ITISQLDatabaseInstalledApps.SetRange("SQL Database Code", ITISQLDatabase."Code");
        ITISQLDatabaseInstalledApps.DeleteAll();
        //Check if NAV App Installed App table exists
        if not DatabaseTableExists(ITISQLDatabase."Code", 'NAV App Installed App') then
            exit;

        //Build SQL queries to run
        SQLQueryText := 'SELECT COUNT([App ID]) FROM [dbo].[NAV App Installed App]';
        SQLQueryText2 := 'SELECT [App ID],[Package ID],[Name],[Publisher],[Version Major],[Version Minor],[Version Build],[Version Revision]';
        if DatabaseFieldExists(ITISQLDatabase."Code", 'NAV App Installed App', '$systemId') then
            SQLQueryText2 := SQLQueryText2 + ',[$systemId]';
        SQLQueryText2 := SQLQueryText2 + ' FROM[dbo].[NAV App Installed App]';
        ConnectionString := ITISQLDatabase.GetDatabaseConnectionString();

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
        DialogProgress.Open(STRSUBSTNO(DownloadingInstalledAppsMsg, ITISQLDatabase."Code", ProgressTotal) + ': #1#####', CurrentProgress);


        //Download installed apps data data
        SQLConnection := SQLConnection.SqlConnection(ConnectionString);
        SQLConnection.Open();
        SQLCommand := SQLCommand.SqlCommand(SQLQueryText2, SQLConnection);
        SQLCommand.CommandTimeout := 10 * 60 * 100; // 10 min.
        SQLReader := SQLCommand.ExecuteReader();

        //Read columns data and put to the SQLColumns table
        WHILE SQLReader.Read() DO BEGIN
            ITISQLDatabaseInstalledApps.Init();
            ITISQLDatabaseInstalledApps."SQL Database Code" := ITISQLDatabase."Code";

            //[App ID]
            ITISQLDatabaseInstalledApps."ID" := CopyStr(UPPERCASE(FORMAT(SQLReader.GetValue(0))), 1, MaxStrLen(ITISQLDatabaseInstalledApps."ID"));
            ITISQLDatabaseInstalledApps."ID" := DELCHR(ITISQLDatabaseInstalledApps."ID", '=', '{}');
            //[Package ID]
            ITISQLDatabaseInstalledApps."Package ID" := FORMAT(SQLReader.GetValue(1));
            ITISQLDatabaseInstalledApps."Package ID" := DELCHR(ITISQLDatabaseInstalledApps."Package ID", '=', '{}');
            //[Name]
            ITISQLDatabaseInstalledApps.Name := SQLReader.GetValue(2);
            //[Publisher]
            ITISQLDatabaseInstalledApps.Publisher := SQLReader.GetValue(3);
            //[Version Major]
            if not SQLReader.IsDBNull(4) then
                ITISQLDatabaseInstalledApps."Version Major" := GetInteger(FORMAT(SQLReader.GetValue(4)));
            //[Version Minor]
            if not SQLReader.IsDBNull(5) then
                ITISQLDatabaseInstalledApps."Version Major" := GetInteger(FORMAT(SQLReader.GetValue(5)));
            //[Version Build]
            if not SQLReader.IsDBNull(6) then
                ITISQLDatabaseInstalledApps."Version Build" := GetInteger(FORMAT(SQLReader.GetValue(6)));
            //[Version Revision]
            if not SQLReader.IsDBNull(7) then
                ITISQLDatabaseInstalledApps."Version Revision" := GetInteger(FORMAT(SQLReader.GetValue(7)));
            //[$systemId]
            if DatabaseFieldExists(ITISQLDatabase."Code", 'NAV App Installed App', '$systemId') then begin
                ITISQLDatabaseInstalledApps."System ID" := FORMAT(SQLReader.GetValue(8));
                ITISQLDatabaseInstalledApps."System ID" := DELCHR(ITISQLDatabaseInstalledApps."System ID", '=', '{}');
            end;
            ITISQLDatabaseInstalledApps.Insert();

            //update progress bar
            CurrentProgress := CurrentProgress + 1;
            DialogProgress.Update();
        end;
        SQLConnection.Close();
        DialogProgress.Close();
    end;

    local procedure DatabaseFieldExists(SQLDatabaseCode: code[20]; TableName: Text; FieldName: Text): Boolean
    var
        ITISQLDatabaseTableField: record "ITI SQL Database Table Field";
    begin
        ITISQLDatabaseTableField.SetRange("SQL Database Code", SQLDatabaseCode);
        ITISQLDatabaseTableField.SetRange("Table Name", TableName);
        ITISQLDatabaseTableField.SetRange("Column Name", FieldName);
        exit(not ITISQLDatabaseTableField.IsEmpty);
    end;

    local procedure DatabaseTableExists(SQLDatabaseCode: code[20]; TableName: Text): Boolean
    var
        ITISQLDatabaseTable: Record "ITI SQL Database Table";
    begin
        ITISQLDatabaseTable.SetRange("SQL Database Code", SQLDatabaseCode);
        ITISQLDatabaseTable.SetRange("Table Name", TableName);
        exit(not ITISQLDatabaseTable.IsEmpty);
    end;

    local procedure GetObjectsMetadata(var ITISQLDatabase: Record "ITI SQL Database")
    var
        ITIAppObject: Record "ITI App. Object";
    begin
        //Delete data if exists
        ITIAppObject.SetRange("SQL Database Code", ITISQLDatabase."Code");
        ITIAppObject.DeleteAll();

        if ITISQLDatabase."Use Metadata Set Code" <> '' then begin
            GetObjectsMetadataFromMetadataSet(ITISQLDatabase);
            exit;
        end;
        //Object Metadata
        if DatabaseTableExists(ITISQLDatabase."Code", 'Object Metadata') then
            GetObjectsMetadataFromSource(ITISQLDatabase, 'Object Metadata');

        //Object Metadata Snapshot
        //ITISQLServerTables.SETRANGE("Server Code", ITISQLServerSetup."Server Code");
        //ITISQLServerTables.SETFILTER("Table Name", 'Object Metadata Snapshot');
        //if NOT ITISQLServerTables.IsEmpty then
        //    GetObjectsMetadataFromSource(ITISQLServerSetup, 'Object Metadata Snapshot');

        //NAV App Object Metadata
        if DatabaseTableExists(ITISQLDatabase."Code", 'NAV App Object Metadata') then
            GetObjectsMetadataFromSource(ITISQLDatabase, 'NAV App Object Metadata');

        //Application Object Metadata
        if DatabaseTableExists(ITISQLDatabase."Code", 'Application Object Metadata') then
            GetObjectsMetadataFromSource(ITISQLDatabase, 'Application Object Metadata');
    end;


    local procedure GetObjectsMetadataFromMetadataSet(var ITISQLDatabase: Record "ITI SQL Database");
    var
        ITIAppMetadataSetObject: Record "ITI App. Metadata Set Object";
        ITIAppObject: Record "ITI App. Object";
        NumberOfRecords: Integer;
        DialogProgress: Dialog;
        ProgressTotal: Integer;
        CurrentProgress: Integer;
    begin

        if ITISQLDatabase."Use Metadata Set Code" <> '' then begin
            ITIAppMetadataSetObject.SetRange("App. Metadata Set Code", ITISQLDatabase."Use Metadata Set Code");
            NumberOfRecords := ITIAppMetadataSetObject.Count;
            //Open progress bar
            CurrentProgress := 0;
            ProgressTotal := NumberOfRecords;
            DialogProgress.OPEN(STRSUBSTNO(DownloadingAppObjMsg, ITISQLDatabase."Code", ProgressTotal) + ': #1#####', CurrentProgress);

            if ITIAppMetadataSetObject.FindSet() then
                repeat
                    ITIAppObject.INIT();
                    ITIAppObject."SQL Database Code" := ITISQLDatabase."Code";
                    ITIAppObject.Source := '';
                    ITIAppObject."Type" := ITIAppMetadataSetObject."Object Type";
                    ITIAppObject."ID" := ITIAppMetadataSetObject."Object ID";
                    ITIAppObject."Subtype" := ITIAppMetadataSetObject."Object Subtype";
                    ITIAppObject."Package ID" := '';
                    ITIAppObject."Runtime Package ID" := '';
                    if ITIAppObject."Package ID" <> '' then begin
                        if IsPackageInstalled(ITIAppObject."Package ID") then
                            if not ITIAppObject.Insert() then;
                    end else
                        if not ITIAppObject.Insert() then;
                    //update progress bar
                    CurrentProgress := CurrentProgress + 1;
                    DialogProgress.Update();
                until ITIAppMetadataSetObject.Next() = 0;
            DialogProgress.Close();
        end;
    end;


    local procedure GetObjectsMetadataFromSource(var ITISQLDatabase: Record "ITI SQL Database"; SourceTable: Text[250]);
    var
        ITIAppObject: Record "ITI App. Object";
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
        //Build SQL queries to run
        SQLQueryText := 'SELECT COUNT([Object ID]) FROM [' + SourceTable + ']';
        SQLQueryText2 := 'SELECT [Object Type],[Object ID]';
        if DatabaseFieldExists(ITISQLDatabase.Code, SourceTable, 'Object Subtype') then
            SQLQueryText2 := SQLQueryText2 + ',[Object Subtype]';
        if DatabaseFieldExists(ITISQLDatabase.Code, SourceTable, 'Package ID') then
            SQLQueryText2 := SQLQueryText2 + ',[Package ID]';
        if DatabaseFieldExists(ITISQLDatabase.Code, SourceTable, 'Runtime Package ID') then
            SQLQueryText2 := SQLQueryText2 + ',[Runtime Package ID]';
        SQLQueryText2 := SQLQueryText2 + ' FROM [' + SourceTable + ']';
        ConnectionString := ITISQLDatabase.GetDatabaseConnectionString();

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
        DialogProgress.OPEN(STRSUBSTNO(DownloadingAppObjMsg, ITISQLDatabase."Code", ProgressTotal) + ': #1#####', CurrentProgress);

        //Download metadata
        SQLConnection := SQLConnection.SqlConnection(ConnectionString);
        SQLConnection.Open();
        SQLCommand := SQLCommand.SqlCommand(SQLQueryText2, SQLConnection);
        SQLCommand.CommandTimeout := 10 * 60 * 100; // 10 min.
        SQLReader := SQLCommand.ExecuteReader();

        //Read columns data and put to the NAV table
        while SQLReader.Read() do begin
            ITIAppObject.INIT();
            ITIAppObject."SQL Database Code" := ITISQLDatabase."Code";
            ITIAppObject.Source := SourceTable;
            //[Object Type]
            if not SQLReader.IsDBNull(0) then
                Evaluate(ITIAppObject."Type", FORMAT(SQLReader.GetValue(0)));
            //[Object ID]
            if not SQLReader.IsDBNull(1) then
                ITIAppObject."ID" := GetInteger(FORMAT(SQLReader.GetValue(1)));
            //[Object Subtype]
            if DatabaseFieldExists(ITISQLDatabase.Code, SourceTable, 'Object Subtype') then
                if not SQLReader.IsDBNull(2) then
                    Evaluate(ITIAppObject."Subtype", FORMAT(SQLReader.GetString(2)));
            //[Package ID]
            if DatabaseFieldExists(ITISQLDatabase.Code, SourceTable, 'Package ID') then
                if not SQLReader.IsDBNull(3) then begin
                    Evaluate(ITIAppObject."Package ID", FORMAT(SQLReader.GetValue(3)));
                    ITIAppObject."Package ID" := DELCHR(ITIAppObject."Package ID", '=', '{}');
                end;
            //[Runtime Package ID]
            if DatabaseFieldExists(ITISQLDatabase.Code, SourceTable, 'Runtime Package ID') then
                if not SQLReader.IsDBNull(4) then begin
                    Evaluate(ITIAppObject."Runtime Package ID", FORMAT(SQLReader.GetValue(4)));
                    ITIAppObject."Runtime Package ID" := DELCHR(ITIAppObject."Runtime Package ID", '=', '{}');
                end;
            if ITIAppObject."Package ID" <> '' then begin
                if IsPackageInstalled(ITIAppObject."Package ID") then
                    if not ITIAppObject.Insert() then;
            end else
                if not ITIAppObject.Insert() then;
            //update progress bar
            CurrentProgress := CurrentProgress + 1;
            DialogProgress.Update();
        end;
        SQLConnection.Close();

        DialogProgress.Close();
    end;

    local procedure IsPackageInstalled(PackageID: text): Boolean
    var
        ITISQLDatabaseInstalledApp: Record "ITI SQL Database Installed App";
    begin
        if ITISQLDatabaseInstalledApp.IsEmpty then
            exit(false);
        ITISQLDatabaseInstalledApp.SetFilter("Package ID", '@' + PackageID);
        exit(not ITISQLDatabaseInstalledApp.IsEmpty);
    end;

    local procedure GetAllObjectDetail(var ITISQLDatabase: Record "ITI SQL Database")
    var
        ITIAppObject: Record "ITI App. Object";
        ITIAppObjectTable: Record "ITI App. Object Table";
        ITIAppObjectTableField: Record "ITI App. Object Table Field";
        ITIAppObjectTblFieldOpt: Record "ITI App. Object Tbl.Field Opt.";
        ITIAppObjectEnum: Record "ITI App. Object Enum";
        ITIAppObjectEnumValue: Record "ITI App. Object Enum Value";
        DialogProgress: Dialog;
        ProgressTotal: Integer;
        CurrentProgress: Integer;
    begin
        //delete existing objects
        ITIAppObjectTable.SetRange("SQL Database Code", ITISQLDatabase."Code");
        ITIAppObjectTableField.SetRange("SQL Database Code", ITISQLDatabase."Code");
        ITIAppObjectTblFieldOpt.SetRange("SQL Database Code", ITISQLDatabase."Code");
        ITIAppObjectEnum.SetRange("SQL Database Code", ITISQLDatabase."Code");
        ITIAppObjectEnumValue.SetRange("SQL Database Code", ITISQLDatabase."Code");
        ITIAppObjectTable.DeleteAll();
        ITIAppObjectTableField.DeleteAll();
        ITIAppObjectTblFieldOpt.DeleteAll();
        ITIAppObjectEnum.DeleteAll();
        ITIAppObjectEnumValue.DeleteAll();

        //read parse and insert objects from metadata
        ITIAppObject.SetRange("SQL Database Code", ITISQLDatabase."Code");
        //filter all objects to find total number for count
        ITIAppObject.SetFilter("Type", '%1|%2|%3|%4', ITIAppObject."Type"::Table, ITIAppObject."Type"::"TableExtension", ITIAppObject."Type"::Enum, ITIAppObject."Type"::EnumExtension);
        ProgressTotal := ITIAppObject.count();
        DialogProgress.Open(STRSUBSTNO(DownloadingMetaDataMsg, ITISQLDatabase."Code", ProgressTotal) + ': #1#####', CurrentProgress);
        //get objects without table extensions
        ITIAppObject.SetFilter("Type", '%1|%2|%3', ITIAppObject."Type"::Table, ITIAppObject."Type"::Enum, ITIAppObject."Type"::EnumExtension);
        if ITIAppObject.FindSet() then
            repeat
                GetObjectDetail(ITIAppObject);
                CurrentProgress := CurrentProgress + 1;
                DialogProgress.Update();
            until ITIAppObject.Next() = 0;
        //get objects table extensions - it was not possible in previous loop, because extended table object is needed before
        ITIAppObject.SetRange("Type", ITIAppObject."Type"::"TableExtension");
        if ITIAppObject.FindSet() then
            repeat
                GetObjectDetail(ITIAppObject);
                CurrentProgress := CurrentProgress + 1;
                DialogProgress.Update();
            until ITIAppObject.Next() = 0;
        DialogProgress.Close();

        //Fill in Options based Enum
        ITIAppObjectTableField.SetRange("SQL Database Code", ITISQLDatabase."Code");
        ITIAppObjectTableField.SetFilter(EnumTypeID, '<>0');
        if ITIAppObjectTableField.FindSet() then
            repeat
                ITIAppObjectEnumValue.SetRange("SQL Database Code", ITIAppObjectTableField."SQL Database Code");
                ITIAppObjectEnumValue.SetRange("Enum ID", ITIAppObjectTableField.EnumTypeID);
                if ITIAppObjectEnumValue.FindSet() then
                    repeat
                        ITIAppObjectTblFieldOpt.Init();
                        ITIAppObjectTblFieldOpt."SQL Database Code" := ITIAppObjectTableField."SQL Database Code";
                        ITIAppObjectTblFieldOpt."Table ID" := ITIAppObjectTableField."Table ID";
                        ITIAppObjectTblFieldOpt."Table Name" := ITIAppObjectTableField."Table Name";
                        ITIAppObjectTblFieldOpt."Field ID" := ITIAppObjectTableField."ID";
                        ITIAppObjectTblFieldOpt."Field Name" := ITIAppObjectTableField."Name";
                        ITIAppObjectTblFieldOpt."Option ID" := ITIAppObjectEnumValue.Ordinal;
                        ITIAppObjectTblFieldOpt.Name := ITIAppObjectEnumValue.Name;
                        if not ITIAppObjectTblFieldOpt.Insert() then
                            ITIAppObjectTblFieldOpt.Modify();
                    until ITIAppObjectEnumValue.Next() = 0;
            until ITIAppObjectTableField.Next() = 0;
    end;

    procedure FindSQLTableNames(var ITISQLDatabase: Record "ITI SQL Database")
    var
        ITIAppObjectTable: Record "ITI App. Object Table";
        ITIAppObjectTableField: Record "ITI App. Object Table Field";
        ITISQLDatabaseTable: Record "ITI SQL Database Table";
        ITISQLDatabaseTableField: Record "ITI SQL Database Table Field";
        DialogProgress: Dialog;
        ProgressTotal: Integer;
        CurrentProgress: Integer;
        CheckedTables: Boolean;
        SQLTableName: Text;
        SQLTableNameWithAppID: Text;
        TableNameFilter: Text;
    begin
        ITIAppObjectTable.Reset();
        ITIAppObjectTableField.Reset();
        ITIAppObjectTable.SetRange("SQL Database Code", ITISQLDatabase."Code");
        ProgressTotal := ITIAppObjectTable.count();
        CurrentProgress := 0;
        DialogProgress.OPEN(STRSUBSTNO(FindingSQLTableNamesMsg, ITISQLDatabase."Code", ProgressTotal) + ': #1#####', CurrentProgress);
        if ITIAppObjectTable.FindSet() then
            repeat
                CheckedTables := false;
                ITIAppObjectTableField.SetRange("SQL Database Code", ITIAppObjectTable."SQL Database Code");
                ITIAppObjectTableField.SetRange("Table ID", ITIAppObjectTable."ID");
                ITIAppObjectTableField.SetFilter(FieldClass, '%1|Normal', '');
                ITIAppObjectTableField.SetFilter(Datatype, '<>TableFilter', '');
                ITISQLDatabaseTable.SetRange("SQL Database Code", ITIAppObjectTable."SQL Database Code");
                ITISQLDatabaseTable.SetRange("Table Type", 'BASE TABLE');
                SQLTableName := GetSQLName(ITISQLDatabase, ITIAppObjectTable.Name);
                if ITIAppObjectTableField.FindSet() then
                    repeat
                        TableNameFilter := '';
                        if ITIAppObjectTableField."App ID" <> '' then
                            SQLTableNameWithAppID := SQLTableName + '$' + ITIAppObjectTableField."App ID"
                        else
                            SQLTableNameWithAppID := SQLTableName;
                        if ITIAppObjectTable.DataPerCompany then
                            TableNameFilter := '''' + '*$' + SQLTableNameWithAppID + ''''
                        else
                            TableNameFilter := '''' + SQLTableNameWithAppID + '''';
                        ITISQLDatabaseTable.SetFilter("Table Name", TableNameFilter);

                        //support for the new BC23 structure
                        if ITISQLDatabaseTable.IsEmpty then
                            if LowerCase(ITIAppObjectTableField."App ID") <> LowerCase(ITIAppObjectTable.SourceAppId) then begin
                                TableNameFilter := '';
                                if ITIAppObjectTable.SourceAppId <> '' then
                                    SQLTableNameWithAppID := SQLTableName + '$' + ITIAppObjectTable.SourceAppId + '$ext'
                                else
                                    SQLTableNameWithAppID := SQLTableName + '$ext';

                                if ITIAppObjectTable.DataPerCompany then
                                    TableNameFilter := '''' + '*$' + SQLTableNameWithAppID + ''''
                                else
                                    TableNameFilter := '''' + SQLTableNameWithAppID + '''';
                                ITISQLDatabaseTable.SetFilter("Table Name", TableNameFilter);
                            end;


                        if not ITISQLDatabaseTable.IsEmpty then begin
                            ITISQLDatabaseTableField.SetRange("SQL Database Code", ITIAppObjectTable."SQL Database Code");
                            ITISQLDatabaseTableField.SetFilter("Table Name", TableNameFilter);
                            ITISQLDatabaseTableField.SetRange("Column Name", ITIAppObjectTableField."SQL Field Name Candidate");
                            if not ITISQLDatabaseTableField.IsEmpty then begin
                                ITIAppObjectTableField."SQL Field Name" := ITIAppObjectTableField."SQL Field Name Candidate";
                                ITIAppObjectTableField."SQL Table Name Excl. C. Name" := CopyStr(SQLTableNameWithAppID, 1, MaxStrLen(ITIAppObjectTableField."SQL Table Name Excl. C. Name"));
                                ITIAppObjectTableField.Modify();
                            end else begin
                                ITISQLDatabaseTableField.SetRange("Column Name", ITIAppObjectTableField."SQL Field Name Candidate 2");
                                if not ITISQLDatabaseTableField.IsEmpty then begin
                                    ITIAppObjectTableField."SQL Field Name" := ITIAppObjectTableField."SQL Field Name Candidate 2";
                                    ITIAppObjectTableField."SQL Table Name Excl. C. Name" := CopyStr(SQLTableNameWithAppID, 1, MaxStrLen(ITIAppObjectTableField."SQL Table Name Excl. C. Name"));
                                    ITIAppObjectTableField.Modify();
                                end;
                            end;

                            if ITISQLDatabaseTable.FindSet() and not CheckedTables then begin
                                ITIAppObjectTable."Number Of Records" := 0;
                                repeat
                                    if ITIAppObjectTable."Number Of Records" < ITISQLDatabaseTable."Number Of Records" then
                                        ITIAppObjectTable."Number Of Records" := ITISQLDatabaseTable."Number Of Records";
                                until ITISQLDatabaseTable.Next() = 0;
                                ITIAppObjectTable.Modify();
                                CheckedTables := true;
                            end;
                        end;
                    until ITIAppObjectTableField.Next() = 0;
                CurrentProgress := CurrentProgress + 1;
                DialogProgress.Update();
            until ITIAppObjectTable.Next() = 0;
        DialogProgress.Close();
    end;

    procedure DownloadObject(ITIAppObject: Record "ITI App. Object")
    var
        FileManagement: Codeunit "File Management";
        ObjectMetadata: BigText;
        DataFile: File;
        FileName: Text;

    begin
        ObjectMetadata := GetObjectMetadataXMLFromSQL(ITIAppObject);
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

    local procedure GetObjectDetail(ITIAppObject: Record "ITI App. Object")
    var
        ITISQLDatabase: Record "ITI SQL Database";
        ITIAppObjectTable: Record "ITI App. Object Table";
        ITIAppObjectTableField: Record "ITI App. Object Table Field";
        ITIAppObjectEnum: Record "ITI App. Object Enum";
        ITIAppObjectEnumValue: Record "ITI App. Object Enum Value";
        ITIAppObjectTblFieldOpt: Record "ITI App. Object Tbl.Field Opt.";
        ITISQLDatabaseTable: Record "ITI SQL Database Table";
        ITIAppMetadataSetObject: Record "ITI App. Metadata Set Object";
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
        ITISQLDatabase.GET(ITIAppObject."SQL Database Code");
        if ITISQLDatabase."Use Metadata Set Code" <> '' then begin
            ITIAppMetadataSetObject.Get(ITISQLDatabase."Use Metadata Set Code", ITIAppObject.ID, ITIAppObject.Type);
            ObjectMetadata := ITIAppMetadataSetObject.GetMetadataText();
        end else
            ObjectMetadata := GetObjectMetadataXMLFromSQL(ITIAppObject);

        GetXMLMetadata(ObjectMetadata, XmlDocument);
        XmlNodeReader := XmlNodeReader.XmlNodeReader(XmlDocument);
        while XmlNodeReader.Read() do
            case ITIAppObject."Type" of
                //table
                ITIAppObject."Type"::Table:
                    begin
                        if XmlNodeReader.Name() = 'MetaTable' then begin
                            ITIAppObjectTable."SQL Database Code" := ITIAppObject."SQL Database Code";
                            TableID := GetInteger(XmlNodeReader.GetAttribute('ID'));
                            TableName := XmlNodeReader.GetAttribute('Name');
                            ITIAppObjectTable."ID" := TableID;
                            ITIAppObjectTable.Name := TableName;
                            ITIAppObjectTable.TableType := XmlNodeReader.GetAttribute('TableType');
                            ITIAppObjectTable.CompressionType := XmlNodeReader.GetAttribute('CompressionType');
                            ITIAppObjectTable.Access := XmlNodeReader.GetAttribute('Access');
                            ITIAppObjectTable.PasteIsValid := GetBoolean(XmlNodeReader.GetAttribute('PasteIsValid'));
                            ITIAppObjectTable.LinkedObject := XmlNodeReader.GetAttribute('LinkedObject');
                            ITIAppObjectTable.Extensible := GetBoolean(XmlNodeReader.GetAttribute('Extensible'));
                            ITIAppObjectTable.ReplicateData := GetBoolean(XmlNodeReader.GetAttribute('ReplicateData'));
                            ITIAppObjectTable.DataClassification := XmlNodeReader.GetAttribute('DataClassification');
                            if ITISQLDatabase."Use Metadata Set Code" <> '' then
                                ITIAppObjectTable.DataPerCompany := ITIAppMetadataSetObject."Data Per Company"
                            else
                                ITIAppObjectTable.DataPerCompany := GetBoolean(XmlNodeReader.GetAttribute('DataPerCompany'));
                            ITIAppObjectTable.SourceAppId := XmlNodeReader.GetAttribute('SourceAppId');
                            ITIAppObjectTable.SourceExtensionType := XmlNodeReader.GetAttribute('SourceExtensionType');
                            ITIAppObjectTable.ObsoleteState := XmlNodeReader.GetAttribute('ObsoleteState');
                            if ITIAppObjectTable.ObsoleteState = 'No' then
                                ITIAppObjectTable.ObsoleteState := '';
                            ITIAppObjectTable.ObsoleteReason := XmlNodeReader.GetAttribute('ObsoleteReason');
                            if not ITIAppObjectTable.Insert() then
                                ITIAppObjectTable.Modify();
                        END;
                        IF XmlNodeReader.Name() = 'Field' then begin
                            SQFieldName := XmlNodeReader.GetAttribute('Name');
                            SQFieldName := GetSQLName(ITISQLDatabase, XmlNodeReader.GetAttribute('Name'));
                            ITISQLDatabaseTable.SetRange("SQL Database Code", ITIAppObject."SQL Database Code");
                            if SQFieldName <> '' then begin
                                ITIAppObjectTableField.INIT();
                                ITIAppObjectTableField."SQL Database Code" := ITIAppObject."SQL Database Code";
                                ITIAppObjectTableField."Table ID" := TableID;
                                ITIAppObjectTableField."Table Name" := TableName;


                                ITIAppObjectTableField."ID" := GetInteger(XmlNodeReader.GetAttribute('ID'));
                                ITIAppObjectTableField.Name := XmlNodeReader.GetAttribute('Name');
                                ITIAppObjectTableField.Datatype := XmlNodeReader.GetAttribute('Datatype');
                                ITIAppObjectTableField.DataLength := GetInteger(XmlNodeReader.GetAttribute('DataLength'));
                                ITIAppObjectTableField."App ID" := XmlNodeReader.GetAttribute('SourceAppId');
                                ITIAppObjectTableField.SourceExtensionType := GetInteger(XmlNodeReader.GetAttribute('SourceExtensionType'));
                                ITIAppObjectTableField.NotBlank := GetBoolean(XmlNodeReader.GetAttribute('NotBlank'));
                                ITIAppObjectTableField.FieldClass := XmlNodeReader.GetAttribute('FieldClass');
                                ITIAppObjectTableField."SQL Field Name" := '';
                                if (UpperCase(ITIAppObjectTableField.FieldClass) = 'NORMAL') or (ITIAppObjectTableField.FieldClass = '') then begin
                                    ITIAppObjectTableField."SQL Field Name Candidate" := CopyStr(SQFieldName, 1, MaxStrLen(ITIAppObjectTableField."SQL Field Name"));
                                    ITIAppObjectTableField."SQL Field Name Candidate 2" := StrSubstNo('%1$%2', SQFieldName, LowerCase(ITIAppObjectTableField."App ID"));
                                end else begin
                                    ITIAppObjectTableField."SQL Field Name Candidate" := '';
                                    ITIAppObjectTableField."SQL Field Name Candidate 2" := '';
                                end;
                                ITIAppObjectTableField.DateFormula := XmlNodeReader.GetAttribute('DateFormula');
                                ITIAppObjectTableField.Editable := GetBoolean(XmlNodeReader.GetAttribute('Editable'));
                                ITIAppObjectTableField.Access := XmlNodeReader.GetAttribute('Access');
                                ITIAppObjectTableField.Numeric := GetBoolean(XmlNodeReader.GetAttribute('Numeric'));
                                ITIAppObjectTableField.ExternalAccess := XmlNodeReader.GetAttribute('ExternalAccess');
                                ITIAppObjectTableField.ValidateTableRelation := GetBoolean(XmlNodeReader.GetAttribute('ValidateTableRelation'));
                                ITIAppObjectTableField.DataClassification := XmlNodeReader.GetAttribute('DataClassification');
                                ITIAppObjectTableField.EnumTypeName := XmlNodeReader.GetAttribute('EnumTypeName');
                                ITIAppObjectTableField.EnumTypeId := GetInteger(XmlNodeReader.GetAttribute('EnumTypeId'));
                                ITIAppObjectTableField.InitValue := XmlNodeReader.GetAttribute('InitValue');
                                ITIAppObjectTableField.ObsoleteState := XmlNodeReader.GetAttribute('ObsoleteState');
                                if ITIAppObjectTableField.ObsoleteState = 'No' then
                                    ITIAppObjectTableField.ObsoleteState := '';
                                ITIAppObjectTableField.ObsoleteReason := XmlNodeReader.GetAttribute('ObsoleteReason');
                                if (uppercase(XmlNodeReader.GetAttribute('Enabled')) <> 'NULL') and (XmlNodeReader.GetAttribute('Enabled') <> '') then
                                    ITIAppObjectTableField.Enabled := GetBoolean(XmlNodeReader.GetAttribute('Enabled'))
                                else
                                    ITIAppObjectTableField.Enabled := true;
                                if not ITIAppObjectTableField.Insert() then
                                    ITIAppObjectTableField.Modify();
                                if not ITIAppObjectTableField.INSERT() then
                                    ITIAppObjectTableField.Modify();
                                if XmlNodeReader.GetAttribute('Datatype') = 'Option' then begin
                                    OptionString := XmlNodeReader.GetAttribute('OptionString');
                                    NoOfOptions := StrLen(DelChr(OptionString, '=', DELCHR(OptionString, '=', ','))) + 1;
                                    for i := 1 to NoOfOptions do begin
                                        ITIAppObjectTblFieldOpt.Init();
                                        ITIAppObjectTblFieldOpt."SQL Database Code" := ITIAppObjectTableField."SQL Database Code";
                                        ITIAppObjectTblFieldOpt."Table ID" := ITIAppObjectTableField."Table ID";
                                        ITIAppObjectTblFieldOpt."Table Name" := ITIAppObjectTableField."Table Name";
                                        ITIAppObjectTblFieldOpt."Field Name" := ITIAppObjectTableField.Name;
                                        ITIAppObjectTblFieldOpt."Field ID" := ITIAppObjectTableField."ID";
                                        ITIAppObjectTblFieldOpt."Option ID" := i - 1;
                                        ITIAppObjectTblFieldOpt.Name := CopyStr(SelectStr(i, OptionString), 1, MaxStrLen(ITIAppObjectTblFieldOpt.Name));
                                        if ITIAppObjectTblFieldOpt.Name <> '' then
                                            IF not ITIAppObjectTblFieldOpt.Insert() then;
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
                                ITIAppObjectTableField.GET(ITIAppObject."SQL Database Code", TableID, KeyFieldNo);
                                ITIAppObjectTableField."Key" := true;
                                ITIAppObjectTableField.Modify()
                            end;
                            KeyInserted := true;
                        end;
                    end;

                //table extension
                ITIAppObject."Type"::TableExtension:
                    begin
                        TableID := GetInteger(ITIAppObject."Subtype");
                        if ITIAppObjectTable.GET(ITIAppObject."SQL Database Code", TableID) then
                            TableName := ITIAppObjectTable.Name
                        else
                            TableName := '';
                        if XmlNodeReader.Name() = 'FieldAdd' then begin
                            SQFieldName := XmlNodeReader.GetAttribute('Name');
                            SQFieldName := CONVERTSTR(SQFieldName, AllowedCharacters, ReplaceCharacters);
                            //ITISQLServerTables.SETRANGE("Server Code", ITISQLObjectsMetadata."Server Code");
                            //ITISQLServerTables.SETFILTER("Table Name", STRSUBSTNO('*%1*'));
                            SQFieldName := GetSQLName(ITISQLDatabase, XmlNodeReader.GetAttribute('Name'));
                            if SQFieldName <> '' then begin
                                ITIAppObjectTableField.init();
                                ITIAppObjectTableField."SQL Database Code" := ITIAppObject."SQL Database Code";
                                ITIAppObjectTableField."Table ID" := TableID;
                                ITIAppObjectTableField."Table Name" := TableName;
                                ITIAppObjectTableField.FieldClass := XmlNodeReader.GetAttribute('FieldClass');
                                ITIAppObjectTableField."App ID" := XmlNodeReader.GetAttribute('SourceAppId');
                                if (UpperCase(ITIAppObjectTableField.FieldClass) = 'NORMAL') or (ITIAppObjectTableField.FieldClass = '') then begin
                                    ITIAppObjectTableField."SQL Field Name Candidate" := CopyStr(SQFieldName, 1, MaxStrLen(ITIAppObjectTableField."SQL Field Name"));
                                    ITIAppObjectTableField."SQL Field Name Candidate 2" := StrSubstNo('%1$%2', SQFieldName, LowerCase(ITIAppObjectTableField."App ID"));
                                end else begin
                                    ITIAppObjectTableField."SQL Field Name Candidate" := '';
                                    ITIAppObjectTableField."SQL Field Name Candidate 2" := '';
                                end;
                                ITIAppObjectTableField."ID" := GetInteger(XmlNodeReader.GetAttribute('ID'));
                                ITIAppObjectTableField.Name := XmlNodeReader.GetAttribute('Name');
                                ITIAppObjectTableField.Datatype := XmlNodeReader.GetAttribute('Datatype');
                                ITIAppObjectTableField.DataLength := GetInteger(XmlNodeReader.GetAttribute('DataLength'));

                                ITIAppObjectTableField.SourceExtensionType := GetInteger(XmlNodeReader.GetAttribute('SourceExtensionType'));
                                ITIAppObjectTableField.NotBlank := GetBoolean(XmlNodeReader.GetAttribute('NotBlank'));

                                ITIAppObjectTableField.DateFormula := XmlNodeReader.GetAttribute('DateFormula');
                                ITIAppObjectTableField.Editable := GetBoolean(XmlNodeReader.GetAttribute('Editable'));
                                ITIAppObjectTableField.Access := XmlNodeReader.GetAttribute('Access');
                                ITIAppObjectTableField.Numeric := GetBoolean(XmlNodeReader.GetAttribute('Numeric'));
                                ITIAppObjectTableField.ExternalAccess := XmlNodeReader.GetAttribute('ExternalAccess');
                                ITIAppObjectTableField.ValidateTableRelation := GetBoolean(XmlNodeReader.GetAttribute('ValidateTableRelation'));
                                ITIAppObjectTableField.DataClassification := XmlNodeReader.GetAttribute('DataClassification');
                                ITIAppObjectTableField.EnumTypeName := XmlNodeReader.GetAttribute('EnumTypeName');
                                ITIAppObjectTableField.EnumTypeId := GetInteger(XmlNodeReader.GetAttribute('EnumTypeId'));
                                ITIAppObjectTableField.InitValue := XmlNodeReader.GetAttribute('InitValue');
                                ITIAppObjectTableField.ObsoleteState := XmlNodeReader.GetAttribute('ObsoleteState');
                                if ITIAppObjectTableField.ObsoleteState = 'No' then
                                    ITIAppObjectTableField.ObsoleteState := '';
                                ITIAppObjectTableField.ObsoleteReason := XmlNodeReader.GetAttribute('ObsoleteReason');
                                if (uppercase(XmlNodeReader.GetAttribute('Enabled')) <> 'NULL') and (XmlNodeReader.GetAttribute('Enabled') <> '') then
                                    ITIAppObjectTableField.Enabled := GetBoolean(XmlNodeReader.GetAttribute('Enabled'))
                                else
                                    ITIAppObjectTableField.Enabled := true;
                                if not ITIAppObjectTableField.Insert() then
                                    ITIAppObjectTableField.Modify();

                                if XmlNodeReader.GetAttribute('Datatype') = 'Option' then begin
                                    OptionString := XmlNodeReader.GetAttribute('OptionString');
                                    NoOfOptions := StrLen(DelChr(OptionString, '=', DELCHR(OptionString, '=', ','))) + 1;
                                    for i := 1 to NoOfOptions do begin
                                        ITIAppObjectTblFieldOpt.Init();
                                        ITIAppObjectTblFieldOpt."SQL Database Code" := ITIAppObjectTableField."SQL Database Code";
                                        ITIAppObjectTblFieldOpt."Table ID" := ITIAppObjectTableField."Table ID";
                                        ITIAppObjectTblFieldOpt."Table Name" := ITIAppObjectTableField."Table Name";
                                        ITIAppObjectTblFieldOpt."Field Name" := ITIAppObjectTableField.Name;
                                        ITIAppObjectTblFieldOpt."Field ID" := ITIAppObjectTableField."ID";
                                        ITIAppObjectTblFieldOpt."Option ID" := i - 1;
                                        ITIAppObjectTblFieldOpt.Name := CopyStr(SelectStr(i, OptionString), 1, MaxStrLen(ITIAppObjectTblFieldOpt.Name));
                                        if ITIAppObjectTblFieldOpt.Name <> '' then
                                            IF not ITIAppObjectTblFieldOpt.Insert() then;
                                    end;
                                end;
                            end;
                        end;
                    end;
                //Enum
                ITIAppObject."Type"::Enum:
                    begin
                        if XmlNodeReader.Name() = 'Enum' then begin
                            ITIAppObjectEnum.Init();
                            ITIAppObjectEnum."SQL Database Code" := ITIAppObject."SQL Database Code";
                            EnumID := GetInteger(XmlNodeReader.GetAttribute('ID'));
                            ITIAppObjectEnum."ID" := EnumID;
                            ITIAppObjectEnum.Name := XmlNodeReader.GetAttribute('Name');
                            ITIAppObjectEnum.Extensible := GetBoolean(XmlNodeReader.GetAttribute('Extensible'));
                            ITIAppObjectEnum.AssignmentCompatibility := FORMAT(XmlNodeReader.GetAttribute('AssignmentCompatibility'));
                            if not ITIAppObjectEnum.Insert() then
                                ITIAppObjectEnum.Modify();
                        end;
                        if XmlNodeReader.Name() = 'Value' then begin

                            ITIAppObjectEnumValue.INIT();
                            ITIAppObjectEnumValue."SQL Database Code" := ITIAppObject."SQL Database Code";
                            ITIAppObjectEnumValue."Enum ID" := EnumID;
                            ITIAppObjectEnumValue.Ordinal := GetInteger(XmlNodeReader.GetAttribute('Ordinal'));
                            ITIAppObjectEnumValue.Name := XmlNodeReader.GetAttribute('Name');
                            if not ITIAppObjectEnumValue.insert() then
                                ITIAppObjectEnumValue.modify();
                        END;
                    END;
                //Enum Extension
                ITIAppObject."Type"::EnumExtension:
                    begin
                        EnumID := GetInteger(ITIAppObject."Subtype");
                        IF XmlNodeReader.Name() = 'Value' then begin
                            ITIAppObjectEnumValue.INIT();
                            ITIAppObjectEnumValue."SQL Database Code" := ITIAppObject."SQL Database Code";
                            ITIAppObjectEnumValue."Enum ID" := EnumID;
                            ITIAppObjectEnumValue.Ordinal := GetInteger(XmlNodeReader.GetAttribute('Ordinal'));
                            ITIAppObjectEnumValue.Name := XmlNodeReader.GetAttribute('Name');
                            IF NOT ITIAppObjectEnumValue.Insert() then
                                ITIAppObjectEnumValue.Modify();
                        end;
                    end;
            end;
    end;



    local procedure GetObjectMetadataXMLFromSQL(ITIAppObject: Record "ITI App. Object"): BigText
    var
        ITISQLDatabase: Record "ITI SQL Database";
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
        ITISQLDatabase.GET(ITIAppObject."SQL Database Code");
        //Build SQL queries to run
        char13 := 13;
        char10 := 10;
        NewLine := FORMAT(char13) + FORMAT(char10);
        SQLQueryText := '';
        SQLQueryText := SQLQueryText + 'SELECT' + NewLine;
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
        SQLQueryText := SQLQueryText + '  [dbo].[' + ITIAppObject.Source + '] ' + NewLine;
        SQLQueryText := SQLQueryText + 'where ' + NewLine;
        SQLQueryText := SQLQueryText + '  [Object Type] = ' + FORMAT(ITIAppObject."Type", 0, 9) + ' and [Object ID] = ' + FORMAT(ITIAppObject."ID", 0, 9) + NewLine;
        if ITIAppObject."Package ID" <> '' then
            SQLQueryText := SQLQueryText + ' and [Package ID] = ''' + ITIAppObject."Package ID" + '''';
        ConnectionString := ITISQLDatabase.GetDatabaseConnectionString();
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

    local procedure GetDBForbiddenChars(var ITISQLDatabase: Record "ITI SQL Database"): Text
    var
        SQLConnection: DotNet SQLConnection;
        SQLCommand: DotNet SqlCommand;
        SQLQueryText1: Text;
        SQLQueryText2: Text;
        ConnectionString: Text;
    begin
        ITISQLDatabase."Forbidden Chars" := '';
        ITISQLDatabase.Modify();

        SQLQueryText1 := 'select top 1 convertidentifiers from [$ndo$dbproperty]';
        SQLQueryText2 := 'select top 1 invalididentifierchars from [$ndo$dbproperty]';
        ConnectionString := ITISQLDatabase.GetDatabaseConnectionString();
        SQLConnection := SQLConnection.SqlConnection(ConnectionString);
        SQLConnection.Open();
        SQLCommand := SQLCommand.SqlCommand(SQLQueryText1, SQLConnection);
        SQLCommand.CommandTimeout := 10 * 60 * 100; // 10 min.
        IF FORMAT(SQLCommand.ExecuteScalar()) = '1' THEN BEGIN
            SQLCommand := SQLCommand.SqlCommand(SQLQueryText2, SQLConnection);
            SQLCommand.CommandTimeout := 10 * 60 * 100; // 10 min.
            ITISQLDatabase."Forbidden Chars" := FORMAT(SQLCommand.ExecuteScalar());
            ITISQLDatabase.Modify();
        END;
        SQLConnection.Close();
    end;

    local procedure GetSQLName(var ITISQLDatabase: Record "ITI SQL Database"; Name: Text): Text
    var
        ReplaceCharacters: Text;
        FindCharacters: Text;
    begin
        FindCharacters := ITISQLDatabase."Forbidden Chars";
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

    local procedure GetSQLTablesNumberOfRows(var ITISQLDatabase: Record "ITI SQL Database")
    var
        ITISQLDatabaseTable: Record "ITI SQL Database Table";
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
        ConnectionString := ITISQLDatabase.GetDatabaseConnectionString();
        SQLConnection := SQLConnection.SqlConnection(ConnectionString);
        SQLConnection.Open();

        SQLCommand := SQLCommand.SqlCommand(SQLQueryText, SQLConnection);
        SQLCommand.CommandTimeout := 10 * 60 * 100; // 10 min.
        SQLReader := SQLCommand.ExecuteReader();

        //Read columns data and put to the SQLColumns table
        While SQLReader.Read() do begin
            ITISQLDatabaseTable.SetRange("SQL Database Code", ITISQLDatabase.Code);
            ITISQLDatabaseTable.SetRange("Table Name", SQLReader.GetString(0));
            if ITISQLDatabaseTable.FindFirst() then begin
                ITISQLDatabaseTable."Number Of Records" := GetInteger(Format(SQLReader.GetValue(1)));
                ITISQLDatabaseTable.Modify();
            end;
        end;
        SQLConnection.Close();
    end;
}

