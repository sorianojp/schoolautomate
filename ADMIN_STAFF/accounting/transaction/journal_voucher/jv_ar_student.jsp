<%@ page language="java" import="utility.*,Accounting.JvCD,java.util.Vector" %>
<%
	WebInterface WI  = new WebInterface(request);
	
	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;	
    }
    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
    }

</style>
</head>

<script language="javascript" src="../../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../../jscript/common.js"></script>
<script language="javascript" src="../../../../jscript/date-picker.js"></script>
<script language="javascript">
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	if(strAction.length == 0) { 
		//cancell is called.
		document.form_.preparedToEdit.value = "";
		document.form_.info_index.value = "";
		
		//document.form_.fname.value = "";
		//document.form_.mname.value = "";
		document.form_.charge_to_name.value = "";
		
		document.form_.amount.value = "";
		document.form_.date_of_payment.value = "";
	}
	if(strAction == "0")
		document.form_.submit();
}
function PreparedToEdit(strInfoIndex) {
//	alert("I am here.");
	document.form_.preparedToEdit.value = "1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
	
}
function AddCOA(strCOACF) {
	location = "./chart_of_account.jsp?coa_cf="+strCOACF;
}
function ConfirmDel(strInfoIndex) {
	if(confirm("Do you want to delete."))
		return this.PageAction('0',strInfoIndex);
}
function nameBlur() {
	<%if(!WI.fillTextValue("account_type").equals("2")){%>
		document.form_.submit();
	<%}%>
}
function AjaxMapName() {
		if(document.form_.account_type[2] && document.form_.account_type[2].checked)
			return;
		var strCompleteName = document.form_.charge_to_name.value;
		var objCOAInput;
		objCOAInput= document.getElementById("coa_info");
		if(strCompleteName.length < 3) {
			objCOAInput.innerHTML = "";
			return;
		}
		
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=2&name_format=4&complete_name="+
			escape(strCompleteName);
		if(document.form_.account_type[1] && document.form_.account_type[1].checked) //faculty
			strURL += "&is_faculty=1";
		<%if(!bolIsSchool){%>
			strURL += "&is_faculty=1";
		<%}%>
		//alert(strURL);
		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.user_index.value = strUserIndex;
	//alert(strUserIndex);
}
function UpdateName(strFName, strMName, strLName) {
	document.getElementById("coa_info").innerHTML = "End of Processing..";
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.form_.charge_to_name.value = strName;
}
</script>

<body bgcolor="#D2AE72">
<%
	DBOperation dbOP = null;

	String strTemp   = null;
	String strErrMsg = null; String strSaveNotAllowedMsg = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-Transaction","jv_ar_student.jsp");
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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-TRANSACTION"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
		}
	}

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
boolean bolIsJVLocked = false; boolean bolSavePermitted = true;//false only if balance is 0
Vector vJVInfo = null;////

String strJVNumber = null;
JvCD jvCD = new JvCD();
Vector vRetResult = null;
Vector vEditInfo  = null; 

