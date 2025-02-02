<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Print Class Program</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
//strPrintStat = 0 = view only.
</script>

<body bgcolor="#FFFFFF" topmargin='0' bottommargin='0' onLoad="window.print();">
<%@ page language="java" import="utility.*,enrollment.SubjectSection,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation();
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
														"Enrollment","SUBJECT OFFERINGS",request.getRemoteAddr(),
														null);
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}
//end of authenticaion code.

SubjectSection SS = new SubjectSection();
Vector vSectionList = null;

	vSectionList = SS.printCPPerCourseVMA(dbOP,request);
	if(vSectionList == null)
		strErrMsg = SS.getErrMsg();
	//System.out.println(vSectionList);

String strDateTimePrinted = WI.formatDateTime(new java.util.Date(), 5);
int iNoOfRowsPerPg = 30;

int iCurRow = 0, iPageNo = 0; int iTotCount = 0; boolean bolShowInstructor = false;
if(WI.fillTextValue("show_faculty").length() > 0)
	bolShowInstructor = true;

String strCollegeName = null;
String strDeptName    = null;
Vector vTemp = null; String strTemp2 = null; int iIndexOf = 0;

String strIsLec = null;
int iCount = 0;

int iEnrolled = 0;
int iCapacity = 0;

boolean bolPrintSectionName = true;

boolean bolIsSPC = false;
if(strSchCode.startsWith("SPC"))
	bolIsSPC = true;

Vector vFaculty = new Vector();
if(!bolIsSPC){
	String strSQLQuery = "select e_sub_section.sub_sec_index, fname, lname from user_table "+
							"join faculty_load on (faculty_load.user_index = user_table.user_index) "+
							"join e_sub_section on (e_sub_section.sub_sec_index = faculty_load.sub_sec_index) "+
							" where faculty_load.is_valid = 1 and offering_sy_from = "+WI.fillTextValue("sy_from")+
							" and offering_sem = "+WI.fillTextValue("offering_sem");
	java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) {
		vFaculty.addElement(new Integer(rs.getInt(1)));
		vFaculty.addElement(WebInterface.formatName(rs.getString(2), null, rs.getString(3), 4));
	}
	rs.close();
}
String[] astrConvertTerm = {"Summer","1st Semester","2nd Semester","3rd Semester"}; 

String strFacultyName = null;

