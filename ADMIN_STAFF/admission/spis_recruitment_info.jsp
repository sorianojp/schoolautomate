<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript">
        
		function PageAction(strAction, strinfo)
		{
			document.form_.page_action.value = strAction;
			if(strAction=='3')
			{
			 document.form_.prepareToEdit.value = '1';
			 document.form_.page_action.value = "";
			}

			if(strinfo.length > 0)
				document.form_.info_index.value = strinfo;
			
			document.form_.submit();
		}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.PersonalInfoManagement,
java.util.Vector,java.util.StringTokenizer" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	boolean bolFatalErr = false;
	
     Vector vRetResult = null;
	 Vector vEditInfo = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Admission-Student Info Mgmt","basic_old_stud_mgmt.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
 %>
<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"> Error in opening connection</font></p>
<%
		return;
	}
      //authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),"Admission","Student Info Mgmt",request.getRemoteAddr(), "spis_recruitment_info.jsp");
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
String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	
PersonalInfoManagement pInfoMgmt = new PersonalInfoManagement();

strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0)
	{
		if(pInfoMgmt.getRecruitmentInfo(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = pInfoMgmt.getErrMsg();
		else
		{
			if(strTemp.equals("0"))
				strErrMsg = "Recruitment Info successfully removed.";
			if(strTemp.equals("1"))
				strErrMsg = "Recruitment Info successfully recorded.";
			if(strTemp.equals("2"))
				strErrMsg = "Recruitment Info successfully edited.";
			
			strPrepareToEdit = "0";
		}
		
		
		
	}


  if(strPrepareToEdit.equals("1"))
  {
     vEditInfo = pInfoMgmt.getRecruitmentInfo(dbOP, request,3);
	 if(vEditInfo == null)
		strErrMsg = pInfoMgmt.getErrMsg();
	 

  }
	vRetResult = pInfoMgmt.getRecruitmentInfo(dbOP, request,4);
	if(vRetResult == null)
		strErrMsg = pInfoMgmt.getErrMsg();
	
	

   
%>
<form name="form_" action="./spis_recruitment_info.jsp" method="post">
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="3"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          RECRUITMENT INFO PAGE ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font> </td>
    </tr>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="17%">Recruitment Info :</td>
	  <td>
	  <%
	  strTemp = "";
	  if(vEditInfo != null && vEditInfo.size() > 0)
	  {
		strTemp = (String)vEditInfo.elementAt(1);
	  }
%>
	  <input type="text" name="rec_info" size="64" maxlength="128" 
	  value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="15" colspan="3"><hr size="1"></td>
    </tr>
    
    <tr>
      <td height="40">&nbsp;</td>
      <td colspan="2"><div align="center">
          <%if(strPrepareToEdit.equals("0"))
		  {
		  %>
          <a href="javascript:PageAction('1','');"><img src="../../images/save.gif" border="0"></a> <font size="1">click to save entries </font>
          <%
		  }
		  else
		  {%>
          <a href="javascript:PageAction('2','<%=vEditInfo.elementAt(0)%>');"><img src="../../images/edit.gif" border="0"></a> <font size="1">click to edit entries </font>
          <%
		  }
		  %>
          <a href="./spis_recruitment_info.jsp"><img src="../../images/cancel.gif" border="0"></a> <font size="1">click to cancel/clear entries </font></div></td>
    </tr>
   
  </table>
  <% 
		if(vRetResult != null && vRetResult.size() > 0) {
%>
  <table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="20" colspan="5" bgcolor="#B9B292" class="thinborder"><div align="center"><strong>::: RECRUITMENT INFORMATION LISTING ::: </strong></div></td>
    </tr>
    <tr>
      <td height="25" width="5%" align="center" class="thinborder"><strong>Count</strong></td>
      <td width="75%" class="thinborder"><strong>Recruitment Info</strong><strong></strong></td>
      <td width="20%" class="thinborder" align="center"><strong>Options</strong></td>
    </tr>
	<%
		int iCount = 0;
		for(int i = 0; i < vRetResult.size(); i += 2) {
	%>
		<tr>
		   <td height="25" class="thinborder"><%=++iCount%></td>
		  <td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
		  <td align="center" class="thinborder">
		  <a href="javascript:PageAction('3','<%=(String)vRetResult.elementAt(i)%>');">
		  <img src="../../images/edit.gif" border="0" /></a> &nbsp;&nbsp; 
		  <a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>');">
		  <img src="../../images/delete.gif" border="0" /></a>
		</tr>
      <%}%>
  </table>
     <%}%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="page_action">
  <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
 <input type="hidden" name="info_index" value="">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
