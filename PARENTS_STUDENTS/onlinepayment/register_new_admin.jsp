<%
String strStudID    = (String)request.getSession(false).getAttribute("userId");
if(strStudID == null) {
%>
 <p style="font-size:14px; color:#FF0000;">You are already logged out. Please login again.</p>
<%return;}

String strAuthTypeIndex = (String)request.getSession(false).getAttribute("authTypeIndex");
//System.out.println(strAuthTypeIndex);
if(strAuthTypeIndex == null || strAuthTypeIndex.equals("4")) {
%>
 <p style="font-size:14px; color:#FF0000;">You are not authorized to view this page.</p>
<%return;
}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Register New Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
</head>
<script language="JavaScript" src="../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript" src="../../jscript/date-picker.js"></script>
<script language="JavaScript">
function Register() {
	objButton = document.getElementById('_submit');
	objButton.disabled=true;

	document.form_.create_.value = '1';
	document.form_.submit();
}
function ReloadPage() {
	document.form_.create_.value = '';
	document.form_.submit();
}
function UpdateStatus() {
	objButton = document.getElementById('_submit');
	objButton.disabled=true;

	document.form_.create_.value = '0';
	document.form_.submit();
}
//all about ajax - to display student list with same name.
function AjaxMapName() {
		var strCompleteName;
		strCompleteName = document.form_.stud_id.value;
		if(strCompleteName.length < 2)
			return;
		
		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");
			
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.stud_id.value = strID;
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}

</script>
<body onLoad="document.form_.stud_id.focus();">
<%@ page language="java" import="utility.*,java.util.Vector,onlinepayment.Registration" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp   = null;
	String[] astrConvertTerm = {"Summer","1st Sem","2nd Sem","3rd Sem"};
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
//authenticate this user.
	Vector vRetResult  	 = null;
	boolean bolIsUserCreated = false; String strStudStatus = null;
	
	String strBGColor = null;
	strTemp = WI.fillTextValue("old_stud_id");
	
	Registration registration = new Registration();
	if(strTemp.length() == 0 || strTemp.equals(WI.fillTextValue("stud_id"))) {
		if(WI.fillTextValue("create_").length() > 0) {
			if(registration.operateOnUserProfile(dbOP, request, Integer.parseInt(WI.fillTextValue("create_")), true) == null)
				strErrMsg = registration.getErrMsg();
			else
				strErrMsg = "Operation Successful.";
		}
	}
	if(WI.fillTextValue("stud_id").length() > 0) {
		//check if created already. 
		vRetResult = registration.operateOnUserProfile(dbOP, request, 6, true);
		if(vRetResult != null) {
			bolIsUserCreated = true;
			if(vRetResult.elementAt(9).equals("1")) {
				strStudStatus = "Active";
				strBGColor = "#FFFFFF";
			}
			else {
				strStudStatus = "Not Active";
				strBGColor = "#CCCCCC";
			}
		}
		else {
			vRetResult = registration.operateOnUserProfile(dbOP, request, 4, true);
			if(vRetResult == null)
				strErrMsg = registration.getErrMsg();
			strStudStatus = "Student Not Registered";
			strBGColor = "#66CC99";
		}
	}

