<%@ page language="java" import="utility.*,java.util.Vector,hr.HRStatsReports" %>
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
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
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
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
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
	<jsp:forward page="./hr_stat_separated_print.jsp" />
<% return;	}
	
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-REPORTS AND STATISTICS-Education","hr_stat_work_type.jsp");

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
														"hr_stat_work_type.jsp");
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

String[] astrSortByName    = {"Last Name","First Name","Emp. Status", 
								"Resignation Date"	
							  };
String[] astrSortByVal     = {"lname","user_table.fname","user_status.status",
							  "RESIGNATION_DATE"
							  };
Vector vRetResult = null;

if (WI.fillTextValue("show_list").equals("1")) {
	vRetResult = hrStat.getWorkTypes(dbOP);
	
	if (vRetResult != null){
		strErrMsg = hrStat.getErrMsg();
	}
 } 
%>
<form action="./hr_stat_work_type.jsp" method="post" name="form_" >
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" class="footerDynamic"><div align="center"><font color="#FFFFFF"><strong>:::: 
          RESEARCH / SCHOLARSHIPS/ TRAINING::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25">&nbsp;<%=WI.getStrValue(strErrMsg,"<strong><font size=\"3\" color=\"#FF0000\">","</font></strong>","")%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;WORK TYPE : 
	  <select name="work_type_index">
                <option value="">ALL </option>
                <%=dbOP.loadCombo("WORK_TYPE_INDEX","WORK_TYPE_NAME"," FROM HR_PRELOAD_WORK_TYPE where work_type_index <=5 and work_type_index <> 4 ",WI.fillTextValue("work_type_index"),false)%> </select>
				<a href="javascript:showList()"><img src="../../../images/form_proceed.gif" border="0"></a>
       </td>
    </tr>
  </table>
  <% if (vRetResult != null && vRetResult.size() > 0) {%>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="49%" height="25">  <input type="hidden" name="show_all" value="1"></td>
      <td width="51%" height="25" align="right">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="2" bgcolor="#B9B292">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td width="16%" height="25"  class="thinborder"><div align="center"><font size="1"><strong>EMPLOYEE 
      NAME</strong></font></div></td>
      <td width="8%"  class="thinborder"><div align="center"><font size="1"><strong>UNIT</strong></font></div></td>
      <td width="8%" align="center" class="thinborder"><font size="1"><strong>TITLE</strong></font></td>
      <td width="8%" align="center" class="thinborder"><strong><font size="1">DATE DURATION </font></strong></td>
      <td width="8%" align="center" class="thinborder"><strong><font size="1">VENUE</font></strong></td>
      <td width="8%" class="thinborder"><font size="1"><strong>GRANTING AGENCY </strong></font></td>
    </tr>
<% 
	String strWorkType = "";
    String strCollege  = null ;
	boolean bolNewWorkType = false;
	String strName = "";
	for (int i = 0; i < vRetResult.size(); i+=8) { 
	bolNewWorkType = false;
	if (i== 0 || !strWorkType.equals((String)vRetResult.elementAt(i)))  { 
		strWorkType = (String)vRetResult.elementAt(i); 
		bolNewWorkType = true;
 %> 
    <tr>
      <td height="25" colspan="6" bgcolor="#FDF2EE"  class="thinborder"><strong>WORK TYPE : <%=strWorkType%> </strong></td>
    </tr>
<%} if (bolNewWorkType || !strCollege.equals((String)vRetResult.elementAt(i+2))) { 
		strCollege = (String)vRetResult.elementAt(i+2); 
%> 
    <tr>
      <td height="25" colspan="6"  class="thinborder"> <strong><%if(bolIsSchool){%>COLLEGE<%}else{%>DIVISION<%}%>  : <%=strCollege%> </strong></td>
    </tr>
<%}%> 
    <tr> 
   <% 
   		if (strName.equals((String)vRetResult.elementAt(i+1))) 
			strTemp = "&nbsp";
		else{
			strName = (String)vRetResult.elementAt(i+1); 
			strTemp = strName; 
		}
   %> 
	  <td height="25" class="thinborder">&nbsp;<%=strTemp%></td>
      <td class="thinborder"> <%=strCollege%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+3),"&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+4)) + 
	   WI.getStrValue((String)vRetResult.elementAt(i+5)," - ","","")%> &nbsp;</td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+6),"&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+7),"&nbsp;")%></td>
    </tr>
    <%}// end for loop%>
  </table>
<%}%>
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
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>