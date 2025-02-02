<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>
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


    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;	
    }

    TD.thinborder {
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }

-->
</style>
<body>
<%@ page language="java" import="utility.*,enrollment.FAEducPlans,enrollment.EnrlAddDropSubject,enrollment.FAPayment,enrollment.FAFeeOperation,enrollment.FAPmtMaintenance,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;



	WebInterface WI = new WebInterface(request);

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-Fee adjustments","fee_adjustment.jsp");
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
														"Fee Assessment & Payments","PAYMENT",request.getRemoteAddr(),
														"fee_adjustment.jsp");
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
String[] astrConvertYrLevel={"","First", "Second","Third", "Fourth", "Fifth", "Sixth"};
String[] astrConvertToSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};
String[] astrConvertProper={"","Preparatory","Proper"};
String[] astrConvertStatus={"DISAPPROVED","APPROVED","PENDING"};
Vector vRetResult = null;
EnrlAddDropSubject enrlAddDropSub = new EnrlAddDropSubject();
FAEducPlans faEP = new FAEducPlans();
		vRetResult = faEP.operateOnEducPlans(dbOP,request,4);
		
		if (vRetResult == null)
			strErrMsg = faEP.getErrMsg();
%>

<form name="form_" action="./list_of_stud_educ_plans.jsp" method="post"><br>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td width="100%"><div align="center"> 
        <p><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%> </strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%>,<%=SchoolInformation.getAddressLine2(dbOP,false,false)%> <br>
          <%=SchoolInformation.getAddressLine3(dbOP,false,false)%> <br>
          <strong> <%=SchoolInformation.getInfo2(dbOP,false,false)%></strong> <br>
      </div></td>
  </tr>
     <tr> 
    <td  height="24" colspan="2">&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg,"")%></td>
  </tr>
  </table>

   
  <% if (vRetResult != null && vRetResult.size()> 0){ %>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="10" class="thinborder"><div align="center"><font color="#000000"><strong>LIST 
          OF STUDENTS WITH EDUCATIONAL PLANS</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="10" class="thinborder"><b>Total Student(s) :<%=(int)(vRetResult.size()/17)%> </b> <div align="right"></div></td>
    </tr>
    <tr> 
      <td width="11%" height="25" class="thinborder"><div align="center"><strong><font size="1">STUDENT 
          ID </font></strong></div></td>
      <td width="25%" class="thinborder"><div align="center"><strong><font size="1">STUDENT NAME</font></strong></div></td>
      <td width="33%" class="thinborder"><div align="center"><strong><font size="1">COURSE/MAJOR</font></strong></div></td>
      <td width="16%" class="thinborder"><div align="center"><strong>PLAN</strong></div></td>
      <td width="8%" class="thinborder"><div align="center"><strong><font size="1">STATUS</font></strong></div></td>
      <td width="7%" class="thinborder"><div align="center"><strong><font size="1">YEAR</font></strong></div></td>
    </tr>
    <% for (int i= 0; i < vRetResult.size() ; i+=17) {%>
    <tr> 
      <td height="25" class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+16)%></font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+12)%></font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+13)%><%=WI.getStrValue((String)vRetResult.elementAt(i+14),"/","","")%></font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+5)%></font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=astrConvertStatus[Integer.parseInt((String)vRetResult.elementAt(i+9))]%></font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+15)%></font></td>
    </tr>
    <%} //end for loop%>
  </table>
  <%} //end vRetResult !=null%>
<input type="hidden" name="showdetails">
</form>
<script language="JavaScript">
window.print();
</script>
</body>
</html>
