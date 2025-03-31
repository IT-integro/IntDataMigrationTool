codeunit 99011 "PTE Run Migr.SQL Query Backgr."
{
    TableNo = "PTE Migration SQL Query";
    trigger OnRun()
    var
        ActiveSession: Record "Active Session";
        PTEMigrBackgroundSession: Record "PTE Migr. Background Session";
        Timeout: Integer;
        SessionStartedMsg: Label 'Migration %1, Query %2 is running in Background\Session ID: %3\Session Unique ID:%4', Comment = '%1 = Migration Code, %2 = Query No., %3= Session ID, %4 = UniqueSessionID';
        SessionNotStartedErr: Label 'Failed to start background session';
        SessionIsRunningMsg: Label 'Migration %1, Query %2 is already running in Background\Session ID: %3\Session Unique ID:%4', Comment = '%1 = Migration Code, %2 = Query No., %3= Session ID, %4 = UniqueSessionID\Wait for the background session to end and try again ';
    begin
        Timeout := 1000 * 60 * 60 * 100; // 100 hours
        if PTEMigrBackgroundSession.Get(Rec."Migration Code", Rec."Query No.") then begin
            PTEMigrBackgroundSession.CalcFields("Is Active");
            if PTEMigrBackgroundSession."Is Active" then
                Error(SessionIsRunningMsg);
        end;
        if StartSession(SessionID, Codeunit::"PTE Run Migration SQL Query", CompanyName, Rec, Timeout) then begin
            ActiveSession.Get(Database.ServiceInstanceId(), SessionID);
            SessionUniqueID := ActiveSession."Session Unique ID";
            if NOT PTEMigrBackgroundSession.Get(Rec."Migration Code", Rec."Query No.") then begin
                PTEMigrBackgroundSession.Init();
                PTEMigrBackgroundSession."Migration Code" := Rec."Migration Code";
                PTEMigrBackgroundSession."Query No." := Rec."Query No.";
                PTEMigrBackgroundSession.Insert();
            end;
            PTEMigrBackgroundSession."Session ID" := SessionID;
            PTEMigrBackgroundSession."Session Unique ID" := SessionUniqueID;
            PTEMigrBackgroundSession.Modify();
            Commit();
            if not HideMessages then
                Message(SessionStartedMsg, Rec."Migration Code", Rec."Query No.", SessionID, SessionUniqueID);
        end else
            Error(SessionNotStartedErr);
    end;

    procedure SetHideMessages(HideMsgValue: Boolean)
    begin
        HideMessages := HideMsgValue;
    end;

    procedure GetSessionUniqueID(): Guid
    begin
        exit(SessionUniqueID);
    end;

    var
        SessionID: Integer;
        SessionUniqueID: Guid;
        HideMessages: Boolean;
}
