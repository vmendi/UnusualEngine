<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0"
                  xmlns:wdm="urn:schemas-themidnightcoders-com:xml-wdm"
                  xmlns:xs="http://www.w3.org/2001/XMLSchema"
                  xmlns:codegen="urn:cogegen-xslt-lib:xslt"
                  xmlns:msdata="urn:schemas-microsoft-com:xml-msdata"
                  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <xsl:template name="codegen.server.csharp.data.odbc.create">
    <xsl:variable name="class-name" select="codegen:getClassName(@name)"   />
    <xsl:variable name="table" select="@name"   />
    <xsl:variable name="functionParam" select="codegen:getFunctionParameter($class-name)" />
    <xsl:variable name="identity" select="boolean(xs:complexType/xs:attribute[@msdata:AutoIncrement='true'])" />
    <xsl:variable name="id" select="@id"   />
    <xsl:variable name="pk" select="xs:key/@name"   />
    <xsl:variable name="timestamp" select="boolean(xs:complexType/xs:attribute[@type='xs:time'])" />
    
    private const String SqlCreate = @"Insert Into <xsl:value-of select="codegen:quoteIdentifier(@wdm:Schema)" />.<xsl:value-of select="codegen:quoteIdentifier(@name)" /> (
    <xsl:for-each select="xs:complexType/xs:attribute[not(@msdata:AutoIncrement='true') and codegen:IsEditable(@type)]">
      <xsl:value-of select="codegen:quoteIdentifier(@name)" />
      <xsl:if test="position() != last()">,</xsl:if>
    </xsl:for-each>) Values (
    <xsl:for-each select="xs:complexType/xs:attribute[not(@msdata:AutoIncrement='true') and codegen:IsEditable(@type)]">
      ? <xsl:if test="position() != last()">,</xsl:if>
    </xsl:for-each>);";

    <xsl:if test="key('dependent',current()/xs:key/@name)">[TransactionRequired]</xsl:if>
    public override <xsl:value-of select="$class-name" /> create( <xsl:value-of select="$class-name" /><xsl:text> </xsl:text><xsl:value-of select="$functionParam" /> )
    {
      using( SynchronizationScope syncScope = new SynchronizationScope( Database ) )
      {
      using (DatabaseConnectionMonitor monitor = new DatabaseConnectionMonitor(Database))
      {
        using(OdbcCommand sqlCommand = Database.CreateCommand( SqlCreate ))
        {
        <xsl:for-each select="xs:complexType/xs:attribute[not(@msdata:AutoIncrement='true') and codegen:IsEditable(@type)]">
          <xsl:variable name="property" select="codegen:getPropertyName($table,@name)" />
            <xsl:choose>
              <xsl:when test="@use  = 'optional'">
                <xsl:choose>
                  <xsl:when test="codegen:IsNullable(@type)">
                    if(<xsl:value-of select="$functionParam" />.<xsl:value-of select="$property"/>.HasValue)
                  </xsl:when>
                  <xsl:otherwise>
                    if(<xsl:value-of select="$functionParam" />.<xsl:value-of select="$property"/> != null)
                  </xsl:otherwise>
                </xsl:choose>
                  sqlCommand.Parameters.AddWithValue("?", <xsl:value-of select="$functionParam" />.<xsl:value-of select="$property"/>);
                else
                  sqlCommand.Parameters.AddWithValue("?", DBNull.Value);
              </xsl:when>
              <xsl:otherwise>
                <xsl:if test="@type = 'xs:anyURI'">
                  if(<xsl:value-of select="$functionParam" />.<xsl:value-of select="$property"/> == Guid.Empty)
                    <xsl:value-of select="$functionParam" />.<xsl:value-of select="$property"/> = Guid.NewGuid();                    
                </xsl:if>
                  sqlCommand.Parameters.AddWithValue("?", <xsl:value-of select="$functionParam" />.<xsl:value-of select="$property"/>);
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
          

          sqlCommand.ExecuteNonQuery();
        }
      }
      
    <xsl:for-each select="key('dependent',current()/xs:key/@name)">
      <xsl:variable name="child-table-pk" select="xs:key/@name" />
      <xsl:for-each select="xs:keyref[@refer = $pk]">
      <xsl:variable name="fk" select="@name" />
        <xsl:for-each select="key('table',$child-table-pk)">
          <xsl:choose>
            <xsl:when test="count(xs:key/xs:field[@xpath = key('fkByName',$fk)/@xpath]) = count(xs:key/xs:field)">
              <xsl:variable name="property-name" select="codegen:getChildProperty($table,@name,$fk,0)" />

              if(<xsl:value-of select="$functionParam" />.<xsl:value-of select="$property-name" /> != null)
              {
              <xsl:value-of select="codegen:getClassName(@name)"/>DataMapper dataMapper = new <xsl:value-of select="codegen:getClassName(@name)"/>DataMapper(Database);

              dataMapper.create(<xsl:value-of select="$functionParam" />.<xsl:value-of select="$property-name" />);
              }
            </xsl:when>
            <xsl:otherwise>
              <xsl:variable name="property-name" select="codegen:getChildProperty($table,@name,$fk,1)" />

              if(<xsl:value-of select="$functionParam" />.<xsl:value-of select="$property-name" /> != null
              <![CDATA[&&]]> <xsl:value-of select="$functionParam" />.<xsl:value-of select="$property-name" />.Count &gt; 0)
              {
              <xsl:value-of select="codegen:getClassName(@name)"/>DataMapper dataMapper = new <xsl:value-of select="codegen:getClassName(@name)"/>DataMapper(Database);

              foreach(<xsl:value-of select="codegen:getClassName(@name)"/> item in <xsl:value-of select="$functionParam" />.<xsl:value-of select="$property-name" />)
              dataMapper.create(item);
              }
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:for-each>
    </xsl:for-each>
      
      raiseAffected(<xsl:value-of select="$functionParam" />,DataMapperOperation.create);
      syncScope.Invoke();
      }
      return registerRecord(<xsl:value-of select="$functionParam" />);
    }

  </xsl:template>
</xsl:stylesheet>