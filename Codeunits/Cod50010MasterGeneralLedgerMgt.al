
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

    procedure RemoveFromMasterCompanyList(MasterCompanyName: Text[30])
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
    var
        MasterGL: Record "G/L Account";
        SubscriberGL: Record "G/L Account";
        MasterDimension: Record Dimension;
        SubscriberDimension: Record Dimension;
        MasterDefaultDimension: Record "Default Dimension";
        SubscriberDefaultDimension: Record "Default Dimension";
    begin
        //This should ONLY ever be triggered from a subscriber company!
        MasterGL.ChangeCompany(MasterCompanyName);
        If MasterGL.FindSet() then repeat
            SubscriberGL.Init();
            SubscriberGL.TransferFields(MasterGL, true);
            SubscriberGL.insert(false);
        until MasterGL.Next() = 0;

        MasterDimension.ChangeCompany(MasterCompanyName);
        if MasterDimension.FindSet() then repeat
            SubscriberDimension.Init();
            SubscriberDimension.TransferFields(MasterDimension, true);
            SubscriberDimension.Insert(false);
        until MasterDimension.Next() = 0;

        MasterDefaultDimension.ChangeCompany(MasterCompanyName);
        MasterDefaultDimension.SetRange("Table ID", 15);
        IF MasterDefaultDimension.FindSet() then repeat
            SubscriberDefaultDimension.Init();
            SubscriberDefaultDimension.TransferFields(MasterDefaultDimension, true);
            SubscriberDefaultDimension.Insert(false);
        until MasterDefaultDimension.Next() = 0;
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

//NEWCODE for deletion of companies
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
// </events>
}