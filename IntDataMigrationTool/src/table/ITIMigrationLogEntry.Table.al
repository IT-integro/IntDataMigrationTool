table 99027 "ITI Migration Log Entry"
{
    Caption = 'ITI Migration Log Entry';
    LookupPageId = "ITI Migration Log Entries";
    DrillDownPageId = "ITI Migration Log Entries";
    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = ToBeClassified;
            Editable = false;
            AutoIncrement = true;
        }
        field(2; "Migration Code"; Code[20])
        {
            Caption = 'Migration Code';
            TableRelation = "ITI Migration".Code;
            DataClassification = ToBeClassified;
            Editable = false;
            ValidateTableRelation = false;
        }
        field(3; "Query No."; Integer)
        {
            Caption = 'Query No.';
            TableRelation = "ITI Migration SQL Query"."Query No." where("Migration Code" = field("Migration Code"));
            DataClassification = ToBeClassified;
            Editable = false;
            ValidateTableRelation = false;
        }
        field(10; "Query Description"; Text[250])
        {
            Caption = 'Query Description';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(20; "Query"; Blob)
        {
            Caption = 'Query';
            DataClassification = ToBeClassified;
        }
        field(30; "Executed"; Boolean)
        {
            Caption = 'Executed';
            Editable = false;
            DataClassification = ToBeClassified;
        }

        field(40; "Executed by User ID"; Code[50])
        {
            Caption = 'Executed by User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
            Editable = false;
        }
        field(50; "Starting Date Time"; DateTime)
        {
            Caption = 'Starting Date Time';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(60; "Ending Date Time"; DateTime)
        {
            Caption = 'Ending Date Time';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(70; "Error Description"; Text[250])
        {
            Caption = 'Error Description';
            Editable = false;
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Migration Code", "Query No.")
        {

        }
    }

    fieldgroups
    {
    }
    procedure InsertLogEntry(ITIMigrationSQLQuery: Record "ITI Migration SQL Query"; QueryExecuted: Boolean; ErrorDescription: text; StartingDatetime: DateTime; EndingDateTime: DateTime)
    ITIMigrationSQLQueryLog: codeunit "ITI Migration SQL Query Log";
    begin
        ITIMigrationSQLQueryLog.LogMigrationQuery(ITIMigrationSQLQuery, QueryExecuted, ErrorDescription, StartingDatetime, EndingDateTime);
    end;

    procedure DownloadQuery()
    var
        InStream: InStream;
        Filename: Text;
    begin
        CalcFields(Query);
        Query.CreateInStream(InStream, TEXTENCODING::UTF8);
        Filename := 'Query-' + "Migration Code" + '-' + Format("Query No.", 0, 9) + '.txt';
        Filename := DELCHR(Filename, '=', DELCHR(Filename, '=', 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-.'));
        DownloadFromStream(InStream, '', '', '', Filename);
    end;
}

