<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<%@ page language="java" import="utility.*,java.util.Vector,ClassMgmt.CMSubjectReq" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
//add security here.

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Faculty/Acad. Admin-Class Management-Requirements","cm_requirements.jsp");
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
														"cm_requirements.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../faculty_acad/faculty_acad_bottom_content.htm");
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
String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
CMSubjectReq cm = new CMSubjectReq();
String strPageAction = WI.fillTextValue("page_action");

%>
<body>
<form action="./cm_requirements.jsp" method="post" name="form_" id="form_">
<% if(WI.fillTextValue("sub_index").length() != 0) {%>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" id="sub_data">
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="3"><div align="center"><font size="2"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></div>
      </td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="20" colspan="3">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td width="2%">&nbsp;</td>
      <td width="19%"><strong>SUBJECT TITLE :</strong> </td>
      <td width="79%" height="25"> <p><%=dbOP.mapOneToOther("subject","is_del","0","sub_name"," and sub_index = " + WI.fillTextValue("sub_index"))%> </p></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td>&nbsp;</td>
      <td><strong>PREREQUISITES :</strong></td>
      <td height="25"> <%
		Vector vSubjPrereq = new enrollment.CurriculumSM().viewAllRequisite(dbOP,WI.fillTextValue("sub_index"));
	  	for(int j= 0; j < vSubjPrereq.size(); j+=4){
	  	if (j == 0){%> <%=(String)vSubjPrereq.elementAt(j+1)+WI.getStrValue((String)vSubjPrereq.elementAt(j+2),"(",")","")%> <%}else{%> <%=WI.getStrValue((String)vSubjPrereq.elementAt(j+1),",","","")+WI.getStrValue((String)vSubjPrereq.elementAt(j+2),"(",")","")%> <%}}%> </td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
  </table>
  <%  vRetResult = cm.operateOnCMSubjReq(dbOP,request,4);
	if (vRetResult !=null){%>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" class="thinborder">
    <tr> 
      <td height="25" colspan="3" class="thinborder"> <div align="center"><strong>LIST 
          OF REQUIREMENTS FOR <%="("+(dbOP.mapOneToOther("subject","is_del","0","sub_name"," and sub_index = " + WI.fillTextValue("sub_index"))).toUpperCase() +")"%></strong></div></td>
    </tr>
    <% for (int i = 0; i < vRetResult.size(); i+=4){
		strTemp = (String)vRetResult.elementAt(i+2);
		strTemp2 =  (String)vRetResult.elementAt(i+3);
     
	 if (strTemp!= null) { %>
    <tr> 
      <td width="2%" height="25" bgcolor="#FFFFFF" class="thinborder">&nbsp;</td>
      <td colspan="2" bgcolor="#FFFFFF" class="thinborderBOTTOM"><strong><%=strTemp%></strong></td>
    </tr>
    <%} if (strTemp2 != null){%>
    <tr> 
      <td width="2%" height="25" bgcolor="#FFFFFF" class="thinborder">&nbsp;</td>
      <td width="4%" bgcolor="#FFFFFF" class="thinborderBOTTOM">&nbsp;</td>
      <td width="80%" bgcolor="#FFFFFF" class="thinborderBOTTOM">&nbsp;<%=strTemp2%></td>
    </tr>
    <%}
	}//end for loop%>
  </table>
<%}
} // if sub_index  selected%>
<script language="Javascript">
window.print();
</script>

</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>