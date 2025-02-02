<%@ page language="java" import="utility.*,java.util.Vector,hr.HRManageList,hr.HRStatsReports" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
%>
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
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
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

<body bgcolor="#C39E60" marginheight="0"  class="bgDynamic">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	int iSearchResult = 0;
	
	if (WI.fillTextValue("print_page").equals("1")){ %>
	<jsp:forward page="./hr_faculty_agd_print.jsp" />
<%	return;}	
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

if ( WI.fillTextValue("show_list").equals("1")){
	if (WI.fillTextValue("c_index").length() != 0){
		vRetResult = hrStat.hrAGDOperation(dbOP);
		if(vRetResult == null)
			strErrMsg = hrStat.getErrMsg();
		else	
			iSearchResult = hrStat.getSearchCount();
	}else{
		strErrMsg = " Please select college";
	}
}


//System.out.println(vRetResult);

String[] astrSemester={"Summer", "1st Sem", "2nd Sem", "3rd Sem","4th Sem"};

%>
<form action="./hr_faculty_agd.jsp" method="post" name="form_" >
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" class="footerDynamic"><div align="center"><font color="#FFFFFF"><strong>:::: 
          FACULTY WITH MA-MS/PhD for AGD::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3">&nbsp;<%=WI.getStrValue(strErrMsg,"<strong><font size=\"3\" color=\"#FF0000\">","</font></strong>","")%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="19%" class="fontsize11">Academic Year / Term </td>
      <td width="78%">&nbsp;
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
<input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> 	  
	  
<select name="semester" onChange="ReloadPage();">
          <option value="0">Summer</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
		    if(strTemp.equals("1")){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.equals("2")){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.equals("3")){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select>	  </td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td colspan="2" class="fontsize11">College
        &nbsp;&nbsp;&nbsp;
        <select name="c_index" >
          <option value=""> </option>
          <%=dbOP.loadCombo("c_index","c_name"," FROM college where IS_DEL = 0 order by c_name",WI.fillTextValue("c_index"),false)%> 
      </select>	  </td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="16%" height="25">&nbsp;</td>
      <td width="84%"><a href="javascript:showList()"%><img src="../../../../images/form_proceed.gif" width="81" height="21" border="0"></a></td>
    </tr>
  </table>
  
<% if (vRetResult != null && vRetResult.size() > 0)  { %>
<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr> 
      <td height="18" colspan="5"><hr size="1"></td>
    </tr>
    <tr>
      <td height="25" colspan="5"><div align="center">&nbsp;
	  <script>
		document.write(document.form_.c_index[document.form_.c_index.selectedIndex].text);
	  </script>
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
			
				if (((String)vRetResult.elementAt(i+11) == null 
					||  ((String)vRetResult.elementAt(i+11)).equals("0"))   // remove car
					&& ((String)vRetResult.elementAt(i+10) == null))   // units 
				{	
					if (strTemp.length() == 0) 
						strTemp = (String)vRetResult.elementAt(i+9);
					else
						strTemp += "<br>" +  (String)vRetResult.elementAt(i+9);

		
					if(vRetResult.elementAt(i+14) != null) {
						vSubjects = (Vector)vRetResult.elementAt(i+14);
				    }
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
  <table border=0 cellpadding="0" cellspacing="0" width="100%" bgcolor="#FFFFFF">
  <tr>
  <td height="25">&nbsp;</td>
  </tr>

  <tr>
  <td height="25" align="center">&nbsp;
  	<a href="javascript:PrintPg()"><img src="../../../../images/print.gif" border="0"></a>
		<font size="1"> click to print report</font></td>
  </tr>

  </table>
  
<%} // end if vEduLevels.size() > 0
 } 
%> 
<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="footer">
  <tr>
    <td height="25">&nbsp;</td>
  </tr>
  <tr>
    <td height="25" colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
  </tr>
</table>

  <input type="hidden" name="print_page">
  <input type="hidden" name="show_list" value="0">
  <input type="hidden" name="faculty_ntp" value="1">
  <input type="hidden" name="get_subjects" value="1">
  <input type="hidden" name="ma_phd_only" value="1">
  <input type="hidden" name="show_grad" value="1"> <!-- remove uniting only --> 
    
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>