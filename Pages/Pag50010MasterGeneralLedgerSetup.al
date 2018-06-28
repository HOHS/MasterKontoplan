page 50010 "Master General Ledger Setup"
{
    PageType = Card;
    Caption = 'Master General Ledger Setup';
    SourceTable = "Master General Ledger Setup";
    InsertAllowed = false;
    DeleteAllowed = false;
    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Subscriber/Publisher"; "Subscriber/Publisher")
                {
                    caption = 'Subscriber/Publisher';
                    optionCaption = '  ,Subscriber,Publisher';

                    trigger OnValidate()
                    begin
                    SubscribeEditable := "Subscriber/Publisher" = "Subscriber/Publisher"::Subscriber;    
                    end;
                }
                field("Subscribes to General Ledger";"Subscribes to General Ledger")
                {
                    caption = 'Subscribes to General Ledger from';
                    Editable = SubscribeEditable;
                }
                
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            action(MasterDataSetup)
            {
                image = MapAccounts;
                Caption = 'Master Data Setup';
                trigger OnAction()
                begin
                    page.run(50012)
                end;
            }
        }
    }
    
    trigger OnOpenPage()
    begin
        Reset();
        if not Get() then begin
            Init();
            Insert();
        end;
    end;

    trigger OnAfterGetRecord()
    begin
        SubscribeEditable := "Subscriber/Publisher" = "Subscriber/Publisher"::Subscriber;         
    end;
    
    var
        SubscribeEditable: Boolean;
}