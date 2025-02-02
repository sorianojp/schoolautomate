<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../jscript/common.js" type="text/javascript"></script>
<script language="JavaScript">
function OpenSearch()
{
	var pgLoc = "../../search/srch_stud_temp.jsp?opner_info=offlineRegd.temp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
	document.offlineRegd.proceedClicked.value = "1";
}
function ProceedClicked()
{
	document.offlineRegd.proceedClicked.value = "1";
	document.offlineRegd.editRecord.value = "";	
	this.SubmitOnce('offlineRegd');
}

function EditRecord()
{
	document.offlineRegd.editRecord.value = "1";
	document.offlineRegd.proceedClicked.value = "1";	
	this.SubmitOnce("offlineRegd");
}
function ClearEntry()
{
	location = "./admission_registration_new_edit.jsp?stud_status=New";
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.OfflineAdmission,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	OfflineAdmission offlineAdm = new OfflineAdmission();
	Vector vRetResult = new Vector();
	String strErrMsg = null;
	String strTemp = null;	
	boolean bolClearEntry = false;		

	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Admission-Registration","admission_registration.jsp");
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
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Admission","Registration",request.getRemoteAddr(),
														"admission_registration.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
vRetResult = null;
String strReadOnly = "";

if(WI.fillTextValue("editRecord").equals("1")){
	strTemp = offlineAdm.createCPUApplicant(dbOP,request,false,2);
	if(strTemp == null)
		strErrMsg = offlineAdm.getErrMsg();		
	else
		strErrMsg = "Applicant info edited successfully.";			
}
		
if(WI.fillTextValue("proceedClicked").equals("1")){
	if (WI.fillTextValue("temp_id").length() ==0){ 
		strErrMsg = " &nbsp; Please enter temporary ID";
	}else{
		vRetResult = offlineAdm.createAdmissionSlipReqNew(dbOP,request,
													WI.fillTextValue("temp_id"));
		if(vRetResult == null)
			strErrMsg = offlineAdm.getErrMsg();	
	}
}
%>
<form action="./admission_registration_new_edit.jsp" method="post" name="offlineRegd">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" colspan="3" align="center" bgcolor="#A49A6A"><font color="#FFFFFF" ><strong>:::: 
        EDIT APPLICANT PAGE ::::</strong></font></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="18" colspan="5"><font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td width="16%">Temporary ID </td>
      <td width= "18%"> <input name="temp_id" type="text" class="textbox" value="<%=WI.fillTextValue("temp_id")%>" size="16" maxlength="16"
         onfocus="style.backgroundColor='#D3EBFF'" onblur='style.backgroundColor="white"'> 
      </td>
      <td width = 8%><a href="javascript:OpenSearch();"><img src="../../images/search.gif" border="0"></a></td>
      <td width="58%"><a href="javascript:ProceedClicked();"><img src="../../images/form_proceed.gif" border="0"></a></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="2" height="25">&nbsp;</td>
    </tr>
    <%if(vRetResult != null){%>
    <tr> 
      <td colspan="2" height="25"><hr size="1"></td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td height="25" valign="bottom">Gender 
        <select name="gender">
          <option value="M">Male</option>
          <%
		  	if(vRetResult != null)
		    	strTemp = (String)vRetResult.elementAt(7);
			else
				strTemp = WI.fillTextValue("gender"); 
			if(strTemp.compareTo("F") == 0)
			{%>
          <option value="F" selected>Female</option>
          <%}else{%>
          <option value="F">Female</option>
          <%}%>
        </select></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="15" colspan="3"><hr size="1"></td>
    </tr>
<% if (!strSchCode.startsWith("CGH")) {%> 
    <tr>
      <td width="16%" height="25">&nbsp;&nbsp;HS Student ID </td>
<% 	if(vRetResult != null){
	 	strTemp = WI.getStrValue((String)vRetResult.elementAt(9));
		if (strTemp != null && strTemp.length() > 0) 
			strReadOnly = " readonly";
	}else
		strTemp = WI.fillTextValue("old_stud_id");
%>
      <td width="16%" height="25"><input name="old_stud_id" type="text" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="16"></td>
      <td width="68%"><font size="1"><a href="javascript:OpenSearch()"><img src="../../images/search.gif" width="37" height="30" border=0></a>encode only this ID if student is a HS Graduate of this University</font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>	
<%} // end if not CGH.. undergrad not applicable%> 
  </table>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="34%" height="25" valign="bottom">Last Name </td>
      <td width="34%" valign="bottom"> First Name </td>
      <td width="30%" height="25" valign="bottom"> Middle Name </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">
	  
	  <%
	  	if(vRetResult != null)
			strTemp = (String)vRetResult.elementAt(5);
		else{
			if(bolClearEntry)
				strTemp = "";
			else
				strTemp = WI.fillTextValue("lname");
		}	  	
		%>			
	  <input name="lname" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  <%=strReadOnly%>> 
      </td>
      <td>
	   <%
	  	if(vRetResult != null)
			strTemp = (String)vRetResult.elementAt(3);
		else{
			if(bolClearEntry)
				strTemp = "";
			else 
				strTemp = WI.fillTextValue("fname");
		 }%> 
	   <input name="fname" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  <%=strReadOnly%>>  
      </td>
      <td height="25"> 
	  <% 	
	  if(vRetResult != null)
	  	strTemp = (String)vRetResult.elementAt(4);
	  else{
	  	if(bolClearEntry) 
			strTemp = "";
	    else 
			strTemp = WI.fillTextValue("mname");
	  }%>			
	<input name="mname" type="text" size="20" value="<%=WI.getStrValue(strTemp)%>" 
 	  class="textbox" <%=strReadOnly%> 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      </td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="7">&nbsp;</td>
      <td width="26%" height="25"> <font size="1" ><a href="javascript:EditRecord();"><img src="../../images/edit.gif" width="40" height="26" border="0"></a> click 
        to edit info</font></td>
      <td width="53%" height="25"><a href="javascript:ClearEntry();"><img src="../../images/cancel.gif" border="0"></a> 
        <font size="1" >click to clear entries</font></td>
    </tr>
    <tr> 
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <%}%>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
 <%
	if(vRetResult != null){
		strTemp = (String)vRetResult.elementAt(8);
	} 
 %>
<input type="hidden" name="editRecord" value="0">
<input type="hidden" name="proceedClicked" value="">
<input type="hidden" name="applIndex" value="<%=strTemp%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>