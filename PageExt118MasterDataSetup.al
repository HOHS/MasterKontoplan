pageextension 50010 "Master Data Setup" extends 118
{
   actions
    {
        // Add changes to page actions here
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



