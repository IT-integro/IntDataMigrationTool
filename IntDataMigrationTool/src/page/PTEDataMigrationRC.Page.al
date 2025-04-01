page 99029 "PTE Data Migration RC"
{
    ApplicationArea = All;
    Caption = 'PTE Data Migration RC';
    PageType = RoleCenter;

    layout
    {
        area(RoleCenter)
        {
            part("SQL Databases"; "PTE SQL DB CardPart")
            {
                ApplicationArea = Suite;
            }
        }
    }

    actions
    {
        area(Embedding)
        {
            ToolTip = 'Manage migration processes.';

            action(ActionName5)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'SQL Databases';

                RunObject = Page "PTE SQL Databases";
                ToolTip = 'Open list of known SQL Databases.';
            }

            action(ActionName7)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Migration Dataset List';

                RunObject = Page "PTE Migration Dataset List";
                ToolTip = 'Open Migration Dataset List.';
            }

            action(ActionName9)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Migrations';

                RunObject = Page "PTE Migrations";
                ToolTip = 'Open Migrations.';
            }
        }
    }
}
