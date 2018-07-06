
codeunit 50010 "Master General Ledger Mgt."
{
  
// <functions>
    procedure UpdateMasterCompanyList(MasterCompanyName: Text[30])
    var
        MasterGLCompany: Record "Master GL Company";
    begin
        MasterGLCompany."Master GL Company Name" := MasterCompanyName;
        MasterGLCompany.Insert(true);
    end;

    procedure RemoveFromMasterCompanyList(MasterCompanyName: Text[30]) //NEWCODE
    var
        MasterGLCompany: Record "Master GL Company";
        MasterGLSubscriber: Record "Master GL Subscriber";
        ErrorMsg: Label 'You cannot change Company: %1, from publisher to subscriber because there are other companies subscribing to it.', comment = '', Maxlength = 999, locked = true;

    begin
        if MasterGLCompany.get(MasterCompanyName) then begin
            MasterGLSubscriber.SetRange("Master GL Company Name", MasterCompanyName);
            If MasterGLSubscriber.Count() > 0 then
                Error(ErrorMsg, MasterCompanyName);
            MasterGLCompany.Delete(false)
        end;
    end;

    procedure AddSubscription(MasterCompanyName: Text[30]; SubscriberCompanyName: Text[30];IslimitedSubscriber: Boolean)
    var
        MasterGLSubscriber: Record "Master GL Subscriber";
    begin
        MasterGLSubscriber."Master GL Company Name" := MasterCompanyName;
        MasterGLSubscriber."Subscriber Company Name" := SubscriberCompanyName;
        MasterGLSubscriber."Is Limited Subscriber" := IslimitedSubscriber;
        MasterGLSubscriber.Insert(true);
    end;

    procedure DoInitialCopy(MasterCompanyName: text[30];SubscriberCompanyName: text[30];FullCopy: Boolean)
    begin
        //should be triggered when a new company starts to subscribe to a master - note that it is expected that the copied tables are EMPTY in the subscriber company
        if FullCopy then begin
        CopyGLAccounts(MasterCompanyName,SubscriberCompanyName);
        CopyDimensions(MasterCompanyName,SubscriberCompanyName);
        CopyDefaultDimensions(MasterCompanyName,SubscriberCompanyName,DATABASE::"G/L Account"); 
        CopyBusinessPostingGroups(MasterCompanyName,SubscriberCompanyName);
        CopyProductPostingGroups(MasterCompanyName,SubscriberCompanyName);
        CopyVATBusinessPostingGroups(MasterCompanyName,SubscriberCompanyName);
        CopyVATProductPostingGroups(MasterCompanyName,SubscriberCompanyName);
        CopyCustomerPostingGroups(MasterCompanyName,SubscriberCompanyName);
        CopyVendorPostingGroups(MasterCompanyName,SubscriberCompanyName);
        end else begin;
            CopyGLAccounts(MasterCompanyName,SubscriberCompanyName);
            CopyDimensions(MasterCompanyName,SubscriberCompanyName);
            CopyDefaultDimensions(MasterCompanyName,SubscriberCompanyName,Database::"G/L Account");
        end;
    end;

    procedure CopyLimitedTables(MasterCompanyName: Text[30];SubscriberCompanyName: Text[30])
    var
        ConfirmTxt: Label 'This will OVERWRITE the setup tables in %1 with the setup tables from %2! Continue?', comment = '', Maxlength = 999, locked = true;
    begin
        if not Confirm(ConfirmTxt,false,SubscriberCompanyName,MasterCompanyName) then 
            exit;
        CopyBusinessPostingGroups(MasterCompanyName,SubscriberCompanyName);
        CopyProductPostingGroups(MasterCompanyName,SubscriberCompanyName);
        CopyVATBusinessPostingGroups(MasterCompanyName,SubscriberCompanyName);
        CopyVATProductPostingGroups(MasterCompanyName,SubscriberCompanyName);
        CopyCustomerPostingGroups(MasterCompanyName,SubscriberCompanyName);
        CopyVendorPostingGroups(MasterCompanyName,SubscriberCompanyName);
    end;

    local procedure CopyGLAccounts(FromCompanyName : Text[30];ToCompanyName : Text[30])
    var
        FromGLAccount: Record "G/L Account";
        ToGLAccount: Record "G/L Account";
    begin
        FromGLAccount.ChangeCompany(FromCompanyName);
        ToGLAccount.CHANGECOMPANY(ToCompanyName);
        IF FromGLAccount.FINDSET THEN REPEAT
            IF not ToGLAccount.get(FromGLAccount."No.") then begin
                ToGLAccount.INIT;
                ToGLAccount.TRANSFERFIELDS(FromGLAccount,TRUE);
                ToGLAccount.INSERT(false);
            end else begin
                ToGLAccount.TransferFields(FromGLAccount,false);
                ToGLAccount.Modify(false);
            end;
        UNTIL FromGLAccount.NEXT = 0;
    end;

    local procedure CopyDimensions(FromCompanyName : Text[30];ToCompanyName : Text[30])
    var
        FromDimension: Record Dimension;
        ToDimension: Record Dimension;
    begin
        FromDimension.ChangeCompany(FromCompanyName);
        ToDimension.CHANGECOMPANY(ToCompanyName);
        IF FromDimension.FINDSET THEN REPEAT
            if not ToDimension.get(FromDimension.Code) then begin
                ToDimension.Init();
                ToDimension.TransferFields(FromDimension,true);
                ToDimension.Insert(false);
            end else begin
                ToDimension.TransferFields(FromDimension,false);
                ToDimension.Modify(false);
            end;
        UNTIL FromDimension.NEXT = 0;
    end;

    local procedure CopyDefaultDimensions(FromCompanyName : Text[30];ToCompanyName : Text[30];ForTableID : Integer)
    var
        FromDefaultDimension: Record "Default Dimension";
        ToDefaultDimension: Record "Default Dimension";
    begin
        FromDefaultDimension.ChangeCompany(FromCompanyName);
        ToDefaultDimension.CHANGECOMPANY(ToCompanyName);
        FromDefaultDimension.setrange("Table ID", ForTableID);
        IF FromDefaultDimension.FINDSET THEN REPEAT
            if not ToDefaultDimension.get(FromDefaultDimension."Table ID",ToDefaultDimension."No.",ToDefaultDimension."Dimension Code") then begin
                ToDefaultDimension.INIT;
                ToDefaultDimension.TRANSFERFIELDS(FromDefaultDimension,TRUE);
                ToDefaultDimension.INSERT(false);
            end else begin
                ToDefaultDimension.TransferFields(FromDefaultDimension,false);
                ToDefaultDimension.Modify(false);
            end;
        UNTIL FromDefaultDimension.NEXT = 0;
    end;

    local procedure CopyBusinessPostingGroups(FromCompanyName : Text[30];ToCompanyName : Text[30])
    var
        FromBPG: Record "Gen. Business Posting Group";
        ToBPG: Record "Gen. Business Posting Group";
    begin
        FromBPG.ChangeCompany(FromCompanyName);
        ToBPG.CHANGECOMPANY(ToCompanyName);
        IF FromBPG.FINDSET THEN REPEAT
            if not ToBPG.Get(FromBPG.Code) then begin
                ToBPG.INIT;
                ToBPG.TRANSFERFIELDS(FromBPG,TRUE);
                ToBPG.INSERT(FALSE);
            end else begin
                ToBPG.TransferFields(FromBPG,false);
                ToBPG.Modify(false);
            end;
        UNTIL FromBPG.NEXT = 0;
    end;
    local procedure CopyProductPostingGroups(FromCompanyName : Text[30];ToCompanyName : Text[30])
    var
        FromPPG: Record "Gen. Product Posting Group";
        ToPPG: Record "Gen. Product Posting Group";
    begin
        FromPPG.ChangeCompany(FromCompanyName);
        ToPPG.CHANGECOMPANY(ToCompanyName);
        IF FromPPG.FINDSET THEN REPEAT
            if not ToPPG.Get(FromPPG.Code) then begin
                ToPPG.INIT;
                ToPPG.TRANSFERFIELDS(FromPPG,TRUE);
                ToPPG.INSERT(FALSE);
            end else begin
                ToPPG.TransferFields(FromPPG,false);
                ToPPG.Modify(false);
            end;
        UNTIL FromPPG.NEXT = 0;
    end;
    local procedure CopyVATBusinessPostingGroups(FromCompanyName : Text[30];ToCompanyName : Text[30])
    var
        FromVBPG: Record "VAT Business Posting Group";
        ToVBPG: Record "VAT Business Posting Group";
    begin
        FromVBPG.ChangeCompany(FromCompanyName);
        ToVBPG.CHANGECOMPANY(ToCompanyName);
        IF FromVBPG.FINDSET THEN REPEAT
            if not ToVBPG.get(FromVBPG.Code) then begin
                ToVBPG.INIT;
                ToVBPG.TRANSFERFIELDS(FromVBPG,TRUE);
                ToVBPG.INSERT(false);
            end else begin
                ToVBPG.TransferFields(FromVBPG,false);
                ToVBPG.Modify(false);
            end;
        UNTIL FromVBPG.NEXT = 0;
    end;
    local procedure CopyVATProductPostingGroups(FromCompanyName : Text[30];ToCompanyName : Text[30])
    var
        FromVPPG: Record "VAT Product Posting Group";
        ToVPPG: Record "VAT Product Posting Group";
    begin
        FromVPPG.ChangeCompany(FromCompanyName);
        ToVPPG.CHANGECOMPANY(ToCompanyName);
        IF FromVPPG.FINDSET THEN REPEAT
            if not ToVPPG.Get(FromVPPG.Code) then begin
                ToVPPG.INIT;
                ToVPPG.TRANSFERFIELDS(FromVPPG,TRUE);
                ToVPPG.INSERT(false);
            end else begin
                ToVPPG.TransferFields(FromVPPG,false);
                ToVPPG.Modify(false);
            end;
        UNTIL FromVPPG.NEXT = 0;
    end;
    local procedure CopyCustomerPostingGroups(FromCompanyName : Text[30];ToCompanyName : Text[30])
    var
        FromCustomerPostingGroup: Record "Customer Posting Group";
        ToCustomerPostingGroup: Record "Customer Posting Group";
    begin
        FromCustomerPostingGroup.ChangeCompany(FromCompanyName);
        ToCustomerPostingGroup.CHANGECOMPANY(ToCompanyName);
        IF FromCustomerPostingGroup.FINDSET THEN REPEAT
            if not ToCustomerPostingGroup.Get(FromCustomerPostingGroup.Code) then begin
                ToCustomerPostingGroup.INIT;
                ToCustomerPostingGroup.TRANSFERFIELDS(FromCustomerPostingGroup,TRUE);
                ToCustomerPostingGroup.INSERT(false);
            end else begin
                ToCustomerPostingGroup.TransferFields(FromCustomerPostingGroup,false);
                ToCustomerPostingGroup.Modify(false);
            end;
        UNTIL FromCustomerPostingGroup.NEXT = 0;
    end;
    local procedure CopyVendorPostingGroups(FromCompanyName : Text[30];ToCompanyName : Text[30])
    var
        FromVendorPostingGroup: Record "Vendor Posting Group";
        ToVendorPostingGroup: Record "Vendor Posting Group";
    begin
        FromVendorPostingGroup.ChangeCompany(FromCompanyName);
        ToVendorPostingGroup.CHANGECOMPANY(ToCompanyName);
        IF FromVendorPostingGroup.FINDSET THEN REPEAT
            if not ToVendorPostingGroup.Get(FromVendorPostingGroup.Code) then begin
                ToVendorPostingGroup.INIT;
                ToVendorPostingGroup.TRANSFERFIELDS(FromVendorPostingGroup,TRUE);
                ToVendorPostingGroup.INSERT(false);
            end else begin
                ToVendorPostingGroup.TransferFields(FromVendorPostingGroup,false);
                ToVendorPostingGroup.Modify(false);
            end;
        UNTIL FromVendorPostingGroup.NEXT = 0;
    end;    

    local procedure UpdateAccount(var GLAccountToUpdate: Record "G/L Account")
    var
        SubscriberGLAccount: Record "G/L Account";
        OldSubscriberGLAccount: Record "G/L Account";
        FilteredSubscribers: Record "Master GL Subscriber";
        UpdateFromOld: Boolean;
    begin
        CreateSubscriberList(FilteredSubscribers,CompanyName());
        if FilteredSubscribers.FindSet() then repeat
            if FilteredSubscribers."Is Limited Subscriber" then begin
                OldSubscriberGLAccount.ChangeCompany(FilteredSubscribers."Subscriber Company Name");
                UpdateFromOld := OldSubscriberGLAccount.get(GLAccountToUpdate."No.");
            end;
            SubscriberGLAccount.ChangeCompany(FilteredSubscribers."Subscriber Company Name");
            SubscriberGLAccount.TransferFields(GLAccountToUpdate, true);
            if UpdateFromOld then begin
                SubscriberGLAccount."Gen. Bus. Posting Group"  := OldSubscriberGLAccount."Gen. Bus. Posting Group";
                SubscriberGLAccount."Gen. Prod. Posting Group" := OldSubscriberGLAccount."Gen. Prod. Posting Group";
                SubscriberGLAccount."VAT Bus. Posting Group"   := OldSubscriberGLAccount."VAT Bus. Posting Group";
                SubscriberGLAccount."VAT Prod. Posting Group"  := OldSubscriberGLAccount."VAT Prod. Posting Group";
            end;
            if not SubscriberGLAccount.Insert(false) then
                SubscriberGLAccount.Modify(false)
        until FilteredSubscribers.Next() = 0;
    end;

    local procedure UpdateDimension(var DimensionToUpdate: Record Dimension)
    var
        FilteredSubscriber: Record "Master GL Subscriber";
        SubscriberDimension: Record Dimension;
    begin
        //triggered by inserting a new dimension in a master company (dimension NOT Value)
        CreateSubscriberList(FilteredSubscriber, CompanyName());
        if FilteredSubscriber.FindSet() then repeat
            SubscriberDimension.ChangeCompany(FilteredSubscriber."Subscriber Company Name");
            SubscriberDimension.TransferFields(DimensionToUpdate,true);
            if not SubscriberDimension.Insert(false) then
                SubscriberDimension.Modify(false);
        until FilteredSubscriber.Next() = 0;
        
    end;

    local procedure UpdateDefaultDimension(var DefaultDimensionToUpdate: Record "Default Dimension")
    var
        FilteredSubscriber: Record "Master GL Subscriber";
        SubscriberDefaultDimension: Record "Default Dimension";
    begin
        //Triggered by inserting a new dimension in a master company (dimension NOT value)
        CreateSubscriberList(FilteredSubscriber,CompanyName());
        If FilteredSubscriber.FindSet() then repeat
            SubscriberDefaultDimension.ChangeCompany(FilteredSubscriber."Subscriber Company Name");
            SubscriberDefaultDimension.TransferFields(DefaultDimensionToUpdate,true);
            if not SubscriberDefaultDimension.Insert(false) then
                SubscriberDefaultDimension.Modify(false);
        until FilteredSubscriber.Next() = 0
    end;
        
    local procedure DeleteDefaultDimension(var DefaultDimensionToUpdate: Record "Default Dimension")
    var
        FilteredSubscriber: Record "Master GL Subscriber";
        SubscriberDefaultDimension: Record "Default Dimension";
    begin
        //Triggered by inserting a new dimension in a master company (dimension NOT value)
        CreateSubscriberList(FilteredSubscriber, CompanyName());
        if FilteredSubscriber.FindSet() then repeat
            SubscriberDefaultDimension.ChangeCompany(FilteredSubscriber."Subscriber Company Name");
            if SubscriberDefaultDimension.Get(DefaultDimensionToUpdate."Table ID", DefaultDimensionToUpdate."No.", DefaultDimensionToUpdate."Dimension Code") then
                SubscriberDefaultDimension.Delete(false);
        until FilteredSubscriber.Next() = 0 ;
    end;    


    local procedure UpdateBusinessPostingGroup(VAR GenBusPosGrpToUpdate : Record "Gen. Business Posting Group")
    var
        FilteredSubscriber: Record "Master GL Subscriber";
        SubscriberGenBusPosGrp: Record "Gen. Business Posting Group";
    begin
        CreateSubscriberList(FilteredSubscriber,COMPANYNAME);
        IF FilteredSubscriber.FINDSET THEN REPEAT
            SubscriberGenBusPosGrp.CHANGECOMPANY(FilteredSubscriber."Subscriber Company Name");
            SubscriberGenBusPosGrp.TRANSFERFIELDS(GenBusPosGrpToUpdate,TRUE);
        IF NOT SubscriberGenBusPosGrp.INSERT(FALSE) THEN
            SubscriberGenBusPosGrp.MODIFY(FALSE);
        UNTIL FilteredSubscriber.NEXT = 0;
    end;
        

    local procedure UpdateProductPostingGroup(VAR GenProdPosGrpToUpdate : Record "Gen. Product Posting Group")
    var 
        FilteredSubscriber: Record "Master GL Subscriber";
        SubscriberGenProdPosGrp: Record "Gen. Product Posting Group";
    begin
        CreateSubscriberList(FilteredSubscriber,COMPANYNAME);
        IF FilteredSubscriber.FINDSET THEN REPEAT
            SubscriberGenProdPosGrp.CHANGECOMPANY(FilteredSubscriber."Subscriber Company Name");
            SubscriberGenProdPosGrp.TRANSFERFIELDS(GenProdPosGrpToUpdate,TRUE);
        IF NOT SubscriberGenProdPosGrp.INSERT(FALSE) THEN
            SubscriberGenProdPosGrp.MODIFY(FALSE);
        UNTIL FilteredSubscriber.NEXT = 0;
    end;

    local procedure UpdateVATBusinessPostingGroup(VAR VATBusPosGrpToUpdate : Record "VAT Business Posting Group")
    var
        FilteredSubscriber: Record "Master GL Subscriber";
        SubscriberVATBusPosGrp: Record "VAT Business Posting Group";
    begin
        CreateSubscriberList(FilteredSubscriber,COMPANYNAME);
        IF FilteredSubscriber.FINDSET THEN REPEAT
            SubscriberVATBusPosGrp.CHANGECOMPANY(FilteredSubscriber."Subscriber Company Name");
            SubscriberVATBusPosGrp.TRANSFERFIELDS(VATBusPosGrpToUpdate,TRUE);
        IF NOT SubscriberVATBusPosGrp.INSERT(FALSE) THEN
            SubscriberVATBusPosGrp.MODIFY(FALSE);
        UNTIL FilteredSubscriber.NEXT = 0;
    end;

    local procedure UpdateVATProductPostingGroup(VAR VATProdPosGrpToUpdate : Record "VAT Product Posting Group")
    var
        FilteredSubscriber: Record "Master GL Subscriber";
        SubscriberVATProdPosGrp: Record "VAT Product Posting Group";
    begin
        CreateSubscriberList(FilteredSubscriber,COMPANYNAME);
        IF FilteredSubscriber.FINDSET THEN REPEAT
            SubscriberVATProdPosGrp.CHANGECOMPANY(FilteredSubscriber."Subscriber Company Name");
            SubscriberVATProdPosGrp.TRANSFERFIELDS(VATProdPosGrpToUpdate,TRUE);
        IF NOT SubscriberVATProdPosGrp.INSERT(FALSE) THEN
            SubscriberVATProdPosGrp.MODIFY(FALSE);
        UNTIL FilteredSubscriber.NEXT = 0;
    end;

    local procedure UpdateCustomerPostingGroup(VAR CustPostGroupToUpdate : Record "Customer Posting Group")
    var
        FilteredSubscriber: Record "Master GL Subscriber";
        SubscriberCustPostGroup: Record "Customer Posting Group";
    begin
        CreateSubscriberList(FilteredSubscriber,COMPANYNAME);
        IF FilteredSubscriber.FINDSET THEN REPEAT
            SubscriberCustPostGroup.CHANGECOMPANY(FilteredSubscriber."Subscriber Company Name");
            SubscriberCustPostGroup.TRANSFERFIELDS(CustPostGroupToUpdate,TRUE);
        IF NOT SubscriberCustPostGroup.INSERT(FALSE) THEN
            SubscriberCustPostGroup.MODIFY(FALSE);
        UNTIL FilteredSubscriber.NEXT = 0;
    end;

    local procedure UpdateVendorPostingGroup(VAR VendPostGroupToUpdate : Record "Vendor Posting Group")
    var
        FilteredSubscriber: Record "Master GL Subscriber";
        SubscribervendPostGroup: Record "Vendor Posting Group";
    begin
        CreateSubscriberList(FilteredSubscriber,COMPANYNAME);
        IF FilteredSubscriber.FINDSET THEN REPEAT
            SubscribervendPostGroup.CHANGECOMPANY(FilteredSubscriber."Subscriber Company Name");
            SubscribervendPostGroup.TRANSFERFIELDS(VendPostGroupToUpdate,TRUE);
        IF NOT SubscribervendPostGroup.INSERT(FALSE) THEN
            SubscribervendPostGroup.MODIFY(FALSE);
        UNTIL FilteredSubscriber.NEXT = 0;
    end;    
    local procedure CreateSubscriberList(var FilteredSubscribers: Record "Master GL Subscriber"; MasterCompanyName: text[30])
    begin
        Clear(FilteredSubscribers);
        FilteredSubscribers.SetRange("Master GL Company Name",MasterCompanyName);
    end;
    
    local procedure CompanyIsPublisher() :Boolean
    var
        MasterGeneralLedgerSetup: Record "Master General Ledger Setup";
    begin
        MasterGeneralLedgerSetup.Get();
        exit(MasterGeneralLedgerSetup."Subscriber/Publisher" = MasterGeneralLedgerSetup."Subscriber/Publisher"::Publisher)
    end;
    
        local procedure CompanyIsSubscriber() :Boolean
    var
        MasterGeneralLedgerSetup: Record "Master General Ledger Setup";
    begin
        MasterGeneralLedgerSetup.Get();
        exit(MasterGeneralLedgerSetup."Subscriber/Publisher" = MasterGeneralLedgerSetup."Subscriber/Publisher"::Subscriber)
    end;

    local procedure CompanyIsLimitedSubscriber() :Boolean
    var
        MasterGeneralLedgerSetup: Record "Master General Ledger Setup";
    begin
        MasterGeneralLedgerSetup.Get();
        exit(MasterGeneralLedgerSetup."Subscriber/Publisher" = MasterGeneralLedgerSetup."Subscriber/Publisher"::"Limited Subscriber")
    end;

    local procedure NotUsingMasterAccounts() :Boolean
    var
        MasterGeneralLedgerSetup: Record "Master General Ledger Setup";
    begin
        MasterGeneralLedgerSetup.Get();
        exit(MasterGeneralLedgerSetup."Subscriber/Publisher" = MasterGeneralLedgerSetup."Subscriber/Publisher"::" ")
    end;    
    local procedure EditModeIsEnabled():Boolean
    var
        MasterGeneralLedgerSetup: Record "Master General Ledger Setup";
    begin
        MasterGeneralLedgerSetup.Get();
        exit(MasterGeneralLedgerSetup."Edit Mode");
    end;

    local procedure AccountsCanBeEdited() CanBeEdited: Boolean
    var
        MasterGeneralLedgerSetup: Record "Master General Ledger Setup";
    begin
        MasterGeneralLedgerSetup.Get();
        CanBeEdited := (MasterGeneralLedgerSetup."Subscriber/Publisher" in [MasterGeneralLedgerSetup."Subscriber/Publisher"::" ",MasterGeneralLedgerSetup."Subscriber/Publisher"::Publisher]);
        Exit(CanBeEdited);
    end;

    local procedure AccountsCanBeLimitedEdited() CanBeEdited: Boolean
    var
        MasterGeneralLedgerSetup: Record "Master General Ledger Setup";
    begin
        MasterGeneralLedgerSetup.Get();
        CanBeEdited := (MasterGeneralLedgerSetup."Subscriber/Publisher" = MasterGeneralLedgerSetup."Subscriber/Publisher"::"Limited Subscriber");
        Exit(CanBeEdited);
    end;

    local procedure InsertEditModeRecord(NewRecordID: RecordId; FieldNo: Integer)
    var
        EditModeRecord: Record "Edit Mode Record";
    begin
        EditModeRecord."Record ID" := NewRecordID;
        EditModeRecord."Field No." := FieldNo;
        if not EditModeRecord.Insert then;
    end;

    local procedure EditModeRecordExists(RecordIDToCheck: RecordId): Boolean
    var
        EditModeRecord: Record "Edit Mode Record";
    begin
        if AccountsCanBeEdited() then begin
            EditModeRecord.SetRange("Record ID",RecordIDToCheck);
            if EditModeRecord.FindFirst() then begin
                EditModeRecord.Delete();
                exit(true);
            end;
            exit(false);
        end else
            exit(false);
    end;

// </functions>

// <events>
[EventSubscriber(ObjectType::Table, Database::"G/L Account", 'OnAfterInsertEvent', '', true, true)]
local procedure AccountInserted(var Rec: Record "G/L Account"; RunTrigger: Boolean)
var
    ErrorMsg: Label 'You can only create %1 in a master company.', comment = '', Maxlength = 999, locked = true;
begin
    if not RunTrigger then
        exit;
        if not AccountsCanBeEdited() then
        Error(ErrorMsg,Rec.TableCaption())
    else 
        if CompanyIsPublisher() then
            UpdateAccount(Rec);
end;

[EventSubscriber(ObjectType::Table, Database::"G/L Account", 'OnAfterModifyEvent', '', true, true)]
local procedure AccountModified(var Rec: Record "G/L Account"; var xRec: Record "G/L Account"; RunTrigger: Boolean)
var 
    ErrorMsg: Label 'You can only change %1 in a master company.', comment = '', Maxlength = 999, locked = true;
begin
    if not RunTrigger then
        exit;
    if EditModeRecordExists(Rec.RecordId()) then
        exit;
    if not AccountsCanBeEdited() then
        Error(ErrorMsg,Rec.TableCaption())
    else
        if CompanyIsPublisher() then
            UpdateAccount(Rec);
end;

[EventSubscriber(ObjectType::Table, Database::"G/L Account", 'OnAfterRenameEvent', '', true, true)]
local procedure AccountRenamed(var Rec: Record "G/L Account"; var xRec: Record "G/L Account"; RunTrigger: Boolean)
var
    ErrorMsg: Label 'You cannot rename an %1', comment = '', Maxlength = 999, locked = true;
begin
    if not RunTrigger then
        exit;
    if NotUsingMasterAccounts() then
        exit;
    if not EditModeIsEnabled() then
        Error(ErrorMsg, Rec.TableCaption());
end;

[EventSubscriber(ObjectType::Table, Database::"G/L Account", 'OnAfterDeleteEvent', '', true, true)]
local procedure AccountDeleted(var Rec: Record "G/L Account"; RunTrigger: Boolean)
var
    ErrorMsg: Label 'You cannot delete an %1', comment = '', Maxlength = 999, locked = true;
begin
    If not RunTrigger then
        exit;
    if NotUsingMasterAccounts() then
        exit;
    if not EditModeIsEnabled() then
        Error(ErrorMsg, rec.TableCaption());
end;


[EventSubscriber(ObjectType::Table, Database::"G/L Account", 'OnAfterValidateEvent','Gen. Bus. Posting Group', true, true)]
local procedure AccountGBPGValidated(var Rec: Record "G/L Account"; var xRec: Record "G/L Account"; CurrFieldNo: Integer)
var
    EditModeRecord: Record "Edit Mode Record";
begin
    if AccountsCanBeEdited() then
        InsertEditModeRecord(Rec.RecordId(),CurrFieldNo);
end;

[EventSubscriber(ObjectType::Table , Database::"G/L Account", 'OnAfterValidateEvent', 'Gen. Prod. Posting Group', true, true)]
local procedure AccountGPPGValidated(var Rec: Record "G/L Account"; var xRec: Record "G/L Account"; CurrFieldNo: Integer)
var
    EditModeRecord: Record "Edit Mode Record";
begin
    if AccountsCanBeEdited() then
        InsertEditModeRecord(Rec.RecordId(),CurrFieldNo);
end;

[EventSubscriber(ObjectType::Table, Database::"G/L Account", 'OnAfterValidateEvent', 'VAT Bus. Posting Group', true, true)]
local procedure AccountVBPGValidated(var Rec: Record "G/L Account"; var xRec: Record "G/L Account"; CurrFieldNo: Integer)
var
    EditModeRecord: Record "Edit Mode Record";
begin
    if AccountsCanBeEdited() then
        InsertEditModeRecord(Rec.RecordId(),CurrFieldNo);
end;
[EventSubscriber(ObjectType::Table, Database::"G/L Account", 'OnAfterValidateEvent', 'VAT Prod. Posting Group', true, true)]
local procedure AccountVPPGValidated(var Rec: Record "G/L Account"; var xRec: Record "G/L Account"; CurrFieldNo: Integer)
var
    EditModeRecord: Record "Edit Mode Record";
begin
    if AccountsCanBeEdited() then
        InsertEditModeRecord(Rec.RecordId(),CurrFieldNo);
end;

[EventSubscriber(ObjectType::Table, Database::Dimension, 'OnAfterInsertEvent', '', true, true)]
local procedure DimensionInserted(var Rec: Record Dimension; RunTrigger: Boolean)
var
    ErrorMsg: Label 'You can only add %1 in a master company.', comment = '', Maxlength = 999, locked = true;
begin
    if not RunTrigger then
        exit;
    if not AccountsCanBeEdited() then
        Error(ErrorMsg, rec.TableCaption())
    else
        if CompanyIsPublisher() then
            UpdateDimension(Rec);
end;

[EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnAfterInsertEvent', '', true, true)]
local procedure DefaultDimensionInserted(var Rec: Record "Default Dimension"; RunTrigger: Boolean)
var 
    ErrorMsg: Label 'You can only add %1 in a master company.', comment = '', Maxlength = 999, locked = true;
begin
    If not RunTrigger then
        exit;
    if not AccountsCanBeEdited() then
        Error(ErrorMsg,rec.TableCaption())
    else
        if CompanyIsPublisher() then
            UpdateDefaultDimension(Rec);
end;

[EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnAfterDeleteEvent', '', true, true)]
local procedure DefualtDimensionDeleted(var Rec: Record "Default Dimension"; RunTrigger: Boolean)
var
    ErrorMsg: Label 'You can only delete  %1 in a master company.', comment = '', Maxlength = 999, locked = true;
begin
    If not RunTrigger then
        exit;
    if not AccountsCanBeEdited() then
        Error(ErrorMsg,rec.TableCaption())
    else
        if CompanyIsPublisher() then
            UpdateDefaultDimension(Rec);
end;

[EventSubscriber(ObjectType::Table, Database::"Gen. Business Posting Group", 'OnAfterInsertEvent', '', true, true)]
local procedure GBPGInserted(VAR Rec : Record "Gen. Business Posting Group";RunTrigger : Boolean)
var
    ErrorMsg: Label 'You can only create %1 in a master company.', comment = '', Maxlength = 999, locked = true;
begin
    IF NOT RunTrigger THEN
        EXIT;
    IF NOT AccountsCanBeEdited() THEN 
        ERROR(ErrorMsg,Rec.TABLECAPTION)
    ELSE
        if CompanyIsPublisher() then
            UpdateBusinessPostingGroup(Rec);
end;

[EventSubscriber(ObjectType::Table, Database::"Gen. Business Posting Group", 'OnAfterModifyEvent', '', true, true)]
local procedure GBPGModified(VAR Rec : Record "Gen. Business Posting Group";VAR xRec : Record "Gen. Business Posting Group";RunTrigger : Boolean)
var
    ErrorMsg: Label 'You can only change %1 in a master company.', comment = '', Maxlength = 999, locked = true;
begin
    IF NOT RunTrigger THEN
        EXIT;
    IF NOT AccountsCanBeEdited() THEN 
        ERROR(ErrorMsg,Rec.TABLECAPTION)
    ELSE
        if CompanyIsPublisher() then
            UpdateBusinessPostingGroup(Rec);
end;

[EventSubscriber(ObjectType::Table, Database::"Gen. Business Posting Group", 'OnAfterRenameEvent', '', true, true)]
local procedure GBPGRenamed(VAR Rec : Record "Gen. Business Posting Group";VAR xRec : Record "Gen. Business Posting Group";RunTrigger : Boolean)
var
    ErrorMsg: Label 'You cannot rename an %1.', comment = '', Maxlength = 999, locked = true;
begin
    IF NOT RunTrigger THEN
        EXIT;
    if NotUsingMasterAccounts() then
        exit;
    IF NOT EditModeIsEnabled THEN
        ERROR(ErrorMsg,Rec.TABLECAPTION);
end;

[EventSubscriber(ObjectType::Table, Database::"Gen. Business Posting Group", 'OnAfterDeleteEvent', '', true, true)]
local procedure GBPGDeleted(VAR Rec : Record "Gen. Business Posting Group";RunTrigger : Boolean)
var
    ErrorMsg: Label 'You cannot delete an %1.', comment = '', Maxlength = 999, locked = true;
begin
    IF NOT RunTrigger THEN
        EXIT;
    if NotUsingMasterAccounts() then
        exit;
    IF NOT EditModeIsEnabled THEN
        ERROR(ErrorMsg,Rec.TABLECAPTION);
end;

[EventSubscriber(ObjectType::Table, Database::"VAT Business Posting Group", 'OnAfterInsertEvent', '', true, true)]
local procedure VBPGInserted(VAR Rec : Record "VAT Business Posting Group";RunTrigger : Boolean)
var
    ErrorMsg: Label 'You can only create %1 in a master company.', comment = '', Maxlength = 999, locked = true;
begin
    IF NOT RunTrigger THEN
        EXIT;
    if CompanyIsLimitedSubscriber() then
        exit;
    IF NOT AccountsCanBeEdited() THEN 
        ERROR(ErrorMsg,Rec.TABLECAPTION)
    ELSE
        if CompanyIsPublisher() then
            UpdateVATBusinessPostingGroup(Rec);
end;

[EventSubscriber(ObjectType::Table, Database::"VAT Business Posting Group", 'OnAfterModifyEvent', '', true, true)]
local procedure VBPGModified(VAR Rec : Record "VAT Business Posting Group";VAR xRec : Record "VAT Business Posting Group";RunTrigger : Boolean)
var
    ErrorMsg: Label 'You can only change %1 in a master company.', comment = '', Maxlength = 999, locked = true;
begin
    IF NOT RunTrigger THEN
        EXIT;
    IF NOT CompanyIsLimitedSubscriber() THEN
        exit;
    if not AccountsCanBeEdited() then
        error(ErrorMsg, rec.TableCaption())
    else
        if CompanyIsPublisher() then
            UpdateVATBusinessPostingGroup(Rec);
end;
[EventSubscriber(ObjectType::Table, Database::"VAT Business Posting Group", 'OnAfterRenameEvent', '', true, true)]
local procedure VBPGRenamed(VAR Rec : Record "VAT Business Posting Group";VAR xRec : Record "VAT Business Posting Group";RunTrigger : Boolean)
var
    ErrorMsg: Label 'You cannot rename an %1.', comment = '', Maxlength = 999, locked = true;
begin
    IF NOT RunTrigger THEN
        EXIT;
    if NotUsingMasterAccounts() then
        exit;
    IF NOT EditModeIsEnabled THEN
        ERROR(ErrorMsg,Rec.TABLECAPTION);
end;

[EventSubscriber(ObjectType::Table, Database::"VAT Business Posting Group", 'OnAfterDeleteEvent', '', true, true)]
local procedure VBPGDeleted(VAR Rec : Record "VAT Business Posting Group";RunTrigger : Boolean)
var
    ErrorMsg: Label 'You cannot delete an %1.', comment = '', Maxlength = 999, locked = true;
begin
    IF NOT RunTrigger THEN
        EXIT;
    if NotUsingMasterAccounts() then
        exit;
    IF NOT EditModeIsEnabled THEN
        ERROR(ErrorMsg,Rec.TABLECAPTION);
end;

[EventSubscriber(ObjectType::Table, Database::"Gen. Product Posting Group", 'OnAfterInsertEvent', '', true, true)]
local procedure GPPGInserted(VAR Rec : Record "Gen. Product Posting Group";RunTrigger : Boolean)
var
    ErrorMsg: Label 'You can only create %1 in a master company.', comment = '', Maxlength = 999, locked = true;
begin
    IF NOT RunTrigger THEN
        EXIT;
    if CompanyIsLimitedSubscriber() then
        exit;
    if not AccountsCanBeEdited() then
        Error(ErrorMsg, Rec.TableCaption())
    else
        if CompanyIsPublisher() then
            UpdateProductPostingGroup(Rec);
end;

[EventSubscriber(ObjectType::Table, Database::"Gen. Product Posting Group", 'OnAfterModifyEvent', '', true, true)]
local procedure GPPGModified(VAR Rec : Record "Gen. Product Posting Group";VAR xRec : Record "Gen. Product Posting Group";RunTrigger : Boolean)
var
    ErrorMsg: Label 'You can only change %1 in a master company.', comment = '', Maxlength = 999, locked = true;
begin
    IF NOT RunTrigger THEN
        EXIT;
    if not AccountsCanBeEdited() then
        Error(ErrorMsg, Rec.TableCaption())
    else
        if CompanyIsPublisher() then
            UpdateProductPostingGroup(Rec);
end;

[EventSubscriber(ObjectType::Table, Database::"Gen. Product Posting Group", 'OnAfterRenameEvent', '', true, true)]
local procedure GPPGRenamed(VAR Rec : Record "Gen. Product Posting Group";VAR xRec : Record "Gen. Product Posting Group";RunTrigger : Boolean)
var
    ErrorMsg: Label 'You cannot rename an %1.', comment = '', Maxlength = 999, locked = true;
begin
    IF NOT RunTrigger THEN
        EXIT;
    if not EditModeIsEnabled() then
        Error(ErrorMsg, Rec.TableCaption());
end;

[EventSubscriber(ObjectType::Table, Database::"Gen. Product Posting Group", 'OnAfterDeleteEvent', '', true, true)]
local procedure GPPGDeleted(VAR Rec : Record "Gen. Product Posting Group";RunTrigger : Boolean)
var
    ErrorMsg: Label 'You cannot delete an %1.', comment = '', Maxlength = 999, locked = true;
begin
    IF NOT RunTrigger THEN
        EXIT;
    if NotUsingMasterAccounts() then
        exit;
    if not EditModeIsEnabled() then
        Error(ErrorMsg,Rec.TableCaption());
end;

[EventSubscriber(ObjectType::Table, Database::"VAT Product Posting Group", 'OnAfterInsertEvent', '', true, true)]
local procedure VPPGInserted(VAR Rec : Record "VAT Product Posting Group";RunTrigger : Boolean)
var
    ErrorMsg: Label 'You can only create %1 in a master company.', comment = '', Maxlength = 999, locked = true;
begin
    IF NOT RunTrigger THEN
        EXIT;
    if CompanyIsLimitedSubscriber() then
        exit;
    if not AccountsCanBeEdited() then
        Error(ErrorMsg,Rec.TableCaption())
    else
        if CompanyIsPublisher() then
            UpdateVATProductPostingGroup(Rec);
end;

[EventSubscriber(ObjectType::Table, Database::"VAT Product Posting Group", 'OnAfterModifyEvent', '', true, true)]
local procedure VPPGModified(VAR Rec : Record "VAT Product Posting Group";VAR xRec : Record "VAT Product Posting Group";RunTrigger : Boolean)
var
    ErrorMsg: Label 'You can only change %1 in a master company.', comment = '', Maxlength = 999, locked = true;
begin
    IF NOT RunTrigger THEN
        EXIT;
    if CompanyIsLimitedSubscriber() then
        exit;
    if not AccountsCanBeEdited() then
        Error(ErrorMsg,Rec.TableCaption())
    else
        if CompanyIsPublisher() then 
            UpdateVATProductPostingGroup(Rec);
end;

[EventSubscriber(ObjectType::Table, Database::"VAT Product Posting Group", 'OnAfterRenameEvent', '', true, true)]
local procedure VPPGRenamed(VAR Rec : Record "VAT Product Posting Group";VAR xRec : Record "VAT Product Posting Group";RunTrigger : Boolean)
var
    ErrorMsg: Label 'You cannot rename an %1.', comment = '', Maxlength = 999, locked = true;
begin
    IF NOT RunTrigger THEN
        EXIT;
    if NotUsingMasterAccounts() then
        exit;
    if not EditModeIsEnabled() then
        error(ErrorMsg,Rec.TableCaption());
end;

[EventSubscriber(ObjectType::Table, Database::"VAT Product Posting Group", 'OnAfterDeleteEvent', '', true, true)]
local procedure VPPGDeleted(VAR Rec : Record "VAT Product Posting Group";RunTrigger : Boolean)
var
    ErrorMsg: Label 'You cannot delete an %1.', comment = '', Maxlength = 999, locked = true;
begin
    IF NOT RunTrigger THEN
        EXIT;
    if NotUsingMasterAccounts() then
        exit;
    if not EditModeIsEnabled() then
        Error(ErrorMsg,Rec.TableCaption());
end;

[EventSubscriber(ObjectType::Table, Database::"Customer Posting Group", 'OnAfterInsertEvent', '', true, true)]
local procedure CustPostGrpInserted(VAR Rec : Record "Customer Posting Group";RunTrigger : Boolean)
var
    ErrorMsg: Label 'You can only create %1 in a master company.', comment = '', Maxlength = 999, locked = true;
begin
    IF NOT RunTrigger THEN
        EXIT;
    if CompanyIsLimitedSubscriber() then
        exit;
    if not AccountsCanBeEdited() then
        Error(ErrorMsg,Rec.TableCaption())
    else
        if CompanyIsPublisher() then
            UpdateCustomerPostingGroup(Rec);

end;

[EventSubscriber(ObjectType::Table, Database::"Customer Posting Group", 'OnAfterModifyEvent', '', true, true)]
local procedure CustPostGrpModified(VAR Rec : Record "Customer Posting Group";VAR xRec : Record "Customer Posting Group";RunTrigger : Boolean)
var
    ErrorMsg: Label 'You can only change %1 in a master company.', comment = '', Maxlength = 999, locked = true;
begin
    IF NOT RunTrigger THEN
        EXIT;
    if CompanyIsLimitedSubscriber() then
        exit;
    if not AccountsCanBeEdited() then
        Error(ErrorMsg,Rec.TableCaption())
    else
        if CompanyIsPublisher() then
            UpdateCustomerPostingGroup(Rec);
end;

[EventSubscriber(ObjectType::Table, Database::"Customer Posting Group", 'OnAfterRenameEvent', '', true, true)]
local procedure CustPostGrpRenamed(VAR Rec : Record "Customer Posting Group";VAR xRec : Record "Customer Posting Group";RunTrigger : Boolean)
var
    ErrorMsg: Label 'You cannot rename an %1.', comment = '', Maxlength = 999, locked = true;
begin
    IF NOT RunTrigger THEN
        EXIT;
    if NotUsingMasterAccounts() then
        exit;
    if not EditModeIsEnabled() then
        error(ErrorMsg,Rec.TableCaption())
end;

[EventSubscriber(ObjectType::Table, Database::"Customer Posting Group", 'OnAfterDeleteEvent', '', true, true)]
local procedure CustPostGrpDeleted(VAR Rec : Record "Customer Posting Group";RunTrigger : Boolean)
var
    ErrorMsg: Label 'You cannot delete an %1.', comment = '', Maxlength = 999, locked = true;
begin
    IF NOT RunTrigger THEN
        EXIT;
    if NotUsingMasterAccounts() then
        exit;
    if not EditModeIsEnabled() then
        Error(ErrorMsg,Rec.TableCaption());
end;

[EventSubscriber(ObjectType::Table, Database::"Vendor Posting Group", 'OnAfterInsertEvent', '', true, true)]
local procedure VendPostGrpInserted(VAR Rec : Record "Vendor Posting Group";RunTrigger : Boolean)
var
    ErrorMsg: Label 'You can only create %1 in a master company.', comment = '', Maxlength = 999, locked = true;
begin
    IF NOT RunTrigger THEN
        EXIT;
    if CompanyIsLimitedSubscriber() then
        exit;
    if not AccountsCanBeEdited() then
        error(ErrorMsg,Rec.TableCaption())
    else
        if CompanyIsPublisher() then
            UpdateVendorPostingGroup(Rec);
end;

[EventSubscriber(ObjectType::Table, Database::"Vendor Posting Group", 'OnAfterModifyEvent', '', true, true)]
local procedure VendPostGrpModified(VAR Rec : Record "Vendor Posting Group";VAR xRec : Record "Vendor Posting Group";RunTrigger : Boolean)
var
    ErrorMsg: Label 'You can only change %1 in a master company.', comment = '', Maxlength = 999, locked = true;
begin
    IF NOT RunTrigger THEN
        EXIT;
    if CompanyIsLimitedSubscriber() then
        exit;
    if not AccountsCanBeEdited() then
        error(ErrorMsg,rec.TableCaption())
    else
        if CompanyIsPublisher() then
            UpdateVendorPostingGroup(Rec);
end;

[EventSubscriber(ObjectType::Table, Database::"Vendor Posting Group", 'OnAfterRenameEvent', '', true, true)]
local procedure VendPostGrpRenamed(VAR Rec : Record "Vendor Posting Group";VAR xRec : Record "Vendor Posting Group";RunTrigger : Boolean)
var
    ErrorMsg: Label 'You cannot rename an %1.', comment = '', Maxlength = 999, locked = true;
begin
    IF NOT RunTrigger THEN
        EXIT;
    if NotUsingMasterAccounts() then
        exit;
    if not EditModeIsEnabled() then
        error(ErrorMsg,rec.TableCaption());
end;

[EventSubscriber(ObjectType::Table, Database::"Vendor Posting Group", 'OnAfterDeleteEvent', '', true, true)]
local procedure VendPostGrpDeleted(VAR Rec : Record "Vendor Posting Group";RunTrigger : Boolean)
var
    ErrorMsg: Label 'You cannot delete an %1.', comment = '', Maxlength = 999, locked = true;
begin
    IF NOT RunTrigger THEN
        EXIT;
    if NotUsingMasterAccounts() then
        exit;
    if not EditModeIsEnabled() then
        Error(ErrorMsg,Rec.TableCaption());
end;

// </events>
}