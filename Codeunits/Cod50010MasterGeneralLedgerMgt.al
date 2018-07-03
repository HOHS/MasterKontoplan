
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

    procedure AddSubscription(MasterCompanyName: Text[30]; SubscriberCompanyName: Text[30])
    var
        MasterGLSubscriber: Record "Master GL Subscriber";
    begin
        MasterGLSubscriber."Master GL Company Name" := MasterCompanyName;
        MasterGLSubscriber."Subscriber Company Name" := SubscriberCompanyName;
        MasterGLSubscriber.Insert(true);
    end;

    procedure DoInitialCopy(MasterCompanyName: text[30];SubscriberCompanyName: text[30])
    begin
        //should be triggered when a new company starts to subscribe to a master - note that it is expected that the copied tables are EMPTY in the subscriber company
        CopyGLAccounts(MasterCompanyName,SubscriberCompanyName);
        CopyDimensions(MasterCompanyName,SubscriberCompanyName);
        CopyDefaultDimensions(MasterCompanyName,SubscriberCompanyName,DATABASE::"G/L Account"); 
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
            ToGLAccount.INIT;
            ToGLAccount.TRANSFERFIELDS(FromGLAccount,TRUE);
            ToGLAccount.INSERT(FALSE);
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
            ToDimension.INIT;
            ToDimension.TRANSFERFIELDS(FromDimension,TRUE);
            ToDimension.INSERT(FALSE);
        UNTIL FromDimension.NEXT = 0;
    end;

    local procedure CopyDefaultDimensions(FromCompanyName : Text[30];ToCompanyName : Text[30];ForTableID : Integer)
    var
        FromDefaultDimension: Record "Default Dimension";
        ToDefaultDimension: Record "Default Dimension";
    begin
        FromDefaultDimension.ChangeCompany(FromCompanyName);
        ToDefaultDimension.CHANGECOMPANY(ToCompanyName);
        IF FromDefaultDimension.FINDSET THEN REPEAT
            ToDefaultDimension.INIT;
            ToDefaultDimension.TRANSFERFIELDS(FromDefaultDimension,TRUE);
            ToDefaultDimension.INSERT(FALSE);
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
            ToBPG.INIT;
            ToBPG.TRANSFERFIELDS(FromBPG,TRUE);
            ToBPG.INSERT(FALSE);
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
            ToPPG.INIT;
            ToPPG.TRANSFERFIELDS(FromPPG,TRUE);
            ToPPG.INSERT(FALSE);
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
            ToVBPG.INIT;
            ToVBPG.TRANSFERFIELDS(FromVBPG,TRUE);
            ToVBPG.INSERT(FALSE);
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
            ToVPPG.INIT;
            ToVPPG.TRANSFERFIELDS(FromVPPG,TRUE);
            ToVPPG.INSERT(FALSE);
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
            ToCustomerPostingGroup.INIT;
            ToCustomerPostingGroup.TRANSFERFIELDS(FromCustomerPostingGroup,TRUE);
            ToCustomerPostingGroup.INSERT(FALSE);
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
            ToVendorPostingGroup.INIT;
            ToVendorPostingGroup.TRANSFERFIELDS(FromVendorPostingGroup,TRUE);
            ToVendorPostingGroup.INSERT(FALSE);
        UNTIL FromVendorPostingGroup.NEXT = 0;
    end;    

    local procedure UpdateAccount(var GLAccountToUpdate: Record "G/L Account")
    var
        CompanyTemp: Record Company;
        SubscriberGLAccount: Record "G/L Account";
    begin
        //Triggered by AccountInserted or AccountModified in Master companies
        CreateSubscriberList(CompanyTemp,CompanyName());
        If CompanyTemp.FindSet() then repeat
            SubscriberGLAccount.ChangeCompany(CompanyTemp.Name);
            SubscriberGLAccount.TransferFields(GLAccountToUpdate, true);
            if not SubscriberGLAccount.Insert(false) then
                SubscriberGLAccount.Modify(true);
        until CompanyTemp.Next() = 0;
        
    end;

    local procedure UpdateDimension(var DimensionToUpdate: Record Dimension)
    var
        CompanyTemp: Record Company;
        SubscriberDimension: Record Dimension;
    begin
        //triggered by inserting a new dimension in a master company (dimension NOT Value)
        CreateSubscriberList(CompanyTemp, CompanyName());
        if CompanyTemp.FindSet() then repeat
            SubscriberDimension.ChangeCompany(CompanyTemp.Name);
            SubscriberDimension.TransferFields(DimensionToUpdate,true);
            if not SubscriberDimension.Insert(false) then
                SubscriberDimension.Modify(false);
        until CompanyTemp.Next() = 0;
        
    end;

    local procedure UpdateDefaultDimension(var DefaultDimensionToUpdate: Record "Default Dimension")
    var
        CompanyTemp: Record Company;
        SubscriberDefaultDimension: Record "Default Dimension";
    begin
        //Triggered by inserting a new dimension in a master company (dimension NOT value)
        CreateSubscriberList(CompanyTemp,CompanyName());
        If CompanyTemp.FindSet() then repeat
            SubscriberDefaultDimension.ChangeCompany(CompanyTemp.Name);
            SubscriberDefaultDimension.TransferFields(DefaultDimensionToUpdate,true);
            if not SubscriberDefaultDimension.Insert(false) then
                SubscriberDefaultDimension.Modify(false);
        until CompanyTemp.Next() = 0
    end;
        
    local procedure DeleteDefaultDimension(var DefaultDimensionToUpdate: Record "Default Dimension")
    var
        CompanyTemp: Record Company temporary;
        SubscriberDefaultDimension: Record "Default Dimension";
    begin
        //Triggered by inserting a new dimension in a master company (dimension NOT value)
        CreateSubscriberList(CompanyTemp, CompanyName());
        if CompanyTemp.FindSet() then repeat
            SubscriberDefaultDimension.ChangeCompany(CompanyTemp.Name);
            if SubscriberDefaultDimension.Get(DefaultDimensionToUpdate."Table ID", DefaultDimensionToUpdate."No.", DefaultDimensionToUpdate."Dimension Code") then
                SubscriberDefaultDimension.Delete(false);
        until CompanyTemp.Next() = 0 ;
    end;    


    local procedure UpdateBusinessPostingGroup(VAR GenBusPosGrpToUpdate : Record "Gen. Business Posting Group")
    var
        CompanyTemp: Record Company temporary;
        SubscriberGenBusPosGrp: Record "Gen. Business Posting Group";
    begin
        CreateSubscriberList(CompanyTemp,COMPANYNAME);
        IF CompanyTemp.FINDSET THEN REPEAT
            SubscriberGenBusPosGrp.CHANGECOMPANY(CompanyTemp.Name);
            SubscriberGenBusPosGrp.TRANSFERFIELDS(GenBusPosGrpToUpdate,TRUE);
        IF NOT SubscriberGenBusPosGrp.INSERT(FALSE) THEN
            SubscriberGenBusPosGrp.MODIFY(FALSE);
        UNTIL CompanyTemp.NEXT = 0;
    end;
        

    local procedure UpdateProductPostingGroup(VAR GenProdPosGrpToUpdate : Record "Gen. Product Posting Group")
    var 
        CompanyTemp: Record Company temporary;
        SubscriberGenProdPosGrp: Record "Gen. Product Posting Group";
    begin
        CreateSubscriberList(CompanyTemp,COMPANYNAME);
        IF CompanyTemp.FINDSET THEN REPEAT
            SubscriberGenProdPosGrp.CHANGECOMPANY(CompanyTemp.Name);
            SubscriberGenProdPosGrp.TRANSFERFIELDS(GenProdPosGrpToUpdate,TRUE);
        IF NOT SubscriberGenProdPosGrp.INSERT(FALSE) THEN
            SubscriberGenProdPosGrp.MODIFY(FALSE);
        UNTIL CompanyTemp.NEXT = 0;
    end;

    local procedure UpdateVATBusinessPostingGroup(VAR VATBusPosGrpToUpdate : Record "VAT Business Posting Group")
    var
        CompanyTemp: Record Company temporary;
        SubscriberVATBusPosGrp: Record "VAT Business Posting Group";
    begin
        CreateSubscriberList(CompanyTemp,COMPANYNAME);
        IF CompanyTemp.FINDSET THEN REPEAT
            SubscriberVATBusPosGrp.CHANGECOMPANY(CompanyTemp.Name);
            SubscriberVATBusPosGrp.TRANSFERFIELDS(VATBusPosGrpToUpdate,TRUE);
        IF NOT SubscriberVATBusPosGrp.INSERT(FALSE) THEN
            SubscriberVATBusPosGrp.MODIFY(FALSE);
        UNTIL CompanyTemp.NEXT = 0;
    end;

    local procedure UpdateVATProductPostingGroup(VAR VATProdPosGrpToUpdate : Record "VAT Product Posting Group")
    var
        CompanyTemp: Record Company temporary;
        SubscriberVATProdPosGrp: Record "VAT Product Posting Group";
    begin
        CreateSubscriberList(CompanyTemp,COMPANYNAME);
        IF CompanyTemp.FINDSET THEN REPEAT
            SubscriberVATProdPosGrp.CHANGECOMPANY(CompanyTemp.Name);
            SubscriberVATProdPosGrp.TRANSFERFIELDS(VATProdPosGrpToUpdate,TRUE);
        IF NOT SubscriberVATProdPosGrp.INSERT(FALSE) THEN
            SubscriberVATProdPosGrp.MODIFY(FALSE);
        UNTIL CompanyTemp.NEXT = 0;
    end;

    local procedure UpdateCustomerPostingGroup(VAR CustPostGroupToUpdate : Record "Customer Posting Group")
    var
        CompanyTemp: Record Company temporary;
        SubscriberCustPostGroup: Record "Customer Posting Group";
    begin
        CreateSubscriberList(CompanyTemp,COMPANYNAME);
        IF CompanyTemp.FINDSET THEN REPEAT
            SubscriberCustPostGroup.CHANGECOMPANY(CompanyTemp.Name);
            SubscriberCustPostGroup.TRANSFERFIELDS(CustPostGroupToUpdate,TRUE);
        IF NOT SubscriberCustPostGroup.INSERT(FALSE) THEN
            SubscriberCustPostGroup.MODIFY(FALSE);
        UNTIL CompanyTemp.NEXT = 0;
    end;

    local procedure UpdateVendorPostingGroup(VAR VendPostGroupToUpdate : Record "Vendor Posting Group")
    var
        CompanyTemp: Record Company temporary;
        SubscribervendPostGroup: Record "Vendor Posting Group";
    begin
        CreateSubscriberList(CompanyTemp,COMPANYNAME);
        IF CompanyTemp.FINDSET THEN REPEAT
            SubscribervendPostGroup.CHANGECOMPANY(CompanyTemp.Name);
            SubscribervendPostGroup.TRANSFERFIELDS(VendPostGroupToUpdate,TRUE);
        IF NOT SubscribervendPostGroup.INSERT(FALSE) THEN
            SubscribervendPostGroup.MODIFY(FALSE);
        UNTIL CompanyTemp.NEXT = 0;
    end;    
    local procedure CreateSubscriberList(var CompanyTemp: Record Company temporary; MasterCompanyName: text[30])
    var
        MasterGLSubscriber: Record "Master GL Subscriber";
    begin
        Clear(CompanyTemp);
        MasterGLSubscriber.SetRange("Master GL Company Name",MasterCompanyName);
        If MasterGLSubscriber.FindSet() then repeat
            CompanyTemp.Name := MasterGLSubscriber."Subscriber Company Name";
            IF not CompanyTemp.Insert() then;
        until MasterGLSubscriber.Next() = 0;
    end;
    
    local procedure CompanyIsPublisher() :Boolean
    var
        MasterGeneralLedgerSetup: Record "Master General Ledger Setup";
    begin
        if MasterGeneralLedgerSetup.Get() then //NEWCODE
            exit(MasterGeneralLedgerSetup."Subscriber/Publisher" IN [
                MasterGeneralLedgerSetup."Subscriber/Publisher"::Publisher,
                MasterGeneralLedgerSetup."Subscriber/Publisher"::" "
            ])
        else
            exit(true);
    end;
    
    local procedure EditModeIsEnabled():Boolean
    var
        MasterGeneralLedgerSetup: Record "Master General Ledger Setup";
    begin
        MasterGeneralLedgerSetup.Get();
        exit(MasterGeneralLedgerSetup."Edit Mode");
    end;