if(vSectionList != null && vSectionList.size() > 0){%>
  <%	for(int i = 0; i < vSectionList.size();){
		if(i > 0) {%>
			<DIV style="page-break-after:always" >&nbsp;</DIV>
		<%}
		iCurRow = 0;
		%>
		  <table width="100%" border="0" cellpadding="0" cellspacing="0">
			<tr>
			  <td colspan="2" align="center">CLASS TIME SCHEDULE			  </td>
		    </tr>
			<tr>
			  <td width="57%">School Year: <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%></td>
		      <td width="31%">Date Printed: <%=strDateTimePrinted%></td>
		    </tr>
			<tr>
			  <td>Semester: <%=astrConvertTerm[Integer.parseInt(WI.fillTextValue("offering_sem"))]%></td>
		      <td>Page: <%=++iPageNo%></td>
		    </tr>
			<tr>
			  <td colspan="2" align="center">&nbsp;</td>
		    </tr>
		  </table>
    	  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
			<tr style="font-weight:bold"> 
			  <td width="10%" height="24" class="thinborderTOPBOTTOM">SUBJECT CODE </td>
			  <td width="25%" class="thinborderTOPBOTTOM">DESCRIPTION</td>
			  <td width="5%" class="thinborderTOPBOTTOM">UNIT</td>
			  <td width="20%" class="thinborderTOPBOTTOM">DAYS - TIME</td>
			  <td width="5%" class="thinborderTOPBOTTOM">ROOM</td>
<%if(!bolIsSPC){%>
			  <td width="15%" class="thinborderTOPBOTTOM">FACULTY</td>
<%}%>
			  <td width="10%" class="thinborderTOPBOTTOM">ENROLLED</td>
			</tr>
		<%
		while( ((Vector)vSectionList.elementAt(i + 1)).size() > 0) {
			//System.out.println(((Vector)vSectionList.elementAt(i + 1)).elementAt(0));
			iIndexOf = vFaculty.indexOf(((Vector)vSectionList.elementAt(i + 1)).elementAt(0));
			if(iIndexOf == -1)
				strFacultyName = null;
			else	
				strFacultyName = (String)vFaculty.elementAt(iIndexOf + 1);
				
		
			strTemp = (String)((Vector)vSectionList.elementAt(i + 1)).elementAt(8);
			if(strTemp != null && strTemp.indexOf("<br>") > 1)
				++iCurRow;
			//limit the subject name size to 30
			strTemp = (String)((Vector)vSectionList.elementAt(i + 1)).elementAt(2);
			if(strTemp != null && strTemp.length() > 30)
				strTemp = strTemp.substring(0, 30);
			
			//check if lab subject.. 
			if(((Vector)vSectionList.elementAt(i + 1)).elementAt(14).equals("1"))
				strIsLec = " (Lab)";
			else {	
				strIsLec = "";
				++iTotCount;//only if lec.. 
			}
		%>
			<%if(bolPrintSectionName){%>
			<tr valign="top">
			  <td height="24" colspan="7" style="font-weight:bold; font-size:18px;"><%=vSectionList.elementAt(i)%></td>
		    </tr>
			<%bolPrintSectionName = false;}%>
			<tr valign="top">
			  <td height="18" class="thinborderNONE"><%=((Vector)vSectionList.elementAt(i + 1)).elementAt(1)%><%=strIsLec%> </td>
			  <td class="thinborderNONE"><%=((Vector)vSectionList.elementAt(i + 1)).elementAt(2)%></td>
			  <td class="thinborderNONE"><%if(strIsLec.length() > 0) {%>&nbsp;<%}else{%><%=((Vector)vSectionList.elementAt(i + 1)).elementAt(12)%><%}%></td>
			  <td class="thinborderNONE"><%=((Vector)vSectionList.elementAt(i + 1)).elementAt(8)%></td>
			  <td class="thinborderNONE"><%=WI.getStrValue(((Vector)vSectionList.elementAt(i + 1)).elementAt(10), "&nbsp;")%></td>
<%if(!bolIsSPC){%>
			  <td class="thinborderNONE"><%=WI.getStrValue(strFacultyName, "&nbsp;")%></td>
<%}%>
			  <td class="thinborderNONE">
			  <%if(strIsLec.length() > 0) {%>&nbsp;
			  <%}else{%>
			  		<%=((Vector)vSectionList.elementAt(i + 1)).elementAt(13)%>
			  		<%
			  			iEnrolled = Integer.parseInt((String)((Vector)vSectionList.elementAt(i + 1)).elementAt(13));
			  			iCapacity = Integer.parseInt(WI.getStrValue(((Vector)vSectionList.elementAt(i + 1)).elementAt(5),"0"));
						if(iEnrolled >= iCapacity){%>Closed
						<%}else{%>Open<%}
			   
			   }%>			  </td>
			</tr>
		<%
			((Vector)vSectionList.elementAt(i + 1)).remove(0);	((Vector)vSectionList.elementAt(i + 1)).remove(0);
			((Vector)vSectionList.elementAt(i + 1)).remove(0);	((Vector)vSectionList.elementAt(i + 1)).remove(0);
			((Vector)vSectionList.elementAt(i + 1)).remove(0);	((Vector)vSectionList.elementAt(i + 1)).remove(0);
			((Vector)vSectionList.elementAt(i + 1)).remove(0);	((Vector)vSectionList.elementAt(i + 1)).remove(0);
			((Vector)vSectionList.elementAt(i + 1)).remove(0);	((Vector)vSectionList.elementAt(i + 1)).remove(0);
			((Vector)vSectionList.elementAt(i + 1)).remove(0);	((Vector)vSectionList.elementAt(i + 1)).remove(0);
			((Vector)vSectionList.elementAt(i + 1)).remove(0);	((Vector)vSectionList.elementAt(i + 1)).remove(0);
			((Vector)vSectionList.elementAt(i + 1)).remove(0);	((Vector)vSectionList.elementAt(i + 1)).remove(0);
			((Vector)vSectionList.elementAt(i + 1)).remove(0);
			
			if(((Vector)vSectionList.elementAt(i + 1)).size() == 0) {
				bolPrintSectionName = true;
				i = i + 2;
			}
				
			if(++iCurRow > iNoOfRowsPerPg || i >=vSectionList.size() )
				break;
			
		}%>
		  </table>
	<%}//for loop to show the pages.%>
<%}//only if vSecList.size()>0%>

</body>
</html>
<%
dbOP.cleanUP();
%>
