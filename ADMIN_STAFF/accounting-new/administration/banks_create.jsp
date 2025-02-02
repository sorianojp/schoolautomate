<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	if(strAction.length == 0) { 
		document.form_.preparedToEdit.value = "";
		document.form_.info_index.value = "";
	}
}
function PreparedToEdit(strInfoIndex) {
//	alert("I am here.");
	document.form_.preparedToEdit.value = "1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
}
function UpdateTaxCode() {
	var loadPg = "./tax_code.jsp";
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField){
	var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+
	"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function MapCOAAjax(strIsBlur) {
		var objCOA;
		objCOA=document.getElementById("coa_info");
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=1&coa_entered="+
			document.form_.coa_index.value+"&coa_field_name=coa_index&is_blur="+strIsBlur;
		this.processRequest(strURL);
}
function COASelected(strAccountName) {
	document.getElementById("coa_info").innerHTML = "End of Processing..";
}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,Accounting.Administration,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);

	String strTemp   = null;
	String strErrMsg = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-Administration","banks_create.jsp");
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
//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-ADMINISTRATION"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
		}
	}

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
Administration adm = new Administration();
Vector vRetResult = null;
Vector vEditInfo  = null;
String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("preparedToEdit"), "0");
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(adm.operateOnBank(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = adm.getErrMsg();
	else {
		strPreparedToEdit = "0";
		strErrMsg = "Operation successful.";
	}
}
vRetResult = adm.operateOnBank(dbOP, request, 4);
if(vRetResult == null && strErrMsg == null)
	strErrMsg = adm.getErrMsg();
	
if(strPreparedToEdit.equals("1"))
	vEditInfo = adm.operateOnBank(dbOP, request, 3);

%>
<form action="./banks_create.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B5AB73"> 
      <td  height="27" colspan="8" bgcolor="#B5AB73"><div align="center"><strong><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          BANKS PAGE ::::</strong></font></strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">
    <tr> 
      <td style="font-size:13px; color:#FF0000; font-weight:bold">&nbsp;</td>
      <td colspan="4" style="font-size:13px; color:#FF0000; font-weight:bold"><%=WI.getStrValue(strErrMsg)%></td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="12%" style="font-size:11px;">Bank Code</td>
      <td width="28%" height="25">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("bank_code");
%>	  <input name="bank_code" type="text" size="16" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td width="13%" style="font-size:11px;">Bank Name</td>
      <td width="44%">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(2);
else	
	strTemp = WI.fillTextValue("bank_name");
%>	  <input name="bank_name" type="text" size="45" maxlength="128" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:11px;"></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td style="font-size:11px;">Bank Account #</td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(3);
else	
	strTemp = WI.fillTextValue("account_no");
%>	  <input name="account_no" type="text" size="16" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td style="font-size:11px;">Account Type</td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(4);
else	
	strTemp = WI.fillTextValue("account_type");

%>
	  <select name="account_type">
          <option value="0">Savings</option>
<%
if(strTemp.equals("1"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>        <option value="1"<%=strErrMsg%>>Checking</option>
<%
if(strTemp.equals("2"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>        <option value="2"<%=strErrMsg%>>Time Deposit</option>
<%
if(strTemp.equals("3"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>        <option value="3"<%=strErrMsg%>>Current</option>
        </select></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td valign="top" style="font-size:11px;">Address</td>
      <td colspan="3">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(5);
else	
	strTemp = WI.fillTextValue("address");
%>	  <textarea name="address" rows="3" cols="55" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea>	  </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td style="font-size:11px;">Bank Group</td>
      <td colspan="3">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(6);
else	
	strTemp = WI.fillTextValue("bank_group");
%>	  <select name="bank_group" style="font-size:11px; color:#0000FF">
	<option></option>
<%=dbOP.loadCombo("BG_INDEX","BG_NAME"," from AC_COA_BG order by bg_name asc",strTemp, false)%>
        </select>
<a href='javascript:viewList("AC_COA_BG","BG_INDEX","BG_NAME","Bank group name",
		"AC_COA_BANKCODE","BANK_GROUP_INDEX", 
		" and AC_COA_BANKCODE.is_valid = 1","","bank_group")'><img src="../../../images/update.gif" border="0"></a><font size="1">click to update list of BANK Group</font></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td style="font-size:11px;">Fund Group</td>
      <td colspan="3">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(8);
else	
	strTemp = WI.fillTextValue("fund_group");
%>	  <select name="fund_group">
	<option></option>
	<%=dbOP.loadCombo("FG_INDEX","FG_NAME"," from AC_COA_FG order by fg_name asc",strTemp, false)%>
        </select>
<a href='javascript:viewList("AC_COA_FG","FG_INDEX","FG_NAME","Fund Group Name",
		"AC_COA_BANKCODE","FUND_GROUP_INDEX", 
		" and AC_COA_BANKCODE.is_valid = 1","","fund_group")'><img src="../../../images/update.gif" border="0"></a><font size="1">click to update list of FUND Group</font></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td style="font-size:11px;" valign="top">Chart of Account #</td>
      <td valign="top">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(10);
else	
	strTemp = WI.fillTextValue("coa_index");
%>	  <input name="coa_index" type="text" size="16" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="MapCOAAjax('0');"></td>
      <td colspan="2"><label id="coa_info" style="font-size:11px;"></label></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="37">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3">
	  <%if(iAccessLevel > 1) {
	if(strPreparedToEdit.equals("0")){%>
	  <input type="submit" name="12" value=" Save Info " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="PageAction('1','');">
&nbsp;&nbsp;&nbsp;&nbsp;
<%}else{%>
<input type="submit" name="12" value=" Edit Info " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="PageAction('2','');">
&nbsp;&nbsp;&nbsp;&nbsp;
<%}
}%>
<input type="submit" name="12" value=" Cancel " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="PageAction('','')"></td>
    </tr>
    <tr> 
      <td colspan="5">&nbsp;</td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="10" bgcolor="#B9B292" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>:: 
          LIST OF BANKS IN RECORD :: </strong></font></div></td>
    </tr>
    <tr> 
      <td width="6%" class="thinborder"><div align="center"><font size="1"><strong>BANK CODE</strong></font></div></td>
      <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>BANK NAME</strong></font></div></td>
      <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>BANK ACCOUNT # </strong></font></div></td>
      <td width="18%" class="thinborder"><div align="center"><font size="1"><strong>ADDRESS</strong></font></div></td>
      <td width="13%" class="thinborder"><div align="center"><font size="1"><strong>BANK GROUP</strong></font></div></td>
      <td width="11%" class="thinborder"><div align="center"><font size="1"><strong>FUND GROUP</strong></font></div></td>
      <td width="9%" height="25" class="thinborder"><div align="center"><font size="1"><strong>CHART OF ACCOUNT 
          NO. </strong></font></div></td>
      <td width="19%" class="thinborder"><div align="center"><strong><font size="1">CHART OF ACCOUNT NAME</font></strong></div></td>
      <td width="4%" class="thinborder"><font size="1">&nbsp;</font></td>
      <td width="5%" class="thinborder">&nbsp;</td>
    </tr>
<%for(int i = 0; i < vRetResult.size(); i +=12){%>
    <tr> 
      <td class="thinborder"><font size="1"><!--ALLIED--><%=vRetResult.elementAt(i + 1)%></font></td>
      <td class="thinborder"><font size="1"><!--Allied Bank Corporation--><%=vRetResult.elementAt(i + 2)%></font></td>
      <td class="thinborder">&nbsp;<%=vRetResult.elementAt(i + 3)%></td>
      <td class="thinborder"><font size="1"><!--Jaro, Iloilo City--><%=vRetResult.elementAt(i + 5)%></font></td>
      <td class="thinborder"><font size="1"><!--Auxiliary Bank Account--><%=vRetResult.elementAt(i + 7)%></font></td>
      <td class="thinborder"><font size="1"><!--General--><%=vRetResult.elementAt(i + 9)%></font></td>
      <td class="thinborder"><font size="1"><!--1324--><%=vRetResult.elementAt(i + 10)%></font></td>
      <td height="25" class="thinborder"><font size="1"><!--Allied Savings for Account #1241464-->
		  <%=vRetResult.elementAt(i + 11)%></font></td>
      <td class="thinborder">
<%if(iAccessLevel > 1) {%>	  
	  <input type="submit" name="122" value="Edit" style="font-size:10px; height:22px;border: 1px solid #FF0000;"
		 onClick="PreparedToEdit('<%=vRetResult.elementAt(i)%>');">
<%}else{%>&nbsp;<%}%>
	  </td>
      <td class="thinborder">
<%if(iAccessLevel > 1) {%>	  
	  <input type="submit" name="125" value="Delete" style="font-size:10px; height:22px;border: 1px solid #FF0000;"
		 onClick="PageAction('0','<%=vRetResult.elementAt(i)%>');">
<%}else{%>&nbsp;<%}%>
	  </td>
    </tr>
<%}%>
  </table>
<%}//show only if vRetResult is not null %>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" >
    <tr> 
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#FFFFFF" >&nbsp;</td>
    </tr>
    <tr>
      <td height="27" bgcolor="#B5AB73">&nbsp;</td>
    </tr>
  </table>


<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="preparedToEdit" value="<%=strPreparedToEdit%>">
<input type="hidden" name="page_action" value="">
<input type="hidden" name="coa_cf" value="<%=WI.fillTextValue("coa_cf")%>">

<!--
<input type="hidden" name="parent_level" value="<%=WI.fillTextValue("parent_level")%>">
-->

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>