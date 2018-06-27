table 50011 "Master GL Company"
{
    
    Caption = 'Master GL Company';
    DataPerCompany = false;
    LookupPageId = "Master GL Companies";
    DrillDownPageId = "Master GL Companies";
    DataClassification = CustomerContent    ;
    fields
    {
        field(1;"Master GL Company Name"; text[30])
        {
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Master GL Company Name")
        {
            Clustered = true;
        }
    }
}