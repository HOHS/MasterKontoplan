table 50013 "Edit Mode Record"
{
    DataClassification = CustomerContent;
    
    fields
    {
        field(1;"Record ID"; RecordId)
        {
            DataClassification = CustomerContent;
        }
        field(2;"Field No."; Integer)
        {
            DataClassification = CustomerContent;
        }
    }
    
    keys
    {
        Key("Record ID";"Record ID")
        {
            Clustered = true;
        }
    }   
}