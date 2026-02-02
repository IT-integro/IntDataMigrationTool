page 99034 "PTE Edit Linked Server Query"
{
    ApplicationArea = All;
    Caption = 'PTE Edit Linked Server Query';
    PageType = Card;
    SourceTable = "PTE Migration";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                ShowCaption = false;
                usercontrol(UserControlDesc; "WebPageViewer")
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
                    Clear(Rec."Linked Server Query");
                    if BlobVarText <> '' then begin
                        Rec."Linked Server Query".CreateOutStream(OutStream, TEXTENCODING::UTF8);
                        OutStream.Write(BlobVarText);
                    end;
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
        Field.SetRange(TableNo, Database::"PTE Migration");
        Field.SetRange(FieldName, 'Linked Server Query');
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