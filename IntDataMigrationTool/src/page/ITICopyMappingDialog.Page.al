page 99035 "ITI Copy Mapping Dialog"
{
    Caption = 'ITI Copy Mapping Dialog';
    PageType = StandardDialog;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(MappingCode; MappingCode)
                {
                    ApplicationArea = All;
                    Caption = 'Mapping Code';
                    ToolTip = 'Specifies the Code of the Mapping which will be filled with data.';
                }
                field(MappingDescription; MappingDescription)
                {
                    ApplicationArea = All;
                    Caption = 'Mapping Description';
                    ToolTip = 'Specifies the Description of the Mapping which will be filled with data.';
                }
            }
        }
    }

    procedure GetMappingCode(): Code[20]
    begin
        exit(MappingCode);
    end;

    procedure GetMappingDescription(): Text[150]
    begin
        exit(MappingDescription);
    end;

    var
        MappingCode: Code[20];
        MappingDescription: Text[150];
}
