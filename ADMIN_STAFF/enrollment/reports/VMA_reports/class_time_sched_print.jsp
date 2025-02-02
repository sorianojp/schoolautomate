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

String[] astrConvertTerm = {"Summer","1st Semester","2nd Semester","3rd Semester"}; 

if(vSectionList != null && vSectionList.size() > 0){%>
  <%	for(int i = 0; i < vSectionList.size();){
		if(i > 0) {%>
			<DIV style="page-break-after:always" >&nbsp;</DIV>
		<%}
		iCurRow = 0;
		%>
		  <table width="100%" border="0" cellpadding="0" cellspacing="0">
			<tr>
			  <td colspan="2" align="center" style="font-size:14px;"><strong>VMA GLOBAL COLLEGE </strong> <br>
			  <font size="1">(Asian Mari-Tech Development Corp)<br>
			  Sum-ag Bacolod City<br>
			  <%=astrConvertTerm[Integer.parseInt(WI.fillTextValue("offering_sem"))]%>, <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%>			  </td>
			  <td width="12%" style="font-size:9px;" valign="top" class="thinborderALL">
			  Form ID: EDP 0011<br>
					Rev. No: 01<br>
					Rev. Date: 06/15/06			  </td>
			</tr>
			<tr>
			  <td colspan="2" align="center" style="font-size:14px;"><strong><br>CLASS TIME SCHEDULE</strong>			  </td>
		      <td width="12%" style="font-size:9px;" valign="top">&nbsp;</td>
			</tr>
			<tr>
			  <td width="57%">&nbsp;</td>
		      <td width="31%">Date Printed: <%=strDateTimePrinted%></td>
		      <td width="12%" style="font-size:9px;" valign="top">&nbsp;</td>
			</tr>
			<tr>
			  <td>&nbsp;</td>
		      <td>Page: <%=++iPageNo%></td>
		    </tr>
			<tr>
			  <td colspan="3" align="center">&nbsp;</td>
		    </tr>
		  </table>
    	  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
			<tr style="font-weight:bold"> 
			  <td width="4%" height="24" class="thinborder">REC#</td><!--thinborderTOPBOTTOM-->
			  <td width="20%" class="thinborder">DAYS - TIME</td>
			  <td width="5%" class="thinborder">ROOM</td>
			  <td width="15%" class="thinborder">SUBJECT CODE </td>
			  <td width="35%" class="thinborder">DESCRIPTION</td>
			  <td width="5%" class="thinborder">UNIT</td>
			  <td width="10%" class="thinborder">ENROLLED</td>
			</tr>
		<%
		while( ((Vector)vSectionList.elementAt(i + 1)).size() > 0) {
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
			  <td height="24" colspan="7" style="font-weight:bold; font-size:14px;" class="thinborder"><%=vSectionList.elementAt(i)%></td>
		    </tr>
			<%bolPrintSectionName = false;}%>
			<tr valign="top">
			  <td height="18" class="thinborder"><%=++iCount%></td>
			  <td class="thinborder"><%=((Vector)vSectionList.elementAt(i + 1)).elementAt(8)%></td>
			  <td class="thinborder"><%=WI.getStrValue(((Vector)vSectionList.elementAt(i + 1)).elementAt(10), "&nbsp;")%></td>
			  <td class="thinborder"><%=((Vector)vSectionList.elementAt(i + 1)).elementAt(1)%><%=strIsLec%></td>
			  <td class="thinborder"><%=((Vector)vSectionList.elementAt(i + 1)).elementAt(2)%></td>
			  <td class="thinborder"><%if(strIsLec.length() > 0) {%>&nbsp;<%}else{%><%=((Vector)vSectionList.elementAt(i + 1)).elementAt(12)%><%}%></td>
			  <td class="thinborder">
			  <%if(strIsLec.length() > 0) {%>&nbsp;
			  <%}else{%>
				  <%=((Vector)vSectionList.elementAt(i + 1)).elementAt(13)%>
					<%
						iEnrolled = Integer.parseInt((String)((Vector)vSectionList.elementAt(i + 1)).elementAt(13));
						iCapacity = Integer.parseInt(WI.getStrValue(((Vector)vSectionList.elementAt(i + 1)).elementAt(5),"0"));
					if(iEnrolled >= iCapacity){%>Closed
					<%}else{%>Open<%}
				
				}%> 
				
			  
			  </td>
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
