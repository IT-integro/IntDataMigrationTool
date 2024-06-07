codeunit 99015 "ITICheckEmptyFieldCount"
{
    TableNo = "ITI Migr. Dataset Table Field";

    trigger OnRun()
    var
        ITIMigrDatasetTableField: Record "ITI Migr. Dataset Table Field";
    begin
        GetCompaniesName(Rec."Source SQL Database Code");

        ITIMigrDatasetTableField.SetRange("Migration Dataset Code", Rec."Migration Dataset Code");
        ITIMigrDatasetTableField.SetRange("Source table name", Rec."Source table name");
        ITIMigrDatasetTableField.SetRange("Mapping Type", Rec."Mapping Type"::FieldToField);
        if ITIMigrDatasetTableField.FindSet() then
            repeat
                ITIMigrDatasetTableField.CalcFields("Source SQL Database Code");
                CheckEmptyFieldCount(ITIMigrDatasetTableField."Migration Dataset Code", ITIMigrDatasetTableField."Source SQL Database Code", ITIMigrDatasetTableField."Source table name", ITIMigrDatasetTableField."Source Field Name");
                ITIMigrDatasetTableFieldUpdateIsEmpty(ITIMigrDatasetTableField);
            until ITIMigrDatasetTableField.Next() = 0;
    end;

    local procedure CheckEmptyFieldCount(MigrationDateasetCode: Code[20]; SourceSQLDatabaseCode: Code[20]; SourceTableName: Text[150]; SourceFieldName: Text[150])
    var
        SqlTableName, SqlQueryTableName : Text;
        SqlFieldName, FieldType, CompanyName : Text[150];
    begin
        GlobalMigrationDateasetCode := MigrationDateasetCode;
        GlobalSourceSQLDatabaseCode := SourceSQLDatabaseCode;
        GLobalSourceTableName := SourceTableName;
        GlobalSourceFieldName := SourceFieldName;

        PrepareToCount();

        GlobalITISQLDatabase.Get(GlobalSourceSQLDatabaseCode);

        SqlFieldName := GetSqlFieldName();

        foreach CompanyName in CompaniesName.Keys do begin
            SqlTableName := GetSqlTableName(CompanyName);

            SqlQueryTableName := '[' + GlobalITISQLDatabase."Database Name" + '].[dbo].[' + SqlTableName + ']';

            FieldType := GlobalITIAppObjectTableField.Datatype;

            GetRecorsCount(SqlQueryTableName, SqlFieldName, CompanyName, FieldType, SqlTableName);
        end;
    end;

    local procedure GetCompaniesName(SourceSQLDatabaseCode: Code[20])
    var
        ITISQLDatabaseCompany: Record "ITI SQL Database Company";
    begin
        ITISQLDatabaseCompany.SetRange("SQL Database Code", SourceSQLDatabaseCode);
        ITISQLDatabaseCompany.FindSet();
        repeat
            CompaniesName.Add(ITISQLDatabaseCompany.Name, ITISQLDatabaseCompany."SQL Name");
        until ITISQLDatabaseCompany.Next() = 0;
    end;

    local procedure GetSqlTableName(CompanyName: Text[150]): Text[250]
    begin
        SetFilterForObjectTableField();
        exit(GlobalITIAppObjectTableField.GetSQLTableName(CompanyName));
    end;

    local procedure GetSqlFieldName(): Text[150]
    begin
        SetFilterForObjectTableField();
        exit(GlobalITIAppObjectTableField."SQL Field Name");
    end;

    local procedure SetFilterForObjectTableField()
    begin
        GlobalITIAppObjectTableField.Reset();
        GlobalITIAppObjectTableField.SetRange("SQL Database Code", GlobalSourceSQLDatabaseCode);
        GlobalITIAppObjectTableField.SetRange("Table Name", GLobalSourceTableName);
        GlobalITIAppObjectTableField.SetRange(Name, GlobalSourceFieldName);
        GlobalITIAppObjectTableField.FindFirst();
    end;

    local procedure GetRecorsCount(SqlQueryTableName: Text; SqlFieldName: Text[150]; CompanyName: Text[150]; FieldType: Text[150]; SqlTableName: Text)
    var
        NumberOfRecords, NumberOfEmptyFields : Integer;
        SQLQueryText: Text;
    begin
        NumberOfRecords := GetRecordsCount(SqlTableName);
        SQLQueryText := 'SELECT COUNT(*) FROM ' + SqlQueryTableName
                + ' WHERE ' + SqlQueryTableName + '.' + '[' + SqlFieldName + '] ' + GetEmptyValue(FieldType, SqlTableName, SqlFieldName) + ';';

        NumberOfEmptyFields := GetDataFromDatabase(SQLQueryText);
        CreateEmptyFieldCountRecord(CompanyName, NumberOfEmptyFields, NumberOfRecords);
    end;

    local procedure GetEmptyValue(DataType: Text[150]; SqlQueryTableName: Text; SqlFieldName: Text): Text[150]
    var
        ITISQLDatabaseTableField: record "ITI SQL Database Table Field";
    begin
        case DataType.ToUpper() of
            'CODE', 'TEXT', 'RECORDID', 'DATEFORMULA':
                exit('=''''');
            'GUID', 'BLOB', 'MEDIA':
                begin
                    ITISQLDatabaseTableField.SetRange("SQL Database Code", GlobalSourceSQLDatabaseCode);
                    ITISQLDatabaseTableField.SetRange("Table Name", SqlQueryTableName);
                    ITISQLDatabaseTableField.SetRange("Column Name", SqlFieldName);
                    ITISQLDatabaseTableField.FindFirst();
                    if UpperCase(ITISQLDatabaseTableField."Data Type") = 'IMAGE' then
                        exit('IS NULL')
                    else
                        exit('=''00000000-0000-0000-0000-000000000000''');
                end;
            'INTEGER', 'DECIMAL', 'BIGINTEGER', 'OPTION':
                exit('=''0''');
            'TIME':
                exit('=''00:00:00.000''');
            'DATE':
                exit('=''1753-01-01''');
            'DATETIME':
                exit('=''1753-01-01 00:00:00.000''');
            else
                exit('=''''');
        end;
    end;

    local procedure ITIMigrDatasetTableFieldUpdateIsEmpty(var ITIMigrDatasetTableField: Record "ITI Migr. Dataset Table Field")
    var
        ITIMigrDsTblFldEmptyCount: Record ITIMigrDsTblFldEmptyCount;
        RecordCount: Integer;
    begin
        ITIMigrDsTblFldEmptyCount.SetRange("Migration Dataset Code", ITIMigrDatasetTableField."Migration Dataset Code");
        ITIMigrDsTblFldEmptyCount.SetRange("Source table name", ITIMigrDatasetTableField."Source table name");
        ITIMigrDsTblFldEmptyCount.SetRange("Source Field Name", ITIMigrDatasetTableField."Source Field Name");
        RecordCount := ITIMigrDsTblFldEmptyCount.Count;
        ITIMigrDsTblFldEmptyCount.SetRange("Is Empty", true);

        if RecordCount = ITIMigrDsTblFldEmptyCount.Count then
            ITIMigrDatasetTableField."Is Empty" := ITIMigrDatasetTableField."Is Empty"::"TRUE"
        else
            ITIMigrDatasetTableField."Is Empty" := ITIMigrDatasetTableField."Is Empty"::"FALSE";

        ITIMigrDatasetTableField.Modify();
    end;

    local procedure GetDataFromDatabase(SQLQueryText: Text): Integer
    var
        SQLConnection: DotNet SqlConnection;
        SQLCommand: DotNet SqlCommand;
        SQLReader: DotNet SqlDataReader;
        ConnectionString: Text;
        NumberOfRecords: Integer;
    begin
        ConnectionString := GlobalITISQLDatabase.GetDatabaseConnectionString();
        SQLConnection := SQLConnection.SqlConnection(ConnectionString);
        SQLConnection.Open();
        SQLCommand := SQLCommand.SqlCommand(SQLQueryText, SQLConnection);
        SQLReader := SQLCommand.ExecuteReader();
        SQLReader.Read();
        EVALUATE(NumberOfRecords, Format(SQLReader.GetValue(0)));
        SQLConnection.Close();
        exit(NumberOfRecords);
    end;

    local procedure GetRecordsCount(TableName: Text): Integer
    var
        ITISQLDatabaseTable: Record "ITI SQL Database Table";
    begin
        ITISQLDatabaseTable.SetRange("SQL Database Code", GlobalITISQLDatabase.Code);
        ITISQLDatabaseTable.SetRange("Table Name", TableName);
        ITISQLDatabaseTable.FindFirst();
        exit(ITISQLDatabaseTable."Number Of Records");
    end;

    local procedure CreateEmptyFieldCountRecord(CompanyName: Text[150]; EmptyFieldCount: Integer; RecordNo: Integer)
    var
        ITIMigrDsTblFldEmptyCount: Record ITIMigrDsTblFldEmptyCount;
    begin
        ITIMigrDsTblFldEmptyCount.Init();
        ITIMigrDsTblFldEmptyCount."Migration Dataset Code" := GlobalMigrationDateasetCode;
        ITIMigrDsTblFldEmptyCount."Source table name" := GlobalSourceTableName;
        ITIMigrDsTblFldEmptyCount."Source Field Name" := GlobalSourceFieldName;
        ITIMigrDsTblFldEmptyCount."Company Name" := CompanyName;
        ITIMigrDsTblFldEmptyCount."Empty Fields Count" := EmptyFieldCount;
        ITIMigrDsTblFldEmptyCount."Records Count" := RecordNo;
        if EmptyFieldCount = RecordNo then
            ITIMigrDsTblFldEmptyCount."Is Empty" := true;

        ITIMigrDsTblFldEmptyCount.Insert();
    end;

    local procedure PrepareToCount()
    var
        ITIMigrDsTblFldEmptyCount: Record ITIMigrDsTblFldEmptyCount;
    begin
        ITIMigrDsTblFldEmptyCount.SetRange("Migration Dataset Code", GlobalMigrationDateasetCode);
        ITIMigrDsTblFldEmptyCount.SetRange("Source table name", GlobalSourceTableName);
        ITIMigrDsTblFldEmptyCount.SetRange("Source Field Name", GlobalSourceFieldName);
        if ITIMigrDsTblFldEmptyCount.FindSet() then
            ITIMigrDsTblFldEmptyCount.DeleteAll();
    end;

    var
        GlobalITIAppObjectTableField: Record "ITI App. Object Table Field";
        GlobalITISQLDatabase: Record "ITI SQL Database";
        CompaniesName: Dictionary of [Text[150], Text[150]];
        GlobalSourceSQLDatabaseCode: Code[20];
        GlobalMigrationDateasetCode: Code[20];
        GlobalSourceTableName: Text[150];
        GlobalSourceFieldName: Text[150];
}