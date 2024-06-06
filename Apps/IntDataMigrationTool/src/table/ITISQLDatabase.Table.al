table 99008 "ITI SQL Database"
{
    Caption = 'SQL Database';
    DrillDownPageID = "ITI SQL Databases";
    LookupPageID = "ITI SQL Databases";
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
            TableRelation = "ITI App. Metadata Set".Code;
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
        ITIGetMetadata: codeunit "ITI Get Metadata";
    begin
        ITIGetMetadata.Run(Rec);
    end;

    trigger OnDelete()
    var
        ITISQLDatabaseInstalledApp: Record "ITI SQL Database Installed App";
        ITIAppObject: Record "ITI App. Object";
        ITIAppObjectEnum: Record "ITI App. Object Enum";
        ITIAppObjectTable: record "ITI App. Object Table";
        ITISQLDatabaseTable: Record "ITI SQL Database Table";
        ITISQLDatabaseTableField: Record "ITI SQL Database Table Field";
        ITIAppObjectEnumValue: record "ITI App. Object Enum Value";
        ITIAppObjectTableField: Record "ITI App. Object Table Field";
        ITIAppObjectTblFieldOpt: Record "ITI App. Object Tbl.Field Opt.";
        ITISQLDatabaseCompany: Record "ITI SQL Database Company";

    begin
        if IsolatedStorage.Contains(Rec.Code) then
            IsolatedStorage.Delete(Rec.Code);
        ITISQLDatabaseInstalledApp.SetRange("SQL Database Code", Code);
        ITISQLDatabaseInstalledApp.DeleteAll();
        ITIAppObject.SetRange("SQL Database Code", Code);
        ITIAppObject.DeleteAll();
        ITIAppObjectEnum.SetRange("SQL Database Code", Code);
        ITIAppObjectEnum.DeleteAll();
        ITIAppObjectTable.SetRange("SQL Database Code", Code);
        ITIAppObjectTable.DeleteAll();
        ITISQLDatabaseTable.SetRange("SQL Database Code", Code);
        ITISQLDatabaseTable.DeleteAll();
        ITISQLDatabaseTableField.SetRange("SQL Database Code", Code);
        ITISQLDatabaseTableField.DeleteAll();
        ITIAppObjectEnumValue.SetRange("SQL Database Code", Code);
        ITIAppObjectEnumValue.DeleteAll();
        ITIAppObjectTableField.SetRange("SQL Database Code", Code);
        ITIAppObjectTableField.DeleteAll();
        ITIAppObjectTblFieldOpt.SetRange("SQL Database Code", Code);
        ITIAppObjectTblFieldOpt.DeleteAll();
        ITISQLDatabaseCompany.SetRange("SQL Database Code", Code);
        ITISQLDatabaseCompany.DeleteAll();
    end;
}

