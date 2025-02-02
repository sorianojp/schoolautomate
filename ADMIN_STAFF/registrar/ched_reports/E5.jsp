<%@ page language="java" import="utility.*,java.util.Vector,chedReport.E5New"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	if(WI.fillTextValue("print_pg").length() > 0) {%>
		<jsp:forward page="./E5_print.jsp"></jsp:forward>
	<%}


	String strErrMsg = null;
	String strTemp = null;

//authenticate this user.
	int iAccessLevel = 0;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT"),"0"));
		}
	}

	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
//end of authenticaion code.

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
							"Admin/staff-CHED REPORTS-CHED COURSE MAPPING","E5.jsp");
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
	
Vector vRetResult = null; Vector vListToEncode = null; boolean bolCleanUP = false;
E5New e5New = new E5New();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(e5New.operateOnE5Info(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = e5New.getErrMsg();
	else {	
		strErrMsg = e5New.getErrMsg();
		bolCleanUP = true;
	}
}

vRetResult = e5New.operateOnE5Info(dbOP, request, 5);  //show already encoded.. 
if(strErrMsg == null && vRetResult == null)
	strErrMsg = e5New.getErrMsg();
	
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>CHED E-FORM B/C</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
.body_font{
	font-size:11px;
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function UpdateCheckBox(objInputBox, objCheckBox) {
	if(objInputBox.value.length > 0) 
		objCheckBox.checked = true;
	else
		objCheckBox.checked = false;
}
</script>
<body>
<form name="form_" action="./E5.jsp" method="post" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="2"><div align="center"><font color="#FFFFFF" size="2" face="Arial, Helvetica, sans-serif"><strong>::: E5 Setup::: </strong> </font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="2" style="font-weight:bold; font-size:14px; color:#FF0000">&nbsp; <%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" width="2%">&nbsp;</td>
      <td width="13%">SY/ Term </td>
      <td>
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
if(strTemp == null)
	strTemp = "";
%>
		  <input name="sy_from" type="text" size="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','sy_from');style.backgroundColor='white'"
	  onKeyUp='AllowOnlyInteger("form_","sy_from");'>

		- 
	<select name="semester" onChange="ReloadPage();">
          <option value="1">1st Sem</option>
<%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp == null)
	strTemp = "";
if(strTemp.compareTo("2") ==0)
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
          <option value="2" <%=strErrMsg%>>2nd Sem</option>
<%if(strTemp.compareTo("3") ==0)
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
          <option value="3" <%=strErrMsg%>>3rd Sem</option>
<%if(strTemp.compareTo("0") ==0)
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
          <option value="0" <%=strErrMsg%>>Summer</option>
      </select>	  
	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Employee ID </td>
      <td style="font-size:9px"><input name="emp_id" type="text" size="32" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','sy_from');style.backgroundColor='white'">
	  (Optional if not shown in list) </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>
        <input type="submit" name="Save2" value="Show Information" onClick="document.form_.page_action.value=''">
      </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder" bgcolor="#DDDDDD">
    <tr>
      <td height="25" colspan="10" align="center" style="font-weight:bold" class="thinborder">List of Employee with Teaching Load </td>
    </tr>
<%
vListToEncode = e5New.operateOnE5Info(dbOP, request, 4);
if(vListToEncode == null){%>
	<tr>
      <td height="25" colspan="10" style="font-size:13px; font-weight:bold; color:#FF0000" class="thinborder">&nbsp;Error in getting the list for encoding. Description :: <%=e5New.getErrMsg()%></td>
    </tr>
<%}else{%>
	
	<tr bgcolor="#CFE9F7">
	  <td height="25" style="font-weight:bold" class="thinborder" width="20%">Bachelor</td>
	  <td style="font-weight:bold" class="thinborder" width="20%">Masters</td>
	  <td style="font-weight:bold" class="thinborder" width="5%">Master Unit </td>
	  <td style="font-weight:bold" class="thinborder" width="20%">Doctor</td>
	  <td style="font-weight:bold" class="thinborder" width="5%">Doctor Unit </td>
	  <td style="font-weight:bold" class="thinborder" width="10%">Professional Licensure </td>
	  <td style="font-weight:bold" class="thinborder" width="5%">Tenure of Employement </td>
	  <td style="font-weight:bold" class="thinborder" width="5%">Faculty Rank </td>
	  <td style="font-weight:bold" class="thinborder" width="5%">Annual Salary </td>
	  <td height="25" style="font-weight:bold" class="thinborder" width="5%">Select</td>
	</tr>
<%
int j = 0;
	for(int i = 0; i < vListToEncode.size(); i += 5,++j) {%>
	<tr bgcolor="#FFFFDD">
	  <td height="25" colspan="10" style="font-weight:bold" class="thinborder"><%=j + 1%>. 
	  Faculty : <%=vListToEncode.elementAt(i + 2)%> (<%=vListToEncode.elementAt(i + 1)%>) &nbsp;&nbsp; 
	  Teaching Load :  <%=WI.getStrValue(vListToEncode.elementAt(i + 3), "None")%>
	  Subjects Tought : <%=WI.getStrValue(vListToEncode.elementAt(i + 4), "None")%>	  </td>
	</tr>
	<tr>
	  <td height="25" class="thinborder">
<%
if(bolCleanUP)
	strTemp = "";
else	
	strTemp = WI.fillTextValue("educ_bachelor_"+j);
%>
  	  <textarea cols="40" rows="3" style="font-size:10px;" name="educ_bachelor_<%=j%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea>	  </td>
	  <td class="thinborder">
<%
if(bolCleanUP)
	strTemp = "";
else	
	strTemp = WI.fillTextValue("educ_master_"+j);
%>
  	  <textarea cols="40" rows="3" style="font-size:10px;" name="educ_master_<%=j%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea>	  </td>
	  <td class="thinborder">
<%
if(bolCleanUP)
	strTemp = "";
else	
	strTemp = WI.fillTextValue("educ_master_unit_"+j);
%>
  	  <textarea cols="15" rows="3" style="font-size:10px;" name="educ_master_unit_<%=j%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea>
	</td>
	  <td class="thinborder">
<%
if(bolCleanUP)
	strTemp = "";
else	
	strTemp = WI.fillTextValue("educ_doctor_"+j);
%>
  	  <textarea cols="40" rows="3" style="font-size:10px;" name="educ_doctor_<%=j%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea>
	  </td>
	  <td class="thinborder">
<%
if(bolCleanUP)
	strTemp = "";
else	
	strTemp = WI.fillTextValue("educ_doctor_unit_"+j);
%>
  	  <textarea cols="15" rows="3" style="font-size:10px;" name="educ_doctor_unit_<%=j%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea>
	  </td>
	  <td class="thinborder">
<%
if(bolCleanUP)
	strTemp = "";
else	
	strTemp = WI.fillTextValue("educ_prof_license_"+j);
%>
  	  <textarea cols="10" rows="2" style="font-size:10px;" name="educ_prof_license_<%=j%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea>
	  </td>
	  <td class="thinborder">
<%
if(bolCleanUP)
	strTemp = "";
else	
	strTemp = WI.fillTextValue("educ_tenure_"+j);
%>
	  <input name="educ_tenure_<%=j%>" type="text" size="4" maxlength="3" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','educ_tenure_<%=j%>');style.backgroundColor='white'"
	  onKeyUp='AllowOnlyInteger("form_","educ_tenure_<%=j%>");'>
	  </td>
	  <td class="thinborder">
<%
if(bolCleanUP)
	strTemp = "";
else	
	strTemp = WI.fillTextValue("educ_rank_"+j);
%>
	  <input name="educ_rank_<%=j%>" type="text" size="4" maxlength="3" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','educ_rank_<%=j%>');style.backgroundColor='white'"
	  onKeyUp='AllowOnlyInteger("form_","educ_rank_<%=j%>");'>
	  </td>
	  <td class="thinborder">
<%
if(bolCleanUP)
	strTemp = "";
else	
	strTemp = WI.fillTextValue("educ_annual_sal_"+j);
%>
	  <input name="educ_annual_sal_<%=j%>" type="text" size="4" maxlength="3" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','educ_annual_sal_<%=j%>');style.backgroundColor='white'"
	  onKeyUp='AllowOnlyInteger("form_","educ_annual_sal_<%=j%>");'>
	  </td>
	  <td class="thinborder">
		<input type="checkbox" name="checkbox_<%=j%>" value="<%=vListToEncode.elementAt(i)%>">
	  </td>
	</tr>
	<%}//end of for loop%>
	<tr>
	  <td height="25" colspan="10" class="thinborder" align="center"><input type="submit" name="Save" value="Save Information" onClick="document.form_.page_action.value='1'"></td>
    </tr><input type="hidden" name="max_disp" value="<%=j%>">
	
<%}//end of else.%>
  </table>
  <br><br>
 <%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" cellpadding="0" cellspacing="0">
  <tr>
  	<td align="right" style="font-size:9px;">
	Number of rows Per page : 
	  	<select name="rows_per_pg">
	  	<%
		int iDefVal = 0;
		strTemp = WI.fillTextValue("rows_per_pg");
		if(strTemp.length() == 0) 
			iDefVal = 15;
		else	
			iDefVal = Integer.parseInt(strTemp);
		for(int i =14; i < 50; ++i){
		if( i == iDefVal)
			strErrMsg = " selected";
		else	
			strErrMsg = "";
		%>
			<option value="<%=i%>"<%=strErrMsg%>><%=i%></option>
		<%}%>
	  	</select>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<input type="image" src="../../../images/print.gif" onClick="document.form_.print_pg.value='1'">Print E5 Form &nbsp;</td>
  </tr>
  </table>
  <table width="100%" cellpadding="0" cellspacing="0" class="thinborder">
  <tr>
  	<td colspan="17" class="thinborder" align="center" style="font-size:14px; font-weight:bold">::: List of Saved Employee with Teaching Load( Appears in E5 if teaching for specifed SY/Term) ::: </td>
  </tr>
		<tr bgcolor="#9DB6F4">
		  <td height="25" style="font-weight:bold" class="thinborder" width="2%">SL NO </td>
		  <td style="font-weight:bold" class="thinborder" width="10%">ID Number </td>
		  <td style="font-weight:bold" class="thinborder" width="10%">Name</td>
		  <td style="font-weight:bold" class="thinborder" width="4%">Full Time/ Part Time </td>
		  <td style="font-weight:bold" class="thinborder" width="4%">Sex</td>
		  <td style="font-weight:bold" class="thinborder" width="15%">Bachelor</td>
		  <td style="font-weight:bold" class="thinborder" width="15%">Masters</td>
		  <td style="font-weight:bold" class="thinborder" width="5%">No of Units Towards Masters Degree </td>
		  <td style="font-weight:bold" class="thinborder" width="15%">Doctoral</td>
		  <td style="font-weight:bold" class="thinborder" width="5%">No of Units Towards Doctors Degree </td>
		  <td style="font-weight:bold" class="thinborder" width="5%">Professioanl Licensure Earned </td>
		  <td style="font-weight:bold" class="thinborder" width="5%">Tenure of Employement </td>
		  <td style="font-weight:bold" class="thinborder" width="5%">Faculty Rank </td>
		  <td style="font-weight:bold" class="thinborder" width="5%">Teaching Load </td>
		  <td style="font-weight:bold" class="thinborder" width="5%">Subjects Tought </td>
		  <td style="font-weight:bold" class="thinborder" width="5%">Annual Salary </td>
		  <td height="25" style="font-weight:bold" class="thinborder" width="5%">Delete</td>
		</tr>
		<%
		String[] astrConvertPTFT   = {"PT","FT"};
		String[] astrConvertGender = {"M","F"};
		
		for(int i = 0; i < vRetResult.size(); i += 17) {%>
		<tr bgcolor="#FFFFCC">
		  <td height="25" class="thinborder"><%=i/17 + 1%>.</td>
		  <td class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
		  <td class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
		  <td class="thinborder"><%=astrConvertPTFT[Integer.parseInt((String)vRetResult.elementAt(i + 12))]%></td>
		  <td class="thinborder"><%=astrConvertGender[Integer.parseInt((String)vRetResult.elementAt(i + 13))]%></td>
		  <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 3), "&nbsp;")%></td>
		  <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 4), "&nbsp;")%></td>
		  <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 5), "&nbsp;")%></td>
		  <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 6), "&nbsp;")%></td>
		  <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 7), "&nbsp;")%></td>
		  <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 8), "&nbsp;")%></td>
		  <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 9), "&nbsp;")%></td>
		  <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 10), "&nbsp;")%></td>
		  <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 14), "&nbsp;")%></td>
		  <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 15), "&nbsp;")%></td>
		  <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 11), "&nbsp;")%></td>
		  <td height="25" class="thinborder"><input type="submit" name="_" value="Delete" onClick="document.form_.page_action.value='0';document.form_.info_index.value='<%=vRetResult.elementAt(i)%>'"></td>
		</tr>
		<%}%>
  </table> 	
  <br>
  <table width="100%" cellpadding="0" cellspacing="0">
  <tr>
  	<td width="17%">Accomplished By : </td>
	<td width="24%">
