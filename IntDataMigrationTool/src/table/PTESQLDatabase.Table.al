table 99008 "PTE SQL Database"
{
    Caption = 'SQL Database';
    DrillDownPageID = "PTE SQL Databases";
    LookupPageID = "PTE SQL Databases";
    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = ToBeClassified;
        }
        field(20; "Server Name"; Text[150])
        {
            Caption = 'Server Name';
            DataClassification = ToBeClassified;
        }
        field(30; "Database Name"; Text[150])
        {
            Caption = 'Database Name';
            DataClassification = ToBeClassified;
        }
        field(40; "User Name"; Text[150])
        {
            Caption = 'User Name';
            DataClassification = ToBeClassified;
        }
        field(50; "Use Metadata Set Code"; Code[20])
        {
            Caption = 'Use Metadata Set Code';
            DataClassification = ToBeClassified;
            TableRelation = "PTE App. Metadata Set".Code;
            ValidateTableRelation = true;
        }
        field(60; "Forbidden Chars"; Text[250])
        {
            Caption = 'Forbidden Chars';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(61; "Application Version"; Text[250])
        {
            Caption = 'Application Version';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(62; "Application Family"; Text[250])
        {
            Caption = 'Application Family';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(70; "Metadata Exists"; Boolean)
        {
            Caption = 'Metadata Exists';
            DataClassification = ToBeClassified;
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    procedure SetPassword(NewPassword: Text)
    var
        CryptographyManagement: Codeunit "Cryptography Management";
    begin
        if NewPassword <> '.' then begin
            //Delete old password if exist 
            if IsolatedStorage.Contains(Rec.Code, DataScope::Module) then
                IsolatedStorage.Delete(Rec.Code, DataScope::Module);
            //Encrypt password if possible
            if CryptographyManagement.IsEncryptionEnabled() and CryptographyManagement.IsEncryptionPossible() then
                NewPassword := CryptographyManagement.EncryptText(CopyStr(NewPassword, 1, 215));
            //Set new password by storage key
            IsolatedStorage.set(Rec.Code, NewPassword, DataScope::Module);
        end;
    end;

    procedure GetPassword(): Text
    var
        CryptographyManagement: Codeunit "Cryptography Management";
        PasswordTxt: Text;
    begin
        //Check if password exist by storage key
        if IsolatedStorage.Contains(Rec.Code, DataScope::Module) then begin
            //Get exist password
            IsolatedStorage.Get(Rec.Code, DataScope::Module, PasswordTxt);
            //Decrypt password if possible
            if CryptographyManagement.IsEncryptionEnabled() and CryptographyManagement.IsEncryptionPossible() then
                PasswordTxt := CryptographyManagement.Decrypt(PasswordTxt);
            //Return password
            exit(PasswordTxt);
        end;
    end;


    procedure GetDatabaseConnectionString(): Text
    begin
        exit('Server=' + "Server Name" + ';Database=' + "Database Name" + ';User ID=' + "User Name" + ';Password=' + GetPassword() + ';Encrypt=False;');
    end;

    procedure GetMetadata()
    var
        PTEGetMetadata: codeunit "PTE Get Metadata";
    begin
        PTEGetMetadata.Run(Rec);
    end;

    trigger OnDelete()
    var
        PTESQLDatabaseInstalledApp: Record "PTE SQL Database Installed App";
        PTEAppObject: Record "PTE App. Object";
        PTEAppObjectEnum: Record "PTE App. Object Enum";
        PTEAppObjectTable: record "PTE App. Object Table";
        PTESQLDatabaseTable: Record "PTE SQL Database Table";
        PTESQLDatabaseTableField: Record "PTE SQL Database Table Field";
        PTEAppObjectEnumValue: record "PTE App. Object Enum Value";
        PTEAppObjectTableField: Record "PTE App. Object Table Field";
        PTEAppObjectTblFieldOpt: Record "PTE App. Object Tbl.Field Opt.";
        PTESQLDatabaseCompany: Record "PTE SQL Database Company";
        PTEAppSkippedObjects: Record "PTE App Skipped Objects";

    begin
        if IsolatedStorage.Contains(Rec.Code) then
            IsolatedStorage.Delete(Rec.Code);
        PTESQLDatabaseInstalledApp.SetRange("SQL Database Code", Code);
        PTESQLDatabaseInstalledApp.DeleteAll();
        PTEAppObject.SetRange("SQL Database Code", Code);
        PTEAppObject.DeleteAll();
        PTEAppObjectEnum.SetRange("SQL Database Code", Code);
        PTEAppObjectEnum.DeleteAll();
        PTEAppObjectTable.SetRange("SQL Database Code", Code);
        PTEAppObjectTable.DeleteAll();
        PTESQLDatabaseTable.SetRange("SQL Database Code", Code);
        PTESQLDatabaseTable.DeleteAll();
        PTESQLDatabaseTableField.SetRange("SQL Database Code", Code);
        PTESQLDatabaseTableField.DeleteAll();
        PTEAppObjectEnumValue.SetRange("SQL Database Code", Code);
        PTEAppObjectEnumValue.DeleteAll();
        PTEAppObjectTableField.SetRange("SQL Database Code", Code);
        PTEAppObjectTableField.DeleteAll();
        PTEAppObjectTblFieldOpt.SetRange("SQL Database Code", Code);
        PTEAppObjectTblFieldOpt.DeleteAll();
        PTESQLDatabaseCompany.SetRange("SQL Database Code", Code);
        PTESQLDatabaseCompany.DeleteAll();
        PTEAppSkippedObjects.SetRange("SQL Database Code", Code);
        PTEAppSkippedObjects.DeleteAll();
    end;
}

