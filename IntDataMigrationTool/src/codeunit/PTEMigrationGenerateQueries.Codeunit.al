codeunit 99003 "PTE Migration Generate Queries"
{
    var
        DataExistsConfAllMsg: Label 'Queries for migration: %1 has already been created. Do you want to delete existing queries and create again?', Comment = '%1 = Migration Code';
        DataExistsConfSelectedTableRecordNoMsg: Label 'Query for migration: %1 with table: %2 has already been created. Do you want to delete existing querry and create again?', Comment = '%1 = Migration Code, %2 = Selected Migration Tale name';
        DownloadingDataMsg: Label 'Generating SQL queries for migration: %1. No Of Records: %2', Comment = '%1 = Migration Code, %2 = No Of Records';
        NoExecTargetErr: Label 'No execution target has been choosen for migration %1', Comment = '%1 = Migration Code';

    procedure GenerateQuery(PTEMigrationSQLQuery: Record "PTE Migration SQL Query"; SkipConfirmation: Boolean; SelectedQuerySourceTableName: Text[150])
    var
        PTEMigration: Record "PTE Migration";
    begin
        PTEMigration.Get(PTEMigrationSQLQuery."Migration Code");
        GenerateQueries(PTEMigration, SkipConfirmation, SelectedQuerySourceTableName);

    end;

    procedure GenerateQueries(PTEMigration: Record "PTE Migration"; SkipConfirmation: Boolean; SelectedQuerySourceTableName: Text[150])
    var
        PTEMigrationDataset: Record "PTE Migration Dataset";
        PTEMigrationDatasetTable: Record "PTE Migration Dataset Table";
        PTEMigrDatasetTableField: Record "PTE Migr. Dataset Table Field";
        PTEMigrationSQLQuery: Record "PTE Migration SQL Query";
        PTEMigrationSQLQueryField: Record "PTE Migration SQL Query Field";
        PTEMigrationSQLQueryTable: record "PTE Migration SQL Query Table";
        PTEMigrDsTblFldOption: Record "PTE Migr. Ds. Tbl. Fld. Option";
        PTEMigrSQLQueryFieldOpt: Record "PTE Migr. SQL Query Field Opt.";
        QueryNo: Integer;
        QueryText: text;
        DialogProgress: Dialog;
        ProgressTotal: Integer;
        CurrentProgress: Integer;
        IsSameServerName: Boolean;
        OutStream: OutStream;
    begin
        PTEMigrationDataset.Get(PTEMigration."Migration Dataset Code");
        PTEMigrationDataset.TestField(Released, true);
        PTEMigrationDatasetTable.SetRange("Migration Dataset Code", PTEMigration."Migration Dataset Code");
        PTEMigrationDatasetTable.SetRange("Skip in Mapping", false);
        //generate data for query 
        //* delete existing queries
        PTEMigrationSQLQuery.SetRange("Migration Code", PTEMigration.Code);
        PTEMigrationSQLQueryField.SetRange("Migration Code", PTEMigration.Code);
        PTEMigrationSQLQueryTable.SetRange("Migration Code", PTEMigration.Code);
        PTEMigrSQLQueryFieldOpt.SetRange("Migration Code", PTEMigration.Code);

        if SelectedQuerySourceTableName <> '' then
            PTEMigrationSQLQuery.SetRange(SourceTableName, SelectedQuerySourceTableName);

        // Confirmation conditions
        if not SkipConfirmation then
            if (SelectedQuerySourceTableName <> '') then
                if not Confirm(DataExistsConfSelectedTableRecordNoMsg, false, PTEMigration.Code, SelectedQuerySourceTableName) then
                    exit;

        if (SelectedQuerySourceTableName = '') then
            if (not PTEMigrationSQLQueryTable.IsEmpty) or (not PTEMigrationSQLQueryField.IsEmpty) or (not PTEMigrationSQLQueryTable.IsEmpty) then
                if not Confirm(DataExistsConfAllMsg, false, PTEMigration.Code) then
                    exit;

        // Single query row deletion
        if SelectedQuerySourceTableName <> '' then begin
            PTEMigrationSQLQuery.FindFirst();
            QueryNo := PTEMigrationSQLQuery."Query No.";
            PTEMigrationSQLQuery.Delete();

            PTEMigrationSQLQueryField.SetRange("Query No.", QueryNo);
            PTEMigrationSQLQueryField.DeleteAll();

            PTEMigrationSQLQueryTable.SetRange("Query No.", QueryNo);
            PTEMigrationSQLQueryTable.DeleteAll();

            PTEMigrSQLQueryFieldOpt.SetRange("Query No.", QueryNo);
            PTEMigrSQLQueryFieldOpt.DeleteAll();
        end;

        // All query deletion
        if SelectedQuerySourceTableName = '' then begin
            PTEMigrationSQLQuery.DeleteAll();
            PTEMigrationSQLQueryField.DeleteAll();
            PTEMigrationSQLQueryTable.DeleteAll();
            PTEMigrSQLQueryFieldOpt.DeleteAll();
        end;

        //Open progress bar
        CurrentProgress := 0;
        ProgressTotal := PTEMigrationDatasetTable.Count;
        DialogProgress.OPEN(STRSUBSTNO(DownloadingDataMsg, PTEMigration."Code", ProgressTotal) + ': #1#####', CurrentProgress);

        //Create Linked server query for migration dataset
        IsSameServerName := CheckIfSameServerName(PTEMigration);

        QueryText := '';
        if not IsSameServerName then begin
            QueryText := QueryText + LinkedServerQueryString(PTEMigration) + NewLine();
            Clear(PTEMigration."Linked Server Query");
            PTEMigration."Linked Server Query".CreateOutStream(OutStream, TEXTENCODING::UTF8);
            OutStream.Write(QueryText);
            Clear(OutStream);
        end else
            Clear(PTEMigration."Linked Server Query");
        PTEMigration.Modify();

        if SelectedQuerySourceTableName <> '' then begin
            PTEMigrationDatasetTable.SetRange("Source Table Name", SelectedQuerySourceTableName);
            PTEMigrationDatasetTable.FindFirst();
        end;


        if PTEMigrationDatasetTable.FindSet() then
            repeat
                CurrentProgress := CurrentProgress + 1;
                DialogProgress.UPDATE(1, CurrentProgress);
                QueryText := '';
                //* collect sql tables and fields for each dataset line

                PTEMigrDatasetTableField.SetRange("Migration Dataset Code", PTEMigrationDataset.Code);
                PTEMigrDatasetTableField.SetRange("Source Table Name", PTEMigrationDatasetTable."Source Table Name");
                PTEMigrDatasetTableField.SetFilter("Source Field Name", '<>''''');
                PTEMigrDatasetTableField.SetFilter("Target Field Name", '<>''''');
                PTEMigrDatasetTableField.SetRange("Skip in Mapping", false);
                if PTEMigrDatasetTableField.FindSet() then begin
                    if SelectedQuerySourceTableName = '' then
                        QueryNo := QueryNo + 10000;
                    PTEMigrationSQLQuery.Init();
                    PTEMigrationSQLQuery."Migration Code" := PTEMigration.Code;
                    PTEMigrationSQLQuery."Query No." := QueryNo;
                    PTEMigrationSQLQuery.Description := PTEMigrationDatasetTable."Source Table Name" + '->' + PTEMigrationDatasetTable."Target table name";
                    PTEMigrationSQLQuery.SourceTableName := PTEMigrationDatasetTable."Source Table Name";
                    PTEMigrationSQLQuery.Insert();
                    InsertAllExtensionTablesAndKeyFields(PTEMigration, PTEMigrationDatasetTable, QueryNo);
                    repeat
                        PTEMigrationSQLQueryField.Init();
                        PTEMigrationSQLQueryField."Migration Code" := PTEMigration.Code;
                        PTEMigrationSQLQueryField."Query No." := QueryNo;
                        PTEMigrationSQLQueryField."Source SQL Table Name" := PTEMigrDatasetTableField.GetSQLSourceTableName(PTEMigration."Source Company Name");

                        if PTEMigrDatasetTableField."Mapping Type" = PTEMigrDatasetTableField."Mapping Type"::FieldToField then
                            PTEMigrationSQLQueryField."Source SQL Field Name" := PTEMigrDatasetTableField.GetSQLSourceFieldName()
                        else begin
                            PTEMigrationSQLQueryField."Source SQL Field Name" := PTEMigrDatasetTableField."Source Field Name";
                            PTEMigrationSQLQueryField.Constant := true;
                        end;

                        PTEMigrationSQLQueryField."Target SQL Field Name" := PTEMigrDatasetTableField.GetSQLTargetFieldName();
                        PTEMigrationSQLQueryField."Target SQL Table Name" := PTEMigrDatasetTableField.GetSQLTargetTableName(PTEMigration."Target Company Name");
                        if not PTEMigrationSQLQueryField.insert() then;

                        PTEMigrDsTblFldOption.SetRange("Migration Dataset Code", PTEMigrationDataset.Code);
                        PTEMigrDsTblFldOption.SetRange("Source Table Name", PTEMigrationDatasetTable."Source Table Name");
                        PTEMigrDsTblFldOption.SetRange("Source Field Name", PTEMigrDatasetTableField."Source Field Name");
                        if PTEMigrDsTblFldOption.FindSet() then
                            repeat
                                PTEMigrSQLQueryFieldOpt.init();
                                PTEMigrSQLQueryFieldOpt."Migration Code" := PTEMigration.Code;
                                PTEMigrSQLQueryFieldOpt."Query No." := QueryNo;
                                PTEMigrSQLQueryFieldOpt."Source SQL Table Name" := PTEMigrationSQLQueryField."Source SQL Table Name";
                                PTEMigrSQLQueryFieldOpt."Source SQL Field Name" := PTEMigrationSQLQueryField."Source SQL Field Name";
                                PTEMigrSQLQueryFieldOpt."Source SQL Field Option" := PTEMigrDsTblFldOption."Source Option ID";
                                PTEMigrSQLQueryFieldOpt."Target SQL Table Name" := PTEMigrationSQLQueryField."Target SQL Table Name";
                                PTEMigrSQLQueryFieldOpt."Target SQL Field Name" := PTEMigrationSQLQueryField."Target SQL Field Name";
                                PTEMigrSQLQueryFieldOpt."Target SQL Field Option" := PTEMigrDsTblFldOption."Target Option ID";
                                if not PTEMigrSQLQueryFieldOpt.insert() then;
                            until PTEMigrDsTblFldOption.Next() = 0;

                        GetEquivalMappingFields(PTEMigrDatasetTableField, PTEMigration, QueryNo);

                        PTEMigrationSQLQueryTable.Init();
                        PTEMigrationSQLQueryTable."Migration Code" := PTEMigration.Code;
                        PTEMigrationSQLQueryTable."Query No." := QueryNo;
                        PTEMigrationSQLQueryTable."Source SQL Table Name" := PTEMigrationSQLQueryField."Source SQL Table Name";
                        PTEMigrationSQLQueryTable."Target SQL Table Name" := PTEMigrationSQLQueryField."Target SQL Table Name";
                        if not PTEMigrationSQLQueryTable.Insert() then;
                    until PTEMigrDatasetTableField.Next() = 0;

                    //* Build Query
                    if not PTEMigration."Do Not Use Transaction" then
                        QueryText := QueryText + 'BEGIN TRAN Q' + FORMAT(QueryNo, 0, 9) + ';' + NewLine();
                    QueryText := QueryText + TablesTransferQueryString(PTEMigration, QueryNo, IsSameServerName) + NewLine();
                    if not PTEMigration."Do Not Use Transaction" then
                        QueryText := QueryText + 'COMMIT TRAN Q' + FORMAT(QueryNo, 0, 9) + ';' + NewLine();
                    Clear(PTEMigrationSQLQuery.Query);
                    PTEMigrationSQLQuery.Query.CreateOutStream(OutStream, TEXTENCODING::UTF8);
                    OutStream.Write(QueryText);
                    PTEMigrationSQLQuery.Modify();
                end;

            until PTEMigrationDatasetTable.Next() = 0;
        DialogProgress.Close();
        PTEMigration."Generated Queries" := true;
        PTEMigration.Modify();
    end;

    local procedure InsertAllExtensionTablesAndKeyFields(PTEMigration: Record "PTE Migration"; PTEMigrationDatasetTable: Record "PTE Migration Dataset Table"; QueryNo: Integer)
    var

        TargetKeysPTEAppObjectTableField: Record "PTE App. Object Table Field";
        TargetPTEAppObjectTableField: Record "PTE App. Object Table Field";
        PTEMigrationSQLQueryField: Record "PTE Migration SQL Query Field";
        PTEMigrationSQLQueryTable: record "PTE Migration SQL Query Table";
        PTEMigrDatasetTableField: record "PTE Migr. Dataset Table Field";
        PTEMigrDsTblFldOption: Record "PTE Migr. Ds. Tbl. Fld. Option";
        PTEMigrSQLQueryFieldOpt: Record "PTE Migr. SQL Query Field Opt.";

    begin
        TargetPTEAppObjectTableField.SetRange("SQL Database Code", PTEMigration."Target SQL Database Code");
        TargetPTEAppObjectTableField.SetRange("Table Name", PTEMigrationDatasetTable."Target table name");
        TargetPTEAppObjectTableField.SetFilter(FieldClass, '@Normal');
        TargetPTEAppObjectTableField.SetRange(Enabled, true); //ITPW 20240108/S/E // miałem w AL zapalone enable = false i dawał błedy

        TargetKeysPTEAppObjectTableField.SetRange("SQL Database Code", PTEMigration."Target SQL Database Code");
        TargetKeysPTEAppObjectTableField.SetRange("Table Name", PTEMigrationDatasetTable."Target table name");
        TargetKeysPTEAppObjectTableField.SetRange("Key", true);

        //Go through all target table object fields to find all table extensions
        if TargetPTEAppObjectTableField.FindSet() then
            repeat
                //for each key field from target find source field and table
                TargetKeysPTEAppObjectTableField.FindSet();
                repeat
                    PTEMigrDatasetTableField.SetRange("Migration Dataset Code", PTEMigration."Migration Dataset Code");
                    PTEMigrDatasetTableField.SetRange("Target SQL Database Code", PTEMigration."Target SQL Database Code");
                    PTEMigrDatasetTableField.SetRange("Target table name", PTEMigrationDatasetTable."Target table name");
                    PTEMigrDatasetTableField.SetRange("Target Field name", TargetKeysPTEAppObjectTableField.Name);
                    PTEMigrDatasetTableField.FindFirst();

                    PTEMigrationSQLQueryField.Init();
                    PTEMigrationSQLQueryField."Migration Code" := PTEMigration.Code;
                    PTEMigrationSQLQueryField."Query No." := QueryNo;
                    PTEMigrationSQLQueryField."Source SQL Field Name" := PTEMigrDatasetTableField.GetSQLSourceFieldName();
                    PTEMigrationSQLQueryField."Source SQL Table Name" := PTEMigrDatasetTableField.GetSQLSourceTableName(PTEMigration."Source Company Name");
                    PTEMigrationSQLQueryField."Target SQL Field Name" := TargetKeysPTEAppObjectTableField."SQL Field Name";
                    PTEMigrationSQLQueryField."Target SQL Table Name" := TargetPTEAppObjectTableField.GetSQLTableName(PTEMigration."Target Company Name");
                    if not PTEMigrationSQLQueryField.insert() then;

                    PTEMigrDsTblFldOption.SetRange("Migration Dataset Code", PTEMigrDatasetTableField."Migration Dataset Code");
                    PTEMigrDsTblFldOption.SetRange("Source Table Name", PTEMigrDatasetTableField."Source Table Name");
                    PTEMigrDsTblFldOption.SetRange("Source Field Name", PTEMigrDatasetTableField."Source Field Name");
                    if PTEMigrDsTblFldOption.FindSet() then
                        repeat
                            PTEMigrSQLQueryFieldOpt.init();
                            PTEMigrSQLQueryFieldOpt."Migration Code" := PTEMigration.Code;
                            PTEMigrSQLQueryFieldOpt."Query No." := QueryNo;
                            PTEMigrSQLQueryFieldOpt."Source SQL Table Name" := PTEMigrationSQLQueryField."Source SQL Table Name";
                            PTEMigrSQLQueryFieldOpt."Source SQL Field Name" := PTEMigrationSQLQueryField."Source SQL Field Name";
                            PTEMigrSQLQueryFieldOpt."Source SQL Field Option" := PTEMigrDsTblFldOption."Source Option ID";
                            PTEMigrSQLQueryFieldOpt."Target SQL Table Name" := PTEMigrationSQLQueryField."Target SQL Table Name";
                            PTEMigrSQLQueryFieldOpt."Target SQL Field Name" := PTEMigrationSQLQueryField."Target SQL Field Name";
                            PTEMigrSQLQueryFieldOpt."Target SQL Field Option" := PTEMigrDsTblFldOption."Target Option ID";
                            if not PTEMigrSQLQueryFieldOpt.insert() then;
                        until PTEMigrDsTblFldOption.Next() = 0;

                    PTEMigrationSQLQueryTable.Init();
                    PTEMigrationSQLQueryTable."Migration Code" := PTEMigration.Code;
                    PTEMigrationSQLQueryTable."Query No." := QueryNo;
                    PTEMigrationSQLQueryTable."Source SQL Table Name" := PTEMigrationSQLQueryField."Source SQL Table Name";
                    PTEMigrationSQLQueryTable."Target SQL Table Name" := PTEMigrationSQLQueryField."Target SQL Table Name";
                    if not PTEMigrationSQLQueryTable.Insert() then;
                until TargetKeysPTEAppObjectTableField.Next() = 0;
            until TargetPTEAppObjectTableField.Next() = 0;
    end;


    local procedure LinkedServerQueryString(PTEMigration: Record "PTE Migration"): Text;
    var
        SourcePTESQLDatabase: Record "PTE SQL Database";
        TargetPTESQLDatabase: Record "PTE SQL Database";
        SQLQueryText: Text;
    begin
        SourcePTESQLDatabase.Get(PTEMigration."Source SQL Database Code");
        TargetPTESQLDatabase.Get(PTEMigration."Target SQL Database Code");
        //drop target linked server if already linked
        if PTEMigration."Execute On" = PTEMigration."Execute On"::Source then begin
            SQLQueryText := SQLQueryText + 'if exists(select * from sys.servers where name = N''' + TargetPTESQLDatabase."Server Name" + ''')' + NewLine();
            SQLQueryText := SQLQueryText + 'BEGIN' + NewLine();
            SQLQueryText := SQLQueryText + 'exec master.dbo.sp_dropserver ''' + TargetPTESQLDatabase."Server Name" + ''', ''droplogins'';' + NewLine();
            SQLQueryText := SQLQueryText + 'END;' + NewLine();
            //add target linked server
            SQLQueryText := SQLQueryText + 'EXEC master.dbo.sp_addlinkedserver ' + NewLine();
            SQLQueryText := SQLQueryText + '@server = N''' + TargetPTESQLDatabase."Server Name" + ''', ' + NewLine();
            SQLQueryText := SQLQueryText + '@srvproduct=N''SQL Server'' ;' + NewLine();
            //add login to the target linked server
            SQLQueryText := SQLQueryText + 'exec master.dbo.sp_addlinkedsrvlogin [' + TargetPTESQLDatabase."Server Name" + '] , ''false'', null , ''' + TargetPTESQLDatabase."User Name" + ''' ,''' + TargetPTESQLDatabase.GetPassword() + ''';' + NewLine();
            exit(SQLQueryText);
        end;

        if PTEMigration."Execute On" = PTEMigration."Execute On"::Target then begin
            SQLQueryText := SQLQueryText + 'if exists(select * from sys.servers where name = N''' + SourcePTESQLDatabase."Server Name" + ''')' + NewLine();
            SQLQueryText := SQLQueryText + 'BEGIN' + NewLine();
            SQLQueryText := SQLQueryText + 'exec master.dbo.sp_dropserver ''' + SourcePTESQLDatabase."Server Name" + ''', ''droplogins'';' + NewLine();
            SQLQueryText := SQLQueryText + 'END;' + NewLine();
            //add target linked server
            SQLQueryText := SQLQueryText + 'EXEC master.dbo.sp_addlinkedserver ' + NewLine();
            SQLQueryText := SQLQueryText + '@server = N''' + SourcePTESQLDatabase."Server Name" + ''', ' + NewLine();
            SQLQueryText := SQLQueryText + '@srvproduct=N''SQL Server'' ;' + NewLine();
            //add login to the target linked server
            SQLQueryText := SQLQueryText + 'exec master.dbo.sp_addlinkedsrvlogin [' + SourcePTESQLDatabase."Server Name" + '] , ''false'', null , ''' + SourcePTESQLDatabase."User Name" + ''' ,''' + SourcePTESQLDatabase.GetPassword() + ''';' + NewLine();
            exit(SQLQueryText);
        end;

        Error(NoExecTargetErr, PTEMigration.Code);
    end;

    local procedure TablesTransferQueryString(PTEMigration: Record "PTE Migration"; QueryNo: Integer; IsSameServerName: Boolean): Text;
    var
        TargetPTESQLDatabase: Record "PTE SQL Database";
        SourcePTESQLDatabase: Record "PTE SQL Database";
        PTEMigrationSQLQueryField: Record "PTE Migration SQL Query Field";
        PTEMigrationSQLQueryTable: record "PTE Migration SQL Query Table";
        PTEMigrSQLQueryFieldOpt: Record "PTE Migr. SQL Query Field Opt.";
        PTESQLDatabaseTableField: Record "PTE SQL Database Table Field";
        SourceFields: Text;
        TargetFields: Text;
        SQLQueryText: Text;
        SourceTableName: Text;
        TargetTableName: Text;
        OptionsDifference: Boolean;
        ContainsAutoincrementValue: Boolean;
        OptionDifferenceCaseStatement: Text;
        SourceFieldLength: Integer;
        TargetFieldLength: Integer;
    begin
        TargetPTESQLDatabase.Get(PTEMigration."Target SQL Database Code");
        if PTEMigration."Execute On" = PTEMigration."Execute On"::Target then
            SourcePTESQLDatabase.Get(PTEMigration."Source SQL Database Code");
        PTEMigrationSQLQueryTable.SetRange("Migration Code", PTEMigration.Code);
        PTEMigrationSQLQueryTable.SetRange("Query No.", QueryNo);
        if PTEMigrationSQLQueryTable.FindSet() then
            repeat
                ContainsAutoincrementValue := false;
                SourceTableName := PTEMigrationSQLQueryTable."Source SQL Table Name";
                TargetTableName := PTEMigrationSQLQueryTable."Target SQL Table Name";
                PTEMigrationSQLQueryField.reset();
                PTEMigrationSQLQueryField.SetRange("Migration Code", PTEMigration.Code);
                PTEMigrationSQLQueryField.SetRange("Query No.", QueryNo);
                PTEMigrationSQLQueryField.SetRange("Source SQL Table Name", SourceTableName);
                PTEMigrationSQLQueryField.SetRange("Target SQL Table Name", TargetTableName);
                SourceFields := '';
                TargetFields := '';
                if PTEMigrationSQLQueryField.FindSet() then
                    repeat
                        if SourceFields <> '' then
                            SourceFields := SourceFields + ',' + NewLine();

                        //check if there is difference in option mapping
                        OptionsDifference := false;
                        OptionDifferenceCaseStatement := '';
                        PTEMigrSQLQueryFieldOpt.SetRange("Migration Code", PTEMigration.Code);
                        PTEMigrSQLQueryFieldOpt.SetRange("Query No.", QueryNo);
                        PTEMigrSQLQueryFieldOpt.SetRange("Source SQL Table Name", SourceTableName);
                        PTEMigrSQLQueryFieldOpt.SetRange("Source SQL Field Name", PTEMigrationSQLQueryField."Source SQL Field Name");
                        PTEMigrSQLQueryFieldOpt.SetRange("Target SQL Table Name", TargetTableName);
                        PTEMigrSQLQueryFieldOpt.SetRange("Target SQL Field Name", PTEMigrationSQLQueryField."Target SQL Field Name");
                        if PTEMigrSQLQueryFieldOpt.FindSet() then begin
                            OptionDifferenceCaseStatement := '   CASE' + NewLine();
                            repeat
                                if PTEMigrSQLQueryFieldOpt."Source SQL Field Option" <> PTEMigrSQLQueryFieldOpt."Target SQL Field Option" then
                                    OptionsDifference := true;
                                OptionDifferenceCaseStatement := OptionDifferenceCaseStatement + '      WHEN ' + '"' + PTEMigrationSQLQueryField."Source SQL Field Name" + '"' + ' = ' + Format(PTEMigrSQLQueryFieldOpt."Source SQL Field Option", 0, 9) + ' THEN ' + Format(PTEMigrSQLQueryFieldOpt."Target SQL Field Option", 0, 9) + NewLine();
                            until PTEMigrSQLQueryFieldOpt.Next() = 0;
                            OptionDifferenceCaseStatement := OptionDifferenceCaseStatement + '      ELSE ' + '"' + PTEMigrationSQLQueryField."Source SQL Field Name" + '"' + NewLine();
                            OptionDifferenceCaseStatement := OptionDifferenceCaseStatement + '   END AS ' + '"' + PTEMigrationSQLQueryField."Source SQL Field Name" + '"';
                            //OptionsDifference := true;
                        end;

                        if OptionsDifference then
                            SourceFields := SourceFields + OptionDifferenceCaseStatement
                        else
                            if PTEMigrationSQLQueryField.Constant then
                                SourceFields := SourceFields + '   ' + '''' + PTEMigrationSQLQueryField."Source SQL Field Name" + ''' AS "' + PTEMigrationSQLQueryField."Target SQL Field Name" + '"'
                            else begin
                                //check if there is difference in field length
                                PTESQLDatabaseTableField.Reset();
                                PTESQLDatabaseTableField.SetRange("SQL Database Code", PTEMigration."Source SQL Database Code");
                                PTESQLDatabaseTableField.SetRange("Table Name", PTEMigrationSQLQueryTable."Source SQL Table Name");
                                PTESQLDatabaseTableField.SetRange("Column Name", PTEMigrationSQLQueryField."Source SQL Field Name");
                                PTESQLDatabaseTableField.FindFirst();
                                SourceFieldLength := PTESQLDatabaseTableField."Character Maximum Length";
                                PTESQLDatabaseTableField.SetRange("SQL Database Code", PTEMigration."Target SQL Database Code");
                                PTESQLDatabaseTableField.SetRange("Table Name", PTEMigrationSQLQueryTable."Target SQL Table Name");
                                PTESQLDatabaseTableField.SetRange("Column Name", PTEMigrationSQLQueryField."Target SQL Field Name");
                                PTESQLDatabaseTableField.FindFirst();
                                if PTESQLDatabaseTableField.Autoincrement then
                                    ContainsAutoincrementValue := true;
                                TargetFieldLength := PTESQLDatabaseTableField."Character Maximum Length";
                                //SourceFieldLength := 1000;
                                if (SourceFieldLength > TargetFieldLength) and ((PTESQLDatabaseTableField."Data Type" = 'varchar') or (PTESQLDatabaseTableField."Data Type" = 'nvarchar')) then
                                    SourceFields := SourceFields + '   ' + 'SUBSTRING(' + '"' + PTEMigrationSQLQueryField."Source SQL Field Name" + '"' + ', 1, ' + Format(TargetFieldLength, 0, 9) + ') AS ' + '"' + PTEMigrationSQLQueryField."Source SQL Field Name" + '"'
                                else
                                    SourceFields := SourceFields + '   ' + '"' + PTEMigrationSQLQueryField."Source SQL Field Name" + '"';
                            end;

                        if TargetFields <> '' then
                            TargetFields := TargetFields + ',' + NewLine();
                        TargetFields := TargetFields + '   ' + '"' + PTEMigrationSQLQueryField."Target SQL Field Name" + '"';


                    until PTEMigrationSQLQueryField.Next() = 0;

                //Insert not maped not nullable Target fields
                PTESQLDatabaseTableField.reset();
                PTESQLDatabaseTableField.SetRange("SQL Database Code", PTEMigration."Target SQL Database Code");
                PTESQLDatabaseTableField.SetRange("Table Name", PTEMigrationSQLQueryTable."Target SQL Table Name");
                PTESQLDatabaseTableField.SetRange("Allow Nulls", false);
                PTESQLDatabaseTableField.SetFilter("Column Name", '<>timestamp&<>$systemId&<>$systemCreatedAt&<>$systemCreatedBy&<>$systemModifiedAt&<>$systemModifiedBy'); //<- to chyba nie jest najlepsze rozwiązanie, ale trzeba odfiltrować systemowe pola
                PTESQLDatabaseTableField.SetFilter("Column Default", '=#NULL#');
                if PTESQLDatabaseTableField.FindSet() then
                    repeat
                        PTEMigrationSQLQueryField.reset();
                        PTEMigrationSQLQueryField.SetRange("Migration Code", PTEMigration.code);
                        PTEMigrationSQLQueryField.SetRange("Query No.", QueryNo);
                        PTEMigrationSQLQueryField.SetRange("Target SQL Table Name", PTEMigrationSQLQueryTable."Target SQL Table Name");
                        PTEMigrationSQLQueryField.SetRange("Target SQL Field Name", PTESQLDatabaseTableField."Column Name");
                        if PTEMigrationSQLQueryField.IsEmpty then begin
                            if SourceFields <> '' then
                                SourceFields := SourceFields + ',' + NewLine();
                            if TargetFields <> '' then
                                TargetFields := TargetFields + ',' + NewLine();
                            TargetFields := TargetFields + '   ' + '"' + PTESQLDatabaseTableField."Column Name" + '"';
                            case LowerCase(PTESQLDatabaseTableField."Data Type") of
                                'int':
                                    SourceFields := SourceFields + '   ((0))' + ' AS [' + PTESQLDatabaseTableField."Column Name" + ']';
                                'nvarchar':
                                    SourceFields := SourceFields + '   (N'''')' + ' AS [' + PTESQLDatabaseTableField."Column Name" + ']';
                                'datetime':
                                    SourceFields := SourceFields + '   (''1753.01.01'')' + ' AS [' + PTESQLDatabaseTableField."Column Name" + ']';
                                'bigint':
                                    SourceFields := SourceFields + '   ((0))' + ' AS [' + PTESQLDatabaseTableField."Column Name" + ']';
                                'decimal':
                                    SourceFields := SourceFields + '   ((0.0))' + ' AS [' + PTESQLDatabaseTableField."Column Name" + ']';
                                'timestamp':
                                    SourceFields := SourceFields + '   CONVERT (timestamp, CURRENT_TIMESTAMP)' + ' AS [' + PTESQLDatabaseTableField."Column Name" + ']';
                                'uniqueidentifier':
                                    SourceFields := SourceFields + '   (''00000000-0000-0000-0000-000000000000'')' + ' AS [' + PTESQLDatabaseTableField."Column Name" + ']';
                                'image':
                                    SourceFields := SourceFields + '   (0x00)' + ' AS [' + PTESQLDatabaseTableField."Column Name" + ']';
                                'tinyint':
                                    SourceFields := SourceFields + '   ((0.0))' + ' AS [' + PTESQLDatabaseTableField."Column Name" + ']';
                                'varbinary':
                                    SourceFields := SourceFields + '   (0x00)' + ' AS [' + PTESQLDatabaseTableField."Column Name" + ']';
                                'varchar':
                                    SourceFields := SourceFields + '   ('''')' + ' AS [' + PTESQLDatabaseTableField."Column Name" + ']';
                                'nchar':
                                    SourceFields := SourceFields + '   ('''')' + ' AS [' + PTESQLDatabaseTableField."Column Name" + ']';
                                else
                                    SourceFields := SourceFields + '   (N'''')' + ' AS [' + PTESQLDatabaseTableField."Column Name" + ']';
                            end;

                        end;
                    until PTESQLDatabaseTableField.Next() = 0;


                /*
                INSERT INTO [dbo].[Table_2] ([ID],[Value],[Tekst]) 
                SELECT [ID],
                        CASE
                           WHEN [Value] = 1 THEN 10
                           WHEN [Value] = 2 THEN 20
                           WHEN [Value] = 3 THEN 30
                           WHEN [Value] = 4 THEN 40
                           ELSE [Value]
                        END AS [Value],
                        SUBSTRING([Tekst], 1, 10) AS [Tekst] 
                        from [dbo].[Table_1];
                */

                if PTEMigration."Execute On" = PTEMigration."Execute On"::Source then begin
                    if ContainsAutoincrementValue then begin
                        //SQLQueryText := 'zażółćgęśląjaźńZAŻÓŁĆGĘŚLĄJAŹŃ';
                        SQLQueryText := SQLQueryText + 'SET IDENTITY_INSERT ';
                        if not IsSameServerName then
                            SQLQueryText := SQLQueryText + '[' + TargetPTESQLDatabase."Server Name" + '].';
                        SQLQueryText := SQLQueryText + '[' + TargetPTESQLDatabase."Database Name" + '].[dbo].[' + TargetTableName + '] ON;' + NewLine();
                    end;

                    SQLQueryText := SQLQueryText + 'DELETE FROM ';
                    if not IsSameServerName then
                        SQLQueryText := SQLQueryText + '[' + TargetPTESQLDatabase."Server Name" + '].';
                    SQLQueryText := SQLQueryText + '[' + TargetPTESQLDatabase."Database Name" + '].[dbo].[' + TargetTableName + '];' + NewLine();

                    SQLQueryText := SQLQueryText + 'INSERT INTO ';
                    if not IsSameServerName then
                        SQLQueryText := SQLQueryText + '[' + TargetPTESQLDatabase."Server Name" + '].';
                    SQLQueryText := SQLQueryText + '[' + TargetPTESQLDatabase."Database Name" + '].[dbo].[' + TargetTableName + '] (' + NewLine() + TargetFields + NewLine() + ')' + NewLine();

                    SQLQueryText := SQLQueryText + 'SELECT ' + NewLine() + SourceFields + ' FROM [dbo].[' + SourceTableName + ']' + ';' + NewLine();

                    if ContainsAutoincrementValue then begin
                        SQLQueryText := SQLQueryText + 'SET IDENTITY_INSERT ';
                        if not IsSameServerName then
                            SQLQueryText := SQLQueryText + '[' + TargetPTESQLDatabase."Server Name" + '].';
                        SQLQueryText := SQLQueryText + '[' + TargetPTESQLDatabase."Database Name" + '].[dbo].[' + TargetTableName + '] OFF;' + NewLine();
                    end;
                end;
                if PTEMigration."Execute On" = PTEMigration."Execute On"::Target then begin
                    if ContainsAutoincrementValue then
                        SQLQueryText := SQLQueryText + 'SET IDENTITY_INSERT [dbo].[' + TargetTableName + '] ON;' + NewLine();
                    SQLQueryText := SQLQueryText + 'DELETE FROM [dbo].[' + TargetTableName + '];' + NewLine();
                    SQLQueryText := SQLQueryText + 'INSERT INTO [dbo].[' + TargetTableName + '] (' + NewLine() + TargetFields + NewLine() + ')' + NewLine();

                    SQLQueryText := SQLQueryText + 'SELECT ' + NewLine() + SourceFields + ' FROM ';
                    if not IsSameServerName then
                        SQLQueryText := SQLQueryText + '[' + SourcePTESQLDatabase."Server Name" + '].';
                    SQLQueryText := SQLQueryText + '[' + SourcePTESQLDatabase."Database Name" + '].[dbo].[' + SourceTableName + ']' + ';' + NewLine();

                    if ContainsAutoincrementValue then
                        SQLQueryText := SQLQueryText + 'SET IDENTITY_INSERT [dbo].[' + TargetTableName + '] OFF;' + NewLine();
                end;
            until PTEMigrationSQLQueryTable.Next() = 0;
        exit(SQLQueryText);
    end;

    local procedure NewLine(): Text
    var
        NewLineText: Text;
        char13: Char;
        char10: Char;
    begin
        char13 := 13;
        char10 := 10;
        NewLineText := FORMAT(char13) + FORMAT(char10);
        exit(NewLineText);
    end;

    local procedure CheckIfSameServerName(PTEMigration: Record "PTE Migration"): Boolean
    var
        SourcePTESQLDatabase, TargetSQLDatabase : Record "PTE SQL Database";
    begin
        SourcePTESQLDatabase.Get(PTEMigration."Source SQL Database Code");
        TargetSQLDatabase.Get(PTEMigration."Target SQL Database Code");

        exit(SourcePTESQLDatabase."Server Name" = TargetSQLDatabase."Server Name");
    end;

    local procedure GetEquivalMappingFields(PTEMigrDatasetTableField: Record "PTE Migr. Dataset Table Field"; PTEMigration: Record "PTE Migration"; QueryNo: Integer)
    var
        PTEMigrationSQLQueryField: Record "PTE Migration SQL Query Field";
        PTEMigrDsTableFieldAddTarget: Record PTEMigrDsTableFieldAddTarget;
        PTEMigrDsTableFieldAddTarOpti: Record PTEMigrDsTableFieldAddTarOpti;
        PTEMigrSQLQueryFieldOpt: Record "PTE Migr. SQL Query Field Opt.";
    begin
        PTEMigrDsTableFieldAddTarget.SetRange("Migration Dataset Code", PTEMigrDatasetTableField."Migration Dataset Code");
        PTEMigrDsTableFieldAddTarget.SetRange("Source table name", PTEMigrDatasetTableField."Source table name");
        PTEMigrDsTableFieldAddTarget.SetRange("Source Field Name", PTEMigrDatasetTableField."Source Field Name");

        if PTEMigrDsTableFieldAddTarget.FindSet() then
            repeat
                PTEMigrationSQLQueryField.Init();
                PTEMigrationSQLQueryField."Migration Code" := PTEMigration.Code;
                PTEMigrationSQLQueryField."Query No." := QueryNo;

                if PTEMigrDatasetTableField."Mapping Type" = PTEMigrDatasetTableField."Mapping Type"::FieldToField then
                    PTEMigrationSQLQueryField."Source SQL Field Name" := PTEMigrDsTableFieldAddTarget.GetSQLSourceFieldName()
                else begin
                    PTEMigrationSQLQueryField.Constant := true;
                    PTEMigrationSQLQueryField."Source SQL Field Name" := PTEMigrDatasetTableField."Source Field Name";
                end;

                PTEMigrationSQLQueryField."Source SQL Table Name" := PTEMigrDatasetTableField.GetSQLSourceTableName(PTEMigration."Source Company Name");
                PTEMigrationSQLQueryField."Target SQL Field Name" := PTEMigrDsTableFieldAddTarget.GetSQLTargetFieldName();
                PTEMigrationSQLQueryField."Target SQL Table Name" := PTEMigrDatasetTableField.GetSQLTargetTableName(PTEMigration."Target Company Name");
                if not PTEMigrationSQLQueryField.insert() then;

                PTEMigrDsTableFieldAddTarOpti.SetRange("Migration Dataset Code", PTEMigrDatasetTableField."Migration Dataset Code");
                PTEMigrDsTableFieldAddTarOpti.SetRange("Source table name", PTEMigrDatasetTableField."Source table name");
                PTEMigrDsTableFieldAddTarOpti.SetRange("Source Field Name", PTEMigrDatasetTableField."Source Field Name");
                PTEMigrDsTableFieldAddTarOpti.SetRange("Target Field Name", PTEMigrDsTableFieldAddTarOpti."Target Field Name");

                if PTEMigrDsTableFieldAddTarOpti.FindSet() then
                    repeat
                        PTEMigrSQLQueryFieldOpt.init();
                        PTEMigrSQLQueryFieldOpt."Migration Code" := PTEMigration.Code;
                        PTEMigrSQLQueryFieldOpt."Query No." := QueryNo;
                        PTEMigrSQLQueryFieldOpt."Source SQL Table Name" := PTEMigrationSQLQueryField."Source SQL Table Name";
                        PTEMigrSQLQueryFieldOpt."Source SQL Field Name" := PTEMigrationSQLQueryField."Source SQL Field Name";
                        PTEMigrSQLQueryFieldOpt."Source SQL Field Option" := PTEMigrDsTableFieldAddTarOpti."Source Option ID";
                        PTEMigrSQLQueryFieldOpt."Target SQL Table Name" := PTEMigrationSQLQueryField."Target SQL Table Name";
                        PTEMigrSQLQueryFieldOpt."Target SQL Field Name" := PTEMigrationSQLQueryField."Target SQL Field Name";
                        PTEMigrSQLQueryFieldOpt."Target SQL Field Option" := PTEMigrDsTableFieldAddTarOpti."Target Option ID";
                        if not PTEMigrSQLQueryFieldOpt.insert() then;
                    until PTEMigrDsTableFieldAddTarOpti.Next() = 0;
            until PTEMigrDsTableFieldAddTarget.Next() = 0;
    end;

}

