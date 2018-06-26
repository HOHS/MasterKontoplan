pageextension 50010 "Master Data Setup" extends "General Ledger Setup"
{
   actions
    {
        addlast(Navigation)
        {
            action(MasterDataSetup)
            {
                image = MapAccounts;
                Caption = 'Master Data Setup';
                trigger OnAction()
                begin
                    page.run(50010)
                end;
            }
        }
    }
}    



