<%if(request.getSession(false).getAttribute("is_sap") == null) {%>
	<p style="font-family:Verdana, Arial, Helvetica, sans-serif; font-weight:bold; font-size:18px; color:#FF0000">You are either logged out or not authorized to view this link. </p>
	<%return;

}%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
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


</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,sap.Configuration,java.util.Vector" %>
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
Vector vRetResult   = null;
Vector vFeeList     = null;
Vector vCollegeList = null;


Configuration conf = new Configuration();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(conf.operateOnScholarshipMap(dbOP, request, Integer.parseInt(strTemp)) == null) 
		strErrMsg = conf.getErrMsg();
	else	
		strErrMsg = "Request processed successfully.";
}
//get list of fee not  yet mapped.. 
//get list of college for that fee. 

vFeeList     = conf.operateOnScholarshipMap(dbOP, request, 5);
if(WI.fillTextValue("fee_name_sa").length() > 0) {
	vCollegeList = conf.operateOnScholarshipMap(dbOP, request, 6);
	
	vRetResult   = conf.operateOnScholarshipMap(dbOP, request, 4);
}
else if(WI.fillTextValue("view_all").length() > 0)
	vRetResult   = conf.operateOnScholarshipMap(dbOP, request, 4);


if(vFeeList == null)
	vFeeList = new Vector();
if(vCollegeList == null)
	vCollegeList = new Vector();
	
%>


<form name="form_" action="./map_scholarship.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: MAP SCHOLARSHIP ::::</strong></font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="28">&nbsp;</td>
      <td colspan="4"><font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4">
	  <input type="checkbox" name="search_con" value="checked" onClick="document.form_.page_action.value='';document.form_.submit()" <%=WI.fillTextValue("search_con")%>>
	  Show Scholarship Having all Colleges Mapped &nbsp;&nbsp;&nbsp;&nbsp;
	  <input type="checkbox" name="view_all" value="checked" onClick="document.form_.page_action.value='';document.form_.submit()" <%=WI.fillTextValue("view_all")%>>View all mapped in one List	  </td>
    </tr>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="18%">Fee Name (SA) </td>
      <td colspan="3">
		<select name="fee_name_sa" onChange="document.form_.page_action.value='';document.form_.submit()">
		<option value=""></option>
<%
strTemp = WI.fillTextValue("fee_name_sa");
for(int i = 0; i < vFeeList.size(); ++i) {
	if(strTemp.equals(vFeeList.elementAt(i)))
		strErrMsg = " selected";
	else
		strErrMsg = "";
	%>
	<option value="<%=vFeeList.elementAt(i)%>" <%=strErrMsg%>><%=vFeeList.elementAt(i)%></option>
	
<%}%>
		</select>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>College</td>
      <td colspan="3">
		<select name="c_index">
			<option value="">-- create for all -- </option>
<%
strTemp = WI.fillTextValue("c_index");
for(int i = 0; i < vCollegeList.size(); i += 3) {
	if(strTemp.equals(vCollegeList.elementAt(i)))
		strErrMsg = " selected";
	else
		strErrMsg = "";
	%>
	<option value="<%=vCollegeList.elementAt(i)%>" <%=strErrMsg%>><%=vCollegeList.elementAt(i + 1)%></option>
	
<%}%>
		</select>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Fee Name (SAP) </td>
      <td colspan="3">
	  <input type="text" name="fee_name_sap" size="60" value="<%=WI.fillTextValue("fee_name_sap")%>" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">	  </td>
    </tr>

    <tr>
      <td height="25">&nbsp;</td>
      <td>Account Code </td>
      <td colspan="3">
	  <input type="text" name="sap_account_code" size="32" value="<%=WI.fillTextValue("sap_account_code")%>" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>SAP OFFICE </td>
      <td colspan="3"><input type="text" name="sap_office" size="32" value="<%=WI.fillTextValue("sap_office")%>" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="45">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td width="31%" align="center"><input type="submit" name="122" value="Add Mapping" style="font-size:11px; height:24px;border: 1px solid #FF0000;" 
		  onClick="document.form_.page_action.value='1';"></td>
      <td width="41%" align="center">&nbsp;</td>
      <td width="7%" align="center">&nbsp;</td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
  	<tr bgcolor="#CCCCCC" style="font-weight:bold">
		<td height="22" class="thinborder" width="4%">Count#</td>
		<td width="20%" class="thinborder">Fee Name (SA) </td>
		<td width="20%" class="thinborder">Fee Name (SAP) </td>
		<td width="15%" align="center" class="thinborder">SAP Account Code </td>
		<td width="10%" class="thinborder">College</td>
	    <td width="10%" class="thinborder">Sap Office </td>
	    <td width="8%" align="center" class="thinborder">Delete</td>
  	</tr>
<%int iMaxDisp = 0;
String strBGColor = "";
String strFeeNameSA = "";
for(int i =0; i < vRetResult.size(); i += 6) {
	if(!strFeeNameSA.equals(vRetResult.elementAt(i + 1))) {
		strFeeNameSA = (String)vRetResult.elementAt(i + 1);
		if(strBGColor.equals("#66CC99"))
			strBGColor = "#99CCCC";
		else	
			strBGColor = "#66CC99";
	}
		%>
  	<tr bgcolor="<%=strBGColor%>">
		<td height="24" class="thinborder"><%=++iMaxDisp%></td>
		<td class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
		<td class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
		<td class="thinborder"><%=vRetResult.elementAt(i + 3)%></td>
		<td class="thinborder"><%=vRetResult.elementAt(i + 4)%></td>
  	    <td class="thinborder"><%=vRetResult.elementAt(i + 5)%></td>
  	    <td class="thinborder" align="center">
			<input type="submit" name="122" value=" Delete " style="font-size:11px; height:22px;border: 1px solid #FF0000;" 
		  onClick="document.form_.page_action.value='0';document.form_.info_index.value=<%=vRetResult.elementAt(i)%>">	  </td>
  	</tr>
<%}%>
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
<input type="hidden" name="page_action">
<input type="hidden" name="info_index">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
