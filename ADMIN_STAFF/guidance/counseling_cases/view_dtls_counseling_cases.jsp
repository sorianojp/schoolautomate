<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script>
function ReloadPage()
{
	this.SubmitOnce('form_');
}
</script>
<%@ page language="java" import="utility.*, osaGuidance.GDCounseling, java.util.Vector " buffer="16kb"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	Vector vRetResult = null;
	Vector vBasicInfo = null;
	Vector vProblems = null;
	Vector vReferral = null;

	String strInfoIndex = null;
	String strErrMsg = null;
	String strTemp = null;
	String[] astrSemester = {"Summer", "1st Semester", "2nd Semester", "3rd Semester"};

		
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Guidance & Counseling-Counseling Cases","view_dtls_counseling_cases.jsp");
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
														"Guidance & Counseling","Counseling Cases",request.getRemoteAddr(),
														"view_dtls_counseling_cases.jsp");
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
enrollment.OfflineAdmission OAdm = new enrollment.OfflineAdmission();
GDCounseling GDCounsel = new GDCounseling();
	vBasicInfo = OAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"));
	vRetResult = GDCounsel.operateOnCounselingCase(dbOP, request, 3);
	vProblems = GDCounsel.operateOnProblems(dbOP, request, 4);
	vReferral = GDCounsel.operateOnRefReason(dbOP, request, 4);
	
%>
<body bgcolor="#663300">
<form action="./view_dtls_counseling_cases.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          GUIDANCE &amp; COUNSELING: COUNSELING CASES ENTRY PAGE ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="2">
   <tr>
   	<td width="5%">&nbsp;</td>
    <td width="30%">&nbsp;</td>
   	<td width="15%">&nbsp;</td>
   	<td width="50%">&nbsp;</td>
   </tr>
    <tr> 
      <%strTemp =(String)vBasicInfo.elementAt(19);%>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Student Name :<strong><%=WebInterface.formatName((String)vBasicInfo.elementAt(0),
	  (String)vBasicInfo.elementAt(1),(String)vBasicInfo.elementAt(2),4)%></strong></td>
      <td height="25">Gender : <strong><%=WI.getStrValue((String)vBasicInfo.elementAt(16),"Not defined")%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Brithdate : <strong><%=WI.getStrValue(strTemp, "Undefined")%></strong></td>
      <td height="25">Age :<strong><%if (strTemp !=null && strTemp.length()>0){%><%=CommonUtil.calculateAGEDatePicker(strTemp)%><%}else{%>Undefined<%}%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">Course/Major : <strong><%=(String)vBasicInfo.elementAt(7)%> <%=WI.getStrValue((String)vBasicInfo.elementAt(8),"/","","")%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">Year Level : <strong><%=WI.getStrValue((String)vBasicInfo.elementAt(14),"N/A")%></strong></td>
    </tr>
    <tr> 
      <td height="25" colspan="4"><hr size="1"></td>
    </tr>
     <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">School Year/Term : <strong><%=(String)vRetResult.elementAt(1)%>&nbsp;-&nbsp;<%=(String)vRetResult.elementAt(2)%>&nbsp;<%=astrSemester[Integer.parseInt((String)vRetResult.elementAt(3))]%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Referred by : <strong><%=WI.formatName((String)vRetResult.elementAt(6), (String)vRetResult.elementAt(7), (String)vRetResult.elementAt(8),7)%></strong></td>
      <td height="25">Counseling Date: <strong><%=(String)vRetResult.elementAt(13)%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Counseled by : <strong><%=WI.formatName((String)vRetResult.elementAt(10), (String)vRetResult.elementAt(11), (String)vRetResult.elementAt(12),7)%></strong></td>
      <td height="25">&nbsp;</td>
    </tr>
      <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">Follow Up : <strong><%=(String)vRetResult.elementAt(14)%></strong></td>
    </tr>
    <tr> 
      <td height="25" colspan="4"><hr size="1"></td>
    </tr>
    <%if (vProblems!=null && vProblems.size()>0){%>
	<tr>
	<td height="25">&nbsp;</td>
	<td><u>Problems :</u></td>
	<td colspan="2"><strong><%for (int i = 0; i<vProblems.size(); i+=2){%><%if (i!=0){%>,&nbsp;<%}%><%=(String)vProblems.elementAt(i)%><%}%></strong></td>
	</tr>
	<%}
	if (vReferral!=null && vReferral.size()>0){%>
	<tr>
	<td height="25">&nbsp;</td>
	<td><u>Reasons for Referral : </u></td>
	<td colspan="2"><strong><%for (int i = 0; i<vReferral.size(); i+=2){%><%if (i!=0){%>,&nbsp;<%}%><%=(String)vReferral.elementAt(i)%><%}%></strong></td>
	</tr>
	<%}%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"><u>Background of the Study:</u></td>
      <td colspan="2"><strong><%=(String)vRetResult.elementAt(15)%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"><u>Present Condition:</u></td>
      <td colspan="2"><strong><%=(String)vRetResult.elementAt(16)%></strong></td>
    </tr>
     <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"><u>Difficulties:</u></td>
      <td colspan="2"><strong><%=(String)vRetResult.elementAt(17)%></strong></td>
    </tr>
     <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"><u>Conclusions and Recommendations:</u></td>
      <td colspan="2"><strong><%=(String)vRetResult.elementAt(18)%></strong></td>
    </tr>
       <tr> 
      <td height="25" colspan="4">&nbsp;</td>
   </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td height="30" colspan="3" valign="bottom"><div align="center"> <a href="javascript:window.print();" ><img src="../../../images/print.gif" border="0" ></a> 
          <font size="1">click to print this report</font></div></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="14"  colspan="3" bgcolor="#FFFFFF"><div align="center"> </div></td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input name = "stud_id" type = "hidden"  value="<%=WI.fillTextValue("stud_id")%>">
  <input type="hidden" name="counsel_res_index" value="<%=WI.fillTextValue("psyc_res_index")%>">
  <input name = "info_index" type = "hidden"  value="<%=WI.fillTextValue("info_index")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
