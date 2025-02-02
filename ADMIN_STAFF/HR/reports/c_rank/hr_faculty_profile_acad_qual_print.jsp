<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
	.fontsize11 {
		font-size:11px;
	}

a:link {
	text-decoration: none;
}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPg()
{
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");	
}

function ReloadPage(){
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function showList(){
	document.form_.show_list.value = "1";
	document.form_.print_page.value = "";
	this.SubmitOnce("form_");
}

function EditRecord(strEmpID){
	var pgLoc = "../personnel/hr_personnel_education.jsp?emp_id=" + escape(strEmpID);
	var win=window.open(pgLoc,"EditWindow",'width=700,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

</script>

<body marginheight="0" >
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

String[] astrSemester={"Summer", "1st Semester", "2nd Semester", "3rd Semester","4th Semester"};

if (strErrMsg != null){
%>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="100%" height="25">&nbsp;<%=WI.getStrValue(strErrMsg,"<strong><font size=\"3\" color=\"#FF0000\">","</font></strong>","")%></td>
    </tr>
  </table>
<%} if (vRetResult != null && vRetResult.size() > 0)  { %>
<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="5"><div align="center">&nbsp;
          <strong><font size="2">FACULTY PROFILE<br>
(by Academic Qualifications)<br>
<%=astrSemester[Integer.parseInt(WI.getStrValue(WI.fillTextValue("semester"),"1"))] +
 ", A.Y. " + WI.fillTextValue("sy_from") + "-" + WI.fillTextValue("sy_to")%> 
          </font></strong>
		</div></td>
    </tr>

    <tr>
      <td height="25" colspan="5"><div align="center"><strong><%=WI.getStrValue(dbOP.mapOneToOther("college","c_index",WI.fillTextValue("c_index"),"c_name",""))%> 	
		</strong></div></td>
    </tr>
</table>
<% 
	Vector vEduLevels = (Vector)vRetResult.elementAt(0);
	Vector vSubjects = null;
	
	if(vEduLevels != null && vEduLevels.size()> 0)  {
%> 
<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td width="16%" height="25" class="thinborder"><div align="center">NAME </div></td>
      <td width="12%" height="25" class="thinborder"><div align="center">STATUS </div></td>
      <td width="17%" height="25" class="thinborder"><div align="center">POSITION </div></td>
<% 
	int iEduLeveIndex = 0;
	for (iEduLeveIndex = 0; iEduLeveIndex < vEduLevels.size(); iEduLeveIndex+=2) {
%>
      <td width="15%" class="thinborder"><div align="center"><%=(String)vEduLevels.elementAt(iEduLeveIndex)%></div></td>
      <td width="12%" class="thinborder">&nbsp;</td>
      <%}%>  
      <td width="12%" class="thinborder">RANK </td>
    </tr>	
	
<% 
	// check to see if any change in i (index) to prevent infinite loop
	boolean bolIncremented = false; 
	String strCurrentUserIndex = null;
	String strSchCode = null;
	String strTemp2 = null;
	String strRank = null;
//	System.out.println(vRetResult);
	
	for (int i = 1; i < vRetResult.size();) {
	vSubjects = null;
	bolIncremented = false;
	
	strCurrentUserIndex = (String)vRetResult.elementAt(i+13);
	strRank = (String)vRetResult.elementAt(i+16);
%>
    <tr>
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i)%>	  </td>
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i+1)%>	  </td>
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i+12)%>	  </td>

      <%   for (iEduLeveIndex = 0; iEduLeveIndex < vEduLevels.size(); iEduLeveIndex+=2) {

 		if ( i < vRetResult.size() &&
			strCurrentUserIndex.equals((String)vRetResult.elementAt(i+13)) && 
			((String)vEduLevels.elementAt(iEduLeveIndex+1)).equals((String)vRetResult.elementAt(i+6))){		

			strTemp = "";
			while( i < vRetResult.size() && 
			strCurrentUserIndex.equals((String)vRetResult.elementAt(i+13)) && 
			((String)vEduLevels.elementAt(iEduLeveIndex+1)).equals((String)vRetResult.elementAt(i+6))){
			
					if (strTemp.length() == 0){
						strTemp = (String)vRetResult.elementAt(i+9);
						strSchCode = WI.getStrValue((String)vRetResult.elementAt(i+7));
					}else{
						strTemp += "<br>" +  (String)vRetResult.elementAt(i+9);
						strSchCode += "<br>" +  WI.getStrValue((String)vRetResult.elementAt(i+7));
					}
				i += 17;
			} 
			bolIncremented = true;
		}else{
			strTemp ="&nbsp;";
			strSchCode = "&nbsp;";
		}
%> 
      <td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(strSchCode,"&nbsp;")%></td>	  
      <%   
	} // end for (iEduLeveIndex = 0;
%>
      <td class="thinborder"><%=strRank%></td>
    </tr>
<% if (!bolIncremented)  break; // prevent infinite loop
  } //end for loop%> 
</table>

<%} // end if vEduLevels.size() > 0 %>

<script language="javascript">
	window.setInterval("javascript:window.print()", 0);
</script>

<%
 } 
%> 

</body>
</html>
<%

	dbOP.cleanUP();
%>