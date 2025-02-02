<%@ page language="java" import="utility.*,java.util.Vector,hr.HRCareerFeedback"%>
<%
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript">
function viewList(table,indexname,colname,labelname){
	var loadPg = "../hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+labelname;
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ViewRecord()
{
	var loadPg = "../hr_career_seminars_detail.jsp";
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function AddRecord(){
	document.staff_profile.page_action.value="1";
	document.staff_profile.hide_save.src = "../../../images/blank.gif";
	document.staff_profile.submit();
}
function EditRecord()
{
	document.staff_profile.page_action.value="2";
}
function DeleteRecord()
{
	document.staff_profile.page_action.value="3";
}
function ReloadPage()
{
	document.staff_profile.reloadPage.value = "1";
	document.staff_profile.submit();
}
function CancelEdit()
{
location = "./hr_career_seminars.jsp";
}

function PrepareToEdit(index){
	document.staff_profile.prepareToEdit.value = "1";
	document.staff_profile.info_index.value = index;
}

</script>
<body bgcolor="#663300" class="bgDynamic">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-CAREER DEVELOPMENT-Seminar/Trainings","hr_career_seminars.jsp");

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
														"HR Management","CAREER DEVELOPMENT",request.getRemoteAddr(),
														"hr_career_seminars.jsp");
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

Vector vEmpRec = null;
Vector vRetResult = null;
String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
String strInfoIndex = WI.fillTextValue("info_index");
HRCareerFeedback cft = new HRCareerFeedback();
vRetResult =  cft.operateOnCFTraining(dbOP,request,3);

if (vRetResult == null) {
	strErrMsg = cft.getErrMsg();
}
%>
<form action="" method="post" name="staff_profile">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A" class="footerDynamic">
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          TRAININGS/SEMINARS ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr> 
      <td width="105%"><img src="../../../images/sidebar.gif" width="11" height="270" align="right"> 
	  <%=WI.getStrValue(strErrMsg,"")%>
	  <% if ( vRetResult !=null && vRetResult.size() > 0){%>
        <table width="92%" border="0" align="center" cellpadding="4" cellspacing="0">
          <tr> 
            <td width="55">&nbsp;</td>
            <td width="246">Name of Seminar/Training</td>
            <td width="555"><%=(String)vRetResult.elementAt(2)%></td>
          </tr>
          <tr> 
            <td width="55">&nbsp;</td>
            <td>Venue</td>
            <td><%=(String)vRetResult.elementAt(3)%></td>
          </tr>
          <tr> 
            <td width="55">&nbsp;</td>
            <td>Conducted by</td>
            <td><%=(String)vRetResult.elementAt(4)%></td>
          </tr>
          <tr> 
            <td width="55">&nbsp;</td>
            <td>Inclusive Dates</td>
            <td>From : <%=(String)vRetResult.elementAt(5)%><%=WI.getStrValue((String)vRetResult.elementAt(6),"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;To: ","","&nbsp;")%></td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>Length in Days/Hours</td>
            <td><%=(String)vRetResult.elementAt(7)%> Days <%=(String)vRetResult.elementAt(8)%> Hours </td>
          </tr>
          <tr> 
            <td width="55">&nbsp;</td>
            <td>Open To</td>
            <td><%=(String)vRetResult.elementAt(9)%></td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>No of attendant(s) per <%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
            <td><%=(String)vRetResult.elementAt(10)%></td>
          </tr>
          <% if ((String)vRetResult.elementAt(11) !=null) 
		  	strTemp ="YES";
			else 
			strTemp = "NO";
		%>
          <tr> 
            <td width="55">&nbsp;</td>
            <td>Mandatory Training</td>
            <td><%=strTemp%></td>
          </tr>
          <% if ((String)vRetResult.elementAt(12) !=null) 
		  	strTemp ="YES";
			else 
			strTemp = "NO";
		%>
          <tr> 
            <td>&nbsp;</td>
            <td>Only for New Employees</td>
            <td><%=strTemp%></td>
          </tr>
        </table> 
		<%}%>

        <br>
        <hr size="1"></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
      </tr>
  </table>
<input type="hidden" name="info_index">
<input type="hidden" name="page_action">
</form>
</body>
</html>