// </functions>

// <events>
[EventSubscriber(ObjectType::Table, Database::"G/L Account", 'OnAfterInsertEvent', '', true, true)]
local procedure UpdateAccountOnAfterInsert(var Rec: Record "G/L Account"; RunTrigger: Boolean)
var
    ErrorMsg: Label 'You can only change account in a master company.', comment = '', Maxlength = 999, locked = true;
begin
    if not RunTrigger then
        exit;
    if not CompanyIsPublisher() then
        Error(ErrorMsg)
    else 
        UpdateAccount(Rec);
end;

[EventSubscriber(ObjectType::Table, Database::"G/L Account", 'OnAfterModifyEvent', '', true, true)]
local procedure UpdateAccountOnAfterModify(var Rec: Record "G/L Account"; var xRec: Record "G/L Account"; RunTrigger: Boolean)
var 
    ErrorMsg: Label 'You can only change account in a master company.', comment = '', Maxlength = 999, locked = true;
begin
    if not RunTrigger then
        exit;
    if not CompanyIsPublisher() then
        Error(ErrorMsg)
    else
        UpdateAccount(Rec);
end;

[EventSubscriber(ObjectType::Table, Database::"G/L Account", 'OnAfterRenameEvent', '', true, true)]
local procedure MessageIfEditModeDisabledOnAfterRename(var Rec: Record "G/L Account"; var xRec: Record "G/L Account"; RunTrigger: Boolean)
var
    ErrorMsg: Label 'You cannot rename an account', comment = '', Maxlength = 999, locked = true;
