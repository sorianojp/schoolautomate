<%
String strAuthIndex = (String)request.getSession(false).getAttribute("authTypeIndex");
//System.out.println(strAuthIndex);
if(strAuthIndex == null || Integer.parseInt(strAuthIndex) > 3) {%>
	<p style="font-size:16px; font-family:Verdana, Arial, Helvetica, sans-serif; font-weight:bold; color:#FF0000">
		Access Denied!!!
	</p>

<%return;}%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
var strQuery1="";
var strQuery2="";
var strQuery3="";
var strQuery4="";

function ClearQuery(strQueryNo){
	eval('document.form_.query_'+strQueryNo+'.value =""');
}
function ReloadPage()
{
	document.form_.submit();
}
function ExecuteQuery() {
	document.form_.execute_query.value = "1";
	ReloadPage();
}

</script>

<body bgcolor="#FFFFFF">
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	DBOperation dbOP       = null;
	String strErrMsg       = null;
	String strTemp         = null;
	WebInterface WI        = new WebInterface(request);
	DBOperation dbOPRemote = null;
	
	try
	{
		dbOP = new DBOperation();
		if(dbOP != null && WI.fillTextValue("remote_loc").length() > 0) {
			//get the db url.. 
			strTemp = "select DB_PROPERTY from EDTR_LOCATION where loc_index =  "+WI.fillTextValue("remote_loc");
			strTemp = dbOP.getResultOfAQuery(strTemp, 0);
			//System.out.println(strTemp);
			if(strTemp == null) {
				strErrMsg = "Failed to get remote connection property.";
				throw new Exception();
			}
			dbOPRemote = new DBOperation(strTemp, 1);
			if(dbOPRemote == null) {
				strErrMsg = "Failed to Connect to Remote Terminal.";
				throw new Exception();
			}
			
		}
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");
		if(strErrMsg == null)
			strErrMsg = "Error in opening connection.";
		if(dbOP != null)
			dbOP.cleanUP();
		if(dbOPRemote != null)
			dbOPRemote.cleanUP();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}

//unless user is super user and logged in, this page can't be accessed.
Vector vRetResult  = null;
Vector vColumnName = null;
Vector vResult     = null;
ExecuteSQLQuery ESQ = new ExecuteSQLQuery();

String[] astrSQLQuery = {null,null,null,null,null};
if(WI.fillTextValue("query_1").length() > 0) {
	astrSQLQuery[0] = WI.fillTextValue("query_1");
}
if(WI.fillTextValue("query_2").length() > 0) {
	astrSQLQuery[1] = WI.fillTextValue("query_2");
}
if(WI.fillTextValue("query_3").length() > 0) {
	astrSQLQuery[2] = WI.fillTextValue("query_3");
}
if(WI.fillTextValue("query_4").length() > 0) {
	astrSQLQuery[3] = WI.fillTextValue("query_4");
}
if(WI.fillTextValue("query_5").length() > 0) {
	astrSQLQuery[4] = WI.fillTextValue("query_5");
}

%>
<form name="form_" action="terminal_query_wnd.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>::::
          DATABASE QUERY TERMINAL ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
<%
if(strErrMsg != null){%>
    <tr>
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;<strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
<%}%>    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="21%">Access Password</td>
      <td width="77%"><input type="password" name="password" value="<%=WI.fillTextValue("password")%>"></td>
    </tr>
<tr>
  <td height="25">&nbsp;</td>
  <td>DTR Terminal </td>
  <td>
		<select name="remote_loc">
			<%=dbOP.loadCombo("loc_index","loc_name", " from edtr_location where is_valid = 1 and db_property is not null", WI.fillTextValue("remote_loc"),false)%> 
		</select>
  </td>
</tr>
    <tr>
      <td  colspan="3" height="25"><hr size="1"></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2"><b><font color="#0000FF">One query is allowed in each box
        below. Delete is not allowed. Update is_valid=0 or is_del=1 is not allowed.</font></b></td>
    </tr>
    <tr>
      <td height="25" width="2%">&nbsp;</td>
      <td width="10%" valign="top"><br>
        Query 1. </td>
      <td width="88%"><textarea name="query_1" cols="120" rows="5" class="textbox" style="font-size:11px;"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("query_1")%></textarea>
      <a href="javascript:ClearQuery(1);"><img src="../../../images/clear.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="top"><br>
        Query 2.</td>
      <td><textarea name="query_2" cols="120" rows="5" class="textbox" style="font-size:11px;"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("query_2")%></textarea>
        <a href="javascript:ClearQuery(2);"><img src="../../../images/clear.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="top"><br>
        Query 3.</td>
      <td><textarea name="query_3" cols="120" rows="5" class="textbox" style="font-size:11px;"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("query_3")%></textarea>
        <a href="javascript:ClearQuery(3);"><img src="../../../images/clear.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="top"><br>
        Query 4.</td>
      <td><textarea name="query_4" cols="120" rows="5" class="textbox" style="font-size:11px;"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("query_4")%></textarea>
        <a href="javascript:ClearQuery(4);"><img src="../../../images/clear.gif" border="0"></a></td>
    </tr>
