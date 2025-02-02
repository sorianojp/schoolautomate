<%@ page language="java" import="utility.*,java.util.Vector,hr.HRGeneric" %>
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
function ReloadPage(){
	document.form_.page_action.value = '';
	document.form_.submit();
}
function SelAll(ref) {
	var iMaxDisp = 0;
	var bolIsChecked = false;
	if(ref == '1') {
		bolIsChecked = document.form_.sel_1.checked;
		iMaxDisp = document.form_.max_disp_ins.value;
	}
	else {
		bolIsChecked = document.form_.sel_2.checked;
		iMaxDisp = document.form_.max_disp_del.value;
	}

	var objChkBox;
	for(var i = 0 ; i < iMaxDisp; ++i) {
		if(ref == '1')
			eval('objChkBox = document.form_.ins_'+i);
		else
			eval('objChkBox = document.form_.del_'+i);
	
		if(!objChkBox)
			continue;
		objChkBox.checked = bolIsChecked;
	}
}
</script>

<body bgcolor="#663300" class="bgDynamic">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-HR Management-Personnel-Manage Hiring Batch","assign_hiring_batch.jsp");

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
														"HR Management","PERSONNEL",request.getRemoteAddr(),
														"assign_hiring_batch.jsp");
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


HRGeneric hrGen   = new HRGeneric();
Vector vRetResult = null; Vector vEmpWithoutBatch = null;

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(hrGen.operateOnHRHiringBatch(dbOP, request, Integer.parseInt(strTemp)) != null) {
		strErrMsg = "Operation successful.";
	}
	else	
		strErrMsg = hrGen.getErrMsg();
}
vRetResult = hrGen.operateOnHRHiringBatch(dbOP, request, 4);
if(vRetResult == null && strErrMsg == null)
	strErrMsg = hrGen.getErrMsg();
else 
	vEmpWithoutBatch = (Vector)vRetResult.remove(0);

%>
<form action="./assign_hiring_batch.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A" class="footerDynamic">
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF"><strong>::::ASSIGN HIRING BATCH ::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25">&nbsp;<%=WI.getStrValue(strErrMsg,"<strong><font size=\"3\" color=\"#FF0000\">","</font></strong>","")%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    
    <tr>
      <td height="25" class="fontsize10">&nbsp;Hiring Batch</td>
      <td>
	  	<select name="batch_ref">
	    	<%=dbOP.loadCombo("HIRING_BATCH_INDEX", "BATCH_NAME"," from HR_HIRING_BATCH where IS_VALID = 1 order by BATCH_NAME",WI.fillTextValue("batch_ref"), false)%> 
		</select>

	  </td>
    </tr>
    <tr> 
      <td width="14%" height="25" class="fontsize10"> &nbsp;Employee ID </td>
      <td width="86%" style="font-size:9px;"><input name="id_" value="<%=WI.fillTextValue("id_")%>" type="text"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16" > (Starts with)       </td>
    </tr>
    <tr> 
      <td height="25" class="fontsize10"> &nbsp;Last Name</td>
      <td style="font-size:9px;"><input name="lname" value="<%=WI.fillTextValue("lname")%>" type="text"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16" > (Starts with)</td>
    </tr>
    <tr>
      <td height="25" class="fontsize10">&nbsp;First Name </td>
      <td style="font-size:9px;"><input name="fname" value="<%=WI.fillTextValue("fname")%>" type="text"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16" > (Starts with)</td>
    </tr>
    <tr> 
      <td height="25" class="fontsize10">&nbsp;<%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td><select name="college" onChange="ReloadPage()">
          <option value=""> &nbsp;</option>
          <%=dbOP.loadCombo("c_index", "c_name"," from college where is_del =0 order by c_name",WI.fillTextValue("college"), false)%> </select></td>
    </tr>
    <tr> 
      <td height="25" class="fontsize10">&nbsp;Dept / Office </td>
      <td><select name="dept">
          <option value=""> &nbsp;</option>
          <%
			if (WI.fillTextValue("college").length() > 0) 
				strTemp = "  c_index = " + WI.fillTextValue("college");
			else 
				strTemp = "  (c_index is null or c_index  = 0)";

		%>
          <%=dbOP.loadCombo("d_index", "d_name"," from department where "+ strTemp  +" and is_del = 0 order by d_name",WI.fillTextValue("dept"), false)%> </select></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="18" colspan="5">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="8%">&nbsp;</td>
      <td width="20%">&nbsp;</td>
      <td width="22%"><input type="image" src="../../../images/form_proceed.gif" width="81" height="21" border="0" onClick="document.form_.show_list.value='1'"></td>
      <td width="47%">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%
