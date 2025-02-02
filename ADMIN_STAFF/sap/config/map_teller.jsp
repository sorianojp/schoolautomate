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
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
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
function SelTellerID() {
	document.form_.teller_id.value = document.form_.tell_pending[document.form_.tell_pending.selectedIndex].value;
	document.form_.sap_map.focus();
}
function AjaxMapName(strKeyCode) {
	if(strKeyCode == '13') {
		document.form_.sap_code.focus();
	}
	var strCompleteName = document.form_.teller_id.value;
	var objCOAInput = document.getElementById("coa_info");

	if(strCompleteName.length <=2) {
		objCOAInput.innerHTML = "";
		return ;
	}

	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
		escape(strCompleteName);

	this.processRequest(strURL);
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
Vector vRetResult  = null;

Configuration conf = new Configuration();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(conf.operateOnTellerIDMap(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = conf.getErrMsg();
	else	
		strErrMsg = "Successfully updated.";

}
vRetResult = conf.operateOnTellerIDMap(dbOP, request, 4);
if(vRetResult == null)
	conf.getErrMsg();


//get here tellers not mapped. 
strTemp = "select distinct id_number, fname, mname, lname from fa_stud_payment join USER_TABLE on (USER_TABLE.USER_INDEX = FA_STUD_PAYMENT.CREATED_BY) "+
			"where fa_stud_payment.is_valid = 1 and amount > 0 and or_number is not null and not exists "+
			"(select * from SAP_TELLER_MAP where user_index = created_by) order by lname";
java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
Vector vTellerNotMapped = new Vector();
while(rs.next()) {
	vTellerNotMapped.addElement(rs.getString(1));
	vTellerNotMapped.addElement(WebInterface.formatName(rs.getString(2), rs.getString(3), rs.getString(4), 4));
}
rs.close();
//get here scholarship users not mapped. 
Vector vTellerNotMappedSch = new Vector();
strTemp = "select distinct id_number, fname, mname, lname from FA_STUD_PMT_ADJUSTMENT join USER_TABLE on (USER_TABLE.USER_INDEX = FA_STUD_PMT_ADJUSTMENT.CREATED_BY) "+
			"where FA_STUD_PMT_ADJUSTMENT.is_valid = 1 and not exists "+
			"(select * from SAP_TELLER_MAP where user_index = created_by) order by lname";
rs = dbOP.executeQuery(strTemp);
while(rs.next()) {
	vTellerNotMappedSch.addElement(rs.getString(1));
	vTellerNotMappedSch.addElement(WebInterface.formatName(rs.getString(2), rs.getString(3), rs.getString(4), 4));
}
rs.close();

%>


<form name="form_" action="./map_teller.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: MAP TELLER ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="28">&nbsp;</td>
      <td colspan="4"><font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%if(vTellerNotMapped.size() > 0) {%>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td>Teller Not Mapped</td>
      <td colspan="3"> 
		<select name="tell_pending" onChange="SelTellerID();">

  <%if(vTellerNotMapped.size() > 0) {%>
  		<optgroup label="Teller To Map" style="color:#0000FF; font-weight:bold">
  <%}
  
strTemp = WI.fillTextValue("tell_pending");
for(int i = 0; i < vTellerNotMapped.size(); i += 2) {
	if(strTemp.equals(vTellerNotMapped.elementAt(i)))
		strErrMsg = " selected";
	else
		strErrMsg = "";
	%>
		  <option value="<%=vTellerNotMapped.elementAt(i)%>" <%=strErrMsg%>><%=vTellerNotMapped.elementAt(i)%> (<%=vTellerNotMapped.elementAt(i + 1)%>)</option>
		  
  <%}%>
  <%if(vTellerNotMapped.size() > 0) {%>
  		</optgroup>
  <%}%>
  <%if(vTellerNotMappedSch.size() > 0) {%>
  		<optgroup label="Scholarship Incharge To Map" style="color:#0000FF; font-weight:bold">
  <%}
  for(int i = 0; i < vTellerNotMappedSch.size(); i += 2) {
	if(strTemp.equals(vTellerNotMappedSch.elementAt(i)))
		strErrMsg = " selected";
	else
		strErrMsg = "";
	%>
		  <option value="<%=vTellerNotMappedSch.elementAt(i)%>" <%=strErrMsg%>><%=vTellerNotMappedSch.elementAt(i)%> (<%=vTellerNotMappedSch.elementAt(i + 1)%>)</option>
		  
  <%}%>
  <%if(vTellerNotMappedSch.size() > 0) {%>
  		</optgroup>
  <%}%>
	    </select>	  </td>
    </tr>
<%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="18%">Teller ID  </td>
      <td colspan="3">
	  <input type="text" name="teller_id" size="32" value="<%=WI.fillTextValue("teller_id")%>" class="textbox"  
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(event.keyCode);">	  </td>
    </tr>
    <tr>
      <td></td>
      <td><label id="coa_info"></label></td>
    </tr>

    <tr>
      <td height="25">&nbsp;</td>
      <td>SAP Map Code </td>
      <td colspan="3">
	  <input type="text" name="sap_map" size="15" value="<%=WI.fillTextValue("sap_map")%>" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">	  </td>
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
		<td height="22" class="thinborder" width="11%">Count#</td>
		<td width="26%" class="thinborder">Teller ID </td>
		<td width="32%" class="thinborder">Teller Name </td>
		<td width="16%" class="thinborder">Sap Map Code </td>
		<td width="15%" align="center" class="thinborder">Delete</td>
  	</tr>
<%int iMaxDisp = 0;
for(int i =0; i < vRetResult.size(); i += 4) {%>
  	<tr>
		<td height="24" class="thinborder"><%=++iMaxDisp%></td>
		<td class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
		<td class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
		<td class="thinborder"><%=vRetResult.elementAt(i + 3)%></td>
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
