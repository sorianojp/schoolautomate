<%@ page language="java" import="utility.*,java.util.Vector,ClassMgmt.CMSyllabus" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;
	
	//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FACULTY/ACAD. ADMIN-CLASS MANAGEMENT"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FACULTY/ACAD. ADMIN"),"0"));
		}
	}
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../faculty_acad/faculty_acad_bottom_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out.Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

	//end of authenticaion code.

	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Faculty/Acad. Admin-CLASS MANAGEMENT-Syllabus","syllabus.jsp");
	}
	catch(Exception exp) {
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"><%=strErrMsg%></p>
		<%
		return;
	}

CMSyllabus cms = new CMSyllabus();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(cms.operateOnMain(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = cms.getErrMsg();
	else
		strErrMsg = "Operation successful.";
}
Vector vSYLMain = null;
Vector vChapterSubChapInfo = null;
Vector vRef = null;

if(request.getParameter("sub_index") != null) {
	vRetResult = cms.operateOnMain(dbOP, request, 4);
	if(vRetResult == null) 
		strErrMsg = cms.getErrMsg();
	else {
		vSYLMain = (Vector)vRetResult.remove(0);
		vChapterSubChapInfo = (Vector)vRetResult.remove(0);
		vRef     = (Vector)vRetResult.remove(0);
	}
}
String strSubCode = null;
String strSubName = null;
java.sql.ResultSet rs = dbOP.executeQuery("select sub_code,sub_name from subject where sub_index = "+
	WI.fillTextValue("sub_index"));
if(rs.next()){
	strSubCode = rs.getString(1);
	strSubName = rs.getString(2);
}
rs.close();
%>
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<body onLoad="window.print();">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
   <%if(strErrMsg != null){%>
    <tr> 
      <td height="25" colspan="2">&nbsp;
	  <font size="3" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
	<%dbOP.cleanUP();return;}%>
    <tr>
      <td height="25" colspan="2" class="thinborderNONE"><div align="center"> <font size="2"> <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
              <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="2" class="thinborderNONE">Subject : <strong><%=strSubCode%></strong> &nbsp;&nbsp;Subject Name : <strong><%=strSubName%></strong></td>
    </tr>
    <tr> 
      <td height="25" colspan="2" align="right" style="font-size:10px;">Date and Time Printed : <%=WI.getTodaysDateTime()%>&nbsp;&nbsp;&nbsp;</td>
    </tr>
  </table>

  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="1" cellspacing="0">
    
    <tr valign="top"> 
      <td colspan="2"><hr size="1" noshade></td>
    </tr>
    <tr valign="top" bgcolor="#EBF5F5">
      <td colspan="2" style="font-size:11px;"><strong>Course Description</strong>: </td>
    </tr>
    <tr valign="top" bgcolor="#EBF5F5"> 
      <td width="83%" colspan="2" bgcolor="#EBF5F5">
	  	<%=ConversionTable.replaceString(WI.getStrValue(vSYLMain.elementAt(0)), "\r\n","<br>")%></td>
    </tr>
    <tr valign="top">
      <td colspan="2" style="font-size:11px;"><strong>Course Objective</strong></td>
    </tr>
    <tr valign="top"> 
      <td colspan="2">
	  	<%=ConversionTable.replaceString(WI.getStrValue(vSYLMain.elementAt(1)), "\r\n","<br>")%></td>
    </tr>
    <tr valign="top" bgcolor="#EBF5F5">
      <td colspan="2" style="font-size:11px;"><strong>Course Outline</strong></td>
    </tr>
    <tr>
      <td colspan="2" bgcolor="#EBF5F5">
	  <%if(vChapterSubChapInfo != null) {
	    Vector vChapterInfo = (Vector)vChapterSubChapInfo.remove(0);%>
		<table width="100%" cellpadding="0" cellspacing="0" class="thinborder">
			<%for(int i = 0; i < vChapterInfo.size(); i += 6){%>
				<tr valign="top">
					<td class="thinborder">
						<%=vChapterInfo.elementAt(i + 5)%>.<%=vChapterInfo.elementAt(i + 1)%>					</td>
					<td class="thinborder">
						<%=ConversionTable.replaceString(WI.getStrValue(vChapterInfo.elementAt(i + 2),"&nbsp;"), "\r\n","<br>")%>					</td>
					<td class="thinborder">
						<%=vChapterInfo.elementAt(i + 3)%>hrs					</td>
				</tr>
				<%for(int j = 0; j < vChapterSubChapInfo.size();){
					if(!vChapterInfo.elementAt(i).equals(vChapterSubChapInfo.elementAt(0)))
						break;
				%>
					<tr valign="top" style="font-size:9px; color:#0000FF;">
						<td class="thinborder">
							<%=vChapterSubChapInfo.elementAt(5)%>.<%=vChapterSubChapInfo.elementAt(2)%>						</td>
						<td class="thinborder">
							<%=ConversionTable.replaceString(WI.getStrValue(vChapterSubChapInfo.elementAt(3),"&nbsp;"), "\r\n","<br>")%>						</td>
						<td class="thinborder">
							<%=vChapterSubChapInfo.elementAt(4)%>hrs						</td>
					</tr>
				<%vChapterSubChapInfo.removeElementAt(0);vChapterSubChapInfo.removeElementAt(0);
				  vChapterSubChapInfo.removeElementAt(0);vChapterSubChapInfo.removeElementAt(0);
				  vChapterSubChapInfo.removeElementAt(0);vChapterSubChapInfo.removeElementAt(0);
				}//end of showing sub chapter.
				//show exam name if there is any.. 
				if(vChapterInfo.elementAt(i + 4) != null) {%>
					<tr valign="top" style="font-size:9px; color:#0000FF;">
						<td colspan="3" class="thinborder" align="center">
							<%=((String)vChapterInfo.elementAt(i + 4)).toUpperCase()%>						</td>
					</tr>
				<%}//show only if exam name is there.. %>
				
			<%}//end of for loop.for(int i = 0; i < vChapterInfo.size(); i += 6)%>
		</table>
	  <%}%>	  </td>
    </tr>
    <tr valign="top">
      <td colspan="2" style="font-size:11px;"><strong>Instructional Techniques</strong></td>
    </tr>
    <tr valign="top"> 
      <td colspan="2">
	  	<%=ConversionTable.replaceString(WI.getStrValue(vSYLMain.elementAt(2)), "\r\n","<br>")%></td>
    </tr>
    <tr valign="top" bgcolor="#EBF5F5">
      <td colspan="2" style="font-size:11px;"><strong>Evaluation Techniques </strong></td>
    </tr>
    <tr bgcolor="#EBF5F5"> 
      <td colspan="2">
	  	<%=ConversionTable.replaceString(WI.getStrValue(vSYLMain.elementAt(3)), "\r\n","<br>")%></td>
    </tr>
    <tr valign="top">
      <td colspan="2" style="font-size:11px;"><strong>References</strong></td>
    </tr>
    <tr> 
      <td colspan="2">
			<%
			if(vRef != null && vRef.size() > 0) {%>
			  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="2" cellspacing="0" class="thinborderALL">
				<tr bgcolor="#BDD5DF">
				  <td height="20" colspan="3" style="font-size:11px" class="thinborderBOTTOM"><div align="center"><strong>LIST OF COURSE
					  REFERENCES</strong></div></td>
				</tr>
			<%for(int i = 0;i < vRef.size();){%>
				<tr>
				  <td width="10%">&nbsp;</td>
				  <td colspan="2"><strong><%=(String)vRef.elementAt(i + 1)%></strong></td>
				</tr>
			<%vRef.setElementAt(null, i + 1);
			for(; i < vRef.size(); i += 5) {
				if(vRef.elementAt( i + 1) != null)
					break;
				%>
				<tr>
				  <td>&nbsp;</td>
				  <td width="5%">&nbsp;</td>
				  <td width="85%"><%=vRef.elementAt( i + 3)%>
				  <font color="#0000FF"><%=WI.getStrValue((String)vRef.elementAt( i + 4), "<br>&nbsp;", "", "")%></font></td>
			    </tr>
			<%}//end of for loop - I
			}//end of main for loop.%>	
			  </table>
			<%}%>	  </td>
    </tr>
  </table>

</body>
</html>
<%
dbOP.cleanUP();
%>