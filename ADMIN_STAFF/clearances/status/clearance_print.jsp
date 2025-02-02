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

.bodystyle {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}
-->
</style>
</head>
<%@ page language="java" import="utility.*, clearance.ClearanceMain, java.util.Vector " buffer="16kb"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	Vector vBasicInfo = null;
	Vector vSignatories = null;
	Vector vRequirements = null;
	boolean bolCleared = true;

	String strErrMsg = null;
	String strTemp = null;
	String strClrName = "";
	String strColor = " color='#000000'";

	//put in session - not using URL/post.	
	HttpSession curSession = request.getSession(false);
	String strStudID = (String)curSession.getAttribute("stud_id");

//add security here.
	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Clearance-CLEARANCE STATUS","clearance_print.jsp");
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
if(strStudID == null)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
enrollment.OfflineAdmission OAdm = new enrollment.OfflineAdmission();
strClrName = (String)curSession.getAttribute("type_index");


ClearanceMain clrMain = new ClearanceMain();
	strClrName = dbOP.mapOneToOther("CLE_TYPE", "CLE_CTYPE_INDEX", strClrName, "CLEARANCE_TYPE", "AND IS_VALID = 1 AND IS_DEL = 0");
	vBasicInfo = OAdm.getStudentBasicInfo(dbOP, strStudID);
if(vBasicInfo != null) {
	vSignatories = clrMain.operateOnPrintingDetails(dbOP, request, 1);
	if (vSignatories == null)
		strErrMsg = clrMain.getErrMsg();
	vRequirements = clrMain.operateOnPrintingDetails(dbOP, request, 2);
	
}
else
{
	strErrMsg = OAdm.getErrMsg();
}
//System.out.println("My Info:"+vBasicInfo);
//System.out.println("My Signatories:"+vSignatories);
//System.out.println("My Dues:"+vRequirements);
%>
<body>
<form name="form_" method="post" action="./clearance_print.jsp">
    <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="100%"><div align="center">
        <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%> </strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%>,<%=SchoolInformation.getAddressLine2(dbOP,false,false)%> <br>
          <%=SchoolInformation.getAddressLine3(dbOP,false,false)%> <br>
          <strong> <%=SchoolInformation.getInfo2(dbOP,false,false)%></strong>
      </div></td>
       </tr>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="2"><div align="center"><strong><%=strClrName%></strong></div></td>
    </tr>
    <tr>
      <td height="18" colspan="2"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
  </table>
	<%if (vBasicInfo != null && vBasicInfo.size()>0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="49%" height="25">Student Name: <strong><%=WebInterface.formatName((String)vBasicInfo.elementAt(0),
	  (String)vBasicInfo.elementAt(1),(String)vBasicInfo.elementAt(2),4)%></strong></td>
      <td width="51%">Student ID : <strong><%=strStudID%></strong></td>
    </tr>
    <tr>
      <td height="25">Course/Major : <strong><%=(String)vBasicInfo.elementAt(7)%> <%=WI.getStrValue((String)vBasicInfo.elementAt(8),"/","","")%></strong></td>
      <td>Year Level : <strong><%=WI.getStrValue((String)vBasicInfo.elementAt(14),"N/A")%></strong></td>
    </tr>
    <tr>
      <td height="25">Degree :</td>
      <td>Year / Term Graduated :</td>
    </tr>
<%if(false){%>
    <tr>
      <td height="27" colspan="2"><strong><font size="1">&lt;note: show Degree
        and year/term graduated if printing Diploma Clearance for UI&gt;</font></strong></td>
    </tr>
<%}%>
    <tr>
      <td height="46" colspan="2"><strong>CLEARANCE STATUS :
      <%if (vRequirements!=null && ((String)vRequirements.elementAt(0)).compareTo("true")==0){%>
      CLEARED<%}else{%>NOT CLEARED<%}
      vRequirements.removeElementAt(0);
      %>
        </strong></td>
    </tr>
  </table>
  <%}%>
  <%if (vSignatories!=null){%>
  <table width="100%" border="1" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr bgcolor="#DFE6EC">
      <td height="25" colspan="3"><div align="center"><strong><font color="#000000" ><strong>SIGNATORIES
          REQUIRED FOR THE <%=strClrName%></strong></font></strong></div></td>
    </tr>
    <tr>
      <td width="30%" height="25"><div align="center"><font size="1"><strong>SIGNATORIES</strong></font></div></td>
      <td width="35%" height="25"><div align="center"><font size="1"><strong>REQUIREMENT</strong></font></div></td>
      <td width="35%"><div align="center"><font size="1"><strong>STATUS</strong></font></div></td>
    </tr>
    <%for (int i = 0; i<vSignatories.size(); i+=3){
    bolCleared = true;%>
    <tr>
      <td height="25"><font size="1"><%=(String)vSignatories.elementAt(i+1)%>&nbsp;-&nbsp;<%=WI.getStrValue((String)vSignatories.elementAt(i+2),"&nbsp;")%></font></td>
      <td height="25"><font size="1">
      <%if (vRequirements.size()>0){
      while (((String)vRequirements.elementAt(0)).compareTo((String)vSignatories.elementAt(i))==0){
      if (((String)vRequirements.elementAt(3)).compareTo("0")==0) {
		strColor = " color='red'";
		bolCleared=false;}
		else strColor = " color='black'";%>
	  <font size="1" <%=strColor%>><%=(String)vRequirements.elementAt(2)%></font><br>
		<%
			vRequirements.removeElementAt(0); vRequirements.removeElementAt(0); vRequirements.removeElementAt(0);
			vRequirements.removeElementAt(0);
		if (vRequirements.size()==0) break;%>
		<%}}%>&nbsp;
      </font></td>
      <td><font size="1"><%if (bolCleared){%>CLEARED<%}else{%>NOT CLEARED<%}%></font></td>
    </tr>
    <%}%>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="4"><font size="1">Printed by :<strong><%=CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1)%></strong></font></td>
    </tr>
  </table>
  <%}%>
<%if (strErrMsg==null){%>
<script language="JavaScript">
	window.print();
</script>
<%}%>
<!--
<input name = "clr_index" type = "hidden"  value="<%=WI.fillTextValue("clr_index")%>">
<input name = "stud_id" type = "hidden"  value="<%=WI.fillTextValue("stud_id")%>">
-->
</form>
</body>
</html>

<%
//remove information from session.
		curSession.removeAttribute("stud_id");
		curSession.removeAttribute("sy_from");
		curSession.removeAttribute("sy_to");
		curSession.removeAttribute("semester");
		curSession.removeAttribute("type_index");
dbOP.cleanUP();
%>