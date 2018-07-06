table 50012 "Master GL Subscriber"
{
    Caption = 'Master GL Subscriber';
    DataPerCompany = false;
    LookupPageId = NewMasterGLCompanies;
    DrillDownPageId = NewMasterGLCompanies;
    DataClassification = CustomerContent;
    fields
    {
        field(1;"Master GL Company Name"; Text[30])
        {
            TableRelation = Company.Name;
            DataClassification = CustomerContent;
        }
        field(2; "Subscriber Company Name"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(3;"Is Limited Subscriber"; Boolean)
        {
            DataClassification = CustomerContent;
        }

    }
    keys
    {
        key(PK; "Master GL Company Name","Subscriber Company Name")
        {
            Clustered = true;
        }
    }   
}