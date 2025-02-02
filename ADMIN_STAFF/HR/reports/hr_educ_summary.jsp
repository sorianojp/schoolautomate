<%@ page language="java" import="utility.*,java.util.Vector,hr.HRManageList,hr.HRStatsReports" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
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
<script language="JavaScript" src="../../../jscript/common.js"></script>
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


function UpdateAll(){
	var iNumCheckBox = Number(document.form_.max_value.value);

	if (iNumCheckBox == 0) {
		alert (" No Selection available");
		document.form_.select_all.checked = false;
		return;
	}

	
	if(document.form_.select_all.checked){
		// check all 
		for(var i = 0; i < iNumCheckBox;i++){
			eval("document.form_.checkboxED"+i+".checked = true");
		}
	}else{
		// remove all
		for(var i = 0; i < iNumCheckBox;i++){
			eval("document.form_.checkboxED"+i+".checked = false");
		}
	}
		
}
</script>

<body bgcolor="#663300" marginheight="0"  class="bgDynamic">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	int iSearchResult = 0;
	
	if (WI.fillTextValue("print_page").equals("1")){ %>
	<jsp:forward page="./hr_educ_summary_print.jsp" />
<%	return;}	
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-REPORTS AND STATISTICS-Education","hr_educ_summary.jsp");

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
														null);
if(iAccessLevel == 0) 
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Executive Management System","ENROLLMENT",request.getRemoteAddr(),
														null);
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
Vector vRetResult = null;

HRStatsReports hrStat = new HRStatsReports(request);

vRetResult = hrStat.summaryDistributionPerCourse(dbOP);
%>
<form action="./hr_educ_summary.jsp" method="post" name="form_" >
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A" class="footerDynamic">
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF"><strong>:::: 
          SUMMARY OF HIGHEST EDUCATIONAL ATTAINMENT ::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="4">&nbsp;<%=WI.getStrValue(strErrMsg,"<strong><font size=\"3\" color=\"#FF0000\">","</font></strong>","")%></td>
    </tr>
	
<% if (bolIsSchool){%> 
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="16%" class="fontsize11">Emp. Category</td>
      <td width="29%">&nbsp;
        <select name="teaching_staff">
          <option value=""> ALL</option>
          <% if (WI.fillTextValue("teaching_staff").equals("1")) {%>
          <option value="1" selected> Academic Personnel</option>
          <%}else{%>
          <option value="1"> Academic Personnel</option>
          <%}if (WI.fillTextValue("teaching_staff").equals("0")){%>
          <option value="0" selected> Non Teaching Personnel</option>
          <%}else{%>
          <option value="0">Non Teaching Personnel</option>
          <%}%>
        </select></td>
      <td width="52%"><a href="javascript:showList()"%><img src="../../../images/form_proceed.gif" width="81" height="21" border="0"></a></td>
    </tr>
<%}%> 
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="10%" height="18">&nbsp;</td>
      <td width="90%">&nbsp;</td>
    </tr>
  </table>
<% 
	int iChkBox = 0;
	if (vRetResult != null && vRetResult.size() > 0) {%>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="49%" height="25" align="right">&nbsp; </td>
    </tr>
    <tr> 
      <td width="51%" height="25" colspan="2" align="center" bgcolor="#B9B292"><strong><font color="#FFFFFF">HIGHEST EDUCATIONAL ATTAINMENT</font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td width="10%" align="center"  class="thinborder"><strong>EDUC TYPE </strong></td>
      <td width="67%" align="center"  class="thinborder"><strong>DEGREE EARNED</strong></td>
      <td width="7%" align="center"  class="thinborder">MALE</td>
      <td width="8%" align="center"  class="thinborder">FEMALE</td>
      <td width="8%" align="center"  class="thinborder"><strong>TOTAL </strong></td>
    </tr>
    <%  
		for (int i=0; i < vRetResult.size(); i += 7){%>				
			<tr>
			  <td class="thinborder"><%=(String)vRetResult.elementAt(i+3)%></td>
			  <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+6)%> </td>
			  <td class="thinborder"><%=(String)vRetResult.elementAt(i+4)%></td>
			  <td class="thinborder"><%=(String)vRetResult.elementAt(i+5)%></td>
			  <td class="thinborder">&nbsp;<%=Integer.parseInt((String)vRetResult.elementAt(i+4)) + Integer.parseInt((String)vRetResult.elementAt(i+5))%></td>
			</tr>
    <%	}// end for loop %>
  </table>
  <%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="footer">
    <% if (vRetResult!= null) {%>
    <tr> 
      <td height="18">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;Title of the Report: 
        <input name="title_report" type="text" class="textbox" size="48"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"><div align="center"><font size="1"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" width="58" height="26" border="0"></a>click 
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
  <input type="hidden" name="max_value" value="<%=iChkBox%>">
  <input type="hidden" name="print_page">
  <input type="hidden" name="show_list" value="0">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>