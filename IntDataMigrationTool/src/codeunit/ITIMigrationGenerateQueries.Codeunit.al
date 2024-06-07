codeunit 99003 "ITI Migration Generate Queries"
{
    var
        DataExistsConfAllMsg: Label 'Queries for migration: %1 has already been created. Do you want to delete existing queries and create again?', Comment = '%1 = Migration Code';
        DataExistsConfSelectedTableRecordNoMsg: Label 'Query for migration: %1 with table: %2 has already been created. Do you want to delete existing querry and create again?', Comment = '%1 = Migration Code, %2 = Selected Migration Tale name';
        DownloadingDataMsg: Label 'Generating SQL queries for migration: %1. No Of Records: %2', Comment = '%1 = Migration Code, %2 = No Of Records';
        NoExecTargetErr: Label 'No execution target has been choosen for migration %1', Comment = '%1 = Migration Code';

    procedure GenerateQuery(ITIMigrationSQLQuery: Record "ITI Migration SQL Query"; SkipConfirmation: Boolean; SelectedQuerySourceTableName: Text[150])
    var
        ITIMigration: Record "ITI Migration";
    begin
        ITIMigration.Get(ITIMigrationSQLQuery."Migration Code");
        GenerateQueries(ITIMigration, SkipConfirmation, SelectedQuerySourceTableName);

    end;

    procedure GenerateQueries(ITIMigration: Record "ITI Migration"; SkipConfirmation: Boolean; SelectedQuerySourceTableName: Text[150])
    var
        ITIMigrationDataset: Record "ITI Migration Dataset";
        ITIMigrationDatasetTable: Record "ITI Migration Dataset Table";
        ITIMigrDatasetTableField: Record "ITI Migr. Dataset Table Field";
        ITIMigrationSQLQuery: Record "ITI Migration SQL Query";
        ITIMigrationSQLQueryField: Record "ITI Migration SQL Query Field";
        ITIMigrationSQLQueryTable: record "ITI Migration SQL Query Table";
        ITIMigrDsTblFldOption: Record "ITI Migr. Ds. Tbl. Fld. Option";
        ITIMigrSQLQueryFieldOpt: Record "ITI Migr. SQL Query Field Opt.";
        QueryNo: Integer;
        QueryText: text;
        DialogProgress: Dialog;
        ProgressTotal: Integer;
        CurrentProgress: Integer;
        IsSameServerName: Boolean;
        OutStream: OutStream;
    begin
        ITIMigrationDataset.Get(ITIMigration."Migration Dataset Code");
        ITIMigrationDataset.TestField(Released, true);
        ITIMigrationDatasetTable.SetRange("Migration Dataset Code", ITIMigration."Migration Dataset Code");
        ITIMigrationDatasetTable.SetRange("Skip in Mapping", false);
        //generate data for query 
        //* delete existing queries
        ITIMigrationSQLQuery.SetRange("Migration Code", ITIMigration.Code);
        ITIMigrationSQLQueryField.SetRange("Migration Code", ITIMigration.Code);
        ITIMigrationSQLQueryTable.SetRange("Migration Code", ITIMigration.Code);
        ITIMigrSQLQueryFieldOpt.SetRange("Migration Code", ITIMigration.Code);

        if SelectedQuerySourceTableName <> '' then
            ITIMigrationSQLQuery.SetRange(SourceTableName, SelectedQuerySourceTableName);

        // Confirmation conditions
        if not SkipConfirmation then
            if (SelectedQuerySourceTableName <> '') then
                if not Confirm(DataExistsConfSelectedTableRecordNoMsg, false, ITIMigration.Code, SelectedQuerySourceTableName) then
                    exit;

        if (SelectedQuerySourceTableName = '') then
            if (not ITIMigrationSQLQueryTable.IsEmpty) or (not ITIMigrationSQLQueryField.IsEmpty) or (not ITIMigrationSQLQueryTable.IsEmpty) then
                if not Confirm(DataExistsConfAllMsg, false, ITIMigration.Code) then
                    exit;

        // Single query row deletion
        if SelectedQuerySourceTableName <> '' then begin
            ITIMigrationSQLQuery.FindFirst();
            QueryNo := ITIMigrationSQLQuery."Query No.";
            ITIMigrationSQLQuery.Delete();

            ITIMigrationSQLQueryField.SetRange("Query No.", QueryNo);
            ITIMigrationSQLQueryField.DeleteAll();

            ITIMigrationSQLQueryTable.SetRange("Query No.", QueryNo);
            ITIMigrationSQLQueryTable.DeleteAll();

            ITIMigrSQLQueryFieldOpt.SetRange("Query No.", QueryNo);
            ITIMigrSQLQueryFieldOpt.DeleteAll();
        end;

        // All query deletion
        if SelectedQuerySourceTableName = '' then begin
            ITIMigrationSQLQuery.DeleteAll();
            ITIMigrationSQLQueryField.DeleteAll();
            ITIMigrationSQLQueryTable.DeleteAll();
            ITIMigrSQLQueryFieldOpt.DeleteAll();
        end;

        //Open progress bar
        CurrentProgress := 0;
        ProgressTotal := ITIMigrationDatasetTable.Count;
        DialogProgress.OPEN(STRSUBSTNO(DownloadingDataMsg, ITIMigration."Code", ProgressTotal) + ': #1#####', CurrentProgress);

        //Create Linked server query for migration dataset
        IsSameServerName := CheckIfSameServerName(ITIMigration);

        QueryText := '';
        if not IsSameServerName then begin
            QueryText := QueryText + LinkedServerQueryString(ITIMigration) + NewLine();
            Clear(ITIMigration."Linked Server Query");
            ITIMigration."Linked Server Query".CreateOutStream(OutStream, TEXTENCODING::UTF8);
            OutStream.Write(QueryText);
            Clear(OutStream);
        end else
            Clear(ITIMigration."Linked Server Query");
        ITIMigration.Modify();

        if SelectedQuerySourceTableName <> '' then begin
            ITIMigrationDatasetTable.SetRange("Source Table Name", SelectedQuerySourceTableName);
            ITIMigrationDatasetTable.FindFirst();
        end;


        if ITIMigrationDatasetTable.FindSet() then
            repeat
                CurrentProgress := CurrentProgress + 1;
                DialogProgress.UPDATE(1, CurrentProgress);
                QueryText := '';
                //* collect sql tables and fields for each dataset line

                ITIMigrDatasetTableField.SetRange("Migration Dataset Code", ITIMigrationDataset.Code);
                ITIMigrDatasetTableField.SetRange("Source Table Name", ITIMigrationDatasetTable."Source Table Name");
                ITIMigrDatasetTableField.SetFilter("Source Field Name", '<>''''');
                ITIMigrDatasetTableField.SetFilter("Target Field Name", '<>''''');
                ITIMigrDatasetTableField.SetRange("Skip in Mapping", false);
                if ITIMigrDatasetTableField.FindSet() then begin
                    if SelectedQuerySourceTableName = '' then
                        QueryNo := QueryNo + 10000;
                    ITIMigrationSQLQuery.Init();
                    ITIMigrationSQLQuery."Migration Code" := ITIMigration.Code;
                    ITIMigrationSQLQuery."Query No." := QueryNo;
                    ITIMigrationSQLQuery.Description := ITIMigrationDatasetTable."Source Table Name" + '->' + ITIMigrationDatasetTable."Target table name";
                    ITIMigrationSQLQuery.SourceTableName := ITIMigrationDatasetTable."Source Table Name";
                    ITIMigrationSQLQuery.Insert();
                    InsertAllExtensionTablesAndKeyFields(ITIMigration, ITIMigrationDatasetTable, QueryNo);
                    repeat
                        ITIMigrationSQLQueryField.Init();
                        ITIMigrationSQLQueryField."Migration Code" := ITIMigration.Code;
                        ITIMigrationSQLQueryField."Query No." := QueryNo;
                        ITIMigrationSQLQueryField."Source SQL Table Name" := ITIMigrDatasetTableField.GetSQLSourceTableName(ITIMigration."Source Company Name");

                        if ITIMigrDatasetTableField."Mapping Type" = ITIMigrDatasetTableField."Mapping Type"::FieldToField then
                            ITIMigrationSQLQueryField."Source SQL Field Name" := ITIMigrDatasetTableField.GetSQLSourceFieldName()
                        else begin
                            ITIMigrationSQLQueryField."Source SQL Field Name" := ITIMigrDatasetTableField."Source Field Name";
                            ITIMigrationSQLQueryField.Constant := true;
                        end;

                        ITIMigrationSQLQueryField."Target SQL Field Name" := ITIMigrDatasetTableField.GetSQLTargetFieldName();
                        ITIMigrationSQLQueryField."Target SQL Table Name" := ITIMigrDatasetTableField.GetSQLTargetTableName(ITIMigration."Target Company Name");
                        if not ITIMigrationSQLQueryField.insert() then;

                        ITIMigrDsTblFldOption.SetRange("Migration Dataset Code", ITIMigrationDataset.Code);
                        ITIMigrDsTblFldOption.SetRange("Source Table Name", ITIMigrationDatasetTable."Source Table Name");
                        ITIMigrDsTblFldOption.SetRange("Source Field Name", ITIMigrDatasetTableField."Source Field Name");
                        if ITIMigrDsTblFldOption.FindSet() then
                            repeat
                                ITIMigrSQLQueryFieldOpt.init();
                                ITIMigrSQLQueryFieldOpt."Migration Code" := ITIMigration.Code;
                                ITIMigrSQLQueryFieldOpt."Query No." := QueryNo;
                                ITIMigrSQLQueryFieldOpt."Source SQL Table Name" := ITIMigrationSQLQueryField."Source SQL Table Name";
                                ITIMigrSQLQueryFieldOpt."Source SQL Field Name" := ITIMigrationSQLQueryField."Source SQL Field Name";
                                ITIMigrSQLQueryFieldOpt."Source SQL Field Option" := ITIMigrDsTblFldOption."Source Option ID";
                                ITIMigrSQLQueryFieldOpt."Target SQL Table Name" := ITIMigrationSQLQueryField."Target SQL Table Name";
                                ITIMigrSQLQueryFieldOpt."Target SQL Field Name" := ITIMigrationSQLQueryField."Target SQL Field Name";
                                ITIMigrSQLQueryFieldOpt."Target SQL Field Option" := ITIMigrDsTblFldOption."Target Option ID";
                                if not ITIMigrSQLQueryFieldOpt.insert() then;
                            until ITIMigrDsTblFldOption.Next() = 0;

                        GetEquivalMappingFields(ITIMigrDatasetTableField, ITIMigration, QueryNo);

                        ITIMigrationSQLQueryTable.Init();
                        ITIMigrationSQLQueryTable."Migration Code" := ITIMigration.Code;
                        ITIMigrationSQLQueryTable."Query No." := QueryNo;
                        ITIMigrationSQLQueryTable."Source SQL Table Name" := ITIMigrationSQLQueryField."Source SQL Table Name";
                        ITIMigrationSQLQueryTable."Target SQL Table Name" := ITIMigrationSQLQueryField."Target SQL Table Name";
                        if not ITIMigrationSQLQueryTable.Insert() then;
                    until ITIMigrDatasetTableField.Next() = 0;

                    //* Build Query
                    if not ITIMigration."Do Not Use Transaction" then
                        QueryText := QueryText + 'BEGIN TRAN Q' + FORMAT(QueryNo, 0, 9) + ';' + NewLine();
                    QueryText := QueryText + TablesTransferQueryString(ITIMigration, QueryNo, IsSameServerName) + NewLine();
                    if not ITIMigration."Do Not Use Transaction" then
                        QueryText := QueryText + 'COMMIT TRAN Q' + FORMAT(QueryNo, 0, 9) + ';' + NewLine();
                    Clear(ITIMigrationSQLQuery.Query);
                    ITIMigrationSQLQuery.Query.CreateOutStream(OutStream, TEXTENCODING::UTF8);
                    OutStream.Write(QueryText);
                    ITIMigrationSQLQuery.Modify();
                end;

            until ITIMigrationDatasetTable.Next() = 0;
        DialogProgress.Close();
        ITIMigration."Generated Queries" := true;
        ITIMigration.Modify();
    end;

    local procedure InsertAllExtensionTablesAndKeyFields(ITIMigration: Record "ITI Migration"; ITIMigrationDatasetTable: Record "ITI Migration Dataset Table"; QueryNo: Integer)
    var

        TargetKeysITIAppObjectTableField: Record "ITI App. Object Table Field";
        TargetITIAppObjectTableField: Record "ITI App. Object Table Field";
        ITIMigrationSQLQueryField: Record "ITI Migration SQL Query Field";
        ITIMigrationSQLQueryTable: record "ITI Migration SQL Query Table";
        ITIMigrDatasetTableField: record "ITI Migr. Dataset Table Field";
        ITIMigrDsTblFldOption: Record "ITI Migr. Ds. Tbl. Fld. Option";
        ITIMigrSQLQueryFieldOpt: Record "ITI Migr. SQL Query Field Opt.";

    begin
        TargetITIAppObjectTableField.SetRange("SQL Database Code", ITIMigration."Target SQL Database Code");
        TargetITIAppObjectTableField.SetRange("Table Name", ITIMigrationDatasetTable."Target table name");
        TargetITIAppObjectTableField.SetFilter(FieldClass, '@Normal');
        TargetITIAppObjectTableField.SetRange(Enabled, true); //ITPW 20240108/S/E // miałem w AL zapalone enable = false i dawał błedy

        TargetKeysITIAppObjectTableField.SetRange("SQL Database Code", ITIMigration."Target SQL Database Code");
        TargetKeysITIAppObjectTableField.SetRange("Table Name", ITIMigrationDatasetTable."Target table name");
        TargetKeysITIAppObjectTableField.SetRange("Key", true);

        //Go through all target table object fields to find all table extensions
        if TargetITIAppObjectTableField.FindSet() then
            repeat
                //for each key field from target find source field and table
                TargetKeysITIAppObjectTableField.FindSet();
                repeat
                    ITIMigrDatasetTableField.SetRange("Migration Dataset Code", ITIMigration."Migration Dataset Code");
                    ITIMigrDatasetTableField.SetRange("Target SQL Database Code", ITIMigration."Target SQL Database Code");
                    ITIMigrDatasetTableField.SetRange("Target table name", ITIMigrationDatasetTable."Target table name");
                    ITIMigrDatasetTableField.SetRange("Target Field name", TargetKeysITIAppObjectTableField.Name);
                    ITIMigrDatasetTableField.FindFirst();

                    ITIMigrationSQLQueryField.Init();
                    ITIMigrationSQLQueryField."Migration Code" := ITIMigration.Code;
                    ITIMigrationSQLQueryField."Query No." := QueryNo;
                    ITIMigrationSQLQueryField."Source SQL Field Name" := ITIMigrDatasetTableField.GetSQLSourceFieldName();
                    ITIMigrationSQLQueryField."Source SQL Table Name" := ITIMigrDatasetTableField.GetSQLSourceTableName(ITIMigration."Source Company Name");
                    ITIMigrationSQLQueryField."Target SQL Field Name" := TargetKeysITIAppObjectTableField."SQL Field Name";
                    ITIMigrationSQLQueryField."Target SQL Table Name" := TargetITIAppObjectTableField.GetSQLTableName(ITIMigration."Target Company Name");
                    if not ITIMigrationSQLQueryField.insert() then;

                    ITIMigrDsTblFldOption.SetRange("Migration Dataset Code", ITIMigrDatasetTableField."Migration Dataset Code");
                    ITIMigrDsTblFldOption.SetRange("Source Table Name", ITIMigrDatasetTableField."Source Table Name");
                    ITIMigrDsTblFldOption.SetRange("Source Field Name", ITIMigrDatasetTableField."Source Field Name");
                    if ITIMigrDsTblFldOption.FindSet() then
                        repeat
                            ITIMigrSQLQueryFieldOpt.init();
                            ITIMigrSQLQueryFieldOpt."Migration Code" := ITIMigration.Code;
                            ITIMigrSQLQueryFieldOpt."Query No." := QueryNo;
                            ITIMigrSQLQueryFieldOpt."Source SQL Table Name" := ITIMigrationSQLQueryField."Source SQL Table Name";
                            ITIMigrSQLQueryFieldOpt."Source SQL Field Name" := ITIMigrationSQLQueryField."Source SQL Field Name";
                            ITIMigrSQLQueryFieldOpt."Source SQL Field Option" := ITIMigrDsTblFldOption."Source Option ID";
                            ITIMigrSQLQueryFieldOpt."Target SQL Table Name" := ITIMigrationSQLQueryField."Target SQL Table Name";
                            ITIMigrSQLQueryFieldOpt."Target SQL Field Name" := ITIMigrationSQLQueryField."Target SQL Field Name";
                            ITIMigrSQLQueryFieldOpt."Target SQL Field Option" := ITIMigrDsTblFldOption."Target Option ID";
                            if not ITIMigrSQLQueryFieldOpt.insert() then;
                        until ITIMigrDsTblFldOption.Next() = 0;

                    ITIMigrationSQLQueryTable.Init();
                    ITIMigrationSQLQueryTable."Migration Code" := ITIMigration.Code;
                    ITIMigrationSQLQueryTable."Query No." := QueryNo;
                    ITIMigrationSQLQueryTable."Source SQL Table Name" := ITIMigrationSQLQueryField."Source SQL Table Name";
                    ITIMigrationSQLQueryTable."Target SQL Table Name" := ITIMigrationSQLQueryField."Target SQL Table Name";
                    if not ITIMigrationSQLQueryTable.Insert() then;
                until TargetKeysITIAppObjectTableField.Next() = 0;
            until TargetITIAppObjectTableField.Next() = 0;
    end;


    local procedure LinkedServerQueryString(ITIMigration: Record "ITI Migration"): Text;
    var
        SourceITISQLDatabase: Record "ITI SQL Database";
        TargetITISQLDatabase: Record "ITI SQL Database";
        SQLQueryText: Text;
    begin
        SourceITISQLDatabase.Get(ITIMigration."Source SQL Database Code");
        TargetITISQLDatabase.Get(ITIMigration."Target SQL Database Code");
        //drop target linked server if already linked
        if ITIMigration."Execute On" = ITIMigration."Execute On"::Source then begin
            SQLQueryText := SQLQueryText + 'if exists(select * from sys.servers where name = N''' + TargetITISQLDatabase."Server Name" + ''')' + NewLine();
            SQLQueryText := SQLQueryText + 'BEGIN' + NewLine();
            SQLQueryText := SQLQueryText + 'exec master.dbo.sp_dropserver ''' + TargetITISQLDatabase."Server Name" + ''', ''droplogins'';' + NewLine();
            SQLQueryText := SQLQueryText + 'END;' + NewLine();
            //add target linked server
            SQLQueryText := SQLQueryText + 'EXEC master.dbo.sp_addlinkedserver ' + NewLine();
            SQLQueryText := SQLQueryText + '@server = N''' + TargetITISQLDatabase."Server Name" + ''', ' + NewLine();
            SQLQueryText := SQLQueryText + '@srvproduct=N''SQL Server'' ;' + NewLine();
            //add login to the target linked server
            SQLQueryText := SQLQueryText + 'exec master.dbo.sp_addlinkedsrvlogin [' + TargetITISQLDatabase."Server Name" + '] , ''false'', null , ''' + TargetITISQLDatabase."User Name" + ''' ,''' + TargetITISQLDatabase.GetPassword() + ''';' + NewLine();
            exit(SQLQueryText);
        end;

        if ITIMigration."Execute On" = ITIMigration."Execute On"::Target then begin
            SQLQueryText := SQLQueryText + 'if exists(select * from sys.servers where name = N''' + SourceITISQLDatabase."Server Name" + ''')' + NewLine();
            SQLQueryText := SQLQueryText + 'BEGIN' + NewLine();
            SQLQueryText := SQLQueryText + 'exec master.dbo.sp_dropserver ''' + SourceITISQLDatabase."Server Name" + ''', ''droplogins'';' + NewLine();
            SQLQueryText := SQLQueryText + 'END;' + NewLine();
            //add target linked server
            SQLQueryText := SQLQueryText + 'EXEC master.dbo.sp_addlinkedserver ' + NewLine();
            SQLQueryText := SQLQueryText + '@server = N''' + SourceITISQLDatabase."Server Name" + ''', ' + NewLine();
            SQLQueryText := SQLQueryText + '@srvproduct=N''SQL Server'' ;' + NewLine();
            //add login to the target linked server
            SQLQueryText := SQLQueryText + 'exec master.dbo.sp_addlinkedsrvlogin [' + SourceITISQLDatabase."Server Name" + '] , ''false'', null , ''' + SourceITISQLDatabase."User Name" + ''' ,''' + SourceITISQLDatabase.GetPassword() + ''';' + NewLine();
            exit(SQLQueryText);
        end;

        Error(NoExecTargetErr, ITIMigration.Code);
    end;

    local procedure TablesTransferQueryString(ITIMigration: Record "ITI Migration"; QueryNo: Integer; IsSameServerName: Boolean): Text;
    var
        TargetITISQLDatabase: Record "ITI SQL Database";
        SourceITISQLDatabase: Record "ITI SQL Database";
        ITIMigrationSQLQueryField: Record "ITI Migration SQL Query Field";
        ITIMigrationSQLQueryTable: record "ITI Migration SQL Query Table";
        ITIMigrSQLQueryFieldOpt: Record "ITI Migr. SQL Query Field Opt.";
        ITISQLDatabaseTableField: Record "ITI SQL Database Table Field";
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
        TargetITISQLDatabase.Get(ITIMigration."Target SQL Database Code");
        if ITIMigration."Execute On" = ITIMigration."Execute On"::Target then
            SourceITISQLDatabase.Get(ITIMigration."Source SQL Database Code");
        ITIMigrationSQLQueryTable.SetRange("Migration Code", ITIMigration.Code);
        ITIMigrationSQLQueryTable.SetRange("Query No.", QueryNo);
        if ITIMigrationSQLQueryTable.FindSet() then
            repeat
                ContainsAutoincrementValue := false;
                SourceTableName := ITIMigrationSQLQueryTable."Source SQL Table Name";
                TargetTableName := ITIMigrationSQLQueryTable."Target SQL Table Name";
                ITIMigrationSQLQueryField.reset();
                ITIMigrationSQLQueryField.SetRange("Migration Code", ITIMigration.Code);
                ITIMigrationSQLQueryField.SetRange("Query No.", QueryNo);
                ITIMigrationSQLQueryField.SetRange("Source SQL Table Name", SourceTableName);
                ITIMigrationSQLQueryField.SetRange("Target SQL Table Name", TargetTableName);
                SourceFields := '';
                TargetFields := '';
                if ITIMigrationSQLQueryField.FindSet() then
                    repeat
                        if SourceFields <> '' then
                            SourceFields := SourceFields + ',' + NewLine();

                        //check if there is difference in option mapping
                        OptionsDifference := false;
                        OptionDifferenceCaseStatement := '';
                        ITIMigrSQLQueryFieldOpt.SetRange("Migration Code", ITIMigration.Code);
                        ITIMigrSQLQueryFieldOpt.SetRange("Query No.", QueryNo);
                        ITIMigrSQLQueryFieldOpt.SetRange("Source SQL Table Name", SourceTableName);
                        ITIMigrSQLQueryFieldOpt.SetRange("Source SQL Field Name", ITIMigrationSQLQueryField."Source SQL Field Name");
                        ITIMigrSQLQueryFieldOpt.SetRange("Target SQL Table Name", TargetTableName);
                        ITIMigrSQLQueryFieldOpt.SetRange("Target SQL Field Name", ITIMigrationSQLQueryField."Target SQL Field Name");
                        if ITIMigrSQLQueryFieldOpt.FindSet() then begin
                            OptionDifferenceCaseStatement := '   CASE' + NewLine();
                            repeat
                                if ITIMigrSQLQueryFieldOpt."Source SQL Field Option" <> ITIMigrSQLQueryFieldOpt."Target SQL Field Option" then
                                    OptionsDifference := true;
                                OptionDifferenceCaseStatement := OptionDifferenceCaseStatement + '      WHEN ' + '"' + ITIMigrationSQLQueryField."Source SQL Field Name" + '"' + ' = ' + Format(ITIMigrSQLQueryFieldOpt."Source SQL Field Option", 0, 9) + ' THEN ' + Format(ITIMigrSQLQueryFieldOpt."Target SQL Field Option", 0, 9) + NewLine();
                            until ITIMigrSQLQueryFieldOpt.Next() = 0;
                            OptionDifferenceCaseStatement := OptionDifferenceCaseStatement + '      ELSE ' + '"' + ITIMigrationSQLQueryField."Source SQL Field Name" + '"' + NewLine();
                            OptionDifferenceCaseStatement := OptionDifferenceCaseStatement + '   END AS ' + '"' + ITIMigrationSQLQueryField."Source SQL Field Name" + '"';
                            //OptionsDifference := true;
                        end;

                        if OptionsDifference then
                            SourceFields := SourceFields + OptionDifferenceCaseStatement
                        else
                            if ITIMigrationSQLQueryField.Constant then
                                SourceFields := SourceFields + '   ' + '''' + ITIMigrationSQLQueryField."Source SQL Field Name" + ''' AS "' + ITIMigrationSQLQueryField."Target SQL Field Name" + '"'
                            else begin
                                //check if there is difference in field length
                                ITISQLDatabaseTableField.Reset();
                                ITISQLDatabaseTableField.SetRange("SQL Database Code", ITIMigration."Source SQL Database Code");
                                ITISQLDatabaseTableField.SetRange("Table Name", ITIMigrationSQLQueryTable."Source SQL Table Name");
                                ITISQLDatabaseTableField.SetRange("Column Name", ITIMigrationSQLQueryField."Source SQL Field Name");
                                ITISQLDatabaseTableField.FindFirst();
                                SourceFieldLength := ITISQLDatabaseTableField."Character Maximum Length";
                                ITISQLDatabaseTableField.SetRange("SQL Database Code", ITIMigration."Target SQL Database Code");
                                ITISQLDatabaseTableField.SetRange("Table Name", ITIMigrationSQLQueryTable."Target SQL Table Name");
                                ITISQLDatabaseTableField.SetRange("Column Name", ITIMigrationSQLQueryField."Target SQL Field Name");
                                ITISQLDatabaseTableField.FindFirst();
                                if ITISQLDatabaseTableField.Autoincrement then
                                    ContainsAutoincrementValue := true;
                                TargetFieldLength := ITISQLDatabaseTableField."Character Maximum Length";
                                //SourceFieldLength := 1000;
                                if (SourceFieldLength > TargetFieldLength) and ((ITISQLDatabaseTableField."Data Type" = 'varchar') or (ITISQLDatabaseTableField."Data Type" = 'nvarchar')) then
                                    SourceFields := SourceFields + '   ' + 'SUBSTRING(' + '"' + ITIMigrationSQLQueryField."Source SQL Field Name" + '"' + ', 1, ' + Format(TargetFieldLength, 0, 9) + ') AS ' + '"' + ITIMigrationSQLQueryField."Source SQL Field Name" + '"'
                                else
                                    SourceFields := SourceFields + '   ' + '"' + ITIMigrationSQLQueryField."Source SQL Field Name" + '"';
                            end;

                        if TargetFields <> '' then
                            TargetFields := TargetFields + ',' + NewLine();
                        TargetFields := TargetFields + '   ' + '"' + ITIMigrationSQLQueryField."Target SQL Field Name" + '"';


                    until ITIMigrationSQLQueryField.Next() = 0;

                //Insert not maped not nullable Target fields
                ITISQLDatabaseTableField.reset();
                ITISQLDatabaseTableField.SetRange("SQL Database Code", ITIMigration."Target SQL Database Code");
                ITISQLDatabaseTableField.SetRange("Table Name", ITIMigrationSQLQueryTable."Target SQL Table Name");
                ITISQLDatabaseTableField.SetRange("Allow Nulls", false);
                ITISQLDatabaseTableField.SetFilter("Column Name", '<>timestamp&<>$systemId&<>$systemCreatedAt&<>$systemCreatedBy&<>$systemModifiedAt&<>$systemModifiedBy'); //<- to chyba nie jest najlepsze rozwiązanie, ale trzeba odfiltrować systemowe pola
                ITISQLDatabaseTableField.SetFilter("Column Default", '=#NULL#');
                if ITISQLDatabaseTableField.FindSet() then
                    repeat
                        ITIMigrationSQLQueryField.reset();
                        ITIMigrationSQLQueryField.SetRange("Migration Code", ITIMigration.code);
                        ITIMigrationSQLQueryField.SetRange("Query No.", QueryNo);
                        ITIMigrationSQLQueryField.SetRange("Target SQL Table Name", ITIMigrationSQLQueryTable."Target SQL Table Name");
                        ITIMigrationSQLQueryField.SetRange("Target SQL Field Name", ITISQLDatabaseTableField."Column Name");
                        if ITIMigrationSQLQueryField.IsEmpty then begin
                            if SourceFields <> '' then
                                SourceFields := SourceFields + ',' + NewLine();
                            if TargetFields <> '' then
                                TargetFields := TargetFields + ',' + NewLine();
                            TargetFields := TargetFields + '   ' + '"' + ITISQLDatabaseTableField."Column Name" + '"';
                            case LowerCase(ITISQLDatabaseTableField."Data Type") of
                                'int':
                                    SourceFields := SourceFields + '   ((0))' + ' AS [' + ITISQLDatabaseTableField."Column Name" + ']';
                                'nvarchar':
                                    SourceFields := SourceFields + '   (N'''')' + ' AS [' + ITISQLDatabaseTableField."Column Name" + ']';
                                'datetime':
                                    SourceFields := SourceFields + '   (''1753.01.01'')' + ' AS [' + ITISQLDatabaseTableField."Column Name" + ']';
                                'bigint':
                                    SourceFields := SourceFields + '   ((0))' + ' AS [' + ITISQLDatabaseTableField."Column Name" + ']';
                                'decimal':
                                    SourceFields := SourceFields + '   ((0.0))' + ' AS [' + ITISQLDatabaseTableField."Column Name" + ']';
                                'timestamp':
                                    SourceFields := SourceFields + '   CONVERT (timestamp, CURRENT_TIMESTAMP)' + ' AS [' + ITISQLDatabaseTableField."Column Name" + ']';
                                'uniqueidentifier':
                                    SourceFields := SourceFields + '   (''00000000-0000-0000-0000-000000000000'')' + ' AS [' + ITISQLDatabaseTableField."Column Name" + ']';
                                'image':
                                    SourceFields := SourceFields + '   (0x00)' + ' AS [' + ITISQLDatabaseTableField."Column Name" + ']';
                                'tinyint':
                                    SourceFields := SourceFields + '   ((0.0))' + ' AS [' + ITISQLDatabaseTableField."Column Name" + ']';
                                'varbinary':
                                    SourceFields := SourceFields + '   (0x00)' + ' AS [' + ITISQLDatabaseTableField."Column Name" + ']';
                                'varchar':
                                    SourceFields := SourceFields + '   ('''')' + ' AS [' + ITISQLDatabaseTableField."Column Name" + ']';
                                'nchar':
                                    SourceFields := SourceFields + '   ('''')' + ' AS [' + ITISQLDatabaseTableField."Column Name" + ']';
                                else
                                    SourceFields := SourceFields + '   (N'''')' + ' AS [' + ITISQLDatabaseTableField."Column Name" + ']';
                            end;

                        end;
                    until ITISQLDatabaseTableField.Next() = 0;


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

                if ITIMigration."Execute On" = ITIMigration."Execute On"::Source then begin
                    if ContainsAutoincrementValue then begin
                        //SQLQueryText := 'zażółćgęśląjaźńZAŻÓŁĆGĘŚLĄJAŹŃ';
                        SQLQueryText := SQLQueryText + 'SET IDENTITY_INSERT ';
                        if not IsSameServerName then
                            SQLQueryText := SQLQueryText + '[' + TargetITISQLDatabase."Server Name" + '].';
                        SQLQueryText := SQLQueryText + '[' + TargetITISQLDatabase."Database Name" + '].[dbo].[' + TargetTableName + '] ON;' + NewLine();
                    end;

                    SQLQueryText := SQLQueryText + 'DELETE FROM ';
                    if not IsSameServerName then
                        SQLQueryText := SQLQueryText + '[' + TargetITISQLDatabase."Server Name" + '].';
                    SQLQueryText := SQLQueryText + '[' + TargetITISQLDatabase."Database Name" + '].[dbo].[' + TargetTableName + '];' + NewLine();

                    SQLQueryText := SQLQueryText + 'INSERT INTO ';
                    if not IsSameServerName then
                        SQLQueryText := SQLQueryText + '[' + TargetITISQLDatabase."Server Name" + '].';
                    SQLQueryText := SQLQueryText + '[' + TargetITISQLDatabase."Database Name" + '].[dbo].[' + TargetTableName + '] (' + NewLine() + TargetFields + NewLine() + ')' + NewLine();

                    SQLQueryText := SQLQueryText + 'SELECT ' + NewLine() + SourceFields + ' FROM [dbo].[' + SourceTableName + ']' + ';' + NewLine();

                    if ContainsAutoincrementValue then begin
                        SQLQueryText := SQLQueryText + 'SET IDENTITY_INSERT ';
                        if not IsSameServerName then
                            SQLQueryText := SQLQueryText + '[' + TargetITISQLDatabase."Server Name" + '].';
                        SQLQueryText := SQLQueryText + '[' + TargetITISQLDatabase."Database Name" + '].[dbo].[' + TargetTableName + '] OFF;' + NewLine();
                    end;
                end;
                if ITIMigration."Execute On" = ITIMigration."Execute On"::Target then begin
                    if ContainsAutoincrementValue then
                        SQLQueryText := SQLQueryText + 'SET IDENTITY_INSERT [dbo].[' + TargetTableName + '] ON;' + NewLine();
                    SQLQueryText := SQLQueryText + 'DELETE FROM [dbo].[' + TargetTableName + '];' + NewLine();
                    SQLQueryText := SQLQueryText + 'INSERT INTO [dbo].[' + TargetTableName + '] (' + NewLine() + TargetFields + NewLine() + ')' + NewLine();

                    SQLQueryText := SQLQueryText + 'SELECT ' + NewLine() + SourceFields + ' FROM ';
                    if not IsSameServerName then
                        SQLQueryText := SQLQueryText + '[' + SourceITISQLDatabase."Server Name" + '].';
                    SQLQueryText := SQLQueryText + '[' + SourceITISQLDatabase."Database Name" + '].[dbo].[' + SourceTableName + ']' + ';' + NewLine();

                    if ContainsAutoincrementValue then
                        SQLQueryText := SQLQueryText + 'SET IDENTITY_INSERT [dbo].[' + TargetTableName + '] OFF;' + NewLine();
                end;
            until ITIMigrationSQLQueryTable.Next() = 0;
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

    local procedure CheckIfSameServerName(ITIMigration: Record "ITI Migration"): Boolean
    var
        SourceITISQLDatabase, TargetSQLDatabase : Record "ITI SQL Database";
    begin
        SourceITISQLDatabase.Get(ITIMigration."Source SQL Database Code");
        TargetSQLDatabase.Get(ITIMigration."Target SQL Database Code");

        exit(SourceITISQLDatabase."Server Name" = TargetSQLDatabase."Server Name");
    end;

    local procedure GetEquivalMappingFields(ITIMigrDatasetTableField: Record "ITI Migr. Dataset Table Field"; ITIMigration: Record "ITI Migration"; QueryNo: Integer)
    var
        ITIMigrationSQLQueryField: Record "ITI Migration SQL Query Field";
        ITIMigrDsTableFieldAddTarget: Record ITIMigrDsTableFieldAddTarget;
        ITIMigrDsTableFieldAddTarOpti: Record ITIMigrDsTableFieldAddTarOpti;
        ITIMigrSQLQueryFieldOpt: Record "ITI Migr. SQL Query Field Opt.";
    begin
        ITIMigrDsTableFieldAddTarget.SetRange("Migration Dataset Code", ITIMigrDatasetTableField."Migration Dataset Code");
        ITIMigrDsTableFieldAddTarget.SetRange("Source table name", ITIMigrDatasetTableField."Source table name");
        ITIMigrDsTableFieldAddTarget.SetRange("Source Field Name", ITIMigrDatasetTableField."Source Field Name");

        if ITIMigrDsTableFieldAddTarget.FindSet() then
            repeat
                ITIMigrationSQLQueryField.Init();
                ITIMigrationSQLQueryField."Migration Code" := ITIMigration.Code;
                ITIMigrationSQLQueryField."Query No." := QueryNo;

                if ITIMigrDatasetTableField."Mapping Type" = ITIMigrDatasetTableField."Mapping Type"::FieldToField then
                    ITIMigrationSQLQueryField."Source SQL Field Name" := ITIMigrDsTableFieldAddTarget.GetSQLSourceFieldName()
                else begin
                    ITIMigrationSQLQueryField.Constant := true;
                    ITIMigrationSQLQueryField."Source SQL Field Name" := ITIMigrDatasetTableField."Source Field Name";
                end;

                ITIMigrationSQLQueryField."Source SQL Table Name" := ITIMigrDatasetTableField.GetSQLSourceTableName(ITIMigration."Source Company Name");
                ITIMigrationSQLQueryField."Target SQL Field Name" := ITIMigrDsTableFieldAddTarget.GetSQLTargetFieldName();
                ITIMigrationSQLQueryField."Target SQL Table Name" := ITIMigrDatasetTableField.GetSQLTargetTableName(ITIMigration."Target Company Name");
                if not ITIMigrationSQLQueryField.insert() then;

                ITIMigrDsTableFieldAddTarOpti.SetRange("Migration Dataset Code", ITIMigrDatasetTableField."Migration Dataset Code");
                ITIMigrDsTableFieldAddTarOpti.SetRange("Source table name", ITIMigrDatasetTableField."Source table name");
                ITIMigrDsTableFieldAddTarOpti.SetRange("Source Field Name", ITIMigrDatasetTableField."Source Field Name");
                ITIMigrDsTableFieldAddTarOpti.SetRange("Target Field Name", ITIMigrDsTableFieldAddTarOpti."Target Field Name");

                if ITIMigrDsTableFieldAddTarOpti.FindSet() then
                    repeat
                        ITIMigrSQLQueryFieldOpt.init();
                        ITIMigrSQLQueryFieldOpt."Migration Code" := ITIMigration.Code;
                        ITIMigrSQLQueryFieldOpt."Query No." := QueryNo;
                        ITIMigrSQLQueryFieldOpt."Source SQL Table Name" := ITIMigrationSQLQueryField."Source SQL Table Name";
                        ITIMigrSQLQueryFieldOpt."Source SQL Field Name" := ITIMigrationSQLQueryField."Source SQL Field Name";
                        ITIMigrSQLQueryFieldOpt."Source SQL Field Option" := ITIMigrDsTableFieldAddTarOpti."Source Option ID";
                        ITIMigrSQLQueryFieldOpt."Target SQL Table Name" := ITIMigrationSQLQueryField."Target SQL Table Name";
                        ITIMigrSQLQueryFieldOpt."Target SQL Field Name" := ITIMigrationSQLQueryField."Target SQL Field Name";
                        ITIMigrSQLQueryFieldOpt."Target SQL Field Option" := ITIMigrDsTableFieldAddTarOpti."Target Option ID";
                        if not ITIMigrSQLQueryFieldOpt.insert() then;
                    until ITIMigrDsTableFieldAddTarOpti.Next() = 0;
            until ITIMigrDsTableFieldAddTarget.Next() = 0;
    end;

}