begin
    if not RunTrigger then
        exit;
    if not EditModeIsEnabled() then
        Error(ErrorMsg);
end;

[EventSubscriber(ObjectType::Table, Database::"G/L Account", 'OnAfterDeleteEvent', '', true, true)]
local procedure MessageIfEditModeDisabledOnAfterDelete(var Rec: Record "G/L Account"; RunTrigger: Boolean)
var
    ErrorMsg: Label 'You cannot delete an account', comment = '', Maxlength = 999, locked = true;
begin
    If not RunTrigger then
        exit;
    if not EditModeIsEnabled() then
        Error(ErrorMsg);
end;

[EventSubscriber(ObjectType::Table, Database::Dimension, 'OnAfterInsertEvent', '', true, true)]
local procedure UpdateDimensionsOnAfterInsert(var Rec: Record Dimension; RunTrigger: Boolean)
var
    ErrorMsg: Label 'You can only add dimensions in a master company.', comment = '', Maxlength = 999, locked = true;
begin
    if not RunTrigger then
        exit;
    if not CompanyIsPublisher() then
        Error(ErrorMsg)
    else
        UpdateDimension(Rec);
end;

[EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnAfterInsertEvent', '', true, true)]
local procedure UpdateDefaultDimensionsOnAfterInsert(var Rec: Record "Default Dimension"; RunTrigger: Boolean)
var 
    ErrorMsg: Label 'You can only add default dimensions in a master company.', comment = '', Maxlength = 999, locked = true;
begin
    If not RunTrigger then
        exit;
    if not CompanyIsPublisher() then
        Error(ErrorMsg)
    else
        UpdateDefaultDimension(Rec);
end;

[EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnAfterDeleteEvent', '', true, true)]
local procedure UpdateMasterWithDefaultDimensionOnAfterDelete(var Rec: Record "Default Dimension"; RunTrigger: Boolean)
var
    ErrorMsg: Label 'You can only delete default dimensions in a master company.', comment = '', Maxlength = 999, locked = true;
begin
    if not RunTrigger then
        exit;
    if not CompanyIsPublisher() then
        Error(ErrorMsg)
    else
        DeleteDefaultDimension(Rec);
end;

[EventSubscriber(ObjectType::Table, Database::Company, 'OnAfterDeleteEvent', '', true, true)]
local procedure UpdateMasterGLCompanyAndMasterGLSubscriberOnAfterDelete(var Rec: Record Company; RunTrigger: Boolean)
var 
    MasterGLCompany: Record "Master GL Company";
    MasterGLSubscriber: Record "Master GL Subscriber";
    ErrorMsg: Label 'You cannot delete Company: %1, because there are other companies subscribing to it.', comment = '', Maxlength = 999, locked = true;
begin
    if MasterGLCompany.get(Rec.Name) then begin
        MasterGLSubscriber.SetRange("Master GL Company Name",Rec.Name);
        If MasterGLSubscriber.Count() > 0 then
            Error(ErrorMsg, Rec.Name);
        MasterGLCompany.Delete(false)
    end else begin
        MasterGLSubscriber.SetRange("Subscriber Company Name",Rec.Name);
        MasterGLSubscriber.DeleteAll();
    end;
end;

[EventSubscriber(ObjectType::Table, Database::"Gen. Business Posting Group", 'OnAfterInsertEvent', '', true, true)]
local procedure GBPGInserted(VAR Rec : Record "Gen. Business Posting Group";RunTrigger : Boolean)
var
    ErrorMsg: Label 'You can only create %1 in a master company.', comment = '', Maxlength = 999, locked = true;
begin
    IF NOT RunTrigger THEN
        EXIT;
    IF NOT CompanyIsPublisher THEN 
        ERROR(ErrorMsg,Rec.TABLECAPTION)
    ELSE
        UpdateBusinessPostingGroup(Rec);
end;

[EventSubscriber(ObjectType::Table, Database::"Gen. Business Posting Group", 'OnAfterModifyEvent', '', true, true)]
local procedure GBPGModified(VAR Rec : Record "Gen. Business Posting Group";VAR xRec : Record "Gen. Business Posting Group";RunTrigger : Boolean)
var
    ErrorMsg: Label 'You can only change %1 in a master company.', comment = '', Maxlength = 999, locked = true;
begin
    IF NOT RunTrigger THEN
        EXIT;
    IF NOT CompanyIsPublisher THEN
            ERROR(ErrorMsg,Rec.TABLECAPTION)
    ELSE
        UpdateBusinessPostingGroup(Rec);   
end;

[EventSubscriber(ObjectType::Table, Database::"Gen. Business Posting Group", 'OnAfterRenameEvent', '', true, true)]
local procedure GBPGRenamed(VAR Rec : Record "Gen. Business Posting Group";VAR xRec : Record "Gen. Business Posting Group";RunTrigger : Boolean)
var
    ErrorMsg: Label 'You cannot rename an %1.', comment = '', Maxlength = 999, locked = true;
begin
    IF NOT RunTrigger THEN
        EXIT;
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
    IF NOT CompanyIsPublisher THEN 
        ERROR(ErrorMsg,Rec.TABLECAPTION)
    ELSE
        UpdateVATBusinessPostingGroup(Rec);
end;

[EventSubscriber(ObjectType::Table, Database::"VAT Business Posting Group", 'OnAfterModifyEvent', '', true, true)]
local procedure VBPGModified(VAR Rec : Record "VAT Business Posting Group";VAR xRec : Record "VAT Business Posting Group";RunTrigger : Boolean)
var
    ErrorMsg: Label 'You can only change %1 in a master company.', comment = '', Maxlength = 999, locked = true;
begin
    IF NOT RunTrigger THEN
        EXIT;
    IF NOT CompanyIsPublisher THEN
        ERROR(ErrorMsg,Rec.TABLECAPTION)
    ELSE
        UpdateVATBusinessPostingGroup(Rec);
end;
[EventSubscriber(ObjectType::Table, Database::"VAT Business Posting Group", 'OnAfterRenameEvent', '', true, true)]
local procedure VBPGRenamed(VAR Rec : Record "VAT Business Posting Group";VAR xRec : Record "VAT Business Posting Group";RunTrigger : Boolean)
var
    ErrorMsg: Label 'You cannot rename an %1.', comment = '', Maxlength = 999, locked = true;
begin
    IF NOT RunTrigger THEN
        EXIT;
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
    IF NOT CompanyIsPublisher THEN 
        ERROR(ErrorMsg,Rec.TABLECAPTION)
    ELSE
        UpdateProductPostingGroup(Rec);
end;

[EventSubscriber(ObjectType::Table, Database::"Gen. Product Posting Group", 'OnAfterModifyEvent', '', true, true)]
local procedure GPPGModified(VAR Rec : Record "Gen. Product Posting Group";VAR xRec : Record "Gen. Product Posting Group";RunTrigger : Boolean)
var
    ErrorMsg: Label 'You can only change %1 in a master company.', comment = '', Maxlength = 999, locked = true;
begin
    IF NOT RunTrigger THEN
        EXIT;
    IF NOT CompanyIsPublisher THEN
        ERROR(ErrorMsg,Rec.TABLECAPTION)
    ELSE
        UpdateProductPostingGroup(Rec);
end;

[EventSubscriber(ObjectType::Table, Database::"Gen. Product Posting Group", 'OnAfterRenameEvent', '', true, true)]
local procedure GPPGRenamed(VAR Rec : Record "Gen. Product Posting Group";VAR xRec : Record "Gen. Product Posting Group";RunTrigger : Boolean)
var
    ErrorMsg: Label 'You cannot rename an %1.', comment = '', Maxlength = 999, locked = true;
begin
    IF NOT RunTrigger THEN
        EXIT;
    IF NOT EditModeIsEnabled THEN
        ERROR(ErrorMsg,Rec.TABLECAPTION);
end;

[EventSubscriber(ObjectType::Table, Database::"Gen. Product Posting Group", 'OnAfterDeleteEvent', '', true, true)]
local procedure GPPGDeleted(VAR Rec : Record "Gen. Product Posting Group";RunTrigger : Boolean)
var
    ErrorMsg: Label 'You cannot delete an %1.', comment = '', Maxlength = 999, locked = true;
begin
    IF NOT RunTrigger THEN
        EXIT;
    IF NOT EditModeIsEnabled THEN
        ERROR(ErrorMsg,Rec.TABLECAPTION);
end;

[EventSubscriber(ObjectType::Table, Database::"VAT Product Posting Group", 'OnAfterInsertEvent', '', true, true)]
local procedure VPPGInserted(VAR Rec : Record "VAT Product Posting Group";RunTrigger : Boolean)
var
    ErrorMsg: Label 'You can only create %1 in a master company.', comment = '', Maxlength = 999, locked = true;
begin
    IF NOT RunTrigger THEN
        EXIT;
    IF NOT CompanyIsPublisher THEN 
        ERROR(ErrorMsg,Rec.TABLECAPTION)
    ELSE
        UpdateVATProductPostingGroup(Rec);
end;

[EventSubscriber(ObjectType::Table, Database::"VAT Product Posting Group", 'OnAfterModifyEvent', '', true, true)]
local procedure VPPGModified(VAR Rec : Record "VAT Product Posting Group";VAR xRec : Record "VAT Product Posting Group";RunTrigger : Boolean)
var
    ErrorMsg: Label 'You can only change %1 in a master company.', comment = '', Maxlength = 999, locked = true;
begin
    IF NOT RunTrigger THEN
        EXIT;
    IF NOT CompanyIsPublisher THEN
        ERROR(ErrorMsg,Rec.TABLECAPTION)
    ELSE
        UpdateVATProductPostingGroup(Rec);
end;

[EventSubscriber(ObjectType::Table, Database::"VAT Product Posting Group", 'OnAfterRenameEvent', '', true, true)]
local procedure VPPGRenamed(VAR Rec : Record "VAT Product Posting Group";VAR xRec : Record "VAT Product Posting Group";RunTrigger : Boolean)
var
    ErrorMsg: Label 'You cannot rename an %1.', comment = '', Maxlength = 999, locked = true;
begin
    IF NOT RunTrigger THEN
        EXIT;
    IF NOT EditModeIsEnabled THEN
        ERROR(ErrorMsg,Rec.TABLECAPTION);
end;

[EventSubscriber(ObjectType::Table, Database::"VAT Product Posting Group", 'OnAfterDeleteEvent', '', true, true)]
local procedure VPPGDeleted(VAR Rec : Record "VAT Product Posting Group";RunTrigger : Boolean)
var
    ErrorMsg: Label 'You cannot delete an %1.', comment = '', Maxlength = 999, locked = true;
begin
    IF NOT RunTrigger THEN
        EXIT;
    IF NOT EditModeIsEnabled THEN
        ERROR(ErrorMsg,Rec.TABLECAPTION);
end;

[EventSubscriber(ObjectType::Table, Database::"Customer Posting Group", 'OnAfterInsertEvent', '', true, true)]
local procedure CustPostGrpInserted(VAR Rec : Record "Customer Posting Group";RunTrigger : Boolean)
var
    ErrorMsg: Label 'You can only create %1 in a master company.', comment = '', Maxlength = 999, locked = true;
begin
    IF NOT RunTrigger THEN
        EXIT;
    IF NOT CompanyIsPublisher THEN 
        ERROR(ErrorMsg,Rec.TABLECAPTION)
    ELSE
        UpdateCustomerPostingGroup(Rec);
end;

[EventSubscriber(ObjectType::Table, Database::"Customer Posting Group", 'OnAfterModifyEvent', '', true, true)]
local procedure CustPostGrpModified(VAR Rec : Record "Customer Posting Group";VAR xRec : Record "Customer Posting Group";RunTrigger : Boolean)
var
    ErrorMsg: Label 'You can only change %1 in a master company.', comment = '', Maxlength = 999, locked = true;
begin
    IF NOT RunTrigger THEN
        EXIT;
    IF NOT CompanyIsPublisher THEN
        ERROR(ErrorMsg,Rec.TABLECAPTION)
    ELSE
        UpdateCustomerPostingGroup(Rec);
end;

[EventSubscriber(ObjectType::Table, Database::"Customer Posting Group", 'OnAfterRenameEvent', '', true, true)]
local procedure CustPostGrpRenamed(VAR Rec : Record "Customer Posting Group";VAR xRec : Record "Customer Posting Group";RunTrigger : Boolean)
var
    ErrorMsg: Label 'You cannot rename an %1.', comment = '', Maxlength = 999, locked = true;
begin
    IF NOT RunTrigger THEN
        EXIT;
    IF NOT EditModeIsEnabled THEN
        ERROR(ErrorMsg,Rec.TABLECAPTION);
end;

[EventSubscriber(ObjectType::Table, Database::"Customer Posting Group", 'OnAfterDeleteEvent', '', true, true)]
local procedure CustPostGrpDeleted(VAR Rec : Record "Customer Posting Group";RunTrigger : Boolean)
var
    ErrorMsg: Label 'You cannot delete an %1.', comment = '', Maxlength = 999, locked = true;
begin
    IF NOT RunTrigger THEN
        EXIT;
    IF NOT EditModeIsEnabled THEN
        ERROR(ErrorMsg,Rec.TABLECAPTION);
end;

[EventSubscriber(ObjectType::Table, Database::"Vendor Posting Group", 'OnAfterInsertEvent', '', true, true)]
local procedure VendPostGrpInserted(VAR Rec : Record "Vendor Posting Group";RunTrigger : Boolean)
var
    ErrorMsg: Label 'You can only create %1 in a master company.', comment = '', Maxlength = 999, locked = true;
begin
    IF NOT RunTrigger THEN
        EXIT;
    IF NOT CompanyIsPublisher THEN 
        ERROR(ErrorMsg,Rec.TABLECAPTION)
    ELSE
        UpdateVendorPostingGroup(Rec);
end;

[EventSubscriber(ObjectType::Table, Database::"Vendor Posting Group", 'OnAfterModifyEvent', '', true, true)]
local procedure VendPostGrpModified(VAR Rec : Record "Vendor Posting Group";VAR xRec : Record "Vendor Posting Group";RunTrigger : Boolean)
var
    ErrorMsg: Label 'You can only change %1 in a master company.', comment = '', Maxlength = 999, locked = true;
begin
    IF NOT RunTrigger THEN
        EXIT;
    IF NOT CompanyIsPublisher THEN
        ERROR(ErrorMsg,Rec.TABLECAPTION)
    ELSE
        UpdateVendorPostingGroup(Rec);
end;

[EventSubscriber(ObjectType::Table, Database::"Vendor Posting Group", 'OnAfterRenameEvent', '', true, true)]
local procedure VendPostGrpRenamed(VAR Rec : Record "Vendor Posting Group";VAR xRec : Record "Vendor Posting Group";RunTrigger : Boolean)
var
    ErrorMsg: Label 'You cannot rename an %1.', comment = '', Maxlength = 999, locked = true;
begin
    IF NOT RunTrigger THEN
        EXIT;
    IF NOT EditModeIsEnabled THEN
        ERROR(ErrorMsg,Rec.TABLECAPTION);
end;

[EventSubscriber(ObjectType::Table, Database::"Vendor Posting Group", 'OnAfterDeleteEvent', '', true, true)]
local procedure VendPostGrpDeleted(VAR Rec : Record "Vendor Posting Group";RunTrigger : Boolean)
var
    ErrorMsg: Label 'You cannot delete an %1.', comment = '', Maxlength = 999, locked = true;
begin
        IF NOT RunTrigger THEN
        EXIT;
    IF NOT EditModeIsEnabled THEN
        ERROR(ErrorMsg,Rec.TABLECAPTION);
end;

// </events>
}