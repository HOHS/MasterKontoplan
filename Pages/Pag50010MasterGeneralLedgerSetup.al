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
            action(CopyLimitedTables)
            {
                Caption = 'Copy Limited Tables';
                image = Copy;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                trigger OnAction()
                var
                    MasterGeneralLedgerMgt: Codeunit "Master General Ledger Mgt.";
                begin
                    MasterGeneralLedgerMgt.CopyLimitedTables("Subscribes to General Ledger",CompanyName());
                end;
            }
            action(InitializeCompanies){
                caption = 'Initialize Companies';
                Image = Setup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                trigger OnAction()
                var 
                    MasterGLAccountInitialize: Codeunit "Master GL Account Initialize";
                begin
                    MasterGLAccountInitialize.Run();
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