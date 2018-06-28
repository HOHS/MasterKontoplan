page 50012 NewMasterGLCompanies
{
    Caption = 'Master GL Companies';
    Editable = false;
    PageType = List;
    SourceTable = "Master GL Company";
    
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Master GL Company Name";"Master GL Company Name")
                {
                    Caption = 'Master GL Company Name';
                    
                }
            }
        }
    }
}