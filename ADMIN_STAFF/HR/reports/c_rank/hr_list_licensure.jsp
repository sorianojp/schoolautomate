<%@ page language="java" import="utility.*,java.util.Vector,hr.HRManageList,hr.HRStatsReports" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
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
	.fontsize10{
		font-size:11px;
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
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function PrintPg()
{
	document.form_.print_page.value="1";
	document.form_.show_list.value="1";
	document.form_.show_all.value="1";
	this.SubmitOnce("form_");
}

function ReloadPage(){
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function showList(){
	document.form_.show_list.value="1";
	document.form_.print_page.value = "";
	this.SubmitOnce("form_");
}

</script>

<body bgcolor="#663300" class="bgDynamic">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

	int iSearchResult = 0;
	
	if (WI.fillTextValue("print_page").equals("1")){ %>
	<jsp:forward page="./hr_list_licensure_print.jsp" />
<% return;	}
	
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-HR Management-REPORTS AND STATISTICS-Education",
								"hr_demographic_profile.jsp");

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
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,
											(String)request.getSession(false).getAttribute("userId"),
											"HR Management","REPORTS AND STATISTICS",
											request.getRemoteAddr(),"hr_demographic_profile.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}


HRStatsReports hrStat = new HRStatsReports(request);

String[] astrSortByName    = {"Last Name","First Name","Emp. Status"};
String[] astrSortByVal     = {"lname","user_table.fname","user_status.status"};
					
int iIndex =1;

Vector vRetResult = null;

if (WI.fillTextValue("show_list").equals("1")){

	vRetResult = hrStat.hrDemographicProfile(dbOP);
	
	if (vRetResult != null){
		iSearchResult = hrStat.getSearchCount();
	}else{
		strErrMsg = hrStat.getErrMsg();
	}
}
%>
<form action="./hr_list_licensure.jsp" method="post" name="form_" >
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A" class="footerDynamic"><div align="center"><font color="#FFFFFF"><strong>:::: 
          LIST OF STAFF WITH LICENSURE::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25">&nbsp;<%=WI.getStrValue(strErrMsg,"<strong><font size=\"3\" color=\"#FF0000\">","</font></strong>","")%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFF0F0">
    <tr> 
      <td width="12%" height="18">&nbsp;</td>
      <td width="88%">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" class="fontsize10">&nbsp;<%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td><select name="c_index" onChange="ReloadPage()">
          <option value=""> &nbsp;</option>
          <%=dbOP.loadCombo("c_index", "c_name"," from college where is_del =0 order by c_name",WI.fillTextValue("c_index"), false)%> </select></td>
    </tr>
    <tr> 
      <td height="25" class="fontsize10">&nbsp;Dept / Office </td>
      <td><select name="d_index">
          <option value=""> &nbsp;</option>
          <%
			if (WI.fillTextValue("c_index").length() > 0) 
				strTemp = "  c_index = " + WI.fillTextValue("c_index");
			else 
				strTemp = "  (c_index is null or c_index  = 0)";

		%>
          <%=dbOP.loadCombo("d_index", "d_name"," from department where "+ strTemp  +" and is_del = 0 order by d_name",WI.fillTextValue("d_index"), false)%> </select></td>
    </tr>
    <tr> 
      <td height="18" colspan="2" class="fontsize10"><hr size="1" noshade></td>
    </tr>
    <tr> 
      <td height="25" class="fontsize10">License</td>
      <td class="fontsize10"><select name="license_index">
		  <% if (WI.fillTextValue("license_index").equals("0")) {%>
			  <option value="0" selected> Show Only Employees With License</option>
		  <%}else{%>
			  <option value="0"> Show Only Employees With License</option>
		   <%}%>		  
          <%=dbOP.loadCombo("LICENSE_INDEX", "LICENSE_NAME", " from HR_PRELOAD_LICENSE order by LICENSE_NAME",
		  					 WI.fillTextValue("license_index"),false)%> </select>      </td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td><a href="javascript:showList()"><img src="../../../../images/form_proceed.gif" width="81" height="21" border="0"></a></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  
  <input type="hidden" name="show_all" value="1" >
<% if (vRetResult != null && vRetResult.size() > 0) {%>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25">&nbsp; 
	  </td>
      <td height="25" align="right">&nbsp;
 
	  </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <% 
		iIndex = 1;
		String strCurrentCollege = null;
		String strCurrEnty = null;
	for (int i=0; i < vRetResult.size(); i+=19){
			
		if (strCurrentCollege == null){
			strCurrentCollege = WI.getStrValue((String)vRetResult.elementAt(i+5));
			if (strCurrentCollege.length() == 0) 
				strCurrentCollege = WI.getStrValue((String)vRetResult.elementAt(i+6));
		}
			
		strCurrEnty = WI.getStrValue((String)vRetResult.elementAt(i+5));
		if (strCurrEnty.length() == 0) 
			strCurrEnty = WI.getStrValue((String)vRetResult.elementAt(i+6));
			
		if (i == 0 || !strCurrentCollege.equals(strCurrEnty))  {
			strCurrentCollege = strCurrEnty;
			iIndex = 1;
	%>
    <tr>
      <td height="25" colspan="5" class="thinborder"><strong>&nbsp;<%=strCurrentCollege.toUpperCase()%></strong></td>
    </tr>
	<%}%> 	
    <tr>
      <td width="5%" class="thinborder">&nbsp;<%=iIndex++%></td> 
      <td width="35%" height="23" class="thinborder">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+2),
	  													(String)vRetResult.elementAt(i+3),
					 	  							    (String)vRetResult.elementAt(i+4),4)%></td>
      <td width="24%" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+12),"&nbsp;")%></td>
      <td width="17%" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+7),"&nbsp;")%></td>
      <td width="19%" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+15),"&nbsp")%></td>
    </tr>
    <%}// end for loop%>
  </table>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="footer">
    <% if (vRetResult!= null) {%>
    <tr> 
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"><div align="center"><font size="1"><a href="javascript:PrintPg();"><img src="../../../../images/print.gif" width="58" height="26" border="0"></a>click 
          to print List</font></div></td>
    </tr>
    <%}%>
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="print_page">
  <input type="hidden" name="show_list" value="0">
  <input type="hidden" name="complete_name" value="1">
  
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>