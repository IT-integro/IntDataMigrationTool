dotnet
{
    assembly(Microsoft.Data.SqlClient)
    {
        type(Microsoft.Data.SqlClient.SqlConnection; SQLConnection) { }
        type(Microsoft.Data.SqlClient.SqlCommand; SQLCommand) { }
        type(Microsoft.Data.SqlClient.SqlDataReader; SqlDataReader) { }
    }
    assembly(System.Xml)
    {
        type(System.Xml.XmlDocument; DotNetXmlDocument) { }
        type(System.Xml.XmlNodeReader; XmlNodeReader) { }
        type(System.Xml.XmlNodeType; XmlNodeTypee) { }
    }

    assembly(mscorlib)
    {
        type(System.IO.StreamReader; SStreamReader) { }
        type(System.Text.Encoding; EEncoding) { }
    }
}