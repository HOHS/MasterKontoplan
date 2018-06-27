page 50011 "Master GL Companies"
{
    Caption = 'Master GL Companies'
    Editable = false;
    PageType = List;
    SourceTable = "Master GL Company";
    layout
    {
        area(content)
        {
            group(MasterGL)
            {
                field("Master GL Company Name"; "Master GL Company Name")
                {
                    Caption = 'Master GL Company Name';
                }
            }
        }
    }
}