int iCount = 0;
if(vEmpWithoutBatch != null && vEmpWithoutBatch.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr align="center" style="font-weight:bold">
      <td height="25" colspan="4" class="thinborder" bgcolor="#FFFFCC">::: LIST OF EMPLOYEE WITHOUT ASSIGNED BATCH :::</td>
    </tr>
    <tr align="center" style="font-weight:bold"> 
      <td height="25" width="7%" class="thinborder">Count</td>
      <td width="28%" class="thinborder">Employee ID</td>
      <td width="60%" class="thinborder">Employee Name</td>
      <td width="5%" class="thinborder">Sel All <input type="checkbox" name="sel_1" onClick="SelAll(1);"></td>
    </tr>
<%
for(int i = 0; i < vEmpWithoutBatch.size(); i += 3){%>
    <tr>
      <td height="25" class="thinborder">&nbsp;<%=++iCount%></td>
      <td class="thinborder">&nbsp;<%=vEmpWithoutBatch.elementAt(i + 1)%></td>
      <td class="thinborder">&nbsp;<%=vEmpWithoutBatch.elementAt(i + 2)%></td>
      <td class="thinborder" align="center"><input type="checkbox" name="ins_<%=iCount-1%>" value="<%=vEmpWithoutBatch.elementAt(i)%>"></td>
    </tr>
<%}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr align="center">
      <td height="25" colspan="4" class="thinborder">
	  <%if(iAccessLevel > 1) {%>
	  <input name="Submit" type="submit" style="font-size:11px; height:25px;border: 1px solid #FF0000;" value="Assign Batch" onClick="document.form_.page_action.value='1';">&nbsp;&nbsp;&nbsp;
	  <%}else{%>Not Authorized to Assign batch<%}%>
	  </td>
    </tr>
  </table>
<input type="hidden" name="max_disp_ins" value="<%=iCount%>">
<%}%>
<%
iCount = 0;
if(vRetResult != null && vRetResult.size() > 0) {%>
<table bgcolor="#FFFFFF" width="100%">
	<tr><td>&nbsp;</td></tr>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr align="center" style="font-weight:bold">
      <td height="25" colspan="7" class="thinborder" bgcolor="#FFFFCC">::: LIST OF EMPLOYEE HAVING BATCH :::</td>
    </tr>
    <tr align="center" style="font-weight:bold"> 
      <td height="25" width="5%" class="thinborder">Count</td>
      <td width="15%" class="thinborder">Employee ID</td>
      <td width="20%" class="thinborder">Employee Name </td>
      <td width="15%" class="thinborder">Batch Name </td>
      <td width="15%" class="thinborder">Hiring Date </td>
      <td width="15%" class="thinborder">Salary</td>
      <td width="5%" class="thinborder">Sel All<br> 
      <input type="checkbox" name="sel_2" onClick="SelAll(2);"></td>
    </tr>
<%
for(int i = 0; i < vRetResult.size(); i += 6){%>
    <tr>
      <td height="25" class="thinborder">&nbsp;<%=++iCount%></td>
      <td class="thinborder">&nbsp;<%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder">&nbsp;<%=vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder">&nbsp;<%=vRetResult.elementAt(i + 3)%></td>
      <td class="thinborder">&nbsp;<%=vRetResult.elementAt(i + 4)%></td>
      <td class="thinborder">&nbsp;<%=vRetResult.elementAt(i + 5)%></td>
      <td class="thinborder" align="center"><input type="checkbox" name="del_<%=iCount-1%>" value="<%=vRetResult.elementAt(i)%>"></td>
    </tr>
<%}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr align="center">
      <td height="25" colspan="4" class="thinborder" bgcolor="#FFFFCC">
	  <%if(iAccessLevel == 2) {%>
	  <input name="Submit" type="submit" style="font-size:11px; height:25px;border: 1px solid #FF0000;" value="Remove Batch" onClick="document.form_.page_action.value='0';">&nbsp;&nbsp;&nbsp;
	  <%}else{%>Not Authorized to remove batch<%}%>
	  </td>
    </tr>
  </table>
<input type="hidden" name="max_disp_del" value="<%=iCount%>">
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="footer">
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="show_list" value="<%=WI.fillTextValue("show_list")%>">
  <input type="hidden" name="page_action">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>