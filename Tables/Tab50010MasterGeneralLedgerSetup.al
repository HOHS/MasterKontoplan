table 50010 "Master General Ledger Setup"
{
    Caption = 'Master General Ledger Setup';
    DataClassification = CustomerContent;
    
    fields
    {
        field(1;"Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(10;"Subscriber/Publisher";Option)
        {
            Caption = 'Subscriber/Publisher';
            OptionCaption = ' ,Subscriber,Publisher';
            OptionMembers = " ",Subscriber,Publisher;
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                MasterGeneralLedgerMgt: Codeunit "Master General Ledger Mgt.";
            begin
                if ((xRec."Subscriber/Publisher" = xRec."Subscriber/Publisher"::Publisher) and (rec."Subscriber/Publisher" <> rec."Subscriber/Publisher"::Publisher)) then
                    MasterGeneralLedgerMgt.RemoveFromMasterCompanyList(CompanyName());
            end;
        }
        field(11; "Subscribes to General Ledger"; Text[30])
        {
            Caption = 'Subscribes to General Ledger from';
            TableRelation = "Master GL Company"."Master GL Company Name";
            DataClassification = CustomerContent;
 
            trigger OnValidate() //NEWCODE
            var
                ErrorMsg:  Label 'Publishers cannot subscribe to a general ledger.', comment = '', Maxlength = 999, locked = true;
                ErrorMsg2: Label 'You cannot change the General Ledger a company subscribes to', comment = '', Maxlength = 999, locked = true;
                ErrorMsg3: Label 'A subscriber must subscribe to a publisher.', comment = '', Maxlength = 999, locked = true;
                MasterGeneralLedgerMgt:Codeunit 50010;
            begin
                if (("Subscribes to General Ledger" <> '') AND ("Subscriber/Publisher" <> "Subscriber/Publisher"::Subscriber)) then
                    Error(ErrorMsg);
                if  (("Subscribes to General Ledger" <> xRec."Subscribes to General Ledger") and (xRec."Subscribes to General Ledger" <> '')) then
                    Error(ErrorMsg2);
                if (("Subscriber/Publisher" = "Subscriber/Publisher"::Subscriber) and ("Subscribes to General Ledger" = '')) then
                    Error(ErrorMsg3);
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
    
    trigger OnModify() //NEWCODE
    var 
        ErrorMsg: Label'This company subscribes to a master GL - you cannot change it to not subscribe', comment = '', Maxlength = 999, locked = true;
        ErrorMsg2: Label 'Publishers cannot subscribe to a general ledger.', comment = '', Maxlength = 999, locked = true;
        ErrorMsg3: Label 'You cannot change the General Ledger a company subscribes to', comment = '', Maxlength = 999, locked = true;
        ErrorMsg4: Label 'A subscriber must subscribe to a publisher.', comment = '', Maxlength = 999, locked = true;
        MasterGeneralLedgerMgt:Codeunit 50010;
    begin
        if (xRec."Subscriber/Publisher" = "Subscriber/Publisher"::Subscriber) then
            if ("Subscribes to General Ledger" <> '') then
                Error(ErrorMsg);
        if "Subscriber/Publisher" = "Subscriber/Publisher"::Publisher then
            MasterGeneralLedgerMgt.UpdateMasterCompanyList(CompanyName());
        if (("Subscribes to General Ledger" <> '') AND ("Subscriber/Publisher" <> "Subscriber/Publisher"::Subscriber)) then
            Error(ErrorMsg2);
        if  (("Subscribes to General Ledger" <> xRec."Subscribes to General Ledger") and (xRec."Subscribes to General Ledger" <> '')) then
            Error(ErrorMsg3);
        if (("Subscriber/Publisher" = "Subscriber/Publisher"::Subscriber) and ("Subscribes to General Ledger" = '')) then
            Error(ErrorMsg4);

        MasterGeneralLedgerMgt.AddSubscription("Subscribes to General Ledger",CompanyName());
        if Rec."Subscriber/Publisher" = Rec."Subscriber/Publisher"::Subscriber then
            MasterGeneralLedgerMgt.DoInitialCopy("Subscribes to General Ledger",CompanyName());
        //det er muligt at oprette en virksomhed som publisher, og derefter sætte den som subscriber på sig selv.
    end;
}