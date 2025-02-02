<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Occupant's Details</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>

<body >
<%@ page language="java" import="utility.*,enrollment.FAPaymentUtil,enrollment.FAPayment,enrollment.Authentication,enrollment.HostelManagement,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	WebInterface WI = new WebInterface(request);
	MessageConstant mConst = new MessageConstant();

	String strErrMsg = null;
	String strTemp = null;String strTemp2 = null;
	String strCurSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
	String strCurSYTo   = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
	boolean bolProceed = true;
	String[] astrConvertTerm = {"Summer","1st Sem","2nd Sem","3rd Sem"};

	if(strCurSYFrom == null || strCurSYTo == null)
	{
		bolProceed = false;
		strErrMsg = "You are logged out. Please login again.";
	}

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/Hostel Management-OCCUPANCY MAINTENANCE- View occupant detail","view_occ.jsp");
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
														"Hostel Management","OCCUPANCY MAINTENANCE",request.getRemoteAddr(),
														"view_occ.jsp");
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

Vector vBasicInfo = null;
Vector vAccountInfo = null;
Vector vReservationInfo = null;
boolean bolIsStaff = false; //true only if the payee type is internal and not a student type.

FAPaymentUtil paymentUtil = new FAPaymentUtil();
FAPayment faPayment = new FAPayment();
HostelManagement HM = new HostelManagement();

if(WI.fillTextValue("stud_id").length() > 0)
{
	vBasicInfo = paymentUtil.getStudBasicInfo(dbOP, request.getParameter("stud_id"));
	if(vBasicInfo == null) //may be it is the teacher/staff
	{
		strErrMsg = paymentUtil.getErrMsg();
		bolIsStaff = true;
		request.setAttribute("emp_id",request.getParameter("stud_id"));
		vBasicInfo = new Authentication().operateOnBasicInfo(dbOP, request,"0");
	}
	//get account detail.
	if(vBasicInfo != null && vBasicInfo.size() > 0)
	{
		vAccountInfo = HM.viewHostelAccountInfo(dbOP,request.getParameter("stud_id"));
		if(vAccountInfo == null)
		{
			strErrMsg = HM.getErrMsg();
			bolProceed = false;
		}
	}
}
if(vBasicInfo == null || vBasicInfo.size() ==0)
{
	bolProceed = false;
	if(strErrMsg == null)
		strErrMsg = "Occupant information not found.";
}
dbOP.cleanUP();
if(strErrMsg == null) strErrMsg = "";
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6" bgcolor="#D5D0BB"><div align="center"><font color="#FFFFFF"><strong><font color="#333333">::::
        OCCUPANCY MAINTENANCE - OCCUPANT'S DETAILS PAGE ::::</font><br>
        </strong></font></div></td>
    </tr>
	</table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>

    <td width="100%" height="25"> &nbsp;&nbsp;&nbsp; <strong><%=strErrMsg%></strong></td>
    </tr>
  </table>
<%
if(!bolProceed)
	return;
%>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td  width="4%"height="25">&nbsp;</td>
      <td width="50%">ID Number : <strong><%=request.getParameter("stud_id")%></strong></td>

    <td width="46%">Account category :<strong>
      <%
	  if(bolIsStaff){%>
      Employee
      <%}else{%>
      Student
      <%}%>
      </strong></td>
    </tr>
  </table>
<%
if(!bolIsStaff){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25">&nbsp;</td>

    <td width="50%">Account name : <strong><%=(String)vBasicInfo.elementAt(1)%></strong></td>

    <td width="46%">School year : <strong><%=strCurSYFrom%> - <%=strCurSYTo%></strong></td>
    </tr>
    <tr>
      <td width="4%" height="25">&nbsp;</td>

    <td colspan="2">Course/Major :<strong> <%=(String)vBasicInfo.elementAt(2)%>
      <%
	  if(vBasicInfo.elementAt(3) != null){%>
      /<%=WI.getStrValue(vBasicInfo.elementAt(3))%>
      <%}%>
      </strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>

    <td height="25">Year/Term : <strong><%=(String)vBasicInfo.elementAt(4)%>/
      <%=astrConvertTerm[Integer.parseInt((String)vBasicInfo.elementAt(5))]%></strong></td>
      <td height="25">&nbsp;</td>
    </tr>
  </table>
<%}else{%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25">&nbsp;</td>

    <td>Account name : <strong><%=WI.formatName((String)vBasicInfo.elementAt(1),(String)vBasicInfo.elementAt(2),(String)vBasicInfo.elementAt(3),1)%></strong></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td width="4%" height="25">&nbsp;</td>

    <td width="96%" colspan="2">Employee type :<strong> <%=(String)vBasicInfo.elementAt(15)%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>

    <td height="25" colspan="2">Employee status : <strong><%=(String)vBasicInfo.elementAt(16)%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>

    <td height="25" colspan="2">College/Department/Office : <strong><%=WI.getStrValue(vBasicInfo.elementAt(13))%>/<%=(String)vBasicInfo.elementAt(14)%></strong></td>
    </tr>
</table>
<%}
if(vAccountInfo != null && vAccountInfo.size() > 0){
%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="2"><hr size="1"></td>
    </tr>
  </table>


  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25">&nbsp;</td>

    <td>School Facility name : <strong> <%=(String)vAccountInfo.elementAt(10)%></strong></td>
    </tr>
    <tr>
      <td width="4%" height="25">&nbsp;</td>

    <td width="96%">Particular (Location/Room or Door #/Rent) : <strong><%=(String)vAccountInfo.elementAt(2)%></strong>/<strong><%=(String)vAccountInfo.elementAt(4)%></strong>/<strong><%=(String)vAccountInfo.elementAt(5)%></strong><strong>
      </strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>

    <td height="25">Deposit : <strong><%=(String)vAccountInfo.elementAt(6)%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>

    <td height="25">O.R. No. :<strong> <%=(String)vAccountInfo.elementAt(7)%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>

    <td height="25">Date paid : <strong><%=(String)vAccountInfo.elementAt(8)%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>

    <td height="25">Start date of Occupancy : <strong><%=(String)vAccountInfo.elementAt(9)%></strong></td>
    </tr>
  </table>
<%}//only if vAccountInfo is not null
%>
</body>
</html>
