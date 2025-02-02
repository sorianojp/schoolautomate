<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

-->
</style>
</head>
<script language="JavaScript">
function PrintPg()
{
	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	if(vProceed)
	{
		var pgLoc = "./reservation_print.jsp?stud_id="+escape(document.res_print.stud_id.value);
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=500,scrollbars=yes,top=10,left=10,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
}
</script>

<%@ page language="java" import="utility.*,enrollment.FAPaymentUtil,enrollment.Authentication,enrollment.HostelManagement,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
%>
<body>
<%
	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
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

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/Hostel Management-OCCUPANCY MAINTENANCE- Reservation","reservation_print.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_add.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
Vector vBasicInfo = null;
Vector vReservationInfo = null;
boolean bolIsStaff = false; //true only if the payee type is internal and not a student type.

FAPaymentUtil paymentUtil = new FAPaymentUtil();
HostelManagement HM = new HostelManagement();

if(WI.fillTextValue("stud_id").length() > 0 && bolProceed)
{
	vBasicInfo = paymentUtil.getStudBasicInfo(dbOP, request.getParameter("stud_id"));
	if(vBasicInfo == null) //may be it is the teacher/staff
	{
		strErrMsg = paymentUtil.getErrMsg();
		bolIsStaff = true;
		request.setAttribute("emp_id",request.getParameter("stud_id"));
		vBasicInfo = new Authentication().operateOnBasicInfo(dbOP, request,"0");
	}
	//check if the applicant is having reservation already, if so - take directly to the print page,
	if(vBasicInfo != null && vBasicInfo.size() > 0)
	{
		vReservationInfo = HM.viewReservationInfo(dbOP, (String)vBasicInfo.elementAt(0));
		if(vReservationInfo == null)
		{
			strErrMsg = HM.getErrMsg();
		}
	}
}

//dbOP.cleanUP();
%>

<form name="res_print">
<%
if(vReservationInfo == null || vReservationInfo.size() ==0)
   dbOP.cleanUP();
if(vReservationInfo != null && vReservationInfo.size() > 0){%>

  <table  width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="100%" height="25" colspan="4"><div align="center"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,true)%><br>
          <br>
          DORMITORY / APARTMENT OCCUPANCY RESERVATION SLIP<br>
          <br>
        </div></td>
    </tr>
    <tr>
      <td height="25" colspan="4"><hr size="1"></td>
    </tr>
  </table>
  <table   width="100%" border="0" cellspacing="0" cellpadding="0">
  <%
  if(WI.fillTextValue("msg").length() > 0){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25"><strong><font size="2"><%=WI.fillTextValue("msg")%></font></strong></td>
    </tr>
<%}%>
	<tr>
      <td height="25">&nbsp;</td>
      <td height="25"><div align="right">Reservation Date:<strong><%=(String)vReservationInfo.elementAt(9)%></strong>
          , Date/time printed: <strong><%=WI.getTodaysDateTime()%></strong></div></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>ID Number : <%=request.getParameter("stud_id")%></td>
    </tr>
    <tr>
      <td  width="2%"height="25">&nbsp;</td>
      <td width="98%">Account type :<strong>
	  	  <%
	  if(bolIsStaff){%>
        Employee
        <%}else{%>
        Student
        <%}%>

</strong></td>
    </tr>
  </table>
<%if(!bolIsStaff && vBasicInfo != null && vBasicInfo.size()> 0){%>
  <table   width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25">&nbsp;</td>
      <td width="43%">Account name : <strong><%=(String)vBasicInfo.elementAt(1)%></strong></td>
      <td width="55%">Year/Term :<strong><%=(String)vBasicInfo.elementAt(4)%>/
        <%=astrConvertTerm[Integer.parseInt((String)vBasicInfo.elementAt(5))]%></strong></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="2">Course/Major :<strong> <%=(String)vBasicInfo.elementAt(2)%>
        <%
	  if(vBasicInfo.elementAt(3) != null){%>
        /<%=WI.getStrValue(vBasicInfo.elementAt(3))%>
        <%}%>
        </strong></td>
    </tr>
  </table>
<%}else if( vBasicInfo != null && vBasicInfo.size()> 0){%>
  <table   width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="24">&nbsp;</td>
      <td width="43%">Account name : <strong><%=WI.formatName((String)vBasicInfo.elementAt(1),(String)vBasicInfo.elementAt(2),(String)vBasicInfo.elementAt(3),1)%></strong></td>
      <td width="55%">Employee status : <strong><%=(String)vBasicInfo.elementAt(16)%></strong></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td>Employee type :<strong> <%=(String)vBasicInfo.elementAt(15)%></strong></td>
      <td>College/Department/Office : <strong><%=WI.getStrValue(vBasicInfo.elementAt(13))%>/<%=(String)vBasicInfo.elementAt(14)%></strong></td>
    </tr>
  </table>
<%}%>
<table  width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td><hr size="1"></td>
  </tr>
</table>
  <table   width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="4"><strong>Particulars :</strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="2%">&nbsp;</td>
      <td width="38%">Location/Name :<strong><%=(String)vReservationInfo.elementAt(3)%></strong></td>
      <td width="36%">Room/House No. : <strong><%=(String)vReservationInfo.elementAt(5)%></strong></td>
      <td width="22%">Rental : Php <strong><%=(String)vReservationInfo.elementAt(6)%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Min amount to deposit : <strong>Php <%=(String)vReservationInfo.elementAt(7)%></strong>
      </td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="4">Start Date of Occupancy :<strong> <%=(String)vReservationInfo.elementAt(10)%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
<%
if(WI.fillTextValue("view").compareTo("1") ==0){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="4">
	  <a href="reservation.jsp"><img src="../../../images/go_back.gif" width="50" height="27" border="0"></a>click
          to go previous page&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          <a href="javascript:PrintPg();"><img src="../../../images/print.gif" width="58" height="26" border="0"></a>click
          to print slip
		  </td>
    </tr>
<%}%>
  </table>

 <%if(WI.fillTextValue("view").compareTo("1") !=0){%>
 <script language="JavaScript">
window.print();
window.setInterval("javascript:window.close();",0);
 </script>
 <%}//if print is called.
 }//most outer loop - -if no error%>

<input type="hidden" name="user_index" value="<%=WI.fillTextValue("user_index")%>">
<input type="hidden" name="stud_id" value="<%=WI.fillTextValue("stud_id")%>">
</form>
</body>
</html>
