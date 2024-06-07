table 99035 ITIMigrDsTblFldEmptyCount
{
    DataClassification = ToBeClassified;
    DrillDownPageId = ITIMigrDsTblFldEmptyCount;
    LookupPageId = ITIMigrDsTblFldEmptyCount;
    fields
    {
        field(10; "Migration Dataset Code"; Code[20])
        {
            DataClassification = ToBeClassified;

        }
        field(20; "Source table name"; Text[150])
        {
            DataClassification = ToBeClassified;

        }
        field(30; "Source Field Name"; Text[150])
        {
            DataClassification = ToBeClassified;
        }
        field(40; "Company Name"; Text[150])
        {
            DataClassification = ToBeClassified;
        }
        field(50; "Empty Fields Count"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(60; "Records Count"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(70; "Is Empty"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "Migration Dataset Code", "Source table name", "Source Field Name", "Company Name")
        {
            Clustered = true;
        }
        key(Key2; "Is Empty")
        {

        }
    }

}