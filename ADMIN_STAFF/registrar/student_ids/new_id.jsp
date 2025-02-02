<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function AddRecord() {
	document.new_id.addRecord.value = "1";
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.RegAssignID,enrollment.FAPaymentUtil,java.util.Vector"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	String strPermStudID = null;
	boolean bolConfirmEnrollment = false;
	Vector vStudInfo = null;
//add security here.
	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-STUDENT IDs - New","new_id.jsp");
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
int iAccessLevel = 2;//comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
						//								"Registrar Management","STUDENT IDs",request.getRemoteAddr(),
							//							"new_id.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
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

if(strErrMsg == null)
{
	strTemp = WI.fillTextValue("addRecord");
	if(strTemp != null && strTemp.compareTo("1") ==0)
	{
		bolConfirmEnrollment = true;
		RegAssignID regAssignID = new RegAssignID();

		strPermStudID = regAssignID.confirmTempStudEnrollment(dbOP, request.getParameter("stud_id"),(String)request.getSession(false).getAttribute("userId"));
		if(strPermStudID == null)
			strErrMsg = regAssignID.getErrMsg();
		else //get here student information
		{//System.out.println(strPermStudID);
			FAPaymentUtil paymentUtil = new FAPaymentUtil();
			vStudInfo = paymentUtil.getStudBasicInfoOLD(dbOP, strPermStudID);
			if(vStudInfo == null)
			{
				strErrMsg = "Student is enrolled successfully. But Error in getting enrollment information. <br> Description : "+
					paymentUtil.getErrMsg();
			}
		}
	}
}
dbOP.cleanUP();
if(strErrMsg == null) strErrMsg = "";
String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester","4th Semester"};
%>

<form name="new_id" action="./new_id.jsp" method="post">
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF"><strong>::::
          NEW IDs PAGE ::::</strong></font></div></td>
    </tr>
    <tr>
      <td width="4%" height="25" >&nbsp;</td>
	  <td height="25" colspan="3" ><font size="3"><strong><%=strErrMsg%></strong></font></td>
    </tr>
<%
if(!bolConfirmEnrollment){%>    <tr>
      <td width="4%" height="25" >&nbsp;</td>
      <td width="15%" height="25" >Temporary ID </td>
      <td width="25%" > <input type="text" name="stud_id" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      </td>
      <td width="56%" >&nbsp; <input type="image" src="../../../images/form_proceed.gif" onClick="AddRecord();">
        <font size="1">click to proceed to assign permanent student ID</font>
      </td>
    </tr>
    <tr>
      <td colspan="4" height="25" ><hr size="1"></td>
    </tr>
<%}else if(vStudInfo != null && vStudInfo.size() > 0){%>
    <tr>
      <td height="25" >&nbsp;</td>
      <td colspan="3" height="25" >Student name : <strong><%=(String)vStudInfo.elementAt(1)%></strong></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td colspan="3" height="25" >Course /Major: <strong><%=(String)vStudInfo.elementAt(2)%>
	  <%
	  if(vStudInfo.elementAt(3) != null){%>
	  / <%=WI.getStrValue(vStudInfo.elementAt(3))%>
	  <%}%>
	  </strong></td>
    </tr>
    <tr>
      <td height="26" >&nbsp;</td>
      <td height="26" colspan="2" >Year : <strong><%=WI.getStrValue(vStudInfo.elementAt(4),"N/A")%></strong></td>
      <td height="26" >&nbsp;</td>
    </tr>
    <tr>
      <td height="26" >&nbsp;</td>
      <td height="26" colspan="2" >Term : <strong><%=astrConvertSem[Integer.parseInt((String)vStudInfo.elementAt(5))]%></strong></td>
      <td height="26" >&nbsp;</td>
    </tr>
    <tr>
      <td colspan="4" height="25" ><hr size="1"></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td  colspan="3" height="25" >Permanent Student ID :<strong> <u><%=strPermStudID%></u></strong></td>
    </tr>
<%}%>
  </table>

  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td colspan="8" height="25" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="8" height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="addRecord" value="0">
  </form>
</body>
</html>
