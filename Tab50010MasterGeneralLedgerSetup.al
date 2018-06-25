table 50010 "Master General Ledger Setup"
{
    DataClassification = CustomerContent;
    
    fields
    {
        field(1;"Primary Key"; Code[10])
        {
            Caption = 'Primærnøgle';
            DataClassification = CustomerContent;
        }
        field(10;"Subscriber/Publisher";Option)
        {
            Caption = 'Abonnent/Udgiver';
            OptionCaption = ' ,Abonnent,Udgiver';
            OptionMembers = ,Subscriber,Publisher;
            DataClassification = CustomerContent;
        }
        field(11; "Subscribes to General Ledger"; Text[30])
        {
            Caption = 'Abonnerer på Kontoplan fra';
            TableRelation = "Master GL Company"."Master GL Company Name";
            DataClassification = CustomerContent;
 
            trigger OnValidate()
            var
                ErrorMsg:TextConst  ENU = 'Publishers cannot subscribe to a general ledger.', 
                                    DAN = 'Udgivere kan ikke abonnere på en kontoplan';
                ErrorMsg2:TextConst ENU = 'You cannot cahnge the General Ledger a company subscribes to', 
                                    DAN = 'Du kan ikke ændre kontoplanen som et regnskab abonnerer på';    
                MasterGeneralLedgerMgt:Codeunit 50010;
            begin
                if (("Subscribes to General Ledger" <> '') AND ("Subscriber/Publisher" <> "Subscriber/Publisher"::Subscriber)) then
                    Error(ErrorMsg);
                if  (("Subscribes to General Ledger" <> xRec."Subscribes to General Ledger") and (xRec."Subscribes to General Ledger" <> '')) then
                    Error(ErrorMsg2);
                MasterGeneralLedgerMgt.AddSubscription("Subscribes to General Ledger",CompanyName());
                MasterGeneralLedgerMgt.DoInitialCopy("Subscribes to General Ledger",CompanyName());
            end;
        }
        field(20; "Edit Mode"; Boolean)
        {
            DataClassification = CustomerContent;
        }

    }
    
    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
    
    trigger OnModify()
    var 
        ErrorMsg: TextConst ENU ='This company subscribes to a master GL - you cannot change it to not subscribe', 
                            DAN = 'Dette regnskab abonnerer på en masterkontoplan - du kan ikke ændre det til ikke at abonnere';
        MasterGeneralLedgerMgt:Codeunit 50010;
    begin
        if (xRec."Subscriber/Publisher" = "Subscriber/Publisher"::Subscriber) then
            if ("Subscribes to General Ledger" <> '') then
                Error(ErrorMsg);
        if "Subscriber/Publisher" = "Subscriber/Publisher"::Publisher then
            MasterGeneralLedgerMgt.UpdateMasterCompanyList(CompanyName());
    end;
}