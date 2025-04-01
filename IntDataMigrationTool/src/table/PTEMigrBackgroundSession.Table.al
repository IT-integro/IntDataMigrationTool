table 99026 "PTE Migr. Background Session"
{
    Caption = 'Migration Background Sessions';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Migration Code"; Code[20])
        {
            Caption = 'Migration Code';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(2; "Query No."; Integer)
        {
            Caption = 'Query No';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(10; "Session ID"; Integer)
        {
            Caption = 'Session ID';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(20; "Session Unique ID"; Guid)
        {
            Caption = 'Session Unique ID';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(30; "Is Active"; Boolean)
        {
            Caption = 'Is Active';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = exist("Active Session" where("Session Unique ID" = field("Session Unique ID")));
        }
        field(40; "No Of Session Events"; Integer)
        {
            Caption = 'No Of Session Events';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = count("Session Event" where("Session Unique ID" = field("Session Unique ID")));
        }
    }
    keys
    {
        key(Key1; "Migration Code", "Query No.")
        {
            Clustered = true;
        }
    }

    procedure GetLastComment(): Text
    var
        SessionEvent: Record "Session Event";
    begin
        SessionEvent.SetRange("Session Unique ID", "Session Unique ID");
        if SessionEvent.FindLast() then
            exit(SessionEvent.Comment)
        else
            exit(SessionNotFountMsg);
    end;

    var
        SessionNotFountMsg: Label 'Session event not found';
}
