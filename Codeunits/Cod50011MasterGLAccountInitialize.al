codeunit 50011 "Master GL Account Initialize"
{
    trigger OnRun()
    begin
        Window.Open('Updating Company #1#########');
        if Company.FindSet() then repeat
            Window.Update(1,Company.Name);
            MasterGeneralLedgerSetup.ChangeCompany(Company.Name);
            if not MasterGeneralLedgerSetup.Get() then begin
                MasterGeneralLedgerSetup.init;
                MasterGeneralLedgerSetup.Insert();
            end;
        until Company.Next() = 0;
        Window.Close();
        Message('Master G/L Account setup initialized in all companies');
    end;
    
    var
    Company: Record Company;
    MasterGeneralLedgerSetup: Record "Master General Ledger Setup";
    Window: Dialog;
}