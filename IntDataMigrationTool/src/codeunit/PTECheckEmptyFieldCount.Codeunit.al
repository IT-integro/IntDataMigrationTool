codeunit 99015 "PTECheckEmptyFieldCount"
{
    TableNo = "PTE Migr. Dataset Table Field";

    trigger OnRun()
    var
        PTEMigrDatasetTableField: Record "PTE Migr. Dataset Table Field";
    begin
        GetCompaniesName(Rec."Source SQL Database Code");

        PTEMigrDatasetTableField.SetRange("Migration Dataset Code", Rec."Migration Dataset Code");
        PTEMigrDatasetTableField.SetRange("Source table name", Rec."Source table name");
        PTEMigrDatasetTableField.SetRange("Mapping Type", Rec."Mapping Type"::FieldToField);
        if PTEMigrDatasetTableField.FindSet() then
            repeat
                PTEMigrDatasetTableField.CalcFields("Source SQL Database Code");
                CheckEmptyFieldCount(PTEMigrDatasetTableField."Migration Dataset Code", PTEMigrDatasetTableField."Source SQL Database Code", PTEMigrDatasetTableField."Source table name", PTEMigrDatasetTableField."Source Field Name");
                PTEMigrDatasetTableFieldUpdateIsEmpty(PTEMigrDatasetTableField);
            until PTEMigrDatasetTableField.Next() = 0;
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

        GlobalPTESQLDatabase.Get(GlobalSourceSQLDatabaseCode);

        SqlFieldName := GetSqlFieldName();

        foreach CompanyName in CompaniesName.Keys do begin
            SqlTableName := GetSqlTableName(CompanyName);

            SqlQueryTableName := '[' + GlobalPTESQLDatabase."Database Name" + '].[dbo].[' + SqlTableName + ']';

            FieldType := GlobalPTEAppObjectTableField.Datatype;

            GetRecordsCount(SqlQueryTableName, SqlFieldName, CompanyName, FieldType, SqlTableName);
        end;
    end;

    local procedure GetCompaniesName(SourceSQLDatabaseCode: Code[20])
    var
        PTESQLDatabaseCompany: Record "PTE SQL Database Company";
    begin
        PTESQLDatabaseCompany.SetRange("SQL Database Code", SourceSQLDatabaseCode);
        PTESQLDatabaseCompany.FindSet();
        repeat
            CompaniesName.Add(PTESQLDatabaseCompany.Name, PTESQLDatabaseCompany."SQL Name");
        until PTESQLDatabaseCompany.Next() = 0;
    end;

    local procedure GetSqlTableName(CompanyName: Text[150]): Text[250]
    begin
        SetFilterForObjectTableField();
        exit(GlobalPTEAppObjectTableField.GetSQLTableName(CompanyName));
    end;

    local procedure GetSqlFieldName(): Text[150]
    begin
        SetFilterForObjectTableField();
        exit(GlobalPTEAppObjectTableField."SQL Field Name");
    end;

    local procedure SetFilterForObjectTableField()
    begin
        GlobalPTEAppObjectTableField.Reset();
        GlobalPTEAppObjectTableField.SetRange("SQL Database Code", GlobalSourceSQLDatabaseCode);
        GlobalPTEAppObjectTableField.SetRange("Table Name", GLobalSourceTableName);
        GlobalPTEAppObjectTableField.SetRange(Name, GlobalSourceFieldName);
        GlobalPTEAppObjectTableField.FindFirst();
    end;

    local procedure GetRecordsCount(SqlQueryTableName: Text; SqlFieldName: Text[150]; CompanyName: Text[150]; FieldType: Text[150]; SqlTableName: Text)
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
        PTESQLDatabaseTableField: record "PTE SQL Database Table Field";
    begin
        case DataType.ToUpper() of
            'CODE', 'TEXT', 'RECORDID', 'DATEFORMULA':
                exit('=''''');
            'GUID', 'BLOB', 'MEDIA', 'MEDIASET':
                begin
                    PTESQLDatabaseTableField.SetRange("SQL Database Code", GlobalSourceSQLDatabaseCode);
                    PTESQLDatabaseTableField.SetRange("Table Name", SqlQueryTableName);
                    PTESQLDatabaseTableField.SetRange("Column Name", SqlFieldName);
                    PTESQLDatabaseTableField.FindFirst();
                    if UpperCase(PTESQLDatabaseTableField."Data Type") = 'IMAGE' then
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

    local procedure PTEMigrDatasetTableFieldUpdateIsEmpty(var PTEMigrDatasetTableField: Record "PTE Migr. Dataset Table Field")
    var
        PTEMigrDsTblFldEmptyCount: Record PTEMigrDsTblFldEmptyCount;
        RecordCount: Integer;
    begin
        PTEMigrDsTblFldEmptyCount.SetRange("Migration Dataset Code", PTEMigrDatasetTableField."Migration Dataset Code");
        PTEMigrDsTblFldEmptyCount.SetRange("Source table name", PTEMigrDatasetTableField."Source table name");
        PTEMigrDsTblFldEmptyCount.SetRange("Source Field Name", PTEMigrDatasetTableField."Source Field Name");
        RecordCount := PTEMigrDsTblFldEmptyCount.Count;
        PTEMigrDsTblFldEmptyCount.SetRange("Is Empty", true);

        if RecordCount = PTEMigrDsTblFldEmptyCount.Count then
            PTEMigrDatasetTableField."Is Empty" := PTEMigrDatasetTableField."Is Empty"::"TRUE"
        else
            PTEMigrDatasetTableField."Is Empty" := PTEMigrDatasetTableField."Is Empty"::"FALSE";

        PTEMigrDatasetTableField.Modify();
    end;

    local procedure GetDataFromDatabase(SQLQueryText: Text): Integer
    var
        SQLConnection: DotNet SqlConnection;
        SQLCommand: DotNet SqlCommand;
        SQLReader: DotNet SqlDataReader;
        ConnectionString: Text;
        NumberOfRecords: Integer;
    begin
        ConnectionString := GlobalPTESQLDatabase.GetDatabaseConnectionString();
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
        PTESQLDatabaseTable: Record "PTE SQL Database Table";
    begin
        PTESQLDatabaseTable.SetRange("SQL Database Code", GlobalPTESQLDatabase.Code);
        PTESQLDatabaseTable.SetRange("Table Name", TableName);
        PTESQLDatabaseTable.FindFirst();
        exit(PTESQLDatabaseTable."Number Of Records");
    end;

    local procedure CreateEmptyFieldCountRecord(CompanyName: Text[150]; EmptyFieldCount: Integer; RecordNo: Integer)
    var
        PTEMigrDsTblFldEmptyCount: Record PTEMigrDsTblFldEmptyCount;
    begin
        PTEMigrDsTblFldEmptyCount.Init();
        PTEMigrDsTblFldEmptyCount."Migration Dataset Code" := GlobalMigrationDateasetCode;
        PTEMigrDsTblFldEmptyCount."Source table name" := GlobalSourceTableName;
        PTEMigrDsTblFldEmptyCount."Source Field Name" := GlobalSourceFieldName;
        PTEMigrDsTblFldEmptyCount."Company Name" := CompanyName;
        PTEMigrDsTblFldEmptyCount."Empty Fields Count" := EmptyFieldCount;
        PTEMigrDsTblFldEmptyCount."Records Count" := RecordNo;
        if EmptyFieldCount = RecordNo then
            PTEMigrDsTblFldEmptyCount."Is Empty" := true;

        PTEMigrDsTblFldEmptyCount.Insert();
    end;

    local procedure PrepareToCount()
    var
        PTEMigrDsTblFldEmptyCount: Record PTEMigrDsTblFldEmptyCount;
    begin
        PTEMigrDsTblFldEmptyCount.SetRange("Migration Dataset Code", GlobalMigrationDateasetCode);
        PTEMigrDsTblFldEmptyCount.SetRange("Source table name", GlobalSourceTableName);
        PTEMigrDsTblFldEmptyCount.SetRange("Source Field Name", GlobalSourceFieldName);
        if PTEMigrDsTblFldEmptyCount.FindSet() then
            PTEMigrDsTblFldEmptyCount.DeleteAll();
    end;

    var
        GlobalPTEAppObjectTableField: Record "PTE App. Object Table Field";
        GlobalPTESQLDatabase: Record "PTE SQL Database";
        CompaniesName: Dictionary of [Text[150], Text[150]];
        GlobalSourceSQLDatabaseCode: Code[20];
        GlobalMigrationDateasetCode: Code[20];
        GlobalSourceTableName: Text[150];
        GlobalSourceFieldName: Text[150];
}