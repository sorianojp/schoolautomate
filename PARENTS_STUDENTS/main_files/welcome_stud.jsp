<%
String strParentIndex = (String)request.getSession(false).getAttribute("parent_i");
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Welcome</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",-1);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%></head>

<script language="JavaScript">
function LoadLeftFrame()
{
	//parent.leftFrame.location="./adm_new_transferee_links.jsp";
}
function Logout()
{
	document.logout.submit();
}
function SwichStudent(strStudIndex) {
	document.logout.new_stud.value=strStudIndex;
	location = "./welcome_stud.jsp?new_stud="+strStudIndex;
}
</script>
<body bgcolor="#9FBFD0" onLoad="LoadLeftFrame();">
<form action="../../commfile/logout.jsp" method="post" target="_parent" name="logout">
<%
	utility.DBOperation dbOP = null;
	utility.WebInterface WI  = new utility.WebInterface(request);
	String strSQLQuery       = null;
	java.sql.ResultSet rs    = null;
	
	String strMsgOnLogon     = null;
	
	dbOP = new utility.DBOperation();
	
	if(WI.fillTextValue("new_stud").length() > 0 && strParentIndex != null) { 
		
		strSQLQuery = "select user_table.user_index, id_number, fname, mname, lname from user_table "+
					"join PARENT_SMS_MAIN on (PARENT_SMS_MAIN.user_index = user_table.user_index) "+
					"where parent_index = "+strParentIndex+" and PARENT_SMS_MAIN.is_valid = 1 and PARENT_SMS_MAIN.user_index = "+
					WI.fillTextValue("new_stud");
		rs = dbOP.executeQuery(strSQLQuery);
		if(rs.next()) {
			request.getSession(false).setAttribute("userId",rs.getString(2));
			request.getSession(false).setAttribute("userIndex",rs.getString(1));
			request.getSession(false).setAttribute("first_name",WI.formatName(rs.getString(3),rs.getString(4),rs.getString(5),4));
		} 
		rs.close();
	}
String strUserId = (String)request.getSession(false).getAttribute("userId");
String strName = (String)request.getSession(false).getAttribute("first_name");
String strAuthIndex = (String)request.getSession(false).getAttribute("authTypeIndex");
if(strUserId == null || strUserId.trim().length() == 0 || (strAuthIndex.compareTo("4") !=0 && strAuthIndex.compareTo("6") !=0))
{
	response.sendRedirect(response.encodeRedirectURL("./parents_student_main_page_rightFrame.jsp"));
	return;
}
String strLoginPersonName       = null;
java.util.Vector vOtherChildren = new java.util.Vector(); //fill up if there are other children.
if(strParentIndex == null)
	strLoginPersonName = (String)request.getSession(false).getAttribute("first_name");
else	
	strLoginPersonName = (String)request.getSession(false).getAttribute("parent_n");

if(strParentIndex != null) {
	String[] astrConvertTerm = {"Summer","1st Term","2nd Term","3rd Term"};
	String[] astrConvertBasic = {"Summer","Regular"};
	
	strSQLQuery = "select user_table.user_index, id_number, fname, mname, lname, sy_from, semester,course_index from user_table "+
	"join PARENT_SMS_MAIN on (PARENT_SMS_MAIN.user_index = user_table.user_index) "+
	"join stud_curriculum_hist on (stud_curriculum_hist.user_index = user_table.user_index) "+
	"join semester_sequence on (semester_val = semester) "+
	" where parent_index = "+strParentIndex+" and PARENT_SMS_MAIN.is_valid = 1 and stud_curriculum_hist.is_valid = 1 "+
	" and user_table.user_index <> "+(String)request.getSession(false).getAttribute("userIndex")+
	" order by sy_from desc, sem_order desc, id_number";

	rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) {
		if(vOtherChildren.indexOf(new Integer(rs.getInt(1))) > -1)
			continue;
		vOtherChildren.addElement(new Integer(rs.getInt(1)));//[0] index
		vOtherChildren.addElement(rs.getString(2));//[1] id number
		vOtherChildren.addElement(utility.WebInterface.formatName(rs.getString(3),rs.getString(4),rs.getString(5),4));//[2] name
		vOtherChildren.addElement(rs.getString(6));//[3] sy_from
		if(rs.getInt(8) == 0) 
			vOtherChildren.addElement(astrConvertBasic[rs.getInt(7)]);//[4] sem
		else
			vOtherChildren.addElement(astrConvertTerm[rs.getInt(7)]);
	}
	rs.close();

}
		strMsgOnLogon = new utility.MessageSystem().getSystemMsg(dbOP, (String)request.getSession(false).getAttribute("userIndex"), 8);
		System.out.println(strMsgOnLogon);

