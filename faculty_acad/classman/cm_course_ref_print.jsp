<%@ page language="java" import="utility.*,java.util.Vector,ClassMgmt.CMSubjectRef" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	boolean bolProceed = true;

	
	boolean bolIsStudent = WI.fillTextValue("is_student").equals("1");
		
	
//add security here.

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Faculty/Acad. Admin-CLASS MANAGEMENT-Course Reference Materials","cm_course_ref.jsp");

	}
catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}

//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Faculty/Acad. Admin","CLASS MANAGEMENT",request.getRemoteAddr(),
														"cm_course_ref.jsp");

if (bolIsStudent)
	iAccessLevel = 1;
	
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
	Vector vRetResult = null;
	Vector vEditInfo = null;
	CMSubjectRef cm = new CMSubjectRef();

vRetResult = cm.operateOnSubjectRef(dbOP,request,4);
if (vRetResult == null && strErrMsg == null){
	strErrMsg = cm.getErrMsg();
}
%>

<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">	
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
table{
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }


    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

-->
</style>

</head>

<body onLoad="window.print()">
<form action="cm_course_ref.jsp" method="post" name="form_" id="form_">
  <table width="100%" border="0" cellpadding="2" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td width="100%" height="25"><strong>&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="20" align="center"><font size="2"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></td>
    </tr>
	<tr bgcolor="#FFFFFF"> 
      <td height="20" align="center">&nbsp;</td>
    </tr>
  </table>
<% if(WI.fillTextValue("sub_index").length() != 0) {%>
  <table width="100%" border="0" cellpadding="2" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td width="2%">&nbsp;</td>
      <td width="18%"><strong>SUBJECT TITLE :</strong> </td>
      <td width="80%" height="25"> <p> <%=WI.fillTextValue("h_sub_code")%> <%=WI.getStrValue(dbOP.mapOneToOther("subject","is_del","0","sub_name"," and sub_index = " + WI.fillTextValue("sub_index")),"(",")","")%> 
        </p></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td>&nbsp;</td>
      <td><strong>PREREQUISITES :</strong></td>
      <td height="25"> 
        <%
		Vector vSubjPrereq = new enrollment.CurriculumSM().viewAllRequisite(dbOP,WI.fillTextValue("sub_index"));
	  	for(int j= 0; j < vSubjPrereq.size(); j+=4){
	  	if (j == 0){%>
        <%=(String)vSubjPrereq.elementAt(j+1)+WI.getStrValue((String)vSubjPrereq.elementAt(j+2),"(",")","")%> 
        <%}else{%>
        <%=WI.getStrValue((String)vSubjPrereq.elementAt(j+1),", ","","")+WI.getStrValue((String)vSubjPrereq.elementAt(j+2),"(",")","")%> 
        <%}}%>
      </td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="15" colspan="3">&nbsp;</td>
    </tr>
  </table>
  <% 
	if (vRetResult != null){%>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="30" colspan="3" class="thinborder"><div align="center"><strong>LIST 
          OF COURSE REFERENCES</strong></div></td>
    </tr>
    <% for (int i = 0; i < vRetResult.size() ; i+=9) {
		if (vRetResult.elementAt(i+1) != null){
	%>
    <tr> 
      <td width="1%" height="19" bgcolor="#EFEFEF" class="thinborder">&nbsp;</td>
      <td colspan="2" bgcolor="#EFEFEF" class="thinborderBOTTOM"><strong><font color="#990000"><%=(String)vRetResult.elementAt(i+2)%></font></strong></td>
    </tr>
    <%}%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;</td>
      <td colspan="2" class="thinborderBOTTOM"><strong><%=(String)vRetResult.elementAt(i+4) + WI.getStrValue((String)vRetResult.elementAt(i+6)," ("," Edition)","")%></strong> <%=WI.getStrValue((String)vRetResult.elementAt(i+5),"<br>Author : ","","")%> <%=WI.getStrValue((String)vRetResult.elementAt(i+7),"<br>Notes : ","","")%> <br> <% if (vRetResult.elementAt(i+8) != null){%> <img src="../../images/tick.gif">Available 
        in Library 
        <%}%> </td>
    </tr>
    <%} //end for loop%>
  </table>
  <%} // if vretresult == null
} // if subject is selected%>

</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>