String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("preparedToEdit"), "0");
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(jvCD.operateOnJVDetailEntry(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = jvCD.getErrMsg();
	else {
		strPreparedToEdit = "0";
		strErrMsg  = "Operation successful.";
	}
}
vJVInfo = jvCD.operateOnJVDetailEntry(dbOP, request, 5);///jv main info.. 
if(vJVInfo == null)
	strErrMsg = jvCD.getErrMsg();
else {
	bolIsJVLocked = ((Boolean)vJVInfo.elementAt(5)).booleanValue();
	if(((String)vJVInfo.elementAt(4)).equals("0.00") ) {
		bolSavePermitted = false;
		strSaveNotAllowedMsg = "Balance is 0";
	}
}

if(strPreparedToEdit.equals("1")) {
	vEditInfo = jvCD.operateOnJVDetailEntry(dbOP, request, 3);
	if(vEditInfo == null)
		strErrMsg = jvCD.getErrMsg();
}

///view detail. 
vRetResult = jvCD.operateOnJVDetailEntry(dbOP, request, 4);
Vector vUserDetail = new Vector();
java.sql.ResultSet rs = null;
//String strFName = WI.getInsertValueForDB(WI.fillTextValue("fname"), true, null);
//String strMName = WI.getInsertValueForDB(WI.fillTextValue("mname"), true, null);
//String strLName = WI.getInsertValueForDB(WI.fillTextValue("lname"), true, null);
strTemp = WI.fillTextValue("account_type");
if(!strTemp.equals("2")) {//either student or faculty.
/**
	if(strFName != null || strLName != null) {
		String strSQLQuery = "select user_index,fname, mname, lname, id_number from user_table where is_valid = 1 "+
			WI.getStrValue(strFName, "and fname=","","")+WI.getStrValue(strLName, "and lname=","","");
		rs = dbOP.executeQuery(strSQLQuery);
		while(rs.next()) {
			vUserDetail.addElement(rs.getString(1));//[0] user_index
			vUserDetail.addElement(rs.getString(2));//[1] lname
			vUserDetail.addElement(rs.getString(3));//[2] fname
			vUserDetail.addElement(rs.getString(4));//[3] mname
			vUserDetail.addElement(rs.getString(5));//[4] id_number
		}
		rs.close();
	}
	if(vUserDetail.size() == 0) {
		strErrMsg = "User not found. Please check Name information.";
		bolSavePermitted = false;
		strSaveNotAllowedMsg = "User not found";
	}
**/
}


%>
<form action="./jv_ar_student.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          VOUCHER SUPPORTING DETAILS ENTRY PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" style="font-size:14px; color:#0000FF; font-weight:bold"><%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
<%if(vJVInfo == null) {
	dbOP.cleanUP();
	return;
}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
<%if(bolIsSchool) {%>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;
<%	if(strTemp.equals("0") || request.getParameter("account_type") == null)
		strErrMsg = " checked";
	else	
		strErrMsg = "";
	%>	  
		  <input name="account_type" type="radio" value="0"<%=strErrMsg%> onClick="PageAction('','');document.form_.submit();">A/R Student &nbsp;
	<%
	if(strTemp.equals("1"))
		strErrMsg = " checked";
	else	
		strErrMsg = "";
	%>	  <input name="account_type" type="radio" value="1"<%=strErrMsg%> onClick="PageAction('','');document.form_.submit();">A/R FS &nbsp;
	<%
	if(strTemp.equals("2"))
		strErrMsg = " checked";
	else	
		strErrMsg = "";
	%>	  <input name="account_type" type="radio" value="2"<%=strErrMsg%> onClick="PageAction('','');document.form_.submit();">A/R Others</td> &nbsp;
    </tr>
<%}else{%>
			<input type="hidden" name="account_type" value="2">
<%}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="100%" height="27" colspan="4" style="font-size:11px; font-weight:bold">
	  &nbsp;&nbsp;
	  Voucher Number : <font color="#FF0000"><%=WI.fillTextValue("jv_number")%></font> 
	  Account # : <font color="#FF0000"><%=vJVInfo.elementAt(0)%></font>
	  Type : <font color="#FF0000"><%if(vJVInfo.elementAt(1).equals("1")){%>Debit <%}else{%>Credit<%}%></font>
	  Amount : <font color="#FF0000"><%=vJVInfo.elementAt(2)%></font>
	  Balance : <font color="#FF0000"><%=vJVInfo.elementAt(4)%></font>
	  </td>
    </tr>
    
    <tr> 
      <td height="10" colspan="4"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
      <td> Name</td>
      <td width="81%" height="29">
<%
if(vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(7);
else	
	strTemp = WI.fillTextValue("charge_to_name");
%>	  
	  <input name="charge_to_name" type="text" size="45" maxlength="64" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';"
	  onKeyUp="AjaxMapName();document.form_.user_index.value=''">
        ( Lastname, Firstname Middle Initial)</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td></td>
      <td><label id="coa_info" style="font-size:11px;"></label></td>
    </tr>
    <tr> 
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
    <tr> 
      <td  width="6%"height="30">&nbsp;</td>
      <td width="13%" height="30">Amount </td>
      <td height="30">
<%
if(vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(0);
else	
	strTemp = WI.fillTextValue("amount");
%>	  <input name="amount" type="text" size="12" maxlength="32" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','amount');style.backgroundColor='white'"
	   onKeyUp="AllowOnlyFloat('form_','amount');"></td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td height="30" colspan="2">Deposit Date / 
        Date of Payment        
<%
if(vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("date_of_payment");
if(strTemp.length() == 0) 
	strTemp = WI.getTodaysDate(1);
	
%>        <input name="date_of_payment" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_of_payment');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td height="30">Transaction Type</td>
      <td height="30">
<%
if(vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(2);
else	
	strTemp = WI.fillTextValue("trans_type");
%>	  <select name="trans_type">
<%strTemp = dbOP.loadCombo("TRANS_TYPE_INDEX","TRANS_CODE", " from AC_TRANSTYPE where is_valid = 1 order by trans_code", 
	strTemp, false);
if(strTemp.length() == 0) {
	bolSavePermitted = false;
	strSaveNotAllowedMsg = "Please create Transaction type";
}
%><%=strTemp%>
      </select>
	  
	  </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td><%if(iAccessLevel > 1) {
	if(strPreparedToEdit.equals("0")){
		if(bolSavePermitted) {//save is not permitted if balance is same.%>
        <input type="submit" name="12" value=" Save Info " style="font-size:11px; height:24px;border: 1px solid #FF0000;"
		 onClick="PageAction('1','');">
&nbsp;&nbsp;&nbsp;&nbsp;
<%}else{%>
<font style="font-size:11px; font-weight:bold; color:#FF0000">Save not allowed(<%=strSaveNotAllowedMsg%>).</font>
<%}//save allowed or not..
}else{//prepared to edit.. %>
<input type="submit" name="124" value=" Edit Info " style="font-size:11px; height:24px;border: 1px solid #FF0000;"
		 onClick="PageAction('2','');">
&nbsp;&nbsp;&nbsp;&nbsp;
<%}
}%>
<input type="submit" name="12" value=" Cancel " style="font-size:11px; height:24px;border: 1px solid #FF0000;"
		 onClick="PageAction('','');"></td>
    </tr>
    <tr> 
      <td height="22">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0) {
vRetResult.removeElementAt(0);//remove main information. i do not need here.
vRetResult.removeElementAt(0);//remove JV_CREDIT_INDEX
vRetResult = (Vector)vRetResult.remove(0);
strTemp = (String)vRetResult.remove(0);//total amt collected.

%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#6699FF"> 
      <td height="25" colspan="7" class="thinborder">
	  <div align="center"><strong><font color="#FFFFFF">:: LIST OF SUPPORTING ENTRIES ::</font></strong></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="4" class="thinborder"><font size="1"><strong>TOTAL AMOUNT : <%=strTemp%></strong></font></td>
      <td colspan="3" class="thinborder"><font size="1"><strong>TOTAL NO. OF PAYEE : <%=vRetResult.size()/7%></strong></font></td>
    </tr>
    <tr> 
      <td width="23%" height="25" class="thinborder"><div align="center"><font size="1"><strong> NAME </strong></font></div></td>
      <td width="9%" class="thinborder"><div align="center"><font size="1"><strong>COURSE CODE /YR</strong></font></div></td>
      <td width="9%" class="thinborder"><div align="center"><strong><font size="1">AMOUNT</font></strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>DATE OF PAYMENT/DEPOSIT DATE</strong></font></div></td>
      <td width="13%" class="thinborder"><div align="center"><font size="1"><strong>TRANSACTION TYPE</strong></font></div></td>
      <td width="4%" class="thinborder">&nbsp;</td>
      <td width="5%" class="thinborder">&nbsp;</td>
    </tr>
<%
for(int i = 0; i < vRetResult.size(); i += 7){%>
    <tr> 
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 2))%> - 
	  		<%=WI.getStrValue(vRetResult.elementAt(i + 3))%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 4)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 5)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 6)%></td>
      <td class="thinborder">
	  <input type="submit" name="1242" value=" Edit " style="font-size:11px; height:22px;border: 1px solid #FF0000;"
		 onClick="PreparedToEdit('<%=(String)vRetResult.elementAt(i)%>');"></td>
      <td class="thinborder">
	  <input type="submit" name="1243" value=" Delete " style="font-size:11px; height:22px;border: 1px solid #FF0000;"
		 onClick="PageAction('0','<%=(String)vRetResult.elementAt(i)%>');"></td>
    </tr>
<%}%>
  </table>
<%}//end of vRetResult.%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25"><div align="left"></div></td>
      <td width="94%" height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" colspan="2" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="preparedToEdit" value="<%=strPreparedToEdit%>">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">

<input type="hidden" name="credit_index" value="<%=WI.fillTextValue("credit_index")%>">
<input type="hidden" name="jv_number" value="<%=WI.fillTextValue("jv_number")%>">
<%
strTemp = "";
if(vEditInfo!= null)
	strTemp = (String)vEditInfo.elementAt(6);
%>
<input type="hidden" name="user_index" value="<%=strTemp%>">
  
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>