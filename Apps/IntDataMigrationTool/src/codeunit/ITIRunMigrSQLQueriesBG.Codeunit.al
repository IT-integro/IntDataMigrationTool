codeunit 99017 "ITI Run Migr SQL Queries BG"
{
    TableNo = "ITI Migration";

    trigger OnRun()
    var
        ActiveSession: Record "Active Session";
        ITIMigrBackgroundSession: Record "ITI Migr. Background Session";
        SessionID: Integer;
        SessionUniqueID: Guid;
        Timeout: Integer;
        SessionStartedMsg: Label 'Migration %1 is running in Background\Session ID: %2\Session Unique ID:%3', Comment = '%1 = Migration Code, %2= Session ID, %3 = UniqueSessionID';
        SessionNotStartedErr: Label 'Failed to start background session';
        SessionIsRunningMsg: Label 'Migration %1, is already running in Background\Session ID: %2\Session Unique ID:%3', Comment = '%1 = Migration Code, %2= Session ID, %3 = UniqueSessionID\Wait for the background session to end and try again ';
    begin
        Timeout := 1000 * 60 * 60 * 100; // 100 hours
        if ITIMigrBackgroundSession.Get(Rec.Code, 0) then begin
            ITIMigrBackgroundSession.CalcFields("Is Active");
            if ITIMigrBackgroundSession."Is Active" then
                Error(SessionIsRunningMsg);
        end;
        if StartSession(SessionID, Codeunit::"ITI Run All Migr SQL Queries", CompanyName, Rec, Timeout) then begin
            ActiveSession.Get(Database.ServiceInstanceId(), SessionID);
            SessionUniqueID := ActiveSession."Session Unique ID";
            if NOT ITIMigrBackgroundSession.Get(Rec.Code, 0) then begin
                ITIMigrBackgroundSession.Init();
                ITIMigrBackgroundSession."Migration Code" := Rec.Code;
                ITIMigrBackgroundSession."Query No." := 0;
                ITIMigrBackgroundSession.Insert();
            end;
            ITIMigrBackgroundSession."Session ID" := SessionID;
            ITIMigrBackgroundSession."Session Unique ID" := SessionUniqueID;
            ITIMigrBackgroundSession.Modify();
            Message(SessionStartedMsg, Rec.Code, SessionID, SessionUniqueID);
        end else
            Error(SessionNotStartedErr);
    end;

}
