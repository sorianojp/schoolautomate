<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

<style>
	body{
		font-family:Verdana, Arial, Helvetica, sans-serif;
		font-size:12px;
	}
	
	TD{
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
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

</style>
</head>


<body marginheight="0" onLoad="window.print()">
<%@ page language="java" import="utility.*,java.util.Vector,hr.HRManageList,hr.HRStatsReports" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	int iSearchResult = 0;

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-REPORTS AND STATISTICS-Ranking/Re-Ranking","hr_faculty_agd.jsp");

	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","REPORTS AND STATISTICS",request.getRemoteAddr(),
														"hr_educ_reports.jsp");
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
Vector vRetResult = null;

HRStatsReports hrStat = new HRStatsReports(request);


if (WI.fillTextValue("c_index").length() != 0){
	vRetResult = hrStat.hrAGDOperation(dbOP);
	if(vRetResult == null)
		strErrMsg = hrStat.getErrMsg();
	else	
		iSearchResult = hrStat.getSearchCount();
}else{
	strErrMsg = " Please select college";
}


//System.out.println(vRetResult);

String[] astrSemester={"Summer", "1st Sem", "2nd Sem", "3rd Sem","4th Sem"};


if (strErrMsg != null) {
%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="100%" height="25">&nbsp;<%=WI.getStrValue(strErrMsg,"<strong><font size=\"3\" color=\"#FF0000\">","</font></strong>","")%></td>
    </tr>
  </table>

  
<%}
 if (vRetResult != null && vRetResult.size() > 0)  { %>
<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">

    <tr>
      <td height="25" colspan="5">
        <div align="center"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
          <br>
        </div></td>
    </tr>
    <tr>
      <td height="25" colspan="5"><div align="center">&nbsp;
		<strong><%=dbOP.mapOneToOther("college","c_index",request.getParameter("c_index"), "c_name","").toUpperCase()%></strong>
	  </div></td>
    </tr>
    <tr>
      <td height="25" colspan="5">&nbsp;</td>
    </tr>
</table>
<% 
	Vector vEduLevels = (Vector)vRetResult.elementAt(0);
	Vector vSubjects = null;
	
	if(vEduLevels != null && vEduLevels.size()> 0)  {
%> 
<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td width="20%" height="25" class="thinborder"><div align="center">NAME OF FACULTY </div></td>
<% 
	int iEduLeveIndex = 0;
	for (iEduLeveIndex = 0; iEduLeveIndex < vEduLevels.size(); iEduLeveIndex+=2) {
%>
      <td width="20%" class="thinborder"><div align="center"><%=(String)vEduLevels.elementAt(iEduLeveIndex)%></div></td>
<%}%>  
      <td width="20%" class="thinborder"><div align="center">Subjects Taught<br>
	  
	  <%=astrSemester[Integer.parseInt(WI.getStrValue(request.getParameter("semester"),"1"))] + " " + 
	  		WI.fillTextValue("sy_from") + " - " +  WI.fillTextValue("sy_to")%>
	  
      </div></td>
    </tr>	
	
<% 
	// check to see if any change in i (index) to prevent infinite loop
	boolean bolIncremented = false; 
	String strCurrentUserIndex = null;
	String strTemp2 = null;
	
//	System.out.println(vRetResult);
	
	for (int i = 1; i < vRetResult.size();) {
	vSubjects = null;
	bolIncremented = false;
	
	strCurrentUserIndex = (String)vRetResult.elementAt(i+13);
%>
    <tr>
      <td height="25" class="thinborder">&nbsp;
  		  <%=(String)vRetResult.elementAt(i)%>
	  </td>
      <%   for (iEduLeveIndex = 0; iEduLeveIndex < vEduLevels.size(); iEduLeveIndex+=2) {

 		if ( i < vRetResult.size() &&
			strCurrentUserIndex.equals((String)vRetResult.elementAt(i+13)) && 
			((String)vEduLevels.elementAt(iEduLeveIndex+1)).equals((String)vRetResult.elementAt(i+6))){		

			strTemp = "";
			while( i < vRetResult.size() && 
			strCurrentUserIndex.equals((String)vRetResult.elementAt(i+13)) && 
			((String)vEduLevels.elementAt(iEduLeveIndex+1)).equals((String)vRetResult.elementAt(i+6))){
			
				if (strTemp.length() == 0) 
					strTemp = (String)vRetResult.elementAt(i+9);
				else
					strTemp += "<br>" +  (String)vRetResult.elementAt(i+9);

		
				if(vRetResult.elementAt(i+14) != null) {
					vSubjects = (Vector)vRetResult.elementAt(i+14);
				}
				i += 17;
			} 
			bolIncremented = true;
		}else
			strTemp ="&nbsp;";
%> 
      <td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
<%   
	} // end for (iEduLeveIndex = 0;
		strTemp2 ="";
		if (vSubjects != null) {		
			while (vSubjects.size() > 0){ 
				if (strTemp2.length() == 0) 
					strTemp2 = "&nbsp;" + (String)vSubjects.remove(0);
				else
					strTemp2 += "<br>&nbsp;" + (String)vSubjects.remove(0);				
			}
		}else{
			strTemp2 = "&nbsp;";
		}
%>
      <td class="thinborder"><%=WI.getStrValue(strTemp2)%></td>
    </tr>
<% if (!bolIncremented)  break; // prevent infinite loop
  } //end for loop%> 
</table>
<%} // end if vEduLevels.size() > 0 %>

<% }  %>
</body>
</html>
<%
	dbOP.cleanUP();
%>