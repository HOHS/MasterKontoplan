page 50010 "Master General Ledger Setup"
{
    PageType = Card;
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
                    caption = 'Abonnent/Udgiver';
                    optionCaption = '  ,Abonnent,Udgiver';

                    trigger OnValidate()
                    begin
                    SubscribeEditable := "Subscriber/Publisher" = "Subscriber/Publisher"::Subscriber;    
                    end;
                }
                field(SubscibeEditable;"Subscribes to General Ledger")
                {
                    caption = 'Abonnerer på Kontoplan fra';
                    Editable = SubscribeEditable;
                }
                
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