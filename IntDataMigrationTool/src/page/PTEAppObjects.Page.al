page 99009 "PTE App. Objects"
{
    //ApplicationArea = All;
    Caption = 'Application Objects';
    PageType = List;
    SourceTable = "PTE App. Object";
    UsageCategory = None;
    DataCaptionFields = "SQL Database Code";
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("SQL Database Code"; Rec."SQL Database Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code of the SQL Database.';
                    Visible = false;
                }
                field("Type"; Rec."Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of the Object.';
                }
                field("Subtype"; Rec."Subtype")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the subtype of the Object.';
                }
                field("ID"; Rec."ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ID of the Object.';
                }
                field("Name"; Rec."Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Name of the Object.';
                }
                field("Duplicated Name"; Rec."Duplicated Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the name of the object is duplicated.';
                }
                field(Skipped; Rec.Skipped)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the object has been added to the skipped ones.';
                }
                field("Application ID"; Rec."Application ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ID of the Application.';
                }
                field("Application Name"; Rec."Application Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Name of the Application.';
                }
                field("Source"; Rec."Source")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the source of the object.';
                }
                field("Package ID"; Rec."Package ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Package ID of the object.';
                }
                field("Runtime Package ID"; Rec."Runtime Package ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Runtime Package ID of the object.';
                }
            }
        }
    }
    actions
    {
        area(creation)
        {
            action("Add to Skipped Objects")
            {
                ToolTip = 'Adds an object to the skipped objects';
                Image = AddAction;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                trigger OnAction()
                var
                    PTEAppObject: Record "PTE App. Object";
                begin
                    CurrPage.SetSelectionFilter(PTEAppObject);
                    PTEAppObject.Next;
                    if PTEAppObject.Count = 1 then
                        PTEAppObject.AddToSkipped()
                    else
                        repeat
                            PTEAppObject.AddToSkipped()
                        until PTEAppObject.Next() = 0;

                end;
            }
            action("Remove from Skipped Objects")
            {
                ToolTip = 'Removes an object from the skipped objects';
                Image = RemoveLine;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                trigger OnAction()
                var
                    PTEAppObject: Record "PTE App. Object";
                begin
                    CurrPage.SetSelectionFilter(PTEAppObject);
                    PTEAppObject.Next;
                    if PTEAppObject.Count = 1 then
                        PTEAppObject.RemoveFromSkipped()
                    else
                        repeat
                            PTEAppObject.RemoveFromSkipped()
                        until PTEAppObject.Next() = 0;

                end;
            }
            action("Download Object Metadata")
            {
                ToolTip = 'Download object metadata to XML file';
                Image = "1099Form";
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Rec.DownloadMetadata();
                end;
            }
        }
    }
}
