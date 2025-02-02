<%@ page language="java" import="utility.*,java.util.Vector,hr.HRMandatoryTrng"%>
<%
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.

boolean bolIsSchool = false;

if ((new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
	
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle_small.css" rel="stylesheet" type="text/css">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
TD{
	font-size:11px;
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PageAction(strInfoIndex,strAction) {
	document.form_.page_action.value = strAction;
	if(strAction == "1") {
		document.form_.hide_save.src = "../../../images/blank.gif";
		if (document.form_.jump_to.selectedIndex == document.form_.jump_to.length-1)
			document.form_.jump_to.selectedIndex--;	
	}
	document.form_.submit();
}

function UpdateSelection(){
	var iMaxDisplay = document.form_.max_display.value;
	if (document.form_.select_all.checked) {
		for( var i =0 ; i < iMaxDisplay ; i++){
			if (eval('document.form_.ban_index'+i+'.checked == false'))
				eval('document.form_.benefit_index'+i+'.checked = true');
		}
	}
	else{
		for( var i =0 ; i < iMaxDisplay ; i++)
			eval('document.form_.benefit_index'+i+'.checked = false');
	}
}

function UpdateBanSelection(){
	var iMaxDisplay = document.form_.max_display.value;
	if (document.form_.ban_all.checked) {
		for( var i =0 ; i < iMaxDisplay ; i++){
			if (eval('document.form_.benefit_index'+i+'.checked == false'))
				eval('document.form_.ban_index'+i+'.checked = true');
		}
	}else{
		for( var i =0 ; i < iMaxDisplay ; i++){
			eval('document.form_.ban_index'+i+'.checked = false');
		}
	}
}

function updateCheck(strCounter,strInfoIndex){
	if (strInfoIndex == 1){
		if (eval('document.form_.benefit_index'+strCounter+'.checked'))
			eval('document.form_.ban_index'+strCounter+'.checked=false');
	}else{
		if (eval('document.form_.ban_index'+strCounter+'.checked'))
			eval('document.form_.benefit_index'+strCounter+'.checked=false');
	}
}

function ReloadPage(){
	document.form_.reload_page.value = "1";
	document.form_.submit();
}
function showList() {
	document.form_.showlist.value = '1';
	ReloadPage();
}
function SelALL() {
	var isSel = document.form_.sel_all.checked;
	var iMaxDisp = document.form_.max_disp.value;
	for(i = 0; i < iMaxDisp; ++i)
		eval('document.form_.mt_'+i+'.checked=isSel');
}
function ViewTraining(strEmpID) {
	var win=window.open("./view_training_one_employee.jsp?emp_id="+strEmpID,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	int iCtr = 0;

	
//add security hehol.
	try
	{
		dbOP = new DBOperation();
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
/**
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
**/

Vector vRetResult = null;
HRMandatoryTrng hm = new HRMandatoryTrng();

if(WI.fillTextValue("showlist").length() > 0) {
	vRetResult = hm.searchTraining(dbOP, request);
	if(vRetResult == null)
		strErrMsg = hm.getErrMsg();
}

boolean bolHasTeam = new ReadPropertyFile().getImageFileExtn("HAS_TEAMS","0").equals("1");
%>

<body bgcolor="#663300" class="bgDynamic">
<form action="./search.jsp" method="post" name="form_">
  <table width="100%" border="0"cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr bgcolor="#999966" class="footerDynamic"> 
      <td height="25" colspan="3"><div align="center"><font color="#FFFFFF" ><strong>:::: SEARCH TRAINING MANAGEMENT ::::</strong></font></div></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="98%"><font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
  </table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFF0F0">
    <tr> 
      <td height="25" colspan="2" class="fontsize10"><div align="center"><u><strong><font color="#FF0000">Employee Listing Filter </font></strong></u></div></td>
    </tr>
    <tr>
      <td width="16%" height="25" class="fontsize10">&nbsp;Employee ID </td>
      <td width="84%"><input type="text" name="id_num" value="<%=WI.fillTextValue("id_num")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16" style="font-size:11px;"> 
      (ID starts with) </td>
    </tr>
    <tr>
      <td height="25" class="fontsize10">&nbsp;Last Name  </td>
      <td><input type="text" name="lname" value="<%=WI.fillTextValue("lname")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16" style="font-size:11px;">
(last name starts with)</td>
    </tr>
    <tr>
      <td height="25" class="fontsize10">&nbsp;First Name </td>
      <td><input type="text" name="fname" value="<%=WI.fillTextValue("fname")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16" style="font-size:11px;">
(first name starts with)</td>
    </tr>
<!--    <tr> 
      <td height="25" class="fontsize10" width="16%"> &nbsp;Position</td>
      <td><select name="emp_type_index">
          <option value=""> &nbsp;</option>
          <%=dbOP.loadCombo("emp_type_index", "emp_type_name"," from hr_employment_type where is_del =0 order by emp_type_name",WI.fillTextValue("emp_type_index"), false)%> </select></td>
    </tr>
-->    <tr> 
      <td height="25" class="fontsize10">&nbsp;<%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td>
	  <select name="c_index" onChange="ReloadPage()">
          <option value=""> &nbsp;</option>
      <%=dbOP.loadCombo("c_index", "c_name"," from college where is_del =0 order by c_name",WI.fillTextValue("c_index"), false)%> </select>
		  </td>
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
<%if(bolHasTeam){%>
    <tr>
      <td height="25" class="fontsize10">&nbsp;Team</td>
      <td>
	  <select name="team">
          <option value=""> &nbsp;</option>
      <%=dbOP.loadCombo("team_index", "team_name"," from AC_TUN_TEAM where is_valid =1 order by team_name",WI.fillTextValue("team"), false)%> </select>
	  </td>
    </tr>
    <tr>
      <td height="25" colspan="2" class="fontsize10">&nbsp;
<%
strTemp = WI.fillTextValue("is_completed");
if(strTemp.equals("1") || strTemp.length() == 0) {
	strTemp = " checked";
	strErrMsg = "";
}
else {
	strTemp = "";
	strErrMsg = " checked";
}
%>
	  <input type="radio" name="is_completed" value="1" <%=strTemp%>> List Employees Completed the following Trainings 
	  <input type="radio" name="is_completed" value="0" <%=strErrMsg%>> List Employees did not complete the following trainings </td>
      </tr>
<%}%>    
    <tr>
      <td height="25" class="fontsize10" valign="top"><br>&nbsp;List of Mandatory Training <br>
	  <input type="checkbox" name="sel_all" onClick="SelALL();">Select ALL</td>
      <td><div style="height: 100px; width:550px; overflow: auto; border: inset black 1px;">
<%
String strSQLQuery    = "select MAND_TRAINING_INDEX,MAND_TRAINING_NAME from HR_MAND_TRAINING_NAME where is_valid = 1 order by  MAND_TRAINING_NAME";
java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
int iCount = 0;
while(rs.next()){
strTemp = WI.fillTextValue("mt_"+iCount);
if(strTemp.length() > 0) 
	strTemp = " checked";
%>
		<input type="checkbox" name="mt_<%=iCount%>" value="<%=rs.getString(1)%>" <%=strTemp%>> <%=rs.getString(2)%> <br>		

<%++iCount;}%> 
<input type="hidden" name="max_disp" value="<%=iCount%>">
</div>
	  </td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td>
	  <%if(iCount == 0) {%>
	  	<br><font style="font-size:14px; color:#FF0000; font-weight:bold">No Mandatory Training is set. Please encode Training list.</font>
	  <%}else{%>
		  <a href="javascript:showList()"%><br><img src="../../../images/form_proceed.gif" width="81" height="21" border="0"></a>
	  <%}%>
	  </td>
    </tr>
  </table>	
<% if (vRetResult != null && vRetResult.size() > 0) { %>
  <table width="100%" border="0" cellpadding="1" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#DBEEE0"> 
      <td height="25" colspan="6" align="center" class="thinborder"><strong>SEARCH RESULT</strong></td>
    </tr>
    <tr style="font-weight:bold"> 
      <td width="5%" height="25" class="thinborder">Count</td>
      <td width="15%" height="25" class="thinborder">ID Number</td>
      <td width="25%" class="thinborder">Name of Employee</td>
      <td width="15%" class="thinborder"><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td width="15%" class="thinborder">Department/Office</td>
      <td width="5%" class="thinborder">View</td>
    </tr>
    <%for(int i = 0; i < vRetResult.size(); i += 6) {%>
	<tr> 
	  <td height="25" class="thinborder">&nbsp;<%=i/6 + 1%>.</td>
		  <td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
		  <td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
		  <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+3),"&nbsp;")%></td>
		  <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+4),"&nbsp;")%></td>
		  <td class="thinborder"><a href="javascript:ViewTraining('<%=vRetResult.elementAt(i+1)%>');"><img src="../../../images/view.gif" border="0"></a></td>
	</tr>
    <%}%>
  </table>
<% } //vRetResult != null && vRetResult.size() > 0%>
  
    <table width="100%" border="0"cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
    <tr bgcolor="#999966" class="footerDynamic"> 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="max_display"  value="<%=iCtr%>">
<input type="hidden" name="reload_page">
<input type="hidden" name="showlist">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
