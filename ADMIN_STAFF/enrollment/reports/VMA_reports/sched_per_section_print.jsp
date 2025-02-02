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
<style>
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 15px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 15px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 15px;
}

.bodystyle {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 15px;
}

    TD.thinborderALL {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }
    TD.thinborderTOPBOTTOM {
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 15px;
    }
    TD.thinborderNONE {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 15px;	
    }
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 15px;	
    }
    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 15px;
    }


</style>

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
Vector vSectionList = null; Vector vRetResult = new Vector();

	vSectionList = SS.printCPPerCourseVMA(dbOP,request);
	if(vSectionList == null)
		strErrMsg = SS.getErrMsg();
	//System.out.println(vSectionList);

String strIsLec = null;
int iCount = 0;

int iEnrolled = 0;
int iCapacity = 0;

String[] astrConvertTerm = {"Summer","1st Semester","2nd Semester","3rd Semester"}; 

if(vSectionList != null && vSectionList.size() > 0){

	for(int i = 0; i < vSectionList.size(); i += 2){
		if(i > 0) {%>
			<DIV style="page-break-after:always" >&nbsp;</DIV>
		<%}%>
		  <table width="100%" border="0" cellpadding="0" cellspacing="0">
			  <tr>
		        <td width="14%">
			    <td align="center">VMA GLOBAL COLLEGE<br>
				(Asian Mari-Tech Dev't Corp.) <br>
				Sum-ag, Bacolod City</td>
		        <td width="14%" class="thinborderALL">
				Form ID: EDP 0011<br>
			      Rev. No: 01<br>
			      Rev. Date: 06/15/06				
				</td>
		    </tr>
		  </table>
		  <table width="100%" border="0" cellpadding="0" cellspacing="0">
		    <tr>
			  <td colspan="4" align="center"><br>STUDENT'S SCHEDULE</td>
		    </tr>
			<tr>
			  <td width="33%">COURSE: <%=dbOP.getResultOfAQuery("select course_code from course_offered where course_index = "+WI.fillTextValue("course_index"), 0)%></td>
			  <td width="23%">SECTION: <%=vSectionList.elementAt(i)%></td>
			  <td width="34%" colspan="2">SY-TERM: <%=astrConvertTerm[Integer.parseInt(WI.fillTextValue("offering_sem"))]%>, <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%></td>
		    </tr>
			
			<tr>
			  <td colspan="4" align="center">&nbsp;</td>
		    </tr>
		  </table>
    	  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
			<tr style="font-weight:bold"> 
			  <td width="15%" height="30" class="thinborder">SUBJECT CODE </td>
			  <td width="35%" class="thinborder">DESCRIPTION</td>
			  <td width="20%" class="thinborder">DAYS - TIME</td>
			  <td width="5%" class="thinborder">ROOM</td>
		    </tr>
		<%
		vRetResult = (Vector)vSectionList.elementAt(i + 1);
		while(vRetResult.size() > 0) {
			strTemp = (String)vRetResult.elementAt(2);
			if(strTemp != null && strTemp.length() > 30)
				strTemp = strTemp.substring(0, 30);
			
			//check if lab subject.. 
			if(vRetResult.elementAt(14).equals("1"))
				strIsLec = " (Lab)";
			else {	
				strIsLec = "";
			}
		%>
			<tr valign="top">
			  <td height="30" class="thinborder"><%=vRetResult.elementAt(1)%></td>
			  <td class="thinborder"><%=vRetResult.elementAt(2)%></td>
			  <td class="thinborder"><%=vRetResult.elementAt(8)%></td>
			  <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(10), "&nbsp;")%></td>
		    </tr>
		<%
			vRetResult.remove(0);	vRetResult.remove(0);	vRetResult.remove(0);	vRetResult.remove(0);
			vRetResult.remove(0);	vRetResult.remove(0);	vRetResult.remove(0);	vRetResult.remove(0);
			vRetResult.remove(0);	vRetResult.remove(0);	vRetResult.remove(0);	vRetResult.remove(0);
			vRetResult.remove(0);	vRetResult.remove(0);	vRetResult.remove(0);	vRetResult.remove(0);
			vRetResult.remove(0);
			
		}%>
		  </table>
	<%}//for loop to show the pages.%>
<%}//only if vSecList.size()>0%>

</body>
</html>
<%
dbOP.cleanUP();
%>