<%
strTemp = WI.fillTextValue("_accomplish");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("first_name");
%>
	<input type="text" name="_accomplish" value="<%=strTemp%>" class="textbox"></td>
    <td width="18%">Certified Correct:</td>
    <td width="41%"><input type="text" name="_certified" value="<%=WI.fillTextValue("_certified")%>" class="textbox"></td>
  </tr>
  <tr>
    <td>Designation</td>
    <td><input type="text" name="accomplish_desig" value="<%=WI.fillTextValue("accomplish_desig")%>" class="textbox"></td>
    <td>Designation:</td>
    <td><input type="text" name="certified_desig" value="<%=WI.fillTextValue("certified_desig")%>" class="textbox"></td>
  </tr>
  <tr>
    <td>Date:</td>
    <td>
<%
strTemp = WI.fillTextValue("accomplish_date");
if(strTemp.length() == 0) 
	strTemp = WI.getTodaysDate(6);
%>
	<input type="text" name="accomplish_date" value="<%=strTemp%>" class="textbox"></td>
    <td>Date:</td>
    <td>
<%
strTemp = WI.fillTextValue("certified_date");
if(strTemp.length() == 0) 
	strTemp = WI.getTodaysDate(6);
%>
	<input type="text" name="certified_date" value="<%=strTemp%>" class="textbox"></td>
  </tr>
  </table>



 <%}%>
<input type="hidden" name="info_index">
<input type="hidden" name="page_action">
<input type="hidden" name="print_pg">
</form>

</body>
</html>
<%
	dbOP.cleanUP();
%>