%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="28" bgcolor="#47768F">&nbsp;</td>
      <td height="28" colspan="3" bgcolor="#47768F"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          MY PERSONAL PAGE ::::</strong></font></div></td>
      <td height="28" bgcolor="#47768F">&nbsp;</td>
    </tr>
    <tr> 
      <td height="28" bgcolor="#9FBFD0">&nbsp;</td>
      <td height="28" colspan="3" bgcolor="#9FBFD0">&nbsp;</td>
      <td height="28" bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
    
    <tr> 
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25"><div align="center"><strong><font size="2" face="Verdana, Arial, Helvetica, sans-serif">Welcome 
          <%=strLoginPersonName%> to 
          </font><font color="#000000" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>your 
          personal page</strong>!</font></strong></div></td>
      <td height="25">&nbsp;</td>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
<%if(strParentIndex == null) {%>
    <tr> 
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
<%}%>
    <tr> 
      <td width="8%" height="25" bgcolor="#9FBFD0">&nbsp;</td>
      <td width="4%"><p align="justify">&nbsp;</p>
        <p>&nbsp;</p></td>
      <td width="80%" align="center">
	  <%if(strParentIndex != null) {%>
	  <img src="../../upload_img/<%=strUserId%>.jpg" width="125" height="125" border="1" align="middle"><br>
	  	<font size="3">You are now accessing records of <b><%=strUserId%> (<%=(String)request.getSession(false).getAttribute("first_name")%>) </b></font>
	  
	  	<%if(vOtherChildren != null && vOtherChildren.size() > 0) {%>
		<br><br>
			<table width="80%" cellpadding="0" cellspacing="0" border="0" class="thinborder" align="center">
				<tr>
					<td colspan="5" class="thinborder" style="font-size:13px; font-weight:bold;" bgcolor="#dddddd" align="center">Switch to Other Student</td>
				</tr>
				<%for(int i = 0; i < vOtherChildren.size(); i += 5) {%>
					<tr>
					  <td width="10%" class="thinborder"><img src="../../upload_img/<%=vOtherChildren.elementAt(i + 1)%>.jpg" width="125" height="125" border="1"></td>
						<td width="20%" class="thinborder" align="center"><%=vOtherChildren.elementAt(i + 1)%></td>
						<td width="41%" class="thinborder"><%=vOtherChildren.elementAt(i + 2)%></td>
						<td width="18%" class="thinborder"><%=vOtherChildren.elementAt(i + 3)%> - <%=vOtherChildren.elementAt(i + 4)%></td>
					  <td width="11%" class="thinborder"><input type="button" name="_" value="Switch" onClick="SwichStudent('<%=vOtherChildren.elementAt(i)%>')"></td>
					</tr>
				<%}%>
			</table>
		<%}%>
	  
	  <%}else{%>
	  <p align="justify"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">		
			Please note that every activity is monitored closely. For any problem in the system, contact System Administrator for details. Click the links under MENU to select operation. It is recommended to logout by clicking the logout button everytime you leave your PC.
		</font></p>
        <p align="justify"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">
		If you do not agree with the conditions or you are not <b> <%=strUserId %> </b> please logout.</font></p>
	  <%}%>		</td>
      <td width="3%">&nbsp;</td>
      <td width="5%" bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
<%if(strMsgOnLogon != null) {%>
    <tr> 
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" style="font-size:15px; color:#FFFF00; background-color:#7777aa" class="thinborderALL"><%=strMsgOnLogon%></td>
      <td height="25">&nbsp;</td>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
<%}%>
    <tr> 
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#47768F">&nbsp;</td>
      <td height="25" bgcolor="#47768F">&nbsp;</td>
      <td height="28" bgcolor="#47768F">&nbsp;</td>
      <td height="25" bgcolor="#47768F">&nbsp;</td>
      <td height="25" bgcolor="#47768F">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="logout_url" value="../PARENTS_STUDENTS/main_files/parents_students_bottom_content.jsp">
<input type="hidden" name="body_color" value="#9FBFD0">
<input type="hidden" name="new_stud" value="">
</form>
</body>
</html>
<%
if(dbOP != null)
	dbOP.cleanUP();
%>