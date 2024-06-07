page 99031 "ITI Edit SQL Query"
{
    ApplicationArea = All;
    Caption = 'ITI Edit SQL Query';
    PageType = Card;
    SourceTable = "ITI Migration SQL Query";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                ShowCaption = false;
                usercontrol(UserControlDesc; "Microsoft.Dynamics.Nav.Client.WebPageViewer")
                {
                    trigger ControlAddInReady(callbackUrl: Text)
                    begin
                        IsReady := true;
                        FillAddIn();
                    end;

                    trigger Callback(data: Text)
                    begin
                        BlobVarText := data;
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Save)
            {
                Caption = 'Save';
                ToolTip = 'Save current SQL query to database.';
                Image = Save;
                ApplicationArea = All;

                trigger OnAction()
                var
                    OutStream: OutStream;
                begin
                    Clear(Rec.Query);
                    Rec.Query.CreateOutStream(OutStream, TEXTENCODING::UTF8);
                    OutStream.Write(BlobVarText);
                    Rec."Modified" := true;
                    Rec.Modify(true);
                end;
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        BlobVarText := '';
    end;

    trigger OnAfterGetCurrRecord()
    begin
        BlobVarText := '';
        GetQuery();
        if IsReady then
            FillAddIn();
    end;

    local procedure GetQuery(): Text

    var
        Field: Record Field;
        TempBlob: Codeunit "Temp Blob";
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        Field.SetRange(TableNo, Database::"ITI Migration SQL Query");
        Field.SetRange(FieldName, 'Query');
        Field.FindFirst();
        TempBlob.FromRecord(Rec, Field."No.");
        TempBlob.CreateInStream(InStream, TEXTENCODING::UTF8);
        BlobVarText := TypeHelper.ReadAsTextWithSeparator(InStream, TypeHelper.LFSeparator());
    end;

    local procedure FillAddIn()
    begin
        CurrPage.UserControlDesc.SetContent(StrSubstNo(BoxPropertiesLbl, BlobVarText, MaxStrLen(BlobVarText)));
    end;

    var
        BlobVarText: Text;
        IsReady: Boolean;
        BoxPropertiesLbl: Label '<textarea Id="TextArea" maxlength="%2" style="width:100%;height:100%;resize: none; font-family:"Segoe UI", "Segoe WP", Segoe, device-segoe, Tahoma, Helvetica, Arial, sans-serif !important; font-size: 10.5pt !important;" OnChange="window.parent.WebPageViewerHelper.TriggerCallback(document.getElementById(''TextArea'').value)">%1</textarea>', Comment = '%1 = blob text; %2 = field data length';
}
