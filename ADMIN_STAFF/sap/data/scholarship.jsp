<%if(request.getSession(false).getAttribute("is_sap") == null) {%>
	<p style="font-family:Verdana, Arial, Helvetica, sans-serif; font-weight:bold; font-size:18px; color:#FF0000">You are not authorized to view this link. </p>
	<%return;

}%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.form_.submit();
}
function PageAction(strInfoIndex, strPageAction) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strPageAction;

	document.form_.submit();
}
function ShowProcessing()
{
	imgWnd=
	window.open("../../../commfile/processing.htm","PrintWindow",'width=600,height=300,top=220,left=200,toolbar=no,location=no,directories=no,status=no,menubar=no');
	imgWnd.focus();
	return true;
}
function CloseProcessing()
{
	if (imgWnd && imgWnd.open && !imgWnd.closed) imgWnd.close();
}
</script>

<body bgcolor="#D2AE72" onUnload="CloseProcessing();">
<%@ page language="java" import="utility.*,sap.Configuration,sap.Scholarship, java.util.Vector" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

//add security here.
	try
	{
		dbOP = new DBOperation();

	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
Vector vRetResult  = null;
String strMapStatus = null;

Configuration conf = new Configuration();
Scholarship sch = new Scholarship();

strTemp = WI.getStrValue(WI.fillTextValue("page_action"), "4");
vRetResult = conf.setSYTermSAP(dbOP, request, Integer.parseInt(strTemp));
strErrMsg = conf.getErrMsg();

if(strErrMsg == null) {//check if all tellers are mapped.. 
	Vector vTellerNotMappedSch = new Vector();
	strTemp = "select distinct id_number, fname, mname, lname from FA_STUD_PMT_ADJUSTMENT join USER_TABLE on (USER_TABLE.USER_INDEX = FA_STUD_PMT_ADJUSTMENT.CREATED_BY) "+
				"where FA_STUD_PMT_ADJUSTMENT.is_valid = 1 and not exists "+
				"(select * from SAP_TELLER_MAP where user_index = created_by) order by lname";
	java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
	while(rs.next()) {
		vTellerNotMappedSch.addElement(rs.getString(1));
		vTellerNotMappedSch.addElement(WebInterface.formatName(rs.getString(2), rs.getString(3), rs.getString(4), 4));
	}
	rs.close();
	
	if(vTellerNotMappedSch != null && vTellerNotMappedSch.size() > 0)
		strMapStatus = "Please map the Following IDs: "+vTellerNotMappedSch.toString();
}


if(strErrMsg == null && WI.fillTextValue("generate_").length() > 0) {
	sch.generateScholarship(dbOP, request);
	strErrMsg = sch.getErrMsg();
}

String[] astrConvertTerm = {"Summer","1st Term","2nd Term","3rd Term"};
String[] astrConvertTermType = {"Semestral","Trimestral","Grade School (Annual)"};

%>


<form name="form_" action="./scholarship.jsp" method="post" onSubmit="SubmitOnceButton(this);return ShowProcessing();">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: SCHOLARSHIP ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="28">&nbsp;</td>
      <td colspan="4"><font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
	<%if(strMapStatus != null) {%>
    <tr>
      <td width="2%" height="28">&nbsp;</td>
      <td colspan="4"><font size="3" style="color:#FF0000"><b><%=strMapStatus%></b></font></td>
    </tr>
	<%}%>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0 && strMapStatus == null) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr style="font-weight:bold;">
      <td height="25">&nbsp;</td>
      <td colspan="4" style="font-size:18px">Default SY-Term: <u><%=WI.getStrValue((String)vRetResult.elementAt(0))%>  - 
	  <%=WI.getStrValue((String)vRetResult.elementAt(1))%>,  
	  <%=astrConvertTerm[Integer.parseInt((String)vRetResult.elementAt(2))]%></u>
	  &nbsp;&nbsp;&nbsp;&nbsp;
	  Term Type: <u><%=astrConvertTermType[Integer.parseInt((String)vRetResult.elementAt(3))]%></u>
		<br><br>
		End of Term Date: 
	  <input name="end_of_term" type="text" size="12" maxlength="12" value="<%=WI.fillTextValue("end_of_term")%>" class="textbox" style="font-size:18px"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      <a href="javascript:show_calendar('form_.end_of_term');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>

	  </td>
    </tr>
    <tr>
      <td height="60">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td width="38%" align="center" valign="bottom">
	  
	  <input type="submit" name="122" value="Generate Scholarship" style="font-size:11px; height:24px;border: 1px solid #FF0000;" 
		  onClick="document.form_.generate_.value='1';ShowProcessing();">
	  </td>
      <td width="41%" align="center">&nbsp;</td>
      <td width="7%" align="center">&nbsp;</td>
    </tr>
  </table>
<%}%>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="generate_">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