%>
<form name="form_" method="post" action="./register_new_admin.jsp">
<%
if(strErrMsg != null) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" style="font-weight:bold; color:#FF0000; font-size:16px;"><%=strErrMsg%></td>
    </tr>
  </table>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">Student ID: 
	  <input name="stud_id" type="text" size="32" value="<%=WI.fillTextValue("stud_id")%>" class="textbox" maxlength="32" onFocus="style.backgroundColor='#D3EBFF'" 
	  onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName()">
	  &nbsp;&nbsp;&nbsp;
	  <input type="button" name="12" value=" Proceed >>> " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="ReloadPage();">
	  
	  <label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF; position:absolute"></label>
	  </td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="<%=strBGColor%>">
		<tr>
		  <td colspan="2" align="center" class="thinborderBOTTOM"><font size="1"><strong>REGISTRATION INFORMATION</strong></font></td>
		</tr>
		<tr >
		  <td height="35" colspan="2" class="thinborderNONE" style="font-weight:bold; color:#0000FF">Note: Please provide all correct information. Once saved, information can't be modified. All fields are mandatory. </td>
		</tr>
		<tr>
		  <td colspan="2" class="thinborderNONE" style="font-weight:bold; font-size:18px;" align="right">Status: <%=strStudStatus%></td>
		</tr>
		<tr >
		  <td width="14%" height="20" class="thinborderNONE">Name: </td>
		  <td width="86%">
	<%
	strTemp = null;
	if(vRetResult != null && vRetResult.size() > 0) {
		if(bolIsUserCreated)
			strTemp = (String)vRetResult.elementAt(6);
		else	
			strTemp = (String)vRetResult.elementAt(0);
	}
	%>	  
		  <input name="payer_name" type="text" size="64" value="<%=WI.getStrValue(strTemp)%>" class="textbox" maxlength="64"
		  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes">	  </td>
		</tr>
		<tr >
		  <td height="20" class="thinborderNONE">Email ID: </td>
		  <td>
	<%
	strTemp = null;
	if(vRetResult != null && vRetResult.size() > 0)
			strTemp = (String)vRetResult.elementAt(1);
	%>	  
		  <input name="payer_email_id" type="text" size="32" value="<%=WI.getStrValue(strTemp)%>" class="textbox" maxlength="64"
		  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes"></td>
		</tr>
		<tr >
		  <td height="20" class="thinborderNONE">Password: </td>
		  <td>
	<%
	strTemp = null;
	if(vRetResult != null && vRetResult.size() > 0)
			strTemp = (String)vRetResult.elementAt(2);
	%>	  
		  <input name="payer_password" type="password" size="32" value="<%=WI.getStrValue(strTemp)%>" class="textbox" maxlength="32"
		  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes">
			<font size="1">(minimum 6 characters)</font></td>
		</tr>
		<tr >
		  <td height="20" class="thinborderNONE">Retype Password: </td>
		  <td>
		  <input name="retype_password" type="password" size="32" value="<%=WI.getStrValue(strTemp)%>" class="textbox" maxlength="32"
		  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes"></td>
		</tr>
		<tr >
		  <td height="20" class="thinborderNONE">DOB: </td>
		  <td>
	<%
	strTemp = null;
	if(vRetResult != null && vRetResult.size() > 0)
			strTemp = (String)vRetResult.elementAt(3);
	%>	  
			<input name="payer_dob" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
		  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
		   <!--
			<a href="javascript:show_calendar('form_.payer_dob');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../images/calendar_new.gif" border="0"></a>
			-->
			</td>
		</tr>
		<tr >
		  <td height="20" class="thinborderNONE">Mobile Number : </td>
		  <td>
	<%
	strTemp = null;
	if(vRetResult != null && vRetResult.size() > 0)
			strTemp = (String)vRetResult.elementAt(4);
	%>	  
		  <input name="payer_phone" type="text" size="12" value="<%=WI.getStrValue(strTemp)%>" class="textbox" maxlength="11"
		  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes"></td>
		</tr>
		<tr >
		  <td height="20" class="thinborderNONE" valign="top"><br>Address: </td>
		  <td>
	<%
	strTemp = null;
	if(vRetResult != null && vRetResult.size() > 0)
			strTemp = (String)vRetResult.elementAt(5);
	%>	  
		  <textarea name="payer_address" rows="4" cols="60" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes"><%=WI.getStrValue(strTemp)%></textarea>	  </td>
		</tr>
		<tr >
		  <td height="20" class="thinborderNONE">Payer Type: </td>
		  <td>
		  <select name="payer_type" style="font-family:Verdana, Arial, Helvetica, sans-serif; font-size:11px;">
			<!--<option value="PARENT">PARENT</option>-->
	<%
	strTemp = WI.fillTextValue("payer_type");
	if(strTemp.equals("STUDENT"))
		strTemp = " selected";
	else	
		strTemp = "";
	%>		
			<option value="STUDENT"<%=strTemp%>>STUDENT</option>
		  </select>	  </td>
		</tr>
	<!--
		<tr >
		  <td height="20" colspan="2" class="thinborderNONE" style="font-size:14px;"><strong>NOTE: If you are having difficulty in registration, Please proceed to Student Accounting Office. </strong></td>
		</tr>
	-->
		<tr >
		  <td height="20" class="thinborderNONE">&nbsp;</td>
		  <td>&nbsp;</td>
		</tr>
		<tr >
		  <td height="20" class="thinborderNONE">&nbsp;</td>
		  <td>
	<%if(bolIsUserCreated) {%>
			<input type="button" name="12" value=" <%if(strStudStatus.equals("Active")){%>In-activate Student<%}else{%>Activate Student<%}%> >>> " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="UpdateStatus();" id="_submit">	  
	<%}else{%>
			<input type="button" name="12" value=" Create Profile >>> " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="Register();" id="_submit">	  
	<%}%>
			</td>
		</tr>
	  </table>
<%}//only if vRetResult is not null%>

<input type="hidden" name="create_">  
<input type="hidden" name="old_stud_id" value="<%=WI.fillTextValue("stud_id")%>">  
</form>	
</body>
</html>
<%
dbOP.cleanUP();
%>