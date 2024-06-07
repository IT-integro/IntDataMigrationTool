codeunit 99016 "ITI Run SQL Query"
{
    trigger OnRun()
    begin
        if SQLServerConnectionString = '' then
            Error(ConnectionStringErr);
        if QueryTextErr = '' then
            Error(QueryTextErr);
        SourceConnection := SourceConnection.SqlConnection(SQLServerConnectionString);
        Command := Command.SqlCommand(SQLQueryText, SourceConnection);
        Command.CommandTimeout := 1000 * 60 * 60 * 100; // 100 hours
        SourceConnection.Open();
        Reader := Command.ExecuteReader();
    end;

    procedure SetSQLQueryText(QueryText: Text)
    begin
        SQLQueryText := QueryText;
    end;

    procedure SetSQLServerConnectionString(ConnectionString: Text)
    begin
        SQLServerConnectionString := ConnectionString;
    end;

    var
        SQLQueryText: text;
        SQLServerConnectionString: text;
        SourceConnection: DotNet SqlConnection;
        Command: DotNet SqlCommand;
        Reader: DotNet SqlDataReader;
        ConnectionStringErr: label 'Connection string is empty';
        QueryTextErr: label 'SQL Query is empty';
}
