codeunit 99017 "PTE Run Migr SQL Queries BG"
{
    TableNo = "PTE Migration";

    trigger OnRun()
    var
        ActiveSession: Record "Active Session";
        PTEMigrBackgroundSession: Record "PTE Migr. Background Session";
        SessionID: Integer;
        SessionUniqueID: Guid;
        Timeout: Integer;
        SessionStartedMsg: Label 'Migration %1 is running in Background\Session ID: %2\Session Unique ID:%3', Comment = '%1 = Migration Code, %2= Session ID, %3 = UniqueSessionID';
        SessionNotStartedErr: Label 'Failed to start background session';
        SessionIsRunningMsg: Label 'Migration %1, is already running in Background\Session ID: %2\Session Unique ID:%3', Comment = '%1 = Migration Code, %2= Session ID, %3 = UniqueSessionID\Wait for the background session to end and try again ';
    begin
        Timeout := 1000 * 60 * 60 * 100; // 100 hours
        if PTEMigrBackgroundSession.Get(Rec.Code, 0) then begin
            PTEMigrBackgroundSession.CalcFields("Is Active");
            if PTEMigrBackgroundSession."Is Active" then
                Error(SessionIsRunningMsg);
        end;
        if StartSession(SessionID, Codeunit::"PTE Run All Migr SQL Queries", CompanyName, Rec, Timeout) then begin
            ActiveSession.Get(Database.ServiceInstanceId(), SessionID);
            SessionUniqueID := ActiveSession."Session Unique ID";
            if NOT PTEMigrBackgroundSession.Get(Rec.Code, 0) then begin
                PTEMigrBackgroundSession.Init();
                PTEMigrBackgroundSession."Migration Code" := Rec.Code;
                PTEMigrBackgroundSession."Query No." := 0;
                PTEMigrBackgroundSession.Insert();
            end;
            PTEMigrBackgroundSession."Session ID" := SessionID;
            PTEMigrBackgroundSession."Session Unique ID" := SessionUniqueID;
            PTEMigrBackgroundSession.Modify();
            Message(SessionStartedMsg, Rec.Code, SessionID, SessionUniqueID);
        end else
            Error(SessionNotStartedErr);
    end;

}