<%
if(WI.fillTextValue("password").compareTo("show5") == 0){%>    <tr>
      <td height="25">&nbsp;</td>
      <td valign="top"><br>
        Query for create table</td>
      <td><textarea name="query_5" cols="120" rows="15" class="textbox" style="font-size:11px;"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("query_5")%></textarea>
        <a href="javascript:ClearQuery(5);"><img src="../../../images/clear.gif" border="0"></a></td>
    </tr>
<%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2"><div align="center"> <a href="javascript:ExecuteQuery();">
          <img src="../../../images/execute_query.gif" height="15" width="15" border="0"></a>
          EXECUTE QUERY</div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="2" bgcolor="#B9B292"><div align="center"><strong>QUERY
          RESULT</strong> </div></td>
    </tr>
  </table>
<%
strErrMsg = null;
int iRowCount = 1;
boolean bolIsSQL5 = false;

for(int i = 0; i < astrSQLQuery.length; ++ i){
	if(astrSQLQuery[i] == null || astrSQLQuery[i].length() == 0)
		continue;
	if(i == 4)
		bolIsSQL5 = true;
	else
		bolIsSQL5 = false;
	//i can now get result.
	vRetResult =
		ESQ.executeSQLQuery(dbOPRemote, WI.fillTextValue("password"),WI.fillTextValue("query_"+Integer.toString(i + 1)),bolIsSQL5);
	if(vRetResult == null) {
		strErrMsg = ESQ.getErrMsg();
		vColumnName = null;
		vResult = null;
	}
	else {
		strErrMsg = null;
		vColumnName = (Vector)vRetResult.elementAt(0);
		vResult     = (Vector)vRetResult.elementAt(1);
	}%>
	<table width="100%" border="0" cellpadding="3" cellspacing="1" bgcolor="#808080">
    <tr bgcolor="#3366FF">
      <td height="25">&nbsp;&nbsp;&nbsp; <strong><font color="#FFFFFF">QUERY <%=i + 1%> :::
	  <%
	  	if(vResult != null && vColumnName != null && vColumnName.size() > 0 &&
			WI.fillTextValue("query_"+Integer.toString(i + 1)).trim().startsWith("select") ){%>
	  &nbsp;&nbsp;&nbsp;&nbsp;Rows Retured : <%=vResult.size()/vColumnName.size()%>
	  <%}else if(vResult != null && vResult.size() == 1){
            //System.out.println(vResult);%>
	  <%=(String)vResult.elementAt(0)%><%}%></font></strong></td>
    </tr>
	</table>
	<%
	if(strErrMsg != null){%>
	 <table  bgcolor="#FFFFFF" width="100%" border="" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"><%=strErrMsg%></td>
    </tr>
  </table>
	<%}else{
	if(vColumnName == null || vColumnName.size() == 0) continue;
	%>

  <table width="100%" border="0" cellpadding="3" cellspacing="1" bgcolor="#808080">
    <tr bgcolor="#FFFFAF">
      <%
	  for(int p = 0 ; p < vColumnName.size();){%>
	  <td height="25"><font size="1"><b><%=(String)vColumnName.elementAt(p++)%></b></font></td>
	  <%}%>
    </tr>
    <%
	for(int s =0 ; s < vResult.size(); s += vColumnName.size()){%>
	<tr bgcolor="#FFFFFF">
      <%
	  for(int p = 0 ; p < vColumnName.size();++p){%>
	  <td height="25"><%=(String)vResult.elementAt( s + p)%></td>
	  <%}%>
    </tr>
	<%}%>
  </table>
	<%}//end of else.
}//end of for loop
%>
	 <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
      </tr>
  </table>
<input type="hidden" name="execute_query">

</form>
</body>
</html>
<%
if(dbOP != null)
	dbOP.cleanUP();
if(dbOPRemote != null)
	dbOPRemote.cleanUP();
%>