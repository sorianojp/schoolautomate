<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
table{
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
 }

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
 }

    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
    }
-->
</style>
</head>

<body>
<%@ page language="java" import="utility.*,enrollment.FAPaymentUtil,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;

	float fUnitPrice = 0f;
	float fNoOfUnit = 0f;
	float fTotalCharge = 0f;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-Post Charges","post_charges_variable.jsp");
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
														"Fee Assessment & Payments","Post Charges",request.getRemoteAddr(),
														"post_charges_variable.jsp");
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

Vector vStudInfo = null;
Vector vRetResult = null;
Vector vSecList   = new Vector();

FAPaymentUtil paymentUtil = new FAPaymentUtil();
enrollment.FAFeePost feePost  = new enrollment.FAFeePost();

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	if(feePost.operateOnPostingCharge(dbOP, request,Integer.parseInt(strTemp)) == null)
		strErrMsg = feePost.getErrMsg();
	else	
		strErrMsg = "Operation successful.";
}
if(WI.fillTextValue("stud_id").length() > 0)//only if student id is entered.
{
	vStudInfo = paymentUtil.getStudBasicInfo(dbOP, WI.fillTextValue("stud_id"));
	if(vStudInfo == null) 
		strErrMsg = paymentUtil.getErrMsg();
}
//get the sections available for a subject.
if(WI.fillTextValue("sub_index").length() > 0){
	enrollment.ReportEnrollment reportEnrl= new enrollment.ReportEnrollment();
	vSecList = reportEnrl.getSubSecList(dbOP,request.getParameter("sy_from"),
						request.getParameter("sy_to"),request.getParameter("semester"),
						request.getParameter("sub_index"), null);
}

vRetResult = feePost.operateOnPostingCharge(dbOP, request,3);
if (vRetResult == null){
	strErrMsg = feePost.getErrMsg();
}
String[] astrConvertTerm = {"Summer","1st Sem","2nd Sem","3rd Sem"};
%>
<form name="form_" action="./post_charges_variable.jsp" method="post">
<% if(vRetResult != null && vRetResult.size() > 0) {%>
    <div align="center"><strong><font size="2"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font> </strong><br>
	<%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
	<%=SchoolInformation.getInfo1(dbOP,false,false)%>
          <br>
        </div>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr> 
      <td height="20" colspan="8" class="thinborder"><div align="center"><strong><font size="2">LIST 
          OF POSTED VARIABLE FEE CHARGES
		<%if(WI.fillTextValue("date_posted_fr").length() > 0) {%>
		  	<br><font size="1">Cut-off Date : <%=WI.fillTextValue("date_posted_fr")%> 
			<%=WI.getStrValue(WI.fillTextValue("date_posted_to")," to ", "", "")%></font>
		  <%}%>  
		  </font></strong></div></td>
    </tr>
      <td height="20" colspan="8" class="thinborder" align="right"><span style="font-size:10px;">Date and time printed : <%=WI.getTodaysDateTime()%></span></td>
    </tr>
    <% if(WI.fillTextValue("specific_stud").length() > 0){%>
    <tr> 
      <td width="15%" align="center" class="thinborder"><strong>STUD ID</strong></td>
      <td width="7%" class="thinborder"><strong>COURSE-YR</strong></td>
      <td width="7%" height="25" class="thinborder"><div align="center"><strong>DATE 
          POSTED</strong></div></td>
      <td width="8%" align="center" class="thinborder"><strong>POSTED BY</strong></td>
      <td width="40%" align="center" class="thinborder"><strong>FEE NAME</strong></td>
      <td width="10%" align="center" class="thinborder"><strong>FEE RATE/ CHARGE</strong></td>
      <td width="7%" align="center" class="thinborder"><strong>NO OF UNIT</strong></td>
      <td width="7%" align="center" class="thinborder"><strong>TOTAL CHARGE</strong></td>
    </tr>
    <%for(int i = 0 ; i < vRetResult.size(); i += 14) {%>
    <tr> 
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 5)%> (<%=(String)vRetResult.elementAt(i + 6)%>)</td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 13)%></td>
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i + 12)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 10)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 2)%></td>
      <td align="center" class="thinborder"><%=(String)vRetResult.elementAt(i + 3)%></td>
      <td align="center" class="thinborder"><%=(String)vRetResult.elementAt(i + 4)%></td>
    </tr>
    <%}//end of for loop.%>
  </table>
<script language="JavaScript">
window.print();
</script>
<%}else {//end of display if charging is per stud.. if(WI.fillTextValue("specific_stud").length() > 0
   %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr>        
      <td width="5%" align="center" class="thinborder"><strong><font size="1">TERM</font></strong></td>
      <td width="15%" align="center" class="thinborder"><strong><font size="1">COURSE/MAJOR</font></strong></td>
      <td width="20%" class="thinborder"><strong><font size="1">SUB CODE/ SUB NAME</font></strong></td>
      <td width="10%" class="thinborder"><strong><font size="1">SECTION</font></strong></td>
      <td width="7%" height="25" class="thinborder"><strong><font size="1">DATE POSTED</font></strong></td>
      <td width="10%" align="center" class="thinborder"><strong><font size="1">POSTED BY</font></strong></td>
      <td width="25%" align="center" class="thinborder"><strong><font size="1">FEE NAME</font></strong></td>
      <td width="7%" align="center" class="thinborder"><font size="1"><strong>FEE RATE/ CHARGE</strong></font></td>
      <td width="7%" align="center" class="thinborder"><font size="1"><strong>NO OF UNIT</strong></font></td>
      <td width="7%" align="center" class="thinborder"><font size="1"><strong>TOTAL CHARGE</strong></font></td>
      <td width="6%" class="thinborder"><div align="center"><font size="1"></font></div></td>
    </tr>
    <%for(int i = 0 ; i < vRetResult.size(); i += 15) {%>
    <tr> 
       <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 14),"ALL")%></td>
     <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 5),"ALL")%>/ <%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"ALL")%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 7),"ALL")%>/ <%=WI.getStrValue((String)vRetResult.elementAt(i + 8),"ALL")%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 9),"ALL")%></td>
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i + 11)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 12)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 2)%></td>
      <td align="center" class="thinborder"><%=(String)vRetResult.elementAt(i + 3)%></td>
      <td align="center" class="thinborder"><%=(String)vRetResult.elementAt(i + 4)%></td>
      <td align="center" class="thinborder"> <%if(iAccessLevel ==2){%> <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'> 
        <img src="../../../images/delete.gif" border="0"></a> <%}%></td>
    </tr>
    <%}//end of for loop.%>
  </table>
<script language="JavaScript">
window.print();
</script>
<%}//end of else.
}//only if vRetResult is not null 
%>


</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